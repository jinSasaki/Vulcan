//
//  UIImageView+Vulcan.swift
//  Vulcan
//
//  Created by Jin Sasaki on 2017/04/23
//  Copyright © 2017年 Sasakky. All rights reserved.
//

import UIKit

private var kVulcanKey: UInt = 0

public extension UIImageView {

    public var vl: Vulcan {
        if let vulcan = objc_getAssociatedObject(self, &kVulcanKey) as? Vulcan {
            return vulcan
        }
        let vulcan = Vulcan()
        if vulcan.imageView == nil {
            vulcan.imageView = self
        }
        objc_setAssociatedObject(self, &kVulcanKey, vulcan, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        return vulcan
    }
}
