//
//  ViewController.swift
//  NotHotdog
//
//  Created by Gong Chen on 21/09/2017.
//  Copyright © 2017 Gong Chen. All rights reserved.
//

import UIKit
import VisualRecognitionV3

class ViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    let apikey = "9c33c4e7c84899c64f370f15b485fcfcf3c0351d"
    let version = "2017-09-21"
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet  var cameraButton: UIBarButtonItem!
    
    let imagePicker = UIImagePickerController()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        imagePicker.delegate =  self
    }

    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        //Show image on screen and send it to ibm
        if let image = info[UIImagePickerControllerOriginalImage] as? UIImage {
            //Set image view to this image
            if imageView != nil{
                imageView.image = image
            }
            else {
                print("Error: imageView nil")
            }
            //Dismiss the imagepicker used earlier
            imagePicker.dismiss(animated: true, completion: nil)
            
            let visualRecognition = VisualRecognition(apiKey: apikey, version: version)
            
            let imageData = UIImageJPEGRepresentation(image, 0.01)
            
            let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
            
            let fileURL = documentsURL.appendingPathComponent("tempImage.jpg")
            
            try? imageData?.write(to: fileURL, options: [])
            
            visualRecognition.classify(imageFile: fileURL, success: { (classifiedImages) in
                print(classifiedImages)
            })
        } else {//Not true
            print("Error: picking image")
        }
    }
    @IBAction func cameraTapped(_ sender: UIBarButtonItem) {
        
        imagePicker.sourceType = .savedPhotosAlbum
        imagePicker.allowsEditing = false
        present(imagePicker, animated: true, completion: nil)
    }
    
}

