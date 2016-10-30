//
//  ImageDownloader.swift
//  Vulcan
//
//  Created by Jin Sasaki on 2016/08/26.
//  Copyright © 2016年 Sasakky. All rights reserved.
//

import UIKit
import ImageIO

public typealias Image = UIImage

public enum ImageDownloadError: Error, CustomDebugStringConvertible {
    case downloading
    case cancelled
    case networkError(Error)
    case invalidResponse(URLResponse?)
    case failedDecode(Error)
    case failedCompose(Error)

    public var debugDescription: String {
        switch self {
        case .downloading:
            return "downloading"
        case .cancelled:
            return "cancelled"
        case .networkError(let error):
            return "Network error: \(error)"
        case .invalidResponse(let response):
            return "Invalid response: \(response)"
        case .failedDecode(let error):
            return "Failed decode: \(error)"
        case .failedCompose(let error):
            return "Failed compose: \(error)"
        }
    }
}

public struct DefaultImageDecoder: ImageDecoder {
    public func decode(data: Data, response: HTTPURLResponse, options: ImageDecodeOptions?) throws -> Image {
        guard let source = CGImageSourceCreateWithData(data as CFData, nil) else {
            throw ImageDecodeError.failedCreateSource
        }

        if let options = options , options.outputSize.width > 0 {
            // Resize to small image
            let maxPixcel = max(options.outputSize.width, options.outputSize.height)
            let options = [kCGImageSourceThumbnailMaxPixelSize as AnyHashable: maxPixcel,
                           kCGImageSourceCreateThumbnailFromImageIfAbsent as AnyHashable: true] as [AnyHashable: Any]
            guard let cgImage = CGImageSourceCreateThumbnailAtIndex(source, 0, options as CFDictionary?) else {
                throw ImageDecodeError.failedCreateThumbnail
            }
            return UIImage(cgImage: cgImage)
        }

        let options = [kCGImageSourceCreateThumbnailFromImageIfAbsent as AnyHashable: true] as [AnyHashable: Any]
        guard let cgImage = CGImageSourceCreateThumbnailAtIndex(source, 0, options as CFDictionary?) else {
            throw ImageDecodeError.failedCreateThumbnail
        }
        return UIImage(cgImage: cgImage)
    }
}

public struct DefaultImageCache: ImageCachable {
    public var memoryCapacity: Int {
        return 1 * 1024 * 1024
    }
    public var diskCapacity: Int {
        return 10 * 1024 * 1024
    }
    public var diskPath: String? {
        return nil
    }

    let cache = NSCache<NSString, Image>()

    public func saveImage(image: Image, with id: String) {
        cache.setObject(image, forKey: id as NSString)
    }
    public func image(id: String) -> Image? {
        return cache.object(forKey: id as NSString)
    }
    public func remove(id: String) {
        cache.removeObject(forKey: id as NSString)
    }
    public func removeAll() {
        cache.removeAllObjects()
    }
}

public typealias ImageDownloadHandler = (_ url: URL, _ result: ImageResult) -> Void

public class ImageDownloader {
    static let `default` = ImageDownloader()

    var cache: ImageCachable?
    var decoder: ImageDecoder

    fileprivate var downloadingTasks: [String: URLSessionDataTask] = [:]
    fileprivate var configuration: URLSessionConfiguration
    fileprivate var session: URLSession

    init(cache: ImageCachable? = DefaultImageCache(), configuration: URLSessionConfiguration = URLSessionConfiguration.default) {
        self.cache = cache
        self.configuration = configuration

        self.session = URLSession(configuration: configuration)
        self.configuration.urlCache = URLCache(memoryCapacity: cache?.memoryCapacity ?? 0, diskCapacity: cache?.diskCapacity ?? 0, diskPath: cache?.diskPath ?? nil)

        self.decoder = DefaultImageDecoder()
    }

    func setCache(_ cache: ImageCachable?) {
        self.cache?.removeAll()

        self.cache = cache
        self.configuration.urlCache = URLCache(memoryCapacity: 0, diskCapacity: cache?.diskCapacity ?? 0, diskPath: nil)
    }

    func setConfiguration(_ configuration: URLSessionConfiguration) {
        self.resetSession()

        self.configuration = configuration
        self.session = URLSession(configuration: configuration)
    }

    func resetSession() {
        self.session.invalidateAndCancel()
        self.downloadingTasks.removeAll()
    }

    func download(url: URL, composer: ImageComposable? = nil, options: ImageDecodeOptions? = nil, handler: ImageDownloadHandler?) -> String {
        let request = URLRequest(url: url)
        return download(request: request, composer: composer, options: options, handler: handler)
    }

    func download(request: URLRequest, composer: ImageComposable? = nil, options: ImageDecodeOptions? = nil, handler: ImageDownloadHandler?) -> String {
        guard let url = request.url else { return "" }
        let id = url.absoluteString
        if let cachedImage = self.cache?.image(id: id) {
            guard let composer = composer else {
                handler?(url, .success(cachedImage))
                return id
            }
            do {
                let composedImage = try composer.compose(image: cachedImage)
                handler?(url, .success(composedImage))
            } catch let error {
                handler?(url, .failure(ImageDownloadError.failedDecode(error)))
            }
            return id
        }
        if let task = self.downloadingTasks[id] {
            switch task.state {
            case .running:
                // Suspend
                handler?(url, .failure(ImageDownloadError.downloading))
                return id
            case .suspended:
                task.resume()
                return id
            default:
                // Do nothing
                break
            }
        }
        let task = self.session.dataTask(with: url, completionHandler: { [weak self] (data, response, error) in
            guard let weakSelf = self else { return }
            let task = weakSelf.downloadingTasks[id]
            weakSelf.downloadingTasks[id] = nil
            if task == nil || task?.state == .canceling {
                handler?(url, .failure(ImageDownloadError.cancelled))
                return
            }

            if let error = error {
                handler?(url, .failure(ImageDownloadError.networkError(error)))
                return
            }

            guard let httpResponse = response as? HTTPURLResponse, let data = data else {
                handler?(url, .failure(ImageDownloadError.invalidResponse(response)))
                return
            }
            if httpResponse.statusCode != 200 {
                handler?(url, .failure(ImageDownloadError.invalidResponse(response)))
                return
            }
            let image: Image
            do {
                image = try weakSelf.decoder.decode(data: data, response: httpResponse, options: options)
            } catch let error {
                handler?(url, .failure(ImageDownloadError.failedCompose(error)))
                return
            }
            self?.cache?.saveImage(image: image, with: id)

            guard let composer = composer else {
                handler?(url, .success(image))
                return
            }
            do {
                let composedImage = try composer.compose(image: image)
                handler?(url, .success(composedImage))
            } catch let error {
                handler?(url, .failure(ImageDownloadError.failedDecode(error)))
            }
        })
        self.downloadingTasks[id] = task
        task.resume()
        return id
    }

    func cancel(id: String) {
        if let task = self.downloadingTasks[id] {
            task.cancel()
            self.downloadingTasks[id] = nil
        }
    }
}
