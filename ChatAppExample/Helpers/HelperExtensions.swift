//
//  HelperExtensions.swift
//  ChatAppExample
//
//  Created by Fomagran on 2021/03/09.
//

import UIKit

extension UIImage {
    
    var isPortrait:Bool {return size.height > size.width}
    var isLandscape:Bool {return size.height < size.width}
    var breadth:CGFloat {return min(size.height, size.width) }
    var breadthSize:CGSize {return CGSize(width: breadth, height: breadth)}
    var breathRect:CGRect {return CGRect(origin: .zero, size: breadthSize)}
    
    var circleMasked:UIImage? {
        UIGraphicsBeginImageContextWithOptions(breadthSize, false, scale)
        defer {
            UIGraphicsEndImageContext()
        }
        guard let cgImage = cgImage?.cropping(to: CGRect(origin: CGPoint(x: isLandscape ? floor((size.width - size.height)/2) : 0, y: isPortrait ? floor((size.width - size.height)/2) : 0), size: breadthSize)) else {return nil }
        UIBezierPath(ovalIn: breathRect).addClip()
        UIImage(cgImage: cgImage).draw(in:breathRect)
        return UIGraphicsGetImageFromCurrentImageContext()
    }
    
    func scaleImageToSize(newSize:CGSize) -> UIImage {
        var  scaledImageRect = CGRect.zero
        
        let aspectWidth = newSize.width/size.width
        let aspectHeight = newSize.height/size.height
        
        let aspectRatio = max(aspectWidth,aspectHeight)
        
        scaledImageRect.size.width = size.width * aspectRatio
        scaledImageRect.size.height = size.height * aspectRatio
        scaledImageRect.origin.x = (newSize.width - scaledImageRect.size.width) / 2.0
        scaledImageRect.origin.y = (newSize.height - scaledImageRect.size.height) / 2.0
        
        UIGraphicsBeginImageContext(newSize)
        draw(in: scaledImageRect)
        let scaledImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return scaledImage!
        
    }
    
}
