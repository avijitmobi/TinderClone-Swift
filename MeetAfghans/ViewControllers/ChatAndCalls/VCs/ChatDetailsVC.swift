//
//  ChatDetailsVC.swift
//  MeetAfghans
//
//  Created by Convergent Infoware on 25/12/20.
//  Copyright © 2020 Convergent Infoware. All rights reserved.
//

import UIKit
import TwilioChatClient

class ChatDetailsVC: UIViewController {

//    struct ChatMessage{
//        var to_message : String?
//        var from_message : String?
//        var from_image : String?
//        var to_image : String?
//        var from_id : String?
//        var to_id : String?
//    }
//
//
    @IBOutlet weak var tableView : UITableView!
    @IBOutlet weak var chatBottomConstraint : NSLayoutConstraint!
    @IBOutlet weak var txtMessageView : IQTextView!
    @IBOutlet weak var chatTextViewHeightConstraint : NSLayoutConstraint!
    
    lazy var backButton = UIBarButtonItem(image: CommonImage.back, style: .plain, target: self, action: #selector(btnBack))
    lazy var callButton = UIBarButtonItem(image: CommonImage.call, style: .plain, target: self, action: #selector(btnPhoneCall))
    lazy var videoButton = UIBarButtonItem(image: CommonImage.video, style: .plain, target: self, action: #selector(btnVideoCall))
    private var keyboardHeight : CGFloat = 360
    private let emojiPickerVC = EmojiPicker.viewController
    var name : String?
    var first_id : String?
    var second_id : String?
    var image : String?
    var unique_id : String?
    private var fromDateFormatter = DateFormatter()
    private var convertedDateFormatter = DateFormatter()
    // Convenience class to manage interactions with Twilio Chat
    var chatManager = TwilloChatManager()
    private var imagePicker : EasyImagePicker?
//    private var chatList = [ChatMessage]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        fromDateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ"
        convertedDateFormatter.dateFormat = "MMM d, h:mm a"
        chatManager.delegate = self
        imagePicker = EasyImagePicker(presentationController: self, delegate: self)
        self.setTitle(name ?? "No Name", andImage: (CommonUrl.profileImageURL)+(image ?? ""))
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(keyboardWillShow),
            name: UIResponder.keyboardWillShowNotification,
            object: nil
        )
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            self.tableView.scrollToBottom()
        }
        login()
        getChatHistory()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationItem.setLeftBarButton(backButton, animated: true)
        self.navigationItem.setRightBarButtonItems([videoButton,callButton], animated: true)
        self.navigationController?.navigationBar.barTintColor = UIColor.black
        self.navigationController?.navigationBar.tintColor = CommonColor.ButtonGradientFirst
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        manageTextView(with: self.txtMessageView)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        chatManager.shutdown()
    }
    
    private func getChatHistory(){
        APIReqeustManager.sharedInstance.serviceCall(param: nil, method: .post, loaderNeed: false, loadingButton: nil, needViewHideShowAfterLoading: nil, vc: self, url: CommonUrl.get_chat_list, isTokenNeeded: true, isErrorAlertNeeded: true, isSuccessAlertNeeded: false, actionErrorOrSuccess: nil, fromLoginPageCallBack: nil) { (resp) in
            let chat = ChatDetailsModel(dictionary: resp.dict as NSDictionary? ?? NSDictionary())
//            self.chatManager.messages = []
//            (chat?.result?.chat_list ?? [Chat_details_model]()).forEach { (data) in
//                let message = TCHMessage()
//                message.attributes()
//            }
            self.tableView.reloadData()
            self.scrollToBottomMessage()
        }
    }
    
    // MARK: Login
    
    func login() {
        chatManager.uniqueChannelName = unique_id ?? "chat_room"
        chatManager.login(first_id == CommonUserDefaults.accessInstance.get(forType: .userID) ? (first_id ?? "") : (second_id ?? "")) { (success) in
            DispatchQueue.main.async {
                if success {
                    //self.navigationItem.prompt = "Logged in as \"\(self.identity)\""
                } else {
//                    self.navigationItem.prompt = "Unable to login"
                    let msg = "Unable to login"
                    self.displayErrorMessage(msg)
                }
            }
        }
    }
    
    // MARK: UI Logic
    
    private func scrollToBottomMessage() {
        if chatManager.messages.count == 0 {
            return
        }
        let bottomMessageIndex = IndexPath(row: chatManager.messages.count - 1,
                                           section: 0)
        tableView.scrollToRow(at: bottomMessageIndex, at: .bottom, animated: true)
    }
    
