//
//  LoginVC.swift
//  chatDemo
//
//  Created by Sundevs on 2/2/17.
//  Copyright © 2017 Sundevs. All rights reserved.
//

import UIKit
import Firebase

class LoginVC: UIViewController {

    @IBOutlet weak var txtPassword: UITextField!
    @IBOutlet weak var txtEmail: UITextField!
    override func viewDidLoad() {
        super.viewDidLoad()

//        self.txtEmail.text! = "juber.patino@sundevs.com"
//        self.txtPassword.text! = "1234567890"
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func onLogin(_ sender: Any) {
        
        FIRAuth.auth()?.signIn(withEmail: self.txtEmail.text!, password: self.txtPassword.text!, completion: { (FIRUser, Error) in
            
            if Error != nil {
                print("error \(Error!.localizedDescription)")
                
                
                let alert = UIAlertController(title: "ENCANTO", message: Error!.localizedDescription, preferredStyle: UIAlertControllerStyle.alert)
                alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
                self.present(alert, animated: true, completion: nil)
                
            }else{
                print("user = \(FIRUser?.email)")
                print("username = \(FIRUser?.displayName)")
                
                
                self.goToHomeVCWith(storyboard: "Main", identifier: "TabBarController")
            }
        })

        
    }

    func goToHomeVCWith(storyboard:String,identifier:String) {
        let storyboard = UIStoryboard(name: storyboard, bundle: nil)
        let goToHome = storyboard.instantiateViewController(withIdentifier: identifier)
        let appDelegate = UIApplication.shared.delegate as? AppDelegate
        appDelegate?.window?.rootViewController = goToHome
    }

}
