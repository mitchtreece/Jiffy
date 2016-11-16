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

    @IBOutlet weak var fullImageView: UIImageView!
    @IBOutlet weak var mediumImageView: UIImageView!
    @IBOutlet weak var lowImageView: UIImageView!
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        if let url = Bundle.main.url(forResource: "gandalf", withExtension: "gif") {
            
            do {
                
                let data = try Data(contentsOf: url)
                let fullImage = AnimatedImage(animatedImageData: data)
                let mediumImage = AnimatedImage(animatedImageData: data, quality: .medium)
                let lowImage = AnimatedImage(animatedImageData: data, quality: .low)
                
                fullImageView.animate(with: fullImage)
                mediumImageView.animate(with: mediumImage)
                lowImageView.animate(with: lowImage)
                
                let fullTapRecognizer = UITapGestureRecognizer(target: self, action: #selector(imageViewTapped(_:)))
                let mediumTapRecognizer = UITapGestureRecognizer(target: self, action: #selector(imageViewTapped(_:)))
                let lowTapRecognizer = UITapGestureRecognizer(target: self, action: #selector(imageViewTapped(_:)))

                fullImageView.addGestureRecognizer(fullTapRecognizer)
                mediumImageView.addGestureRecognizer(mediumTapRecognizer)
                lowImageView.addGestureRecognizer(lowTapRecognizer)
                
            }
            catch {
                print("Error loading GIF data")
            }
            
        }
        
    }
    
    func imageViewTapped(_ recognizer: UITapGestureRecognizer) {
        
        guard let imageView = recognizer.view as? UIImageView else { return }
        imageView.isAnimatingImage ? imageView.stopAnimatedImage() : imageView.playAnimatedImage()
        
    }

    override func didReceiveMemoryWarning() {
        
        super.didReceiveMemoryWarning()
        
    }

}

