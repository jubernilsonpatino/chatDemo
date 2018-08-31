//
//  ChatVC.swift
//  chatDemo
//
//  Created by Sundevs on 11/11/16.
//  Copyright © 2016 Sundevs. All rights reserved.
//

import UIKit
import Firebase
import MobileCoreServices
import AVFoundation
import FirebaseMessaging

class ComposeView: UIView {
    override func didMoveToWindow() {
        super.didMoveToWindow()
        if #available(iOS 11.0, *) {
            if let window = window {
                bottomAnchor.constraintLessThanOrEqualToSystemSpacingBelow(window.safeAreaLayoutGuide.bottomAnchor, multiplier: 1.0).isActive = true
                self.layoutIfNeeded()
            }
        }
    }
    
}
class ChatVC: UIViewController,UITextFieldDelegate,UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout {

    @IBOutlet weak var constraintBottomCollectionView: NSLayoutConstraint!
   lazy var inputTextField:UITextField = {
        
        let textField = UITextField()
        textField.placeholder = "Escribe un mensaje..."
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.delegate = self
        return textField
        
    }()
    
    lazy var sendButton:UIButton = {
        let button = UIButton()
        button.setImage(#imageLiteral(resourceName: "icon_send"), for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.isUserInteractionEnabled = false
        button.addTarget(self, action: #selector(handleSend) , for: .touchUpInside)
        return button
    }()
    
    lazy var inputContainerView: UIView = {
        var containerView = ComposeView(frame: CGRect(x: 0, y: 0, width: self.view.frame.width, height: 50))
        containerView.backgroundColor = UIColor.white
        
        let uploadImageView = UIImageView()
        uploadImageView.image = #imageLiteral(resourceName: "Picture")
        uploadImageView.isUserInteractionEnabled = true
        uploadImageView.contentMode = .scaleAspectFit
        uploadImageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.handleUploadTap)))
        uploadImageView.translatesAutoresizingMaskIntoConstraints = false
        containerView.addSubview(uploadImageView)
        
        uploadImageView.leftAnchor.constraint(equalTo: containerView.leftAnchor, constant:8).isActive = true
        uploadImageView.centerYAnchor.constraint(equalTo: containerView.centerYAnchor).isActive = true
        uploadImageView.widthAnchor.constraint(equalToConstant: 30).isActive = true
        uploadImageView.heightAnchor.constraint(equalToConstant: 30).isActive = true

        containerView.addSubview(self.sendButton)
        
        self.sendButton.rightAnchor.constraint(equalTo: containerView.rightAnchor, constant: -8).isActive = true
        self.sendButton.centerYAnchor.constraint(equalTo: containerView.centerYAnchor).isActive = true
        self.sendButton.widthAnchor.constraint(equalToConstant: 30).isActive = true
        self.sendButton.heightAnchor.constraint(equalToConstant: 30).isActive = true
        
        
        containerView.addSubview(self.inputTextField)
        
        self.inputTextField.leftAnchor.constraint(equalTo: uploadImageView.rightAnchor, constant: 8).isActive = true
        self.inputTextField.centerYAnchor.constraint(equalTo: containerView.centerYAnchor).isActive = true
        self.inputTextField.rightAnchor.constraint(equalTo: self.sendButton.leftAnchor).isActive = true
        self.inputTextField.heightAnchor.constraint(equalTo: containerView.heightAnchor).isActive = true

        let separatorLineView = UIView()
        separatorLineView.backgroundColor = UIColor(red: 220/255, green: 220/255, blue: 220/255, alpha: 1.0)
        separatorLineView.translatesAutoresizingMaskIntoConstraints = false
        containerView.addSubview(separatorLineView)
        
        
        separatorLineView.leftAnchor.constraint(equalTo: containerView.leftAnchor).isActive = true
        separatorLineView.topAnchor.constraint(equalTo: containerView.topAnchor).isActive = true
        separatorLineView.widthAnchor.constraint(equalTo: containerView.widthAnchor).isActive = true
        separatorLineView.heightAnchor.constraint(equalToConstant: 1).isActive = true
        
