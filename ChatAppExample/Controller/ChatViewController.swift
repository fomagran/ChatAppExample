//
//  ChatViewController.swift
//  ChatAppExample
//
//  Created by Fomagran on 2021/03/11.
//

import UIKit
import JSQMessagesViewController
import ProgressHUD
import IQAudioRecorderController
import IDMPhotoBrowser
import AVFoundation
import AVKit
import FirebaseFirestore

class ChatViewController: JSQMessagesViewController {
    
    var chatRoomId:String!
    var memberIds:[String]!
    var membersToPush:[String]!
    var titleName:String!
    
    let legitTypes = [kAUDIO,kVIDEO,kTEXT,kLOCATION,kPICTURE]
    
    var maxMessageNumber = 0
    var minMessageNumber = 0
    var loadOld = false
    var loadedMessagesCount = 0
    
    var messages:[JSQMessage] = []
    var objectMessages:[NSDictionary] = []
    var loadedMessages:[NSDictionary] = []
    var allPicturesMessages:[String] = []
    var initialLoadComplete = false
    
    var myBubble = JSQMessagesBubbleImageFactory()?.outgoingMessagesBubbleImage(with: .systemOrange)
    var otherBubble = JSQMessagesBubbleImageFactory()?.outgoingMessagesBubbleImage(with: .lightGray)
    
    

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationItem.leftBarButtonItems = [UIBarButtonItem(image: #imageLiteral(resourceName: "Back"), style: .plain, target: self, action: #selector(tapBackButton))]
        
        collectionView.collectionViewLayout.incomingAvatarViewSize = CGSize.zero
        collectionView.collectionViewLayout.outgoingAvatarViewSize = CGSize.zero

        loadMessages()
        self.senderId = FUser.currentId()
        self.senderDisplayName = FUser.currentUser()!.firstname
        
        //노치없는 아이폰을 위한 바텀 세팅
        let constraint = perform(Selector(("toolbarBottomLayoutGuide")))?.takeUnretainedValue() as! NSLayoutConstraint
        
        constraint.priority = UILayoutPriority(rawValue: 1000)
        
        self.inputToolbar.bottomAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.bottomAnchor).isActive = true
        
        inputToolbar.contentView.rightBarButtonItem.setImage(#imageLiteral(resourceName: "mic"), for: .normal)
        inputToolbar.contentView.rightBarButtonItem.setTitle("", for: .normal)
        
    }
    
    override func viewDidLayoutSubviews() {
        perform(Selector(("jsq_updateCollectionViewInsets")))
        
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = super.collectionView(collectionView,cellForItemAt: indexPath) as! JSQMessagesCollectionViewCell
        let data = messages[indexPath.row]
        
        if data.senderId == FUser.currentId() {
            cell.textView.textColor = .white
        }else {
            cell.textView.textColor = .black
        }
        return cell
    }
    
    override func collectionView(_ collectionView: JSQMessagesCollectionView!, messageDataForItemAt indexPath: IndexPath!) -> JSQMessageData! {
        
        return messages[indexPath.row]
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return messages.count
    }
    
    override func collectionView(_ collectionView: JSQMessagesCollectionView!, messageBubbleImageDataForItemAt indexPath: IndexPath!) -> JSQMessageBubbleImageDataSource! {
        let data = messages[indexPath.row]
        if data.senderId == FUser.currentId() {
            return myBubble
        }else {
            return otherBubble
        }
        
    }
    
    override func collectionView(_ collectionView: JSQMessagesCollectionView!, attributedTextForCellTopLabelAt indexPath: IndexPath!) -> NSAttributedString! {
        if indexPath.item%3 == 0 {
            let message = messages[indexPath.row]
            return JSQMessagesTimestampFormatter.shared()?.attributedTimestamp(for: message.date)
        }
        return nil
    }
    
    override func collectionView(_ collectionView: JSQMessagesCollectionView!, layout collectionViewLayout: JSQMessagesCollectionViewFlowLayout!, heightForCellTopLabelAt indexPath: IndexPath!) -> CGFloat {
        if indexPath.item%3 == 0 {
           
            return kJSQMessagesCollectionViewCellLabelHeightDefault
        }
        return 0.0
    }
    
    @objc func tapBackButton() {
        self.navigationController?.popViewController(animated: true)
    }
    
    func updateSendButton(isSend:Bool) {
        if isSend {
            inputToolbar.contentView.rightBarButtonItem.setImage(#imageLiteral(resourceName: "send"), for: .normal)
        }else{
        inputToolbar.contentView.rightBarButtonItem.setImage(#imageLiteral(resourceName: "mic"), for: .normal)
        }
    }
    
    
    func sendMessage(text:String?,date:Date,picture:UIImage?,location:String?,video:NSURL?,audio:String?) {
        var outgoingMessage:OutgoingMessage?
        let currentUser = FUser.currentUser()!
        
        if let text = text {
            outgoingMessage = OutgoingMessage(message: text, senderId: currentUser.objectId, senderName: currentUser.firstname, date: date, status: kDELETED, type: kTEXT)
        }
        
        JSQSystemSoundPlayer.jsq_playMessageSentSound()
        self.finishSendingMessage()
        
        outgoingMessage!.sendMessage(chatRoomID: chatRoomId , messageDictionary: outgoingMessage!.messageDictionary, memberIds: memberIds, membersToPush: membersToPush)
    }
    

    //클립모양버튼 눌렀을 때
    override func didPressAccessoryButton(_ sender: UIButton!) {
        let optionMenu = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        
        let photoOrVideo = UIAlertAction(title: "Camera", style: .default) { (action) in
            
        }
        
        let sharePhoto = UIAlertAction(title: "Photo Library", style: .default) { (action) in
    
        }
        
        let shareVideo = UIAlertAction(title: "Video Library", style: .default) { (action) in
            
        }
        
        let shareLocation = UIAlertAction(title: "Location Library", style: .default) { (action) in
            
        }
        
        let cancel = UIAlertAction(title: "Cancel", style: .cancel) { (action) in
            
        }
        
        photoOrVideo.setValue(UIImage(named: "camera"), forKey: "image")
        sharePhoto.setValue(UIImage(named: "picture"), forKey: "image")
        shareVideo.setValue(UIImage(named: "video"), forKey: "image")
        shareLocation.setValue(UIImage(named: "location"), forKey: "image")
        
        optionMenu.addAction(photoOrVideo)
        optionMenu.addAction(sharePhoto)
        optionMenu.addAction(shareVideo)
        optionMenu.addAction(shareLocation)
        optionMenu.addAction(cancel)
        
        self.present(optionMenu, animated: true, completion: nil)
        
   
        
    }
    
    //마이크버튼 눌렀을때
    override func didPressSend(_ button: UIButton!, withMessageText text: String!, senderId: String!, senderDisplayName: String!, date: Date!) {
        if text != "" {
            updateSendButton(isSend: false)
            sendMessage(text: text, date: date, picture: nil, location: nil, video: nil, audio: nil)
        }else {
            
        }
    }
    
    override func textViewDidChange(_ textView: UITextView) {
        if textView.text != "" {
            updateSendButton(isSend: true)
        }else{
            updateSendButton(isSend: false)
        }
    }
    
    func loadMessages() {
        reference(.Message).document(FUser.currentId()).collection(chatRoomId).order(by: kDATE,descending: true).limit(to: 11).getDocuments { (snapshot, error) in
            
            guard let snapshot = snapshot else { return  self.initialLoadComplete = true }
            let sorted = ((dictionaryFromSnapshots(snapshots: snapshot.documents)) as NSArray).sortedArray(using: [NSSortDescriptor(key: kDATE, ascending: true)]) as! [NSDictionary]
            self.loadedMessages = self.removeBadMessages(allMessages: sorted)
            self.insertMessages()
            self.finishReceivingMessage(animated: true)
            self.initialLoadComplete = true
            print(self.messages.count)
            
        }
    }
    func removeBadMessages(allMessages:[NSDictionary]) -> [NSDictionary] {
        
        var tempMessages = allMessages
        for message in tempMessages {
            if message[kTYPE] != nil {
                if !self.legitTypes.contains(message[kTYPE] as! String) {
                    tempMessages.remove(at: tempMessages.firstIndex(of: message)!)
                }
            }else {
                tempMessages.remove(at: tempMessages.firstIndex(of: message)!)
            }
        }
        return tempMessages
    }
    
    func insertMessages() {
        maxMessageNumber = loadedMessages.count - loadedMessagesCount
        minMessageNumber = maxMessageNumber - kNUMBEROFMESSAGES
        
        if minMessageNumber < 0 {
            minMessageNumber = 0
        }
    
        for i in minMessageNumber ..< maxMessageNumber {
            let messageDictionary = loadedMessages[i]
            insertInitialLoadMessages(messageDictionary: messageDictionary)
            loadedMessagesCount += 1
        }
        self.showLoadEarlierMessagesHeader = loadedMessagesCount != loadedMessages.count
        
    }
    
    func insertInitialLoadMessages(messageDictionary:NSDictionary) -> Bool {
        
        let incomingMessage = IncomingMessage(collectionView: self.collectionView!)

        if (messageDictionary[kSENDERID] as! String) != FUser.currentId() {
            
        }
        
        let message = incomingMessage.createMessage(messageDictionary: messageDictionary, chatRoomId: chatRoomId)

        if message != nil {
            objectMessages.append(messageDictionary)
            messages.append(message!)
        }
        
        return isIncoming(messageDictionary: messageDictionary)
    }
    
    func isIncoming(messageDictionary:NSDictionary) -> Bool {
        if FUser.currentId() == messageDictionary[kSENDERID] as! String {
            return false
        }else {
            return true
        }
    }

}

extension JSQMessagesInputToolbar {
    
    override open func didMoveToWindow() {
        
        super.didMoveToWindow()
        
        guard let window = window else { return }
        
        if #available(iOS 11.0, *) {
            
            let anchor = window.safeAreaLayoutGuide.bottomAnchor
            
            bottomAnchor.constraint(lessThanOrEqualToSystemSpacingBelow: anchor, multiplier: 1.0).isActive = true
            
        }
        
    }
    
}
