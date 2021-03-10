//
//  RecentChatTableViewCell.swift
//  ChatAppExample
//
//  Created by Fomagran on 2021/03/10.
//

import UIKit

protocol RecentChatTableViewCellDelegate {
    func didTapProfile(indexPath:IndexPath)
}

class RecentChatTableViewCell: UITableViewCell {

    @IBOutlet weak var messageView: UIView!
    @IBOutlet weak var messageNumber: UILabel!
    @IBOutlet weak var date: UILabel!
    @IBOutlet weak var recentChat: UILabel!
    @IBOutlet weak var name: UILabel!
    @IBOutlet weak var profile: UIImageView!
    
    var indexPath:IndexPath!
    
    let tap = UITapGestureRecognizer()
    var delegate:RecentChatTableViewCellDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        messageView.layer.cornerRadius = messageView.frame.width/2
        tap.addTarget(self, action: #selector(self.tapProfile))
        profile.isUserInteractionEnabled = true
        profile.addGestureRecognizer(tap)

        
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

    }
    
    func generateCell(recentChat:NSDictionary,indexPath:IndexPath) {
        self.indexPath = indexPath
        self.name.text = recentChat[kWITHUSERFULLNAME] as? String
        self.recentChat.text = recentChat[kLASTMESSAGE] as? String
        self.messageNumber.text = recentChat[kCOUNTER] as? String
        
        if let avatarString = recentChat[kAVATAR] {
            imageFromData(pictureData: avatarString as! String) { (image) in
                if image != nil {
                    self.profile.image = image!.circleMasked
                }
                
            }
        }
        
        if recentChat[kCOUNTER] as! Int != 0 {
            self.messageNumber.text = "\(recentChat[kCOUNTER] as! Int)"
            self.messageView.isHidden = false
            self.messageNumber.isHidden = false
        }else{
            self.messageView.isHidden = true
            self.messageNumber.isHidden = true
        }
        
        var date:Date!
        
        if let created = recentChat[kDATE] as? String {
            if (created).count != 14 {
                date = Date()
            }else{
                date = dateFormatter().date(from: created)
            }
        }else{
            date = Date()
        }
        
        //timeElapsed 얼마나 됐는지 시간 계산해서 보여줌
        self.date.text = timeElapsed(date: date)
    }
    
    @objc func tapProfile() {
     
        delegate?.didTapProfile(indexPath: indexPath)
    }

}
