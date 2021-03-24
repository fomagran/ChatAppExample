//
//  Call.swift
//  ChatAppExample
//
//  Created by Fomagran on 2021/03/24.
//

import Foundation

class Call {
    
    var objectId:String
    var callerId:String
    var callerFullName:String
    var withUserFullName:String
    var withUserId:String
    var status:String
    var isIncoming:Bool
    
    init(_callerID:String,_withUserId:String,_callerFullName:String,_withUserFullName:String) {
        
        objectId = UUID().uuidString
      callerId =  _callerID
      callerFullName = _callerFullName
      withUserFullName = _withUserFullName
      withUserId = _withUserId
      status = ""
      isIncoming = false
    }
    
    init(_dictionary:NSDictionary) {
        
        objectId = _dictionary[kOBJECTID] as! String
        
        if let callId = _dictionary[kCALLERID] {
            callerId = callId as! String
        }else {
            callerId = ""
        }
        if let withId = _dictionary[kWITHUSERUSERID] {
            withUserId  = withId as! String
        }else {
            withUserId = ""
        }
        if let callFName = _dictionary[kCALLERFULLNAME] {
            callerFullName = callFName as! String
        }else {
            callerFullName = "Unknown"
        }
        if let withUserFName = _dictionary[kWITHUSERFULLNAME] {
            withUserFullName = withUserFName as! String
        }else {
            withUserFullName = "Unknwon"
        }
        if let callStatus = _dictionary[kCALLSTATUS] {
            status = callStatus as! String
        }else {
            status = ""
        }
        if let incoming = _dictionary[kISINCOMING] {
            isIncoming = incoming as! Bool
        }else {
            isIncoming = false
        }
    }
    
    func dictionaryFromCall() -> NSDictionary {
        
        return NSDictionary(objects: [objectId,callerId,callerFullName,withUserId,withUserFullName,status,isIncoming], forKeys: [kOBJECTID as NSCopying,kCALLERID as NSCopying,kCALLERFULLNAME as NSCopying,kWITHUSERUSERID as NSCopying,kWITHUSERFULLNAME as NSCopying,kSTATUS as NSCopying,kISINCOMING as NSCopying])
    }
    
    func saveCallInBackground() {
        reference(.Call).document(callerId).collection(callerId).document(objectId).setData(dictionaryFromCall() as! [String:Any])
        reference(.Call).document(withUserId).collection(withUserId).document(objectId).setData(dictionaryFromCall() as! [String:Any])
    }
    
    func deleteCall() {
        reference(.Call).document(FUser.currentId()).collection(FUser.currentId()).document(objectId).delete()
    }
}
