//
//  ImageCachable.swift
//  Vulcan
//
//  Created by Jin Sasaki on 2016/10/30.
//  Copyright © 2016年 Sasakky. All rights reserved.
//

import Foundation

public protocol ImageCachable {
    var memoryCapacity: Int { get set }
    var diskCapacity: Int { get set }
    var diskPath: String? { get set }
    
    func saveImage(image: Image, with id: String)
    func image(id: String) -> Image?
    func remove(id: String)
    func removeAll()
}
