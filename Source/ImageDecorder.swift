//
//  ImageDecorder.swift
//  Vulcan
//
//  Created by Jin Sasaki on 2016/10/30.
//  Copyright © 2016年 Sasakky. All rights reserved.
//

import Foundation

public protocol ImageDecoder {
    func decode(data: Data, response: HTTPURLResponse, options: ImageDecodeOptions?) throws -> Image
}

public struct ImageDecodeOptions {
    var outputSize: CGSize = CGSize.zero
    var opaque: Bool = false
}

public enum ImageDecodeError: Error {
    case failedCreateSource
    case failedCreateThumbnail
}

