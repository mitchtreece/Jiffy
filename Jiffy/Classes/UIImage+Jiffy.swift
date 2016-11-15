//
//  UIImage+Jiffy.swift
//  Pods
//
//  Created by Mitch Treece on 11/15/16.
//
//

import UIKit
import ImageIO

public typealias AnimatedImage = UIImage

public enum AnimatedImageQuality: Float {
    
    case full = 1.0
    case high = 0.8
    case medium = 0.5
    case low = 0.2
    
    public static func custom(quality: Float) -> AnimatedImageQuality {
        return AnimatedImageQuality(rawValue: quality)!
    }
    
}

let kDefaultImageQuality: AnimatedImageQuality = .full
let kFloatEPS: Float = 1E-6
let kCheckIntervals = [60, 30, 20, 15, 12, 10, 6, 5, 4, 3, 2, 1]
let kAnimatedImageStorageKey = malloc(8)

private class AnimatedImageStorage {
    
    var imageSource: CGImageSource?
    var displayRefreshFactor: Int?
    var imageSize: Int?
    var imageCount: Int?
    var displayOrder: [Int]?
    
}

public extension UIImage {
    
    private var storage: AnimatedImageStorage? {
        
        get {
            return (objc_getAssociatedObject(self, kAnimatedImageStorageKey) as! AnimatedImageStorage)
        }
        set {
            objc_setAssociatedObject(self, kAnimatedImageStorageKey, newValue, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN);
        }
        
    }
    
    public convenience init(animatedImageData: Data, quality: AnimatedImageQuality = kDefaultImageQuality) {
        
        self.init()
        addAnimatedImage(with: animatedImageData, quality: quality)
        
    }
    
    private func addAnimatedImage(with data: Data, quality: AnimatedImageQuality = kDefaultImageQuality) {
        
        let cfData = data as CFData
        
        storage = AnimatedImageStorage()
        storage!.imageSource = CGImageSourceCreateWithData(cfData, nil)
        
        if(quality.rawValue <= 0 || quality.rawValue > 1) {
            // Use default quality
            calculateFrameDelay(for: calculateDelayTimes(for: storage!.imageSource), quality: kDefaultImageQuality)
        }
        else {
            // Custom quality
            calculateFrameDelay(for: calculateDelayTimes(for: storage!.imageSource), quality: quality)
        }
        
        calculateFrameSize()
        
    }
    
    internal func getImageSource() -> CGImageSource {
        return storage!.imageSource!
    }
    
    internal func getRefreshFactor() -> Int {
        return storage!.displayRefreshFactor!
    }
    
    internal func getImageSize() -> Int {
        return storage!.imageSize!
    }
    
    internal func getImageNumber() -> Int {
        return storage!.imageCount!
    }
    
    internal func getDisplayOrder() -> [Int] {
        return storage!.displayOrder!
    }
    
    private func calculateDelayTimes(for imageSource: CGImageSource?) -> [Float] {
        
        let imageCount = CGImageSourceGetCount(imageSource!)
        
        var imageProperties = [CFDictionary]()
        for i in 0..<imageCount{
            imageProperties.append(CGImageSourceCopyPropertiesAtIndex(imageSource!, i, nil)!)
        }
        
        var frameProperties = [CFDictionary]()
        
        if(CFDictionaryContainsKey(imageProperties[1], Unmanaged.passUnretained(kCGImagePropertyGIFDictionary).toOpaque())) {
            
            // Animated Gif
            
            frameProperties = imageProperties.map(){
                unsafeBitCast(CFDictionaryGetValue($0, Unmanaged.passUnretained(kCGImagePropertyGIFDictionary).toOpaque()), to: CFDictionary.self)
            }
            
        }
        else if(CFDictionaryContainsKey(imageProperties[1], Unmanaged.passUnretained(kCGImagePropertyPNGDictionary).toOpaque())) {
            
            // Animated Png
            
            frameProperties = imageProperties.map(){
                unsafeBitCast(CFDictionaryGetValue($0, Unmanaged.passUnretained(kCGImagePropertyPNGDictionary).toOpaque()), to: CFDictionary.self)
            }
            
        }
        else{
            fatalError("Illegal image type.")
        }
        
        let EPS: Float = 1e-6
        let frameDelays: [Float] = frameProperties.map() {
            
            var delayObject: AnyObject = unsafeBitCast(CFDictionaryGetValue($0, Unmanaged.passUnretained(kCGImagePropertyGIFUnclampedDelayTime).toOpaque()), to: AnyObject.self)
            
            if(delayObject.floatValue < EPS) {
                delayObject = unsafeBitCast(CFDictionaryGetValue($0, Unmanaged.passUnretained(kCGImagePropertyGIFDelayTime).toOpaque()), to: AnyObject.self)
            }
            
            return delayObject as! Float
            
        }
        
        return frameDelays
        
    }
    
    private func calculateFrameDelay(for delayValues: [Float], quality: AnimatedImageQuality) {
        
        var delays = delayValues
        
        let maxFramePerSecond = kCheckIntervals.first
        
        // Frame numbers per second
        let displayRefreshRates = kCheckIntervals.map({ maxFramePerSecond! / $0 })
        
        // Time interval per frame
        let displayRefreshDelayTime = displayRefreshRates.map({ 1.0 / Float($0) })
        
        // Caclulate the time when eash frame should be displayed at (start at 0)
        for i in 1..<delays.count{
            delays[i] += delays[i - 1]
        }
        
        // Find the appropriate Factors then break
        for i in 0..<displayRefreshDelayTime.count {
            
            let displayPosition = delays.map({ Int($0 / displayRefreshDelayTime[i]) })
            
            var framelosecount = 0
            for j in 1..<displayPosition.count{
                if(displayPosition[j] == displayPosition[j-1])
                {framelosecount += 1}
            }
            
            if(Float(framelosecount) <= Float(displayPosition.count) * (1.0 - quality.rawValue) || i == displayRefreshDelayTime.count - 1) {
                
                storage!.imageCount = displayPosition.last!
                storage!.displayRefreshFactor = kCheckIntervals[i]
                storage!.displayOrder = [Int]()
                
                var indexOfold = 0, indexOfnew = 1
                while(indexOfnew <= storage!.imageCount!) {
                    
                    if(indexOfnew <= displayPosition[indexOfold]) {
                        storage!.displayOrder!.append(indexOfold)
                        indexOfnew += 1
                    }
                    else {
                        indexOfold += 1
                    }
                    
                }
                
                break
                
            }
            
        }
        
    }
    
    private func calculateFrameSize() {
        
        let image = UIImage(cgImage: CGImageSourceCreateImageAtIndex(storage!.imageSource!, 0, nil)!)
        storage!.imageSize = Int(image.size.height * image.size.width * 4) * storage!.imageCount! / (1000 * 1000)
        
    }
    
}
