//
//  UIImage+WebP.swift
//  SwiftWebP
//
//  Created by Jin Sasaki on 2016/11/04.
//  Copyright © 2016年 Sasakky. All rights reserved.
//

import UIKit

public extension UIImage {
    public class func image(fromWebPData webpData: Data) -> UIImage? {
        guard let image = WebPDecoder.decode(webpData) else {
            return nil
        }
        return image
    }
}
