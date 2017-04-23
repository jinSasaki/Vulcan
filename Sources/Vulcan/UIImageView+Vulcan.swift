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
        get {
            let vulcan = objc_getAssociatedObject(self, &kVulcanKey) as? Vulcan ?? Vulcan()
            if vulcan.imageView == nil {
                vulcan.imageView = self
            }
            return vulcan
        }
        set {
            objc_setAssociatedObject(self, &kVulcanKey, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
}
