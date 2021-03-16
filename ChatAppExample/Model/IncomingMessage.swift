//
//  IncomingMessages.swift
//  ChatAppExample
//
//  Created by Fomagran on 2021/03/11.
//

import Foundation
import JSQMessagesViewController

class IncomingMessage {
    
    var collection:JSQMessagesCollectionView
    
    init(collectionView:JSQMessagesCollectionView) {
        collection = collectionView
    }
    
    func createMessage(messageDictionary:NSDictionary,chatRoomId:String) -> JSQMessage?{
        var message : JSQMessage?
        
        let type = messageDictionary[kTYPE] as! String
        
        switch type {
        case kTEXT:
         message = createTextMessage(messageDictionary: messageDictionary, chatRoomId: chatRoomId)
        case kPICTURE:
           message = createPictureMessage(messageDictionary: messageDictionary)
        case kVIDEO:
            print("text")
        case kAUDIO:
            print("text")
        case kLOCATION:
            print("text")
        default:
            print("Unknwon message type")
        }
        
        if message != nil {
            return message
        }
        
        return nil
    }
    
    func createTextMessage(messageDictionary:NSDictionary,chatRoomId:String) -> JSQMessage {
        let name = messageDictionary[kSENDERNAME] as? String
        let userId = messageDictionary[kSENDERID] as? String
        
        var date:Date!
        
        if let created = messageDictionary[kDATE] {
            if (created as! String).count != 14 {
                date = Date()
            }else {
                date = dateFormatter().date(from: created as! String)
            }
        }else {
            date = Date()
        }
        
        let text = messageDictionary[kMESSAGE] as! String
        
        
        return JSQMessage(senderId: userId, senderDisplayName: name, date: date, text:text)
    }
    
    func createPictureMessage(messageDictionary:NSDictionary) -> JSQMessage {
        let name = messageDictionary[kSENDERNAME] as? String
        let userId = messageDictionary[kSENDERID] as? String
        
        let date:Date!
        
        if let created = messageDictionary[kDATE] {
            if (created as! String).count != 14 {
                date = Date()
            }else {
                date = dateFormatter().date(from: created as! String)
            }
        }else {
            date = Date()
        }
        
        let mediaItem = PhotoMediaItem(image: nil)
        
        mediaItem?.appliesMediaViewMaskAsOutgoing = returnOutgoingStatusForUser(senderId: userId!)
        downloadImage(imageUrl: messageDictionary[kPICTURE] as! String) { (image) in
            if image != nil {
                mediaItem?.image = image!
                self.collection.reloadData()
            }
        }
        return JSQMessage(senderId: userId, senderDisplayName: name,date:date, media: mediaItem)
    }
    
    func returnOutgoingStatusForUser(senderId:String) -> Bool {
        if senderId == FUser.currentId() {
            return true
        }else {
            return false
        }
    }
}
