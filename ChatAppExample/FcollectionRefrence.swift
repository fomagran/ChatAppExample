//
//  FcollectionRefrence.swift
//  ChatAppExample
//
//  Created by Fomagran on 2021/03/03.
//

import Foundation
import FirebaseFirestore

enum FCollectionReference:String{
    case User
    case Typing
    case Recent
    case Message
    case Group
    case Call
}

func reference(_ collectionReference:FCollectionReference) -> CollectionReference {
    return Firestore.firestore().collection(collectionReference.rawValue)
}
