# Vulcan
Multi image downloader with priority in Swift

## Features
- Very light
- Multi image download with priority
- Caching images
- Pure Swift
- Composable image
- Support webp
  - Now supported by Carthage only. See [SwiftWebP](https://github.com/jinSasaki/SwiftWebP).

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
imageView.vl_setImage(url: URL(string: "/path/to/image")!)

// Multi downloading
// This image will be overridden by the image of higher priority URL.
imageView.vl_setImage(urls: [
    .url(URL(string: "/path/to/image")!, priority: 100),
    .url(URL(string: "/path/to/image")!, priority: 1000)
    ])
```

### WebP image
Add `SwiftWebP.framework`.

```swift
import Vulcan
import SwiftWebP

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
UIImageView.vl_sharedImageDownloader.decoder = WebPDecoder()

// Request image with URL
imageView.vl_setImage(url: URL(string: "/path/to/image")!)
```

## Requirements
- iOS 8.0+
- Xcode 8.1+
- Swift 3.0.1+
