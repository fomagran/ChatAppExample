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
