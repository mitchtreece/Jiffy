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
    
    private func setAnimatedImage(_ animatedImage: UIImage, memoryLimit: Int = kDefaultMemoryLimit) {
        
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
    
    public func playAnimatedImage() {
        
        guard let storage = storage else {
            print("Trying to animate a UIImage without animatedImageData!")
            return
        }
        
        storage.needToPlay = true
        
    }
    
    public func stopAnimatedImage() {
        
        guard let storage = storage else {
            print("Trying to stop animation on a UIImage without animatedImageData!")
            return
        }
        
        storage.needToPlay = false
        
    }
    
    internal func getPlayJudge() -> Bool {
        return storage!.needToPlay!
    }
    
    internal func getTimer() -> CADisplayLink {
        return storage!.timer!
    }
    
    internal func getAnimatedImage() -> UIImage {
        return storage!.aImage!
    }
    
    internal func getDisplayOrderIndex() -> Int{
        return storage!.displayOrderIndex!
    }
    
    internal func getCurrentImage() -> UIImage{
        return storage!.currentImage!
    }
    
    internal func getImageCache() -> NSCache<AnyObject, UIImage> {
        return storage!.cache!
    }
    
    private func prepareCache() {
        
        storage!.cache = NSCache()
        
        for i in 0..<self.getAnimatedImage().getDisplayOrder().count {
            
            let array = [(kCGImageSourceShouldCacheImmediately as String): kCFBooleanTrue] as! CFDictionary
            let cgImage = CGImageSourceCreateImageAtIndex(self.getAnimatedImage().getImageSource(), self.getAnimatedImage().getDisplayOrder()[i], array)
            let image = UIImage(cgImage: cgImage!)
            self.getImageCache().setObject(image, forKey: (i as AnyObject))
            
        }
        
    }
    
    // Bound to 'displayLink'
    @objc private func updateFrameWithoutCache() {
        
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
    @objc private func updateFrameWithCache() {
        
        if(self.getPlayJudge() == true) {
            
            if let key = self.getDisplayOrderIndex() as? AnyObject, let image = self.getImageCache().object(forKey: key) {
                
                self.image = image
                storage!.displayOrderIndex = (self.getDisplayOrderIndex() + 1) % self.getAnimatedImage().getImageNumber()
                
            }
                        
        }
        
    }
    
}
