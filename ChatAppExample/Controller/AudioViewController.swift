//
//  AudioViewController.swift
//  ChatAppExample
//
//  Created by Fomagran on 2021/03/22.
//

import Foundation
import IQAudioRecorderController

class AudioViewController {
    
    var delegate:IQAudioRecorderViewControllerDelegate
    
    init(delegate_:IQAudioRecorderViewControllerDelegate) {
        delegate = delegate_
    }
    
    func presentAudioRecorder(target:UIViewController) {
        
     
        let controller = IQAudioRecorderViewController()
        controller.delegate = delegate
        controller.title = "Record"
        controller.maximumRecordDuration = kAUDIOMAXDURATION
        controller.allowCropping = true
        
        target.presentBlurredAudioRecorderViewControllerAnimated(controller)
    }
}