        if #available(iOS 11.0, *) {
            // Running iOS 11 OR NEWER
            //containerView.bottomAnchor.constraint(equalTo: self.view.layoutMarginsGuide.bottomAnchor,constant: -8).isActive = true
        } else {
            // Earlier version of iOS
        }
        
        return containerView
    }()
    
    @IBOutlet weak var collectionViewChats: UICollectionView!
    
    var user:User?
    var messages = [Message]()
    var containerViewBottomAnchor: NSLayoutConstraint?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.title = user?.name!
        self.observeMessages()
        self.setupKeyboardObservers()
        
        collectionViewChats.contentInset = UIEdgeInsets(top: 8, left: 0, bottom: 58, right: 0)
        collectionViewChats.keyboardDismissMode = .interactive
        
        self.inputTextField.addTarget(self, action: #selector(textFieldDidChange(textField:)), for: UIControlEvents.editingChanged)
        
//        let backButton = UIBarButtonItem(title: "", style: .plain, target: navigationController, action: nil)
//        navigationItem.leftBarButtonItem = backButton
        
        self.view.layoutIfNeeded()
    }

    func textFieldDidChange(textField : UITextField){
        
        if (textField.text?.count)! > 0 {
            
            self.sendButton.setImage(#imageLiteral(resourceName: "icon_send_selected"), for: .normal)
            self.sendButton.isUserInteractionEnabled = true
        }else{
            self.sendButton.setImage(#imageLiteral(resourceName: "icon_send"), for: .normal)
            self.sendButton.isUserInteractionEnabled = false
        }
    }
    
    override var inputAccessoryView: UIView? {
        get {
            return inputContainerView
        }
    }
    
    override var canBecomeFirstResponder: Bool {
        self.hideKeyboard()
        return true
    }
    
    override var canResignFirstResponder: Bool {
        self.showKeyboard()
        return true
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        NotificationCenter.default.removeObserver(self)
    }
    
    func showKeyboard() {
        NotificationCenter.default.addObserver(self, selector: #selector(handleKeyboardWillShow(notification:)), name: .UIKeyboardWillShow, object: nil)
    }
    
    func hideKeyboard() {
       NotificationCenter.default.addObserver(self, selector: #selector(handleKeyboardWillHide(notification:)), name: .UIKeyboardWillHide, object: nil)
    }
    
    func setupKeyboardObservers() {
        
        NotificationCenter.default.addObserver(self, selector: #selector(handleKeyboardDidShow(notification:)), name: .UIKeyboardDidShow, object: nil)

    }
    
    func handleKeyboardDidShow(notification: NSNotification) {
        
        if messages.count > 0 {
            let indexPath = IndexPath(item: self.messages.count - 1, section: 0)
            self.collectionViewChats.scrollToItem(at: indexPath, at: .top, animated: true)
        }
    }
    
    func handleKeyboardWillShow(notification: NSNotification) {
        let keyboardFrame = (notification.userInfo?[UIKeyboardFrameEndUserInfoKey] as AnyObject).cgRectValue
        let keyboardDuration = (notification.userInfo?[UIKeyboardAnimationDurationUserInfoKey] as AnyObject).doubleValue

        constraintBottomCollectionView.constant = keyboardFrame!.height
        //self.inputContainerView.frame = CGRect(x: 0, y: self.view.frame.height - 44 - keyboardFrame!.height, width: self.view.frame.width, height: 50)
        
        UIView.animate(withDuration: keyboardDuration!) {
            self.view.layoutIfNeeded()
        }
    }
    
    func handleKeyboardWillHide(notification: NSNotification) {
        let keyboardDuration = (notification.userInfo?[UIKeyboardAnimationDurationUserInfoKey] as AnyObject).doubleValue

        constraintBottomCollectionView.constant = 0
        //self.inputContainerView.frame = CGRect(x: 0, y: self.view.frame.height - 108, width: self.view.frame.width, height: 50)
        UIView.animate(withDuration: keyboardDuration!) {
            self.view.layoutIfNeeded()
        }
    }
    
    func handleUploadTap () {
        
        self.inputTextField.resignFirstResponder()
        
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
    
    func observeMessages() {
        
        guard let uid = FIRAuth.auth()?.currentUser?.uid, let toId = user?.id else {
            return
        }
        
        let userMessageRef = FIRDatabase.database().reference().child("user-messages").child(uid).child(toId)
        userMessageRef.observe(.childAdded, with: { (snapshot) in
            
            let messageId = snapshot.key
            let messageRef = FIRDatabase.database().reference().child("messages").child(messageId)
            messageRef.observeSingleEvent(of: .value, with: { (snapshot) in
                
                guard let dictionary = snapshot.value as? [String:AnyObject] else{
                    return
                }
                
                let message = Message(dictionary: dictionary)
                self.messages.append(message)
                
                    self.collectionViewChats.reloadData()
                    
                    let indexPath = NSIndexPath(item: self.messages.count - 1, section: 0)
                    self.collectionViewChats.scrollToItem(at: indexPath as IndexPath, at: .bottom, animated: true)

            }, withCancel: nil)

            
        }, withCancel: nil)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.handleSend()
        return true
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.messages.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell:ChatMessageCollectionViewCell = collectionView.dequeueReusableCell(withReuseIdentifier: "Cell", for: indexPath) as! ChatMessageCollectionViewCell
        
        cell.chatVC = self
        let message = self.messages[indexPath.row]
        cell.message = message
        cell.textView.text = message.text
        
        setupCell(cell: cell, message: message)
        
        if let text = message.text {
            cell.bubbleWidthAnchor?.constant = estimateFrameForText(text: text).width + 32
            cell.textView.isHidden = false
        }else if message.imageUrl != nil {
            cell.bubbleWidthAnchor?.constant = 200
            cell.textView.isHidden = true
        }
        
        cell.playButton.isHidden = message.videoUrl == nil
        
        return cell
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        
        self.collectionViewChats.collectionViewLayout.invalidateLayout()
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        var height:CGFloat = 80
        let message = messages[indexPath.item]
        
        if let text = message.text {
            height = estimateFrameForText(text: text).height + 20
        }else if let imageWidth = message.imageWidth?.floatValue, let imageHeight = message.imageHeight?.floatValue{
            
            height = CGFloat(imageHeight / imageWidth * 200)
        }
        
        let width = UIScreen.main.bounds.width
        
        return CGSize(width: width, height: height)
    }
    
    private func setupCell(cell:ChatMessageCollectionViewCell, message:Message) {
        
        if let profileImageUrl = self.user?.profileImageUrl {
            cell.profileImageView.loadImageUsingCacheWithUrlString(urlString: profileImageUrl)
        }
        
        if message.fromId == FIRAuth.auth()?.currentUser?.uid {
            cell.bubbleView.backgroundColor = ChatMessageCollectionViewCell.blueColor
            cell.textView.textColor = UIColor.white
            cell.bubbleViewRightAnchor?.isActive = true
            cell.bubbleViewLeftAnchor?.isActive = false
            cell.profileImageView.isHidden = true
        }else{
            
            cell.bubbleView.backgroundColor = UIColor(red: 240/255, green: 240/255, blue: 240/255, alpha: 1.0)
            cell.textView.textColor = UIColor.black
            
            cell.bubbleViewRightAnchor?.isActive = false
            cell.bubbleViewLeftAnchor?.isActive = true
            cell.profileImageView.isHidden = false
        }
        
        if let messageImageUrl = message.imageUrl {
            cell.messageImageView.loadImageUsingCacheWithUrlString(urlString: messageImageUrl)
            cell.messageImageView.isHidden = false
            cell.bubbleView.backgroundColor = UIColor.clear
        }else{
            cell.messageImageView.isHidden = true
        }
        
    }
    
    func estimateFrameForText(text: String) -> CGRect {
        
        let size = CGSize(width: 200, height: 1000)
        let options = NSStringDrawingOptions.usesFontLeading.union(.usesLineFragmentOrigin)
        return NSString(string: text).boundingRect(with: size, options: options, attributes: [NSFontAttributeName: UIFont.boldSystemFont(ofSize: 16)] , context: nil)
    }
    
    // MARK: - UIImagePickerControllerDelegate
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion:nil)
        
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
        
        if let videoUrl = info[UIImagePickerControllerMediaURL] as? URL {
            
            self.handleVideoSelectedForUrl(url: videoUrl)
            
        }else{
            
            handleImageSelectedForInfo(info: info, picker: picker)
        }

        dismiss(animated: true, completion: nil)
        
    }
    
    private func handleVideoSelectedForUrl(url: URL) {
        
        let fileName = NSUUID().uuidString + ".mov"
        let uploadTask = FIRStorage.storage().reference().child("message-movies").child(fileName).putFile(url, metadata: nil, completion: { (metadata, error) in
            
            if error != nil {
                print("failed upload of video:\(error)")
                return
            }
            
            if let videoUrl = metadata?.downloadURL()?.absoluteString {
                if let thumbnailImage = self.thumbnailImageForVideoUrl(fileUrl: url) {
                    
                    self.uploadToFirebaseStorageUsingImage(image: thumbnailImage, completion: { (imageUrl) in
                        
                        let properties:[String:AnyObject] = ["imageUrl":imageUrl as AnyObject,"imageWidth":thumbnailImage.size.width as AnyObject,"imageHeight":thumbnailImage.size.height as AnyObject,"videoUrl":videoUrl as AnyObject]
                        self.sendMessageWithProperties(properties: properties)
                    })
                    
                }
                
            }
        })
        
        uploadTask.observe(.progress) { (snapshot) in
            if let completedUnitCount = snapshot.progress?.completedUnitCount {
             self.navigationItem.title = String(completedUnitCount)
            }
        }
    
        uploadTask.observe(.success) { (snapshot) in
            self.navigationItem.title = self.user?.name
        }
    }
    
    func thumbnailImageForVideoUrl(fileUrl: URL) -> UIImage? {
        let asset = AVAsset(url: fileUrl)
        let imageGenerator = AVAssetImageGenerator(asset: asset)
        
        do {
            let thumbnailCGImage = try imageGenerator.copyCGImage(at: CMTime(value: 1, timescale: 60), actualTime: nil)
            return UIImage(cgImage: thumbnailCGImage)
            
        } catch let error {
            print("error = \(error)")
        }
        
        return nil
    }
    
    func handleImageSelectedForInfo(info:[String:AnyObject], picker: UIImagePickerController) {
        
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
        
        uploadToFirebaseStorageUsingImage(image: newImage) { (imageUrl) in
            self.uploadMessageWithImageUrl(imageUrl: imageUrl, image: newImage)

        }
    }

    private func uploadToFirebaseStorageUsingImage(image: UIImage, completion: @escaping (_ imageUrl:String) -> ()) {
        let imageName = NSUUID().uuidString
        let ref = FIRStorage.storage().reference().child("messages_images").child(imageName)
        
        let metadata = FIRStorageMetadata()
        metadata.contentType = "image/jpeg"
        
        if let uploadData = UIImageJPEGRepresentation(image, 0.1) {
            ref.put(uploadData, metadata: metadata, completion: { (metadata, error) in
                
                if error != nil {
                    print("failed to upload image:\(error)")
                    return
                }
                
                if let imageUrl = metadata?.downloadURL()?.absoluteString {
                    completion(imageUrl)
                    //self.uploadMessageWithImageUrl(imageUrl: imageUrl, image: image)
                }
                
            })
        }
    }
    
    func handleSend() {
        
        let properties = ["text":inputTextField.text!] as [String : Any]
        sendMessageWithProperties(properties: properties as [String : AnyObject])
        
    }
    
    private func uploadMessageWithImageUrl(imageUrl: String, image: UIImage) {

        let properties = ["imageUrl":imageUrl,"imageWidth":image.size.width,"imageHeight":image.size.height] as [String : Any]
        
        self.sendMessageWithProperties(properties: properties as [String : AnyObject])

    }
    
    private func sendMessageWithProperties(properties:[String:AnyObject]) {
        
        let ref = FIRDatabase.database().reference().child("messages")
        let childRef = ref.childByAutoId()
        
        let toId = user!.id!
        let fromId = FIRAuth.auth()!.currentUser!.uid
        let timestamp = Int(NSDate().timeIntervalSince1970)
        
        var values = ["toId":toId,"fromId":fromId,"timestamp":timestamp] as [String : Any]
        
        properties.forEach({values[$0] = $1})
        
        childRef.updateChildValues(values) { (error, ref) in
            
            if error != nil {
                
                print("error = \(error)")
                return
            }
            
            FIRDatabase.database().reference().child("users").child(fromId).observeSingleEvent(of: .value, with: { (snapshot) in
                
                if let dictionary = snapshot.value as? [String:AnyObject] {

                    let name = dictionary["name"] as! String
                    let message = "\(name): \(self.inputTextField.text!)"
                    
                    self.inputTextField.text = ""
                    self.sendButton.setImage(#imageLiteral(resourceName: "icon_send"), for: .normal)
                    self.sendButton.isUserInteractionEnabled = false
                    let userMessageRef = FIRDatabase.database().reference().child("user-messages").child(fromId).child(toId)
                    
                    let messageId = childRef.key
                    userMessageRef.updateChildValues([messageId:1])
                    
                    let recipientUserMessageRef = FIRDatabase.database().reference().child("user-messages").child(toId).child(fromId)
                    recipientUserMessageRef.updateChildValues([messageId:1])
//                    
//                    var request = URLRequest(url: URL(string: "https://fcm.googleapis.com/fcm/send")!)
//                    request.httpMethod = "POST"
//                    request.setValue("application/json", forHTTPHeaderField: "Content-Type")
//                    request.setValue("key=AAAA8czkZgE:APA91bE4RmqF64k74CHxfjOlWhMDZfonnl3uMpzUfgWVVIGFIf56mOQvNcJTZh6MByUrDnuJaQRYpesUSh1zrfa6iaTYSCZQGO1ieNXTUBdGQTJFyVKJ11umpGV6MYuKsmpJyhmCV9R2751wf0RIGM_Ip8iGkyNSbQ", forHTTPHeaderField: "Authorization")
//                    let json = [
//                        "to" : self.user!.token!,
//                        "priority" : "high",
//                        "notification" : [
//                            "body" : message
//                        ]
//                        ] as [String : Any]
//                    do {
//                        let jsonData = try JSONSerialization.data(withJSONObject: json, options: .prettyPrinted)
//                        request.httpBody = jsonData
//                        let task = URLSession.shared.dataTask(with: request) { data, response, error in
//                            guard let data = data, error == nil else {
//                                print("Error=\(error)")
//                                return
//                            }
//                            
//                            if let httpStatus = response as? HTTPURLResponse, httpStatus.statusCode != 200 {
//                                // check for http errors
//                                print("Status Code should be 200, but is \(httpStatus.statusCode)")
//                                print("Response = \(response)")
//                                
//                            }
//                            
//                            let responseString = String(data: data, encoding: .utf8)
//                            print("responseString = \(responseString)")
//                            
//                        }
//                        task.resume()
//                    }
//                    catch {
//                        print(error)
//                    }

                    print(dictionary["name"] as! String)
                }
                
            }, withCancel: nil)

    
        }
    }
    
    // custom zooming logic
    
    var startingFrame:CGRect?
    var blackBackgroundView:UIView?
    var startingImageView: UIImageView?
    
    func performZoomInForStartingImageView(startingImageView: UIImageView) {
        
        self.startingImageView = startingImageView
        self.startingImageView?.isHidden = true
        print("touch image")
        
        startingFrame = startingImageView.superview?.convert(startingImageView.frame, to: nil)
        let zoomingImageView = UIImageView(frame: startingFrame!)
        zoomingImageView.backgroundColor = UIColor.red
        zoomingImageView.image = startingImageView.image
        zoomingImageView.isUserInteractionEnabled = true
        zoomingImageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleZoomOut(tapGesture:))))
        
        if let keyWindow = UIApplication.shared.keyWindow {
            blackBackgroundView = UIView(frame: keyWindow.frame)
            blackBackgroundView?.backgroundColor = UIColor.black
            blackBackgroundView?.alpha = 0
            keyWindow.addSubview(blackBackgroundView!)
            keyWindow.addSubview(zoomingImageView)
            
            UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .curveEaseOut, animations: {
                
                self.blackBackgroundView?.alpha = 1
                self.inputContainerView.alpha = 0
                
                let height = self.startingFrame!.height / self.startingFrame!.width * keyWindow.frame.width
                
                zoomingImageView.frame = CGRect(x: 0, y: 0, width: keyWindow.frame.width, height: height)
                zoomingImageView.center = keyWindow.center
                
            }, completion: { (completed) in
                
            })
        }
    }
    
    func handleZoomOut(tapGesture:UITapGestureRecognizer) {
        if let zoomOutImageView = tapGesture.view {
            
            zoomOutImageView.layer.cornerRadius = 16
            zoomOutImageView.clipsToBounds = true
            
            UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .curveEaseOut, animations: { 
                zoomOutImageView.frame = self.startingFrame!
                self.blackBackgroundView?.alpha = 0
                self.inputContainerView.alpha = 1
            }, completion: { (completed) in
                zoomOutImageView.removeFromSuperview()
                self.startingImageView?.isHidden = false

            })

        }
    }
    
    func sendDataMessageFailure(notification:Notification) {
        
        print("error = \(notification)")
    }
    
    func sendDataMessageSuccess(notification:Notification) {
        
        print("success = \(notification)")
    }
}
