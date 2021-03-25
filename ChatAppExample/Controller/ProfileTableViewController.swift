//
//  ProfileTableViewController.swift
//  ChatAppExample
//
//  Created by Fomagran on 2021/03/09.
//

import UIKit
import ProgressHUD

class ProfileTableViewController: UITableViewController {

    @IBOutlet weak var blockButton: UIButton!
    @IBOutlet weak var messageButton: UIButton!
    @IBOutlet weak var callButton: UIButton!
    @IBOutlet weak var phoneNumberLabel: UILabel!
    @IBOutlet weak var fullNameLabel: UILabel!
    @IBOutlet weak var profileImage: UIImageView!
    
    var user:FUser?
    override func viewDidLoad() {
        super.viewDidLoad()

        setUI()
    }

    @IBAction func tapBlockButton(_ sender: Any) {
        var currentBlockedIds = FUser.currentUser()!.blockedUsers
        if currentBlockedIds.contains(user!.objectId) {
            let index = currentBlockedIds.firstIndex(of:user!.objectId)!
            currentBlockedIds.remove(at: index)
        }else{
            currentBlockedIds.append(user!.objectId)
        }
        
        updateCurrentUserInFirestore(withValues: [kBLOCKEDUSERID:currentBlockedIds]) { (error) in
            if error != nil {
                print(error?.localizedDescription)
                return
            }
            self.updateBlockStatus()
        }
        
        blockUser(userToBlock: user!)
    }
    @IBAction func tapMessageButton(_ sender: Any) {
        
        if !checkBlockedStatus(withUser: user!) {
            let chatVC = ChatViewController()
            chatVC.titleName = user!.firstname
            chatVC.membersToPush = [FUser.currentId(),user!.objectId]
            chatVC.memberIds = [FUser.currentId(),user!.objectId]
            chatVC.chatRoomId =  startPrivateChat(user1: FUser.currentUser()!, user2: user!)
            chatVC.isGroup = false
            chatVC.hidesBottomBarWhenPushed = true
            self.navigationController?.pushViewController(chatVC, animated: true)
       
        }else {
            ProgressHUD.showError("This user is not available for chat")
        }
    }
    @IBAction func tapCallButton(_ sender: Any) {
        
        let currentUser = FUser.currentUser()!
        
        let call = Call(_callerID: currentUser.objectId, _withUserId: user!.objectId, _callerFullName: currentUser.fullname, _withUserFullName: user!.fullname)
        call.saveCallInBackground()
        
    }
    
    func setUI() {
        if user != nil {
            self.title  = "Profile"
            fullNameLabel.text = user!.fullname
            phoneNumberLabel.text = user!.phoneNumber
            updateBlockStatus()
            imageFromData(pictureData: user!.avatar) { (image) in
                if image != nil {
                    self.profileImage.image = image!.circleMasked
                }
            }
        }
    }
    
    func updateBlockStatus() {
        if user!.objectId != FUser.currentId() {
            blockButton.isHidden  = false
            messageButton.isHidden = false
            callButton.isHidden = false
        }else{
            blockButton.isHidden  = true
            messageButton.isHidden = true
            callButton.isHidden = true
        }
        
        if FUser.currentUser()!.blockedUsers.contains(user!.objectId) {
            blockButton.setTitle("Unblock User", for: .normal)
        }else{
            blockButton.setTitle("Block User", for: .normal)
        }
    }
    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
       
        return 3
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
      
        return 1
    }

    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        ""
    }
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        return UIView()
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if section == 0 {
            return 0
        }
        return 30
    }

}