    private func displayErrorMessage(_ errorMessage: String) {
        let alertController = UIAlertController(title: "Error",
                                                message: errorMessage,
                                                preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
        alertController.addAction(okAction)
        present(alertController, animated: true, completion: nil)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
    }
    
    func setTitle(_ title: String, andImage imageUrl : String) {
        DispatchQueue.main.async {
            if self.navigationItem.titleView != nil {return}
            let titleLbl = UILabel()
            titleLbl.text = title
            titleLbl.textColor = UIColor.white
            titleLbl.font = UIFont(name: "Roboto-Medium", size: 16) ?? UIFont.systemFont(ofSize: 16)
            let imageView = UIImageViewX(image: CommonImage.logoImage)
            imageView.getImage(withUrl: imageUrl, placeHolder: CommonImage.logoImage)
            imageView.translatesAutoresizingMaskIntoConstraints = false
            imageView.widthAnchor.constraint(equalToConstant: 30).isActive = true
            imageView.heightAnchor.constraint(equalToConstant: 30).isActive = true
            imageView.clipsToBounds = true
            imageView.contentMode = .scaleAspectFill
            imageView.cornerRadius = 15
            let titleView = UIStackView(arrangedSubviews: [imageView, titleLbl])
            titleView.axis = .horizontal
            titleView.spacing = 10.0
            let contentView = UIView()
            contentView.autoresizingMask = .flexibleWidth
            self.navigationItem.titleView = contentView
            self.navigationItem.titleView?.addSubview(titleView)
            titleView.translatesAutoresizingMaskIntoConstraints = false
            titleView.centerXAnchor.constraint(equalTo: contentView.centerXAnchor).isActive = true
            titleView.heightAnchor.constraint(equalToConstant: 30).isActive = true
            titleView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor,constant: 2).isActive = true
        }
    }
    
    @IBAction func btnPhotoVideoPicker(_ from : UIButton){
        showTwoButtonAlertWithTwoAction(title: "Choose Prefereable Option", buttonTitleLeft: "Choose Image", buttonTitleRight: "Choose Video") {
            self.imagePicker?.present(from: from, mediaType: .images, onViewController: self)
        } completionHandlerRight: {
            self.imagePicker?.present(from: from, mediaType: .video, onViewController: self)
        }
    }
    
    @IBAction func btnSendMessage(_ from : UIButton){
        guard let message = txtMessageView.text, message.trim() != "" else {return}
        self.txtMessageView.text = ""
        let param = ["to_id" : first_id == CommonUserDefaults.accessInstance.get(forType: .userID) ? (second_id ?? "") : (first_id ?? ""),
                     "message" : message]
        chatManager.sendMessage(message,param: param,from: self, completion: { (result, _) in
            if result.isSuccessful() {
                self.manageTextView(with: self.txtMessageView)
            } else {
                self.displayErrorMessage("Unable to send message")
            }
        })
    }
    
    @IBAction func btnEmojiPicker(_ from : UIButton){
        txtMessageView.resignFirstResponder()
        emojiPickerVC.sourceRect = from.frame
        emojiPickerVC.delegate = self
        emojiPickerVC.sourceView = from
        emojiPickerVC.size = CGSize(width: self.view.frame.width * 0.7, height: self.view.frame.height * 0.4)
        present(emojiPickerVC, animated: true, completion: nil)
    }
    
    @objc
    func keyboardWillShow(_ notification: Notification) {
        if let keyboardFrame: NSValue = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue {
            let keyboardHeight = keyboardFrame.cgRectValue.height
            if #available(iOS 11.0, *) {
                self.keyboardHeight = keyboardHeight - self.view.safeAreaInsets.bottom
            } else {
                self.keyboardHeight = keyboardHeight
            }
        }
    }
    
    @objc
    private func btnBack(_ from : UIBarButtonItem){
        self.navigationController?.dismiss(animated: true, completion: {
            
        })
    }
    
    @objc
    private func btnPhoneCall(_ from : UIBarButtonItem){
        let vc = Helper.getVcObject(vcName: .AudioVideoCallVC, StoryBoardName: .Chat) as! AudioVideoCallVC
        vc.toUserID = first_id == CommonUserDefaults.accessInstance.get(forType: .userID) ? (second_id ?? "") : (first_id ?? "")
        vc.toUserName = name ?? "No Name"
        vc.callerImage = image ?? ""
        vc.unique_room = unique_id ?? "justafghan_room1"
        vc.isVideoCall = false
        navigationController?.pushViewController(vc, animated: true)
    }
    
    @objc
    private func btnVideoCall(_ from : UIBarButtonItem){
        let vc = Helper.getVcObject(vcName: .AudioVideoCallVC, StoryBoardName: .Chat) as! AudioVideoCallVC
        vc.toUserID = first_id == CommonUserDefaults.accessInstance.get(forType: .userID) ? (second_id ?? "") : (first_id ?? "")
        vc.toUserName = name ?? "No Name"
        vc.callerImage = image ?? ""
        vc.unique_room = unique_id ?? "justafghan_room1"
        vc.isVideoCall = true
        navigationController?.pushViewController(vc, animated: true)
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }

}

//EmojiPickerView Delegate Protocol

extension ChatDetailsVC : EmojiPickerViewControllerDelegate, EasyImagePickerDelegate{
    
    func emojiPickerViewController(_ controller: EmojiPickerViewController, didSelect emoji: String) {
        txtMessageView.text += emoji
    }
    
