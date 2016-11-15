//
//  UIImageView+Jiffy.swift
//  Pods
//
//  Created by Mitch Treece on 11/15/16.
//
//

import UIKit
import ImageIO

public typealias AnimatedImageView = UIImageView

let kDefaultMemoryLimit = 20
let kAnimatedImageViewStorageKey = malloc(8)

private class AnimatedImageViewStorage {
    
    var needToPlay: Bool?
    var timer: CADisplayLink?
    var aImage: UIImage?
    var displayOrderIndex: Int?
    var currentImage: UIImage?
    var cache: NSCache<AnyObject, UIImage>?
    
}

public extension UIImageView {
    
    private var storage: AnimatedImageViewStorage? {
        
        get {
            return (objc_getAssociatedObject(self, kAnimatedImageViewStorageKey) as! AnimatedImageViewStorage)
        }
        set {
            objc_setAssociatedObject(self, kAnimatedImageViewStorageKey, newValue, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN)
        }
        
    }
    
    public convenience init(animatedImage: UIImage, memoryLimit: Int = kDefaultMemoryLimit) {
        
        self.init()
        setAnimatedImage(animatedImage, memoryLimit: memoryLimit)
        
    }
    
    public func setAnimatedImage(_ animatedImage: UIImage, memoryLimit: Int = kDefaultMemoryLimit) {
        
        storage = AnimatedImageViewStorage()
        storage!.aImage = animatedImage
        storage!.displayOrderIndex = 0
        storage!.needToPlay = false
        storage!.timer = nil
        storage!.currentImage = UIImage(cgImage: CGImageSourceCreateImageAtIndex(self.getAnimatedImage().getImageSource(), 0, nil)!)
        
        if(self.getAnimatedImage().getImageSize() >= memoryLimit) {
            storage!.timer = CADisplayLink(target: self, selector: #selector(UIImageView.updateFrameWithoutCache))
        }
        else {
            
            DispatchQueue.global(priority: .high).async {
                self.prepareCache()
            }
            
            storage!.timer = CADisplayLink(target: self, selector: #selector(UIImageView.updateFrameWithCache))
            
        }
        
        storage!.timer!.frameInterval = self.getAnimatedImage().getRefreshFactor()
        storage!.timer!.add(to: .main, forMode: .commonModes)
        
    }
    
    public func play() {
        storage!.needToPlay = true
    }
    
    public func stop() {
        storage!.needToPlay = false
    }
    
    public func getPlayJudge() -> Bool {
        return storage!.needToPlay!
    }
    
    public func getTimer() -> CADisplayLink {
        return storage!.timer!
    }
    
    public func getAnimatedImage() -> UIImage {
        return storage!.aImage!
    }
    
    public func getDisplayOrderIndex() -> Int{
        return storage!.displayOrderIndex!
    }
    
    public func getCurrentImage() -> UIImage{
        return storage!.currentImage!
    }
    
    public func getImageCache() -> NSCache<AnyObject, UIImage> {
        return storage!.cache!
    }
    
    func prepareCache() {
        
        storage!.cache = NSCache()
        
        for i in 0..<self.getAnimatedImage().getDisplayOrder().count {
            
            let array = [(kCGImageSourceShouldCacheImmediately as String): kCFBooleanTrue] as! CFDictionary
            let cgImage = CGImageSourceCreateImageAtIndex(self.getAnimatedImage().getImageSource(), self.getAnimatedImage().getDisplayOrder()[i], array)
            let image = UIImage(cgImage: cgImage!)
            self.getImageCache().setObject(image, forKey: (i as AnyObject))
            
        }
        
    }
    
    // Bound to 'displayLink'
    func updateFrameWithoutCache() {
        
        if(self.getPlayJudge() == true) {
            
            self.image = self.getCurrentImage()
            
            DispatchQueue.global(priority: .high).async {
                
                let array = [(kCGImageSourceShouldCacheImmediately as String): kCFBooleanTrue] as! CFDictionary
                let cgImage = CGImageSourceCreateImageAtIndex(self.getAnimatedImage().getImageSource(), self.getAnimatedImage().getDisplayOrder()[self.getDisplayOrderIndex()], array)
                self.storage!.currentImage = UIImage(cgImage: cgImage!)
                self.storage!.displayOrderIndex = (self.getDisplayOrderIndex() + 1) % self.getAnimatedImage().getImageNumber()
                
            }
            
        }
        
    }
    
    // Bound to 'displayLink'
    func updateFrameWithCache() {
        
        if(self.getPlayJudge() == true) {
            
            if let key = self.getDisplayOrderIndex() as? AnyObject, let image = self.getImageCache().object(forKey: key) {
                
                self.image = image
                storage!.displayOrderIndex = (self.getDisplayOrderIndex() + 1) % self.getAnimatedImage().getImageNumber()
                
            }
                        
        }
        
    }
    
}
