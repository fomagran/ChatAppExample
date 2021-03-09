//
//  HelperFunctions.swift
//  ChatAppExample
//
//  Created by Fomagran on 2021/03/03.
//

import UIKit
import FirebaseFirestore

private let dateFormat = "yyyyMMddHHmmss"

func dateFormatter() -> DateFormatter {
    let dateFormatter = DateFormatter()
    dateFormatter.timeZone = TimeZone(secondsFromGMT: TimeZone.current.secondsFromGMT())
    dateFormatter.dateFormat = dateFormat
    return dateFormatter
}

func imageFromInitials(firstName:String?,lastName:String?,withBlock:@escaping (_ image:UIImage) -> Void) {
    var string:String!
    var size = 36
    
    if firstName != nil && lastName != nil {
        string = String(firstName!.first!).uppercased() + String(lastName!.first!).uppercased()
    }else{
        string = String(firstName!.first!).uppercased()
        size = 72
    }
    
    let lblNameInitialize = UILabel()
    lblNameInitialize.frame.size = CGSize(width: 100, height: 100)
    lblNameInitialize.textColor = .white
    lblNameInitialize.font = UIFont(name: lblNameInitialize.font.fontName, size: CGFloat(size))
    lblNameInitialize.text = string
    lblNameInitialize.textAlignment = NSTextAlignment.center
    lblNameInitialize.backgroundColor = UIColor.lightGray
    lblNameInitialize.layer.cornerRadius = 25
    
    UIGraphicsBeginImageContext(lblNameInitialize.frame.size)
    lblNameInitialize.layer.render(in: UIGraphicsGetCurrentContext()!)
    
    let img = UIGraphicsGetImageFromCurrentImageContext()
    UIGraphicsEndImageContext()
    withBlock(img!)
}

//문자열로 된 이미지 정보를 이미지로 디코딩해준다.
func imageFromData(imageData:String,completion: (_ image:UIImage?) -> Void) {
    var image:UIImage?
    let decodedData = NSData(base64Encoded: imageData, options: NSData.Base64DecodingOptions(rawValue: 0))
    image = UIImage(data: decodedData! as Data)
    completion(image)
}

