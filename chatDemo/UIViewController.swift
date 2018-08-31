//
//  UIViewController.swift
//  ENCANTO
//
//  Created by juber patiño garcia on 20/09/16.
//  Copyright © 2016 juber patiño garcia. All rights reserved.
//

import UIKit
import MobileCoreServices
import AVFoundation

var image:UIImage?


extension UIViewController:UIImagePickerControllerDelegate,UINavigationControllerDelegate,UIViewControllerTransitioningDelegate {
    
    func selectedPicture(){
        // permite entrar a la camara
        if(UIImagePickerController .isSourceTypeAvailable(UIImagePickerControllerSourceType.camera)){
            let picker = UIImagePickerController()
            picker.allowsEditing = true
            picker.sourceType = UIImagePickerControllerSourceType.camera
            picker.delegate = self
            picker.transitioningDelegate = self
            picker.modalPresentationStyle = .custom
            picker.mediaTypes = [kUTTypeImage as String, kUTTypeMovie as String]
            picker.videoQuality = .typeIFrame1280x720

            present(picker, animated: true, completion: nil)
        }else{
            
            let alert = UIAlertController.init(title: "Cámara",
                                               message: "Su cámara no está disponible",
                                               preferredStyle: UIAlertControllerStyle.alert)
            
            let defaultAction = UIAlertAction.init(title: "Ok", style: .default, handler: { (UIAlertAction) -> Void in
                
            })
            
            alert.addAction(defaultAction)
            alert.transitioningDelegate = self
            alert.modalPresentationStyle = .custom
            self.present(alert, animated: true, completion: nil)
            
        }
        
        
    }
    func selectedGallery(){
        // permite entrar a galeria
        if(UIImagePickerController .isSourceTypeAvailable(UIImagePickerControllerSourceType.photoLibrary)){
            
                let picker = UIImagePickerController()
                picker.allowsEditing = true
                picker.sourceType = UIImagePickerControllerSourceType.photoLibrary
                picker.delegate = self
                picker.transitioningDelegate = self
                picker.modalPresentationStyle = .custom
                picker.mediaTypes = [kUTTypeImage as String, kUTTypeMovie as String]
                self.present(picker, animated: true, completion: nil)

        }else{
            
            let alert = UIAlertController.init(title: "Galería",
                                               message: "Su galería no está disponible",
                                               preferredStyle: UIAlertControllerStyle.alert)
            
            let defaultAction = UIAlertAction.init(title: "Ok", style: .default, handler: { (UIAlertAction) -> Void in
                
            })
            
            alert.addAction(defaultAction)

            self.present(alert, animated: true, completion: nil)

        }
        

    }
    
}
