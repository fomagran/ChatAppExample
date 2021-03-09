//
//  Recent.swift
//  ChatAppExample
//
//  Created by Fomagran on 2021/03/09.
//

import Foundation

func startPrivateChat(user1:FUser,user2:FUser) -> String {
    let userId1 = user1.objectId
    let userId2 = user2.objectId
    var chatRoomId = ""
    
    let value = userId1.compare(userId2).rawValue
    
    if value < 0 {
        chatRoomId = userId1 + userId2
    }else{
        chatRoomId = userId2 + userId1
    }
    
    let members = [userId1,userId2]
    
    createRecent(members: members, chatRoomId: chatRoomId, withUserName: "", type: kPRIVATE, users: [user1,user2], avatarOfGroup: nil)
    
    return chatRoomId
}

func createRecent(members:[String],chatRoomId:String,withUserName:String,type:String,users:[FUser]?,avatarOfGroup:String?) {
    
    var tempMembers = members
    
    reference(.Recent).whereField(kCHATROOMID, isEqualTo: chatRoomId).getDocuments { (snapshot, error) in
        guard let snapshot = snapshot else {return}
        
        if !snapshot.isEmpty {
            for recent in snapshot.documents {
                let currentRecent = recent.data() as NSDictionary
                if let currentUserId = currentRecent[kUSERID] {
                    
                    if tempMembers.contains(currentUserId as! String) {
                        tempMembers.remove(at: tempMembers.firstIndex(of: currentUserId as! String)!)
                        
                    }
                }
            }
            
            for  userId in  tempMembers {
                createRecentItems(userId: userId, chatRoomId: chatRoomId, members: members, withUserName: withUserName, type: type, users: users, avatarOfGroup: avatarOfGroup)
            }
        }
    }
    
}

func createRecentItems(userId:String,chatRoomId:String,members:[String],withUserName:String,type:String,users:[FUser]?,avatarOfGroup:String?) {
    let localReference = reference(.Recent).document()
    let recentId = localReference.documentID
    let date = dateFormatter().string(from: Date())
    var recent:[String:Any]!
    var withUser:FUser?
    
    if type == kPRIVATE {
        if users != nil && users!.count > 0 {
            if userId == FUser.currentId() {
                withUser = users!.last
            }else{
                withUser = users!.first
            }
        }
        recent = [kRECENTID:recentId,kUSERID:userId,kCHATROOMID:chatRoomId,kMEMBERS:members,kMEMBERSTOPUSH:members,kWITHUSERFULLNAME:withUser!.fullname,kWITHUSERUSERID:withUser!.objectId,kLASTMESSAGE:"",kCOUNTER:0,kDATE:date,kTYPE:type,kAVATAR:withUser!.avatar] as [String:Any]
        
    }else{
        if  avatarOfGroup != nil {
            recent = [kRECENTID:recentId,kUSERID:userId,kCHATROOMID:chatRoomId,kMEMBERS:members,kMEMBERSTOPUSH:members,kWITHUSERFULLNAME:withUser!.fullname,kWITHUSERUSERID:withUser!.objectId,kLASTMESSAGE:"",kCOUNTER:0,kDATE:date,kTYPE:type,kAVATAR:withUser!.avatar] as [String:Any]
        }
    }
    
    localReference.setData(recent)
}
