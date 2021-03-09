//
//  UserTableViewCell.swift
//  ChatAppExample
//
//  Created by Fomagran on 2021/03/09.
//

import UIKit

class UserTableViewCell: UITableViewCell {

    @IBOutlet weak var fullname: UILabel!
    @IBOutlet weak var avatar: UIImageView!
    
    var indexpath:IndexPath!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        
    }
    
    func generateCellWith(fUser:FUser,indexPath:IndexPath) {
        
        self.indexpath = indexPath
        
        self.fullname.text = fUser.fullname
        
        if fUser.avatar != "" {
            imageFromData(imageData: fUser.avatar) { (image) in
                if image != nil {
                    self.avatar.image = image!.circleMasked
                }
            }
        }
        
    }

}
