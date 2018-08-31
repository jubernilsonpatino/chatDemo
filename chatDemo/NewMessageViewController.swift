//
//  NewMessageViewController.swift
//  chatDemo
//
//  Created by Sundevs on 2/24/17.
//  Copyright © 2017 Sundevs. All rights reserved.
//

import UIKit
import Firebase

class NewMessageViewController: UIViewController,UITableViewDelegate,UITableViewDataSource {

    @IBOutlet weak var tableViewUsers: UITableView!
    
    var users = [User]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = "Usuarios"

        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Cancel", style: .plain, target: self, action: #selector(handleCancel))
        
        fetchUser()
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func fetchUser() {
        
        FIRDatabase.database().reference().child("users").observe(.childAdded, with: { (snapshot) in
            
            if let dictionary = snapshot.value as? [String:AnyObject] {
                
                let user = User()
                user.id = snapshot.key
                user.setValuesForKeys(dictionary)
                
                let userLogged = FIRAuth.auth()?.currentUser?.uid
                
                if userLogged != user.id {
                    self.users.append(user)
                }
                
                DispatchQueue.main.async {
                    self.tableViewUsers.reloadData()
                }
                print(user.name!,user.email!)
            }
            
        }, withCancel: nil)
    }
    
    func handleCancel() {
        
        self.dismiss(animated: true, completion: nil)
    }
    
    var chatListVC = ChatListViewController()

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        //self.dismiss(animated: true) {
            
            let user = self.users[indexPath.row]
            
            let storyboard:UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
            let newChatVC:ChatVC = storyboard.instantiateViewController(withIdentifier: "ChatVC") as! ChatVC
            newChatVC.user = user
            newChatVC.hidesBottomBarWhenPushed = true
            self.navigationController?.pushViewController(newChatVC, animated: true)
      //  }
        
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.users.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell:UsersTableViewCell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! UsersTableViewCell
        
        let user = users[indexPath.row]
        
        cell.labName.text = user.name!
        cell.labEmail.text = user.email!
        
        if let profileImageUrl = user.profileImageUrl {
            
            cell.imgProfile.loadImageUsingCacheWithUrlString(urlString: profileImageUrl)
            cell.imgProfile.layer.cornerRadius = cell.imgProfile.frame.size.width / 2

        }
        
        return cell

    }

}
