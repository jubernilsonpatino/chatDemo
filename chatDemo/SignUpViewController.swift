//
//  SignUpViewController.swift
//  chatDemo
//
//  Created by Sundevs on 2/24/17.
//  Copyright © 2017 Sundevs. All rights reserved.
//

import UIKit
import Firebase
import FirebaseMessaging

class SignUpViewController: UIViewController {

    @IBOutlet weak var imgProfile: UIImageView!
    @IBOutlet weak var txtPassword: UITextField!
    @IBOutlet weak var txtEmail: UITextField!
    @IBOutlet weak var txtName: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.imgProfile.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.onSelectedProfileImage)))
        self.imgProfile.isUserInteractionEnabled = true
        self.imgProfile.image = #imageLiteral(resourceName: "User-96")
        self.imgProfile.layer.masksToBounds = true
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func onRegister(_ sender: Any) {
        
        FIRAuth.auth()?.createUser(withEmail: self.txtEmail.text!, password: self.txtPassword.text!, completion: { (user, error) in
            
            if error != nil {
                print("error = \(error)")
            }else{
                
                let imageNamed = NSUUID().uuidString
                let storageRef = FIRStorage.storage().reference().child("profile_images").child("\(imageNamed).png")
                
                if let uploadData = UIImageJPEGRepresentation(self.imgProfile.image!, 0.5) {
                    
                    let metadata = FIRStorageMetadata()
                    metadata.contentType = "image/jpeg"
                    
                    storageRef.put(uploadData, metadata: metadata, completion: { (metadata, error) in
                        
                        if error != nil {
                            print(error!)
                            return
                        }
                        
                        if let profileImageUrl = metadata?.downloadURL()?.absoluteString {
                            
                            var token:String = ""
                            
                            if let refreshedToken = FIRInstanceID.instanceID().token() {
                                token = refreshedToken
                            }

                            
                            let values = ["name":self.txtName.text!,"email":self.txtEmail.text!,"profileImageUrl":profileImageUrl,"token":token]
                            
                            self.registerUserIntoDatabaseWithUID(uid: user!.uid, values: values as [String : AnyObject])
                            print(metadata!)

                        }
                        

                    })
                }
                
            }
        })
    }
    
    func registerUserIntoDatabaseWithUID(uid:String, values:[String:AnyObject]) {
        
        let ref = FIRDatabase.database().reference()
        let usersRef = ref.child("users").child(uid)
        
        usersRef.updateChildValues(values, withCompletionBlock: { (error, reference) in
            
            if error != nil {
                
                print("error = \(error)")
            }else{
                self.goToHomeVCWith(storyboard: "Main", identifier: "navController")
                print("reference = \(reference)")
            }
        })
        
    }
    
    func goToHomeVCWith(storyboard:String,identifier:String) {
        let storyboard = UIStoryboard(name: storyboard, bundle: nil)
        let goToHome = storyboard.instantiateViewController(withIdentifier: identifier)
        let appDelegate = UIApplication.shared.delegate as? AppDelegate
        appDelegate?.window?.rootViewController = goToHome
    }
    
    @IBAction func onCloseVC(_ sender: Any) {
        
        self.dismiss(animated: true, completion: nil)
    }
    
    func onSelectedProfileImage(){
        
        print("image profile")
        
        let alertVC = UIAlertController.init(title: "Chat Demo", message: "Elija un modo", preferredStyle:.actionSheet)
        
        let galleryAction = UIAlertAction.init(title: "Galería", style: .default) { (UIAlertAction) -> Void in
            self.selectedGallery()
        }
        let cameraAction = UIAlertAction.init(title: "Cámara", style:.default) { (UIAlertAction) -> Void in
            self.selectedPicture()
            
        }
        let cancelAction = UIAlertAction.init(title: "Cancelar", style: .cancel, handler: nil)
        
        alertVC.addAction(galleryAction)
        alertVC.addAction(cameraAction)
        alertVC.addAction(cancelAction)
        
        self.present(alertVC, animated: true, completion: nil)
    }
    
    // MARK: - UIImagePickerControllerDelegate
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion:nil)
        
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
        
        
        var newImage: UIImage
        
        if let possibleImage = info["UIImagePickerControllerEditedImage"] as? UIImage {
            newImage = possibleImage
        } else if let possibleImage = info["UIImagePickerControllerOriginalImage"] as? UIImage {
            newImage = possibleImage
        } else {
            return
        }
        
        if(picker.sourceType == UIImagePickerControllerSourceType.camera){
            
            let imageToSave: UIImage = info[UIImagePickerControllerOriginalImage] as! UIImage
            
            UIImageWriteToSavedPhotosAlbum(imageToSave, nil, nil, nil)
            
        }
        
        print(newImage.size)
        
        self.imgProfile.image = newImage
        self.imgProfile.layer.cornerRadius = self.imgProfile.frame.size.width / 2
        self.imgProfile.layer.masksToBounds = true
        dismiss(animated: true, completion: nil)
        
    }

}
