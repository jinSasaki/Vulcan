//
//  ImageDownloaderTests.swift
//  Vulcan
//
//  Created by Jin Sasaki on 2016/10/30.
//  Copyright © 2016年 Sasakky. All rights reserved.
//

import XCTest
@testable import Vulcan
import OHHTTPStubs

class ImageDownloaderTests: XCTestCase {
    
    static var downloader: ImageDownloader!

    override class func setUp() {
        super.setUp()

        let configuration = URLSessionConfiguration.ephemeral
        OHHTTPStubs.setEnabled(true, for: configuration)
        self.downloader = ImageDownloader(cache: nil, configuration: configuration)
    }
    

    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    

    func testSetCache() {
        struct Cache: ImageCachable {
            var memoryCapacity:Int { return 100 }
            var diskCapacity: Int { return 100 }
            var diskPath: String? { return "path" }
            func saveImage(image: Image, with id: String) {}
            func image(id: String) -> Image? { return nil }
            func remove(id: String) {}
            func removeAll() {}
        }
        XCTAssertNil(ImageDownloaderTests.downloader.cache)

        ImageDownloaderTests.downloader.set(cache: Cache())
        XCTAssertNotNil(ImageDownloaderTests.downloader.cache)
        let _cache = ImageDownloaderTests.downloader.cache!
        XCTAssertEqual(_cache.memoryCapacity, 100)
        XCTAssertEqual(_cache.diskCapacity, 100)
        XCTAssertEqual(_cache.diskPath, "path")
    }
}
