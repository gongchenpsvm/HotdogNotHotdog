//
//  ViewController.swift
//  NotHotdog
//
//  Created by Gong Chen on 21/09/2017.
//  Copyright © 2017 Gong Chen. All rights reserved.
//

import UIKit
import VisualRecognitionV3
import SVProgressHUD
import Social

class ViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    let apikey = "9c33c4e7c84899c64f370f15b485fcfcf3c0351d"
    let version = "2017-09-21"
    
    @IBOutlet weak var shareButton: UIButton!
    @IBOutlet weak var topBarImageView: UIImageView!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var cameraButton: UIBarButtonItem!
    
    let imagePicker = UIImagePickerController()
    var classificationResult : [String] = []//Set to empty array
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //Hide share button
        self.shareButton.isHidden = true;
        imagePicker.delegate =  self
    }

    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        //Show image on screen and send it to ibm
        
        cameraButton.isEnabled = false;//Disable camera
        SVProgressHUD.show()
        
        
        
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
                let classes = classifiedImages.images.first!.classifiers.first!.classes
                
                self.classificationResult = []
                
                for index in 0..<classes.count {
                    self.classificationResult.append(classes[index].classification)
                }
                print(self.classificationResult)
                
                //Re-enable camera
                DispatchQueue.main.async {
                    self.cameraButton.isEnabled = true
                    SVProgressHUD.dismiss()
                    self.shareButton.isHidden = false
                }
                
                if self.classificationResult.contains("hotdog") {
                    //Update UI at main thread
                    DispatchQueue.main.async {
                        self.navigationItem.title = "Hotdog!"
                        self.navigationController?.navigationBar.barTintColor = UIColor.green
                        self.navigationController?.navigationBar.isTranslucent = false
                        self.topBarImageView.image = UIImage(named:"hotdog")
                        
                    }
                    //Remove since in back thread
                    //self.navigationItem.title = "Hotdog!"
                }
                else {
                    DispatchQueue.main.async {
                        self.navigationItem.title = "Not Hotdog!"
                        self.navigationController?.navigationBar.barTintColor = UIColor.red
                        self.navigationController?.navigationBar.isTranslucent = false
                        self.topBarImageView.image = UIImage(named:"not-hotdog")
                    }
                }
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

    @IBAction func shareTapped(_ sender: UIButton) {
        if SLComposeViewController.isAvailable(forServiceType: SLServiceTypeFacebook){
            let vc = SLComposeViewController(forServiceType: SLServiceTypeTwitter)
            vc?.setInitialText("See if your food is a hotdog or not")
            vc?.add(#imageLiteral(resourceName: "hotdog"))
            present(vc!, animated: true, completion: nil)
        } else {
            self.navigationItem.title = "Please log in to Twitter"
        }
    }
}

