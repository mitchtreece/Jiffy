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
    
    var shouldPlay: Bool?
    var timer: CADisplayLink?
    var animatedImage: UIImage?
    var frameOrderIndex: Int?
    var currentFrame: UIImage?
    var cache: NSCache<AnyObject, UIImage>?
    
}

public extension UIImageView {
    
    public var isAnimatingImage: Bool {
        
        guard let storage = storage, let animating = storage.shouldPlay else { return false }
        return animating
        
    }
    
    private var storage: AnimatedImageViewStorage? {
        
        get {
            return (objc_getAssociatedObject(self, kAnimatedImageViewStorageKey) as! AnimatedImageViewStorage)
        }
        set {
            objc_setAssociatedObject(self, kAnimatedImageViewStorageKey, newValue, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN)
        }
        
    }
    
    public convenience init(animatedImage: AnimatedImage, memoryLimit: Int = kDefaultMemoryLimit) {
        
        self.init()
        setAnimatedImage(animatedImage, memoryLimit: memoryLimit)
        playAnimatedImage()
        
    }
    
    public func animate(with animatedImage: AnimatedImage, memoryLimit: Int = kDefaultMemoryLimit) {
    
        setAnimatedImage(animatedImage, memoryLimit: memoryLimit)
        playAnimatedImage()
        
    }
    
    private func setAnimatedImage(_ animatedImage: AnimatedImage, memoryLimit: Int = kDefaultMemoryLimit) {
        
        storage = AnimatedImageViewStorage()
        storage!.animatedImage = animatedImage
        storage!.frameOrderIndex = 0
        storage!.shouldPlay = false
        storage!.timer = nil
        storage!.currentFrame = UIImage(cgImage: CGImageSourceCreateImageAtIndex(self.getAnimatedImage().getImageSource(), 0, nil)!)
        
        if(self.getAnimatedImage().getImageSize() >= memoryLimit) {
            storage!.timer = CADisplayLink(target: self, selector: #selector(UIImageView.updateFrameWithoutCache))
        }
        else {
            
            DispatchQueue.global(qos: DispatchQoS.QoSClass.default).async {
                self.prepareCache()
            }
            
            storage!.timer = CADisplayLink(target: self, selector: #selector(UIImageView.updateFrameWithCache))
            
        }
        
        storage!.timer!.frameInterval = self.getAnimatedImage().getRefreshFactor()
        storage!.timer!.add(to: .main, forMode: .commonModes)
        
    }
    
    public func playAnimatedImage() {
        
        guard let storage = storage else {
            print("Trying to animate a UIImageView without animatedImageData!")
            return
        }
        
        storage.shouldPlay = true
        
    }
    
    public func stopAnimatedImage() {
        
        guard let storage = storage else {
            print("Trying to stop animation on a UIImageView without animatedImageData!")
            return
        }
        
        storage.shouldPlay = false
        
    }
    
    internal func getShouldPlay() -> Bool {
        return storage!.shouldPlay!
    }
    
    internal func getTimer() -> CADisplayLink {
        return storage!.timer!
    }
    
    internal func getAnimatedImage() -> UIImage {
        return storage!.animatedImage!
    }
    
    internal func getFrameOrderIndex() -> Int{
        return storage!.frameOrderIndex!
    }
    
    internal func getCurrentFrame() -> UIImage{
        return storage!.currentFrame!
    }
    
    internal func getImageCache() -> NSCache<AnyObject, UIImage> {
        return storage!.cache!
    }
    
    private func prepareCache() {
        
        storage!.cache = NSCache()
        
        for i in 0..<self.getAnimatedImage().getDisplayOrder().count {
            
            let array = [(kCGImageSourceShouldCacheImmediately as String): kCFBooleanTrue] as CFDictionary
            let cgImage = CGImageSourceCreateImageAtIndex(self.getAnimatedImage().getImageSource(), self.getAnimatedImage().getDisplayOrder()[i], array)
            let image = UIImage(cgImage: cgImage!)
            self.getImageCache().setObject(image, forKey: (i as AnyObject))
            
        }
        
    }
    
    // Bound to 'displayLink'
    @objc private func updateFrameWithoutCache() {
        
        if(self.getShouldPlay() == true) {
            
            self.image = self.getCurrentFrame()
            
            DispatchQueue.global(qos: DispatchQoS.QoSClass.default).async {
                
                let array = [(kCGImageSourceShouldCacheImmediately as String): kCFBooleanTrue] as CFDictionary
                let cgImage = CGImageSourceCreateImageAtIndex(self.getAnimatedImage().getImageSource(), self.getAnimatedImage().getDisplayOrder()[self.getFrameOrderIndex()], array)
                self.storage!.currentFrame = UIImage(cgImage: cgImage!)
                self.storage!.frameOrderIndex = (self.getFrameOrderIndex() + 1) % self.getAnimatedImage().getImageNumber()
                
            }
            
        }
        
    }
    
    // Bound to 'displayLink'
    @objc private func updateFrameWithCache() {
        
        if(self.getShouldPlay() == true) {
            
            let key = self.getFrameOrderIndex() as AnyObject
            
            if let image = self.getImageCache().object(forKey: key) {
                
                self.image = image
                storage!.frameOrderIndex = (self.getFrameOrderIndex() + 1) % self.getAnimatedImage().getImageNumber()
                
            }
                        
        }
        
    }
    
}
