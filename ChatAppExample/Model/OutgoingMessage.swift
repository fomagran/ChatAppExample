//
//  OutgoingMessage.swift
//  ChatAppExample
//
//  Created by Fomagran on 2021/03/11.
//

import Foundation

class OutgoingMessage {
    let messageDictionary:NSMutableDictionary
    
    init(message:String,senderId:String,senderName:String,date:Date,status:String,type:String) {
        messageDictionary = NSMutableDictionary(objects: [message,senderId,senderName,dateFormatter().string(from: date),status,type], forKeys: [kMESSAGE as NSCopying,kSENDERID as  NSCopying,kSENDERNAME as  NSCopying,kDATE as  NSCopying,kSTATUS as  NSCopying,kTYPE as  NSCopying])
    }
    
    //Picture 이니셜라이즈
    
    init(message:String,pictureLink:String,senderId:String,senderName:String,date:Date,status:String,type:String) {
        messageDictionary = NSMutableDictionary(objects: [message,pictureLink,senderId,senderName,dateFormatter().string(from: date),status,type], forKeys: [kMESSAGE as NSCopying,kPICTURE as NSCopying,kSENDERID as  NSCopying,kSENDERNAME as  NSCopying,kDATE as  NSCopying,kSTATUS as  NSCopying,kTYPE as  NSCopying])
    }
    
    //Video 이니셜
    
    init(message: String, video: String, thumbNail: NSData, senderId: String, senderName: String, date: Date, status: String, type: String) {
        
        let picThumb = thumbNail.base64EncodedString(options: NSData.Base64EncodingOptions(rawValue: 0))
        
        messageDictionary = NSMutableDictionary(objects: [message, video, picThumb, senderId, senderName, dateFormatter().string(from: date), status, type], forKeys: [kMESSAGE as NSCopying, kVIDEO as NSCopying, kPICTURE as NSCopying, kSENDERID as NSCopying, kSENDERNAME as NSCopying, kDATE as NSCopying, kSTATUS as NSCopying, kTYPE as NSCopying])
    }
    
    //Audio 이니셜
    
    init(message:String,audio:String,senderId:String,senderName:String,date:Date,status:String,type:String) {
        messageDictionary = NSMutableDictionary(objects: [message,audio,senderId,senderName,dateFormatter().string(from: date),status,type], forKeys: [kMESSAGE as NSCopying,kAUDIO as NSCopying,kSENDERID as  NSCopying,kSENDERNAME as  NSCopying,kDATE as  NSCopying,kSTATUS as  NSCopying,kTYPE as  NSCopying])
    }
    
    
    func sendMessage(chatRoomID:String,messageDictionary:NSMutableDictionary,memberIds:[String],membersToPush:[String]) {
    
        let messageId = UUID().uuidString
        messageDictionary[kMESSAGEID] = messageId
        
        for memberId in memberIds {
            reference(.Message).document(memberId).collection(chatRoomID).document(messageId).setData(messageDictionary as! [String:Any])
        }
        
        
    }
}
