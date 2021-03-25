//
//  CallTableViewCell.swift
//  ChatAppExample
//
//  Created by Fomagran on 2021/03/24.
//

import UIKit

class CallTableViewCell: UITableViewCell {

    @IBOutlet weak var status: UILabel!
    @IBOutlet weak var name: UILabel!
    @IBOutlet weak var profile: UIImageView!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func generateCell(call:Call) {
        status.text = ""
        
        if call.callerId == FUser.currentId() {
            status.text = "Outgoing"
            name.text = call.withUserFullName
            profile.image = #imageLiteral(resourceName: "avatarPlaceholder")
        }else {
            status.text = "Incoming"
            name.text = call.callerFullName
            profile.image = #imageLiteral(resourceName: "avatarPlaceholder")
        }
    }

}
