//
//  ImageComposable.swift
//  Vulcan
//
//  Created by Jin Sasaki on 2016/10/30.
//  Copyright © 2016年 Sasakky. All rights reserved.
//

import Foundation

public protocol ImageComposable {
    func compose(image: Image) throws -> Image
}
