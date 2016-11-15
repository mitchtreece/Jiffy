//
//  ViewController.swift
//  Jiffy
//
//  Created by Mitch Treece on 11/15/2016.
//  Copyright (c) 2016 Mitch Treece. All rights reserved.
//

import UIKit
import Jiffy

class ViewController: UIViewController {

    var imageView: AnimatedImageView!
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        if let url = Bundle.main.url(forResource: "gandalf", withExtension: "gif") {
            
            do {
                
                let data = try Data(contentsOf: url)
                let image = AnimatedImage(animatedImageData: data)
                
                imageView = AnimatedImageView(animatedImage: image)
                imageView.frame = CGRect(x: 0, y: 0, width: view.bounds.width, height: view.bounds.width/2)
                imageView.center = view.center
                view.addSubview(imageView)
                
                imageView.playAnimatedImage()
                
            }
            catch {
                print("Error loading GIF data")
            }
            
        }

        
    }

    override func didReceiveMemoryWarning() {
        
        super.didReceiveMemoryWarning()
        
    }

}

