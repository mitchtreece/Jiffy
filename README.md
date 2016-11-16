# Jiffy
Easy animated images for Swift! Based on [AImage](https://github.com/wangjwchn/AImage).

[![Language](https://img.shields.io/badge/swift-3.0-orange.svg)](http://swift.org)
[![Version](https://img.shields.io/cocoapods/v/Jiffy.svg?style=flat)](http://cocoapods.org/pods/Jiffy)
[![License](https://img.shields.io/cocoapods/l/Jiffy.svg?style=flat)](http://cocoapods.org/pods/Jiffy)
[![Platform](https://img.shields.io/cocoapods/p/Jiffy.svg?style=flat)](http://cocoapods.org/pods/Jiffy)

## Overview
_Jiffy_ makes working with animated images **(.gif / .apng)** a breeze. While there are a lot of libraries out there that accomplish something similar, most of them are usually plagued with un-needed features and performance issues. _Jiffy_ aims to be a small & simple animated image library with little-to-no performance overhead.

This library is named after the absurd way my co-worker tries to pronounce _"Gif"_. It's not a jar of peanut-butter, it's an animated image.

## Installation
### CocoaPods
Jiffy is integrated with CocoaPods!

1. Add the following to your `Podfile`:
```
use_frameworks!
pod 'Jiffy'
```
2. In your project directory, run `pod install`
3. Import the `Jiffy` module wherever you need it
4. Profit

### Manually
You can also manually add the source files to your project.

1. Clone this git repo
2. Add all the Swift files in the `Jiffy/` subdirectory to your project
3. Profit

## Jiffy
At it's core, _Jiffy_ is just a set of extensions over `UIImage` & `UIImageView`. This makes working with animated images familiar and easy.

```swift
let imageData = ...
let animatedImage = UIImage(animatedImageData: imageData)

let imageView = UIImageView(animatedImage: animatedImage)
imageView.frame = CGRect(x: 0, y: 0, 200, height: 200)
view.addSubview(imageView)
```

That's it. You now have a beautiful animated image looping in your view! If you want to stop your animated image, just call `imageView.stopAnimatedImage()`. Naturally, a call to `imageView.playAnimatedImage()` will start your animation again.

You can also tell an existing `UIImageView` to start playing an animated image. This is useful when you want to layout your views with _Storyboards_.

```swift
@IBOutlet weak var imageView: UIImageView!

...

let imageData = ...
let animatedImage = UIImage(animatedImageData: imageData)
imageView.animate(with: animatedImage)
```

## Image Quality
_Jiffy_ also provides a way to specify image quality. The `AnimatedImageQuality` enum is defined as follows:

```swift
public enum AnimatedImageQuality: Float {

    case full = 1.0
    case high = 0.8
    case medium = 0.5
    case low = 0.2

    public static func custom(quality: Float) -> AnimatedImageQuality {
        return AnimatedImageQuality(rawValue: quality)!
    }

}
```

Using this enum, we can pass a pre-defined quality level to `UIImageView` upon initialization with an animated image:

```swift
let animatedImage = UIImage(animatedImageData: imageData, quality: .high)
```

If one of the pre-defined quality levels doesn't do it for you, you can pass a custom quality level:

```swift
let animatedImage = UIImage(animatedImageData: imageData, quality: AnimatedImageQuality.custom(quality: 0.42))
```

If no quality is passed to `UIImageView`, it will assume max (`AnimatedImageQuality.full`) quality settings.

## Memory Limit
You can also specify a memory limit (in whole MB values) on `UIImageView`:

```swift
let imageView = UIImageView(animatedImage: animatedImage, memoryLimit: 5)
```

If no memory limit is passed to `UIImageView`, it will default to a 20MB limit.

## Contributing
Pull-requests are more than welcome. I only ask that any additions made to this library stick to a simple & performant standard.
