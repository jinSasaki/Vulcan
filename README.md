# Vulcan
Multi image downloader with priority in Swift

## Features
- Very light
- Multi image download with priority
- Caching images
- Pure Swift
- Composable image
- [TODO] Support webp by subspec

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


### Carthage **[TODO]**
**NOTE: Not supported yet**  

Setup carthage:

```
$ brew update
$ brew install carthage
```

`Cartfile`
```
github "Alamofire/Alamofire"
```


## Usage

```swift
import Vulcan

// Single downloading
imageView.vl_setImage(url: URL(string: "/path/to/image")!)

// Multi downloading
// This image will be overridden by the image of higher priority URL.
imageView.vl_setImage(urls: [
    UIImageView.PriorityURL(url: URL(string: "/path/to/image")!, priority: 100),
    UIImageView.PriorityURL(url: URL(string: "/path/to/image")!, priority: 1000)
    ])
```

## Requirements
- iOS 8.0+
- Xcode 8.0+
- Swift 3.0+
