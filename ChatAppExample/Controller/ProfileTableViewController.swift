//
//  ProfileTableViewController.swift
//  ChatAppExample
//
//  Created by Fomagran on 2021/03/09.
//

import UIKit

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
    }
    @IBAction func tapMessageButton(_ sender: Any) {
    }
    @IBAction func tapCallButton(_ sender: Any) {
    }
    
    func setUI() {
        if user != nil {
            self.title  = "Profile"
            fullNameLabel.text = user!.fullname
            phoneNumberLabel.text = user!.phoneNumber
            updateBlockStatus()
            imageFromData(imageData: user!.avatar) { (image) in
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