    func didSelect(image: UIImage?, video: URL?, fileName: String?) {
        if let img = image{
            if let data = img.pngData(){
                let param = ["to_id" : first_id == CommonUserDefaults.accessInstance.get(forType: .userID) ? (second_id ?? "") : (first_id ?? ""),
                             "message" : ""]
                chatManager.sendFile(with: data, param: param, on: self) { (result, _) in
                    if !result.isSuccessful() {
                        self.displayErrorMessage("Unable to send message")
                    }
                }
            }
        }else if let url = video{
            if let data = try? Data.init(contentsOf: url){
                let param = ["to_id" : first_id == CommonUserDefaults.accessInstance.get(forType: .userID) ? (second_id ?? "") : (first_id ?? ""),
                             "message" : ""]
                chatManager.sendFile(with: data, param: param, on: self) { (result, _) in
                    if !result.isSuccessful() {
                        self.displayErrorMessage("Unable to send message")
                    }
                }
            }
        }
    }
    
}


// MARK: TwilloChatManagerDelegate
extension ChatDetailsVC: TwilloChatManagerDelegate {
    
    func reloadMessages() {
        self.tableView.reloadData()
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            self.tableView.scrollToBottom()
        }
    }
    
    // Scroll to bottom of table view for messages
    func receivedNewMessage() {
        scrollToBottomMessage()
    }
}


//Text View Delegate

extension ChatDetailsVC : UITextViewDelegate{
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        chatBottomConstraint.constant = keyboardHeight
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            self.tableView.scrollToBottom()
        }
        UIView.animate(withDuration: 0.3) {
            self.view.layoutIfNeeded()
        }
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        chatBottomConstraint.constant = 0
        UIView.animate(withDuration: 0.3) {
            self.view.layoutIfNeeded()
        }
    }
    
    func textViewDidChange(_ textView: UITextView) {
        manageTextView(with: textView)
    }
    
    private func manageTextView(with textView: UITextView){
        let sizeToFitIn = CGSize(width: textView.bounds.size.width, height: CGFloat(MAXFLOAT))
        let newSize = textView.sizeThatFits(sizeToFitIn)
        if textView.numberOfLines() <= 5{
            textView.isScrollEnabled = false
            chatTextViewHeightConstraint.constant = newSize.height + 5
        }else{
            textView.isScrollEnabled = true
        }
    }
    
}

// Table View Protocols

extension ChatDetailsVC : UITableViewDelegate, UITableViewDataSource{
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return chatManager.messages.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let message = chatManager.messages[indexPath.row]
        if message.author == identity{
            let cell = tableView.dequeueReusableCell(withIdentifier: "FromUserTableCell", for: indexPath) as! FromUserTableCell
            if let date = message.dateCreated{
                if let cdate = fromDateFormatter.date(from: date){
                    cell.lblTime.text = convertedDateFormatter.string(from: cdate)
                }
            }
            if message.hasMedia() {
                message.getMediaContentTemporaryUrl { (result, mediaContentUrl) in
                    guard let mediaContentUrl = mediaContentUrl else {
                        return
                    }
                    cell.imgItems.getImage(withUrl: mediaContentUrl, placeHolder: CommonImage.placeholder)
                }
                cell.widthOfImageView.constant = 150
                cell.lblMessage.text = ""
            }else{
                cell.widthOfImageView.constant = 0
                cell.lblMessage.text = message.body
            }
            return cell
        }else{
            let cell = tableView.dequeueReusableCell(withIdentifier: "ToUserTableCell", for: indexPath) as! ToUserTableCell
            if let date = message.dateCreated{
                if let cdate = fromDateFormatter.date(from: date){
                    cell.lblTime.text = convertedDateFormatter.string(from: cdate)
                }
            }
            if message.hasMedia() {
                message.getMediaContentTemporaryUrl { (result, mediaContentUrl) in
                    guard let mediaContentUrl = mediaContentUrl else {
                        return
                    }
                    cell.imgItems.getImage(withUrl: mediaContentUrl, placeHolder: CommonImage.placeholder)
                }
                cell.widthOfImageView.constant = 150
                cell.lblMessage.text = ""
            }else{
                cell.widthOfImageView.constant = 0
                cell.lblMessage.text = message.body
            }
            return cell
        }
    }
}


//From User Table Cell

class FromUserTableCell : UITableViewCell{
    
    @IBOutlet weak var lblMessage : UILabel!
    @IBOutlet weak var lblTime : UILabel!
    @IBOutlet weak var imgItems : UIImageViewX!
    @IBOutlet weak var btnForItems: UIButton!
    @IBOutlet weak var widthOfImageView: NSLayoutConstraint!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
    }
    
}

//To User Table Cell

class ToUserTableCell : UITableViewCell{
    
    @IBOutlet weak var lblMessage : UILabel!
    @IBOutlet weak var lblTime : UILabel!
    @IBOutlet weak var imgItems : UIImageViewX!
    @IBOutlet weak var btnForItems: UIButton!
    @IBOutlet weak var widthOfImageView: NSLayoutConstraint!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
    }
    
}

