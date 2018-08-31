//
//  ChatListViewController.swift
//  chatDemo
//
//  Created by Sundevs on 2/24/17.
//  Copyright © 2017 Sundevs. All rights reserved.
//

import UIKit
import Firebase

class ChatListViewController: UIViewController,UITableViewDelegate,UITableViewDataSource {

    @IBOutlet weak var tableViewChats: UITableView!
    
    var messages = [Message]()
    var dictionaryMessages = [String:Message]()
    var timer: Timer?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        self.checkIfUserIsLogged()
        self.observeUserMessages()
        self.tableViewChats.allowsMultipleSelectionDuringEditing = true
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    func observeUserMessages() {
        
        self.messages.removeAll()
        self.dictionaryMessages.removeAll()
        self.tableViewChats.reloadData()
        
        guard let uid = FIRAuth.auth()?.currentUser?.uid else {
            return
        }
        
        let ref = FIRDatabase.database().reference().child("user-messages").child(uid)
        ref.observe(.childAdded, with: { (snapshot) in
            
            let userId = snapshot.key
            
            FIRDatabase.database().reference().child("user-messages").child(uid).child(userId).observe(.childAdded, with: { (snapshot) in
                
                let messageId = snapshot.key
                
                self.fetchMessageWithMessageId(messageId: messageId)
                
            }, withCancel: nil)

        }, withCancel: nil)
        
        ref.observe(.childRemoved, with: { (snapshot) in
            
            self.dictionaryMessages.removeValue(forKey: snapshot.key)
            self.attemptReloadOfTable()
            
        }, withCancel: nil)
        
    }
    
    private func fetchMessageWithMessageId(messageId:String) {
        
        let messagesReference = FIRDatabase.database().reference().child("messages").child(messageId)
        
        messagesReference.observeSingleEvent(of: .value, with: { (snapshot) in
            
            if let dictionary = snapshot.value as? [String:AnyObject] {
                
                let message = Message(dictionary: dictionary)
                
                if let chatParnertId = message.chatpatnerId() {
                    self.dictionaryMessages[chatParnertId] = message
                    
                }
                
                self.attemptReloadOfTable()
            }
            
        }, withCancel: nil)

    }
    
