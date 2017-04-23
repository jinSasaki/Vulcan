//
//  Vulcan.swift
//  Vulcan
//
//  Created by Jin Sasaki on 2017/04/23.
//  Copyright © 2017年 Sasakky. All rights reserved.
//

import UIKit

final public class Vulcan {
    public static var defaultImageDownloader: ImageDownloader = ImageDownloader.default
    public private(set) var priority: Int = Int.min
    public var imageDownloader: ImageDownloader {
        get {
            return _imageDownloader ?? Vulcan.defaultImageDownloader
        }
        set {
            _imageDownloader = newValue
        }
    }
    public static var cacheMemoryCapacity: Int? {
        get {
            return defaultImageDownloader.cache?.memoryCapacity
        }
        set {
            guard let newValue = newValue else { return }
            defaultImageDownloader.cache?.memoryCapacity = newValue
        }
    }
    public static var diskCapacity: Int? {
        get {
            return defaultImageDownloader.cache?.diskCapacity
        }
        set {
            guard let newValue = newValue else { return }
            defaultImageDownloader.cache?.diskCapacity = newValue
        }
    }
    public static var diskPath: String? {
        get {
            return defaultImageDownloader.cache?.diskPath
        }
        set {
            guard let newValue = newValue else { return }
            defaultImageDownloader.cache?.diskPath = newValue
        }
    }
    internal weak var imageView: UIImageView?
    private var _imageDownloader: ImageDownloader?
    private var downloadTaskId: String?
    private var dummyView: UIImageView?

    public static func setDefault(imageDownloader: ImageDownloader) {
        self.defaultImageDownloader = imageDownloader
    }

    public func setImage(url: URL, placeholderImage: UIImage? = nil, composer: ImageComposable? = nil, options: ImageDecodeOptions? = nil, completion: ImageDownloadHandler? = nil) {
        let downloader = imageDownloader
        cancelLoading()

        imageView?.image = placeholderImage
        let id = downloader.download(url: url, composer: composer, options: options) { (url, result) in
            switch result {
            case .success(let image):
                DispatchQueue.main.async {
                    self.showImage(image: image)
                }
            default:
                break
            }
            completion?(url, result)
        }
        self.downloadTaskId = id
    }

    public enum PriorityURL {
        case url(URL, priority: Int)
        case request(URLRequest, priority: Int)

        public var priority: Int {
            switch self {
            case .url(_, let priority):
                return priority
            case .request(_, let priority):
                return priority
            }
        }

        public var url: URL {
            switch self {
            case .url(let url, _):
                return url
            case .request(let request, _):
                return request.url!
            }
        }
    }

    /// Download images with priority
    public func setImage(urls: [PriorityURL], placeholderImage: UIImage? = nil, composer: ImageComposable? = nil, options: ImageDecodeOptions? = nil) {
        let downloader = imageDownloader
        cancelLoading()

        imageView?.image = placeholderImage
        let ids = urls.sorted(by: { $0.priority < $1.priority })
            .map({ (priorityURL) -> String in
                return downloader.download(url: priorityURL.url, composer: composer, options: options) { (url, result) in
                    switch result {
                    case .success(let image):
                        DispatchQueue.main.async {
                            if self.priority <= priorityURL.priority {
                                self.priority = priorityURL.priority
                                self.showImage(image: image)
                            }
                        }
                    default:
                        break
                    }
                }
            })
        self.downloadTaskId = ids.joined(separator: ",")
    }

    public func cancelLoading() {
        let downloader = imageDownloader
        guard let splited = downloadTaskId?.components(separatedBy: ",") else {
            return
        }
        splited.forEach({ downloader.cancel(id: $0) })
        self.priority = Int.min
    }

    private func showImage(image newImage: UIImage) {
        guard let baseImageView = self.imageView else { return }
        let imageView = dummyView ?? UIImageView()
        imageView.frame = baseImageView.bounds
        imageView.alpha = 1
        imageView.image = baseImageView.image
        imageView.contentMode = baseImageView.contentMode
        baseImageView.addSubview(imageView)
        baseImageView.image = newImage
        dummyView = imageView

        UIView.animate(withDuration: 0.3, animations: {
            self.dummyView?.alpha = 0
        }) { (finished) in
            self.dummyView?.removeFromSuperview()
            self.dummyView = nil
        }
    }
}
