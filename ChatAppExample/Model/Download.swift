//
//  Dwonload.swift
//  ChatAppExample
//
//  Created by Fomagran on 2021/03/16.
//

import Foundation
import FirebaseStorage
import Firebase
import MBProgressHUD
import AVFoundation

let storage = Storage.storage()

//image

func uploadImage(image:UIImage,chatRoomId:String,view:UIView,completion:@escaping(_ imageLink:String?) -> Void) {
    
    let progressHUD = MBProgressHUD.showAdded(to: view, animated: true)
    progressHUD.mode = .determinateHorizontalBar
    
    let dateString = dateFormatter().string(from: Date())
    let photoFileName = "PictureMessages/" + FUser.currentId() + "/" + chatRoomId + "/" + dateString + ".jpg"
    //kFILEREFERENCE에 스토리지 경로 써야함.
    let ref  = storage.reference(forURL: kFILEREFERENCE).child(photoFileName)
    let imageData = image.jpegData(compressionQuality: 0.7)
    var task:StorageUploadTask!
    task = ref.putData(imageData!,metadata: nil,completion: { (metadata, error) in
        task.removeAllObservers()
        progressHUD.hide(animated: true)
        
        if error != nil {
            print("error uploading image \(error?.localizedDescription)")
            return
        }
        
        ref.downloadURL { (url, error) in
            guard let downloadUrl = url else {
                completion(nil)
                return }
            completion(downloadUrl.absoluteString)
        }
       
    })
    
    task.observe(StorageTaskStatus.progress) { (snapshot) in
        progressHUD.progress = Float((snapshot.progress?.completedUnitCount)!)/Float((snapshot.progress?.totalUnitCount)!)
    }
}