    private func attemptReloadOfTable() {
        
        self.timer?.invalidate()
        self.timer = Timer.scheduledTimer(timeInterval: 0.1, target: self, selector: #selector(self.handleReloadTable), userInfo: nil, repeats: false)
    }
    
    func observeMessages() {
      
        let ref = FIRDatabase.database().reference().child("messages")
        ref.observe(.childAdded, with: { (snapshot) in
            
            if let dictionary = snapshot.value as? [String:AnyObject] {
                
                let message = Message(dictionary: dictionary)
                
                if let chatParnertId = message.chatpatnerId() {
                    self.dictionaryMessages[chatParnertId] = message
                    self.messages = Array(self.dictionaryMessages.values)
                    self.messages.sort(by: { (message1, message2) -> Bool in
                        
                        return message1.timestamp!.intValue > message2.timestamp!.intValue
                    })
                }
                
                self.timer?.invalidate()
                self.timer = Timer.scheduledTimer(timeInterval: 0.1, target: self, selector: #selector(self.handleReloadTable), userInfo: nil, repeats: false)
               
                print(message.text!)
            }
            
            print(snapshot)
            
        }) { (error) in
            
            
        }
        
    }
    
    func handleReloadTable() {
        
        self.messages = Array(self.dictionaryMessages.values)
        self.messages.sort(by: { (message1, message2) -> Bool in
            
            return message1.timestamp!.intValue > message2.timestamp!.intValue
        })
        
        DispatchQueue.main.async {
            print("reload table")
            self.tableViewChats.reloadData()
            
        }
    }
    
    func checkIfUserIsLogged() {
        
        if FIRAuth.auth()?.currentUser?.uid == nil {
            perform(#selector(onLogOut(_:)), with: nil, afterDelay: 0)
        }else{
            fetchUserAndSetupNavBarTittle()
        }
        
    }
    
    func fetchUserAndSetupNavBarTittle() {
        
        guard let uid = FIRAuth.auth()?.currentUser?.uid else {
            
            return
        }

        FIRDatabase.database().reference().child("users").child(uid).observeSingleEvent(of: .value, with: { (snapshot) in
            
            print(snapshot)
            
            if let dictionary = snapshot.value as? [String:AnyObject] {
                
                let user = User()
                user.setValuesForKeys(dictionary)
                self.setupNavBarWithUser(user: user)
            }
        })

    }
    
    func setupNavBarWithUser(user:User) {
        self.navigationItem.title = user.name!

        let titleView = UIView()
        
        titleView.frame = CGRect(x: 0, y: 0, width: 100, height: 40)

        let containerView = UIView()
        containerView.translatesAutoresizingMaskIntoConstraints = false
        titleView.addSubview(containerView)
        
        let profileImageView = UIImageView()
        profileImageView.translatesAutoresizingMaskIntoConstraints = false
        profileImageView.contentMode = .scaleAspectFill
        profileImageView.layer.cornerRadius = 20
        profileImageView.layer.masksToBounds = true
        
        if let profileImageUrl = user.profileImageUrl {
            
            profileImageView.loadImageUsingCacheWithUrlString(urlString: profileImageUrl)
        }
        
        containerView.addSubview(profileImageView)
        
        profileImageView.leftAnchor.constraint(equalTo: containerView.leftAnchor).isActive = true
        profileImageView.centerYAnchor.constraint(equalTo: containerView.centerYAnchor).isActive = true
        profileImageView.widthAnchor.constraint(equalToConstant: 40).isActive = true
        profileImageView.heightAnchor.constraint(equalToConstant: 40).isActive = true
        
        let nameLabel = UILabel()
        containerView.addSubview(nameLabel)

        nameLabel.text = user.name
        nameLabel.translatesAutoresizingMaskIntoConstraints = false
        
        nameLabel.leftAnchor.constraint(equalTo: profileImageView.rightAnchor, constant: 8).isActive = true
        nameLabel.centerYAnchor.constraint(equalTo: profileImageView.centerYAnchor).isActive = true
        nameLabel.rightAnchor.constraint(equalTo: containerView.rightAnchor).isActive = true
        nameLabel.heightAnchor.constraint(equalTo: profileImageView.heightAnchor).isActive = true
        
        containerView.centerXAnchor.constraint(equalTo: titleView.centerXAnchor).isActive = true
        containerView.centerYAnchor.constraint(equalTo: titleView.centerYAnchor).isActive = true
        
        
        self.navigationItem.titleView = titleView
    }
    
    @IBAction func onLogOut(_ sender: Any) {
        
        
        let alert = UIAlertController(title: "ChatDemo ", message: "¿Está seguro que desea salir?", preferredStyle: .alert)
        
        let alertAction = UIAlertAction(title: "Salir", style: .default) { (UIAlertAction) in

            do {
                
                try FIRAuth.auth()?.signOut()
                let storyboard:UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
                let goToHome = storyboard.instantiateViewController(withIdentifier: "LoginVC")
                
                let appDelegate = UIApplication.shared.delegate as? AppDelegate
                appDelegate?.window?.rootViewController = goToHome
                
            }catch let logOutError{
                print(logOutError)
                
            }
            
        }
        
        let cancelAction = UIAlertAction(title: "Cancelar", style: .cancel, handler: nil)
        
        alert.addAction(cancelAction)
        alert.addAction(alertAction)
        self.present(alert, animated: true, completion: nil)

    }
    
    @IBAction func onNewChat(_ sender: Any) {
      
        let storyboard:UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let newChatVC:NewMessageViewController = storyboard.instantiateViewController(withIdentifier: "NewMessageViewController") as! NewMessageViewController
        newChatVC.chatListVC = self
        
        let navVC = UINavigationController(rootViewController: newChatVC)
        present(navVC, animated: true, completion: nil)
        
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let message = messages[indexPath.row]
        
        guard let chatPartnerId = message.chatpatnerId() else {
            return
        }
        
        let ref = FIRDatabase.database().reference().child("users").child(chatPartnerId)
        ref.observeSingleEvent(of: .value, with: { (snapshot) in
            
            guard let dictionary = snapshot.value as? [String:AnyObject] else{
                return
            }
            
            let user = User()
            user.id = snapshot.key
            user.setValuesForKeys(dictionary)
            
            let storyboard:UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
            let newChatVC:ChatVC = storyboard.instantiateViewController(withIdentifier: "ChatVC") as! ChatVC
            newChatVC.user = user
            newChatVC.hidesBottomBarWhenPushed = true
            self.navigationController?.pushViewController(newChatVC, animated: true)
            
        }) { (error) in
            
        }
        
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.messages.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell:ChatListTableViewCell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! ChatListTableViewCell
        
        let message = self.messages[indexPath.row]
        
        if let id = message.chatpatnerId() {
            
            let ref = FIRDatabase.database().reference().child("users").child(id)
            ref.observeSingleEvent(of: .value, with: { (snapshot) in
                
                if let dictionary = snapshot.value as? [String:AnyObject] {
                    cell.labName.text! = dictionary["name"] as! String
                    
                    if let profileImageUrl = dictionary["profileImageUrl"] as? String {
                        
                        cell.imgUserProfile.loadImageUsingCacheWithUrlString(urlString: profileImageUrl)
                        cell.imgUserProfile.layer.cornerRadius = cell.imgUserProfile.frame.size.width / 2
                    }

                }
            }, withCancel: { (error) in
                
                
            })
        }
        
        if let seconds = message.timestamp?.doubleValue {
            
            let timestamp = NSDate(timeIntervalSince1970: seconds)
            
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "hh:mm a"
            cell.labDate.text! = dateFormatter.string(from: timestamp as Date)
        }

        if let message = message.text {
            cell.labMessage.text! = message
            cell.constraintWidthCameraIcon.constant = 0.0
        }else{
            cell.labMessage.text! = "foto"
            cell.constraintWidthCameraIcon.constant = 20.0
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        
        let alert = UIAlertController(title: "ChatDemo", message: "¿Está seguro que desea eliminar esta conversación?", preferredStyle: .alert)
        
        let alertAction = UIAlertAction(title: "Eliminar", style: .destructive) { (UIAlertAction) in
            
            guard let uid = FIRAuth.auth()?.currentUser?.uid else {
                return
            }
            
            let message = self.messages[indexPath.row]
            
            if let chatPartnerId = message.chatpatnerId() {
                FIRDatabase.database().reference().child("user-messages").child(uid).child(chatPartnerId).removeValue(completionBlock: { (error, ref) in
                    
                    if error != nil {
                        
                        print("Failed to delete message: \(error)")
                        return
                    }
                    
                    self.dictionaryMessages.removeValue(forKey: chatPartnerId)
                    self.attemptReloadOfTable()

                })
            }

        }
        
        let cancelAction = UIAlertAction(title: "Cancelar", style: .cancel, handler: nil)
        
        alert.addAction(cancelAction)
        alert.addAction(alertAction)
        self.present(alert, animated: true, completion: nil)
        
    }
    
    func tableView(_ tableView: UITableView, titleForDeleteConfirmationButtonForRowAt indexPath: IndexPath) -> String? {
        return "Eliminar"
    }

}
