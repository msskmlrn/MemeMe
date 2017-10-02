//
//  MemeDetailViewController.swift
//  MemeMe
//

import Foundation
import UIKit

class MemeDetailViewController: UIViewController {
    
    var meme: Meme!
    
    @IBOutlet weak var imageView: UIImageView!
    
    @IBOutlet weak var textView: UITextView!
 
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        //set the text and image to the view
        self.textView.text = self.meme.topText + " ... " + self.meme.bottomText
        self.imageView!.image = meme.memeImage
    }
}
