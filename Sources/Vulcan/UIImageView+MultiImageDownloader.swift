//
//  UIImageView+MultiImageDownloader.swift
//  Vulcan
//
//  Created by Jin Sasaki on 2016/10/02.
//  Copyright © 2016年 Sasakky. All rights reserved.
//

import UIKit

public extension UIImageView {

    private struct AssociatedObjectKey {
        static var imageDownloader = "UIImageView.vl_imageDownloader"
        static var sharedImageDownloader = "UIImageView.vl_sharedDownloader"
        static var downloadTaskId = "UIImageView.vl_downloadTaskId"
        static var priority = "UIImageView.vl_priority"
        static var dummyView = "UIImageView.vl_dummyView"
    }

    public var vl_imageDownloader: ImageDownloader? {
        get {
            return objc_getAssociatedObject(self, &AssociatedObjectKey.imageDownloader) as? ImageDownloader
        }
        set(downloader) {
            objc_setAssociatedObject(self, &AssociatedObjectKey.imageDownloader, downloader, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }

    public class var vl_sharedImageDownloader: ImageDownloader {
        get {
            if let downloader = objc_getAssociatedObject(self, &AssociatedObjectKey.sharedImageDownloader) as? ImageDownloader {
                return downloader
            } else {
                return ImageDownloader.default
            }
        }
        set {
            objc_setAssociatedObject(self, &AssociatedObjectKey.sharedImageDownloader, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }

    public var vl_downloadTaskId: String? {
        get {
            return objc_getAssociatedObject(self, &AssociatedObjectKey.downloadTaskId) as? String
        }
        set {
            objc_setAssociatedObject(self, &AssociatedObjectKey.downloadTaskId, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }

    public var vl_priority: Int {
        get {
            return objc_getAssociatedObject(self, &AssociatedObjectKey.priority) as? Int ?? Int.min
        }
        set {
            objc_setAssociatedObject(self, &AssociatedObjectKey.priority, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }

    public var vl_dummyView: UIImageView? {
        get {
            return objc_getAssociatedObject(self, &AssociatedObjectKey.dummyView) as? UIImageView
        }
        set {
            objc_setAssociatedObject(self, &AssociatedObjectKey.dummyView, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }

    public func vl_setImage(url: URL, placeholderImage: UIImage? = nil, composer: ImageComposable? = nil, options: ImageDecodeOptions? = nil, completion: ImageDownloadHandler? = nil) {
        let downloader = vl_imageDownloader ?? UIImageView.vl_sharedImageDownloader
        vl_cancelLoading()

        if let placeholderImage = placeholderImage {
            self.image = placeholderImage
        }
        let id = downloader.download(url: url, composer: composer, options: options) { (url, result) in
            switch result {
            case .success(let image):
                DispatchQueue.main.async {
                    self.vl_showImage(image: image)
                }
            default:
                break
            }
            completion?(url, result)
        }
        self.vl_downloadTaskId = id
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
    public func vl_setImage(urls: [PriorityURL], placeholderImage: UIImage? = nil, composer: ImageComposable? = nil, options: ImageDecodeOptions? = nil) {
        let downloader = vl_imageDownloader ?? UIImageView.vl_sharedImageDownloader
        vl_cancelLoading()

        if let placeholderImage = placeholderImage {
            self.image = placeholderImage
        }
        let ids = urls.sorted(by: { $0.priority < $1.priority })
            .map({ (priorityURL) -> String in
                return downloader.download(url: priorityURL.url, composer: composer, options: options) { (url, result) in
                    switch result {
                    case .success(let image):
                        DispatchQueue.main.async {
                            if self.vl_priority <= priorityURL.priority {
                                self.vl_priority = priorityURL.priority
                                self.vl_showImage(image: image)
                            }
                        }
                    default:
                        break
                    }
                }
            })
        self.vl_downloadTaskId = ids.joined(separator: ",")
    }

    internal func vl_showImage(image newImage: UIImage) {
        let imageView = vl_dummyView ?? UIImageView()
        imageView.frame = bounds
        imageView.alpha = 1
        imageView.image = image
        imageView.contentMode = contentMode
        addSubview(imageView)
        image = newImage
        vl_dummyView = imageView

        UIView.animate(withDuration: 0.3, animations: {
            self.vl_dummyView?.alpha = 0
            }) { (finished) in
                self.vl_dummyView?.removeFromSuperview()
                self.vl_dummyView = nil
        }
    }

    public func vl_cancelLoading() {
        let downloader = vl_imageDownloader ?? UIImageView.vl_sharedImageDownloader
        guard let splited = vl_downloadTaskId?.components(separatedBy: ",") else {
            return
        }
        splited.forEach({ downloader.cancel(id: $0) })
        self.vl_priority = Int.min
    }
}
