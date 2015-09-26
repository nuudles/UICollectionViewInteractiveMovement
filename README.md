# UICollectionViewInteractiveMovement

This library attempts to backport the new `UICollectionView` interative movement APIs from iOS 9 to support earlier versions of iOS.

## Features

- Allows you to add interactive movement (tap and hold to move `UICollectionViewCells`) to any `UICollectionView` using any `UICollectionViewLayout`
- Defaults to use the new iOS 9 APIs if available

## Requirements

- iOS 8.0+ (for now)
- Xcode 7.0+

## Installation Using CocoaPods

[CocoaPods](http://cocoapods.org) is a dependency manager for Cocoa projects.

This library is in development and has not yet been pushed to the main CocoaPods spec repository. If you would like to try including it in your `Podfile` by specifying this repo like such:

```ruby
source 'https://github.com/CocoaPods/Specs.git'
platform :ios, '8.0'
use_frameworks!

pod 'UICollectionViewInteractiveMovement', :git => 'https://github.com/nuudles/UICollectionViewInteractiveMovement'
```

## Usage

The easiest way to use it is to simply attach the gestureRecognizer to your `UICollectionView` by calling the install method:

```
collectionView.installStandardGestureForInteractiveMovement()
```

## TODOs

- When a moved cell replaces another cell, the animation puts it in the actual spot, then moves it back to the touch position
- Add auto-scrolling support when the dragged cell approaches the edges
- iOS 7 and earlier support?