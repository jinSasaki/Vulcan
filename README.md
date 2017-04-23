Vulcan
=====
[![Build Status](https://travis-ci.org/jinSasaki/Vucan.svg?branch=master)](https://travis-ci.org/jinSasaki/Vulcan)
[![Carthage compatible](https://img.shields.io/badge/Carthage-compatible-4BC51D.svg?style=flat)](https://github.com/Carthage/Carthage)
[![Version](https://img.shields.io/cocoapods/v/Vulcan.svg?style=flat)](http://cocoadocs.org/docsets/Vulcan)
[![Platform](https://img.shields.io/cocoapods/p/Vulcan.svg?style=flat)](http://cocoadocs.org/docsets/Vulcan)


Multi image downloader with priority in Swift

## Features
- Very light
- Multi image download with priority
- Caching images
- Pure Swift
- Composable image
- Support WebP

Single download | Multi download with priority
--- | ---
![demo_01](https://github.com/jinSasaki/Vulcan/raw/master/assets/demo_01.gif) | ![demo_02](https://github.com/jinSasaki/Vulcan/raw/master/assets/demo_02.gif)

## Installation

### CocoaPods
Setup CocoaPods:

```
$ gem install cocoapods
```

> CocoaPods 1.1.0+ is required to build Vulcan

`Podfile`
```
platform :ios, '8.0'
use_frameworks!

target '<Your Target Name>' do
pod 'Vulcan'
end

```

Then, run the following command:

```
$ pod install
```


### Carthage
Setup carthage:

```
$ brew update
$ brew install carthage
```

`Cartfile`
```
github "jinSasaki/Vulcan"
```


## Usage

### Image downloading and show

```swift
import Vulcan

// Single downloading
imageView.vl.setImage(url: URL(string: "/path/to/image")!)

// Multi downloading
// This image will be overridden by the image of higher priority URL.
imageView.vl.setImage(urls: [
    .url(URL(string: "/path/to/image")!, priority: 100),
    .url(URL(string: "/path/to/image")!, priority: 1000)
    ])
```

### WebP image
If you installed via CocoaPods, add `pod 'Vulcan/WebP'`.
If you installed via Carthage, add `SwiftWebP.framework` to project.

```swift
import Vulcan
import SwiftWebP // Only installed via Carthage

extension WebPDecoder: ImageDecoder {
    public func decode(data: Data, response: HTTPURLResponse, options: ImageDecodeOptions?) throws -> Image {
        let contentTypes = response.allHeaderFields.filter({ ($0.key as? String ?? "").lowercased() == "content-type" })
        guard
            let contentType = contentTypes.first,
            let value = contentType.value as? String,
            value == "image/webp",
            let image = WebPDecoder.decode(data) else {
                return try DefaultImageDecoder().decode(data: data, response: response, options: options)
        }
        return image
    }
}

// Set decoder to shared ImageDownloader
Vulcan.defaultImageDownloader.decoder = WebPDecoder()

// Request image with URL
imageView.vl.setImage(url: URL(string: "/path/to/image")!)
```

## Requirements
- iOS 8.0+
- Xcode 8.1+
- Swift 3.0.1+
