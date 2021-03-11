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
    
    var myBubble = JSQMessagesBubbleImageFactory()?.outgoingMessagesBubbleImage(with: .systemOrange)
    var otherBubble = JSQMessagesBubbleImageFactory()?.outgoingMessagesBubbleImage(with: .lightGray)
    
    

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationItem.leftBarButtonItems = [UIBarButtonItem(image: #imageLiteral(resourceName: "Back"), style: .plain, target: self, action: #selector(tapBackButton))]
        
        collectionView.collectionViewLayout.incomingAvatarViewSize = CGSize.zero
        collectionView.collectionViewLayout.outgoingAvatarViewSize = CGSize.zero


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
    
    @objc func tapBackButton() {
        
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
