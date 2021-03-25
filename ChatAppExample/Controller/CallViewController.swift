//
//  CallViewController.swift
//  ChatAppExample
//
//  Created by Fomagran on 2021/03/25.
//

import UIKit

class CallViewController: UIViewController,SINCallDelegate {

    @IBOutlet weak var declineButton: UIButton!
    @IBOutlet weak var endCallButton: UIButton!
    @IBOutlet weak var callButton: UIButton!
    @IBOutlet weak var speakerButton: UIButton!
    @IBOutlet weak var muteButton: UIButton!
    @IBOutlet weak var profile: UIImageView!
    @IBOutlet weak var time: UILabel!
    @IBOutlet weak var name: UILabel!
    
    var speaker = false
    var mute = false
    var durationTimer:Timer! = nil
    var _call:SINCall!
    
    var callAnswered = false
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    
    override func viewWillAppear(_ animated: Bool) {
        name.text = "Unknown"
        let id = _call.remoteUserId
        
        getUsersFromFirestore(withIds: [id!]) { (allUsers) in
            if allUsers.count > 0 {
                let user  = allUsers.first!
                self.name.text = user.fullname
                
                imageFromData(pictureData: user.avatar) { (image) in
                    if image != nil {
                        self.profile.image = image!.circleMasked
                    }
                }
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        _call.delegate = self
        
        if _call.direction == SINCallDirection.incoming {
            showButtons()
            audioController().startPlayingSoundFile("ring", loop: true)
        }else {
            callAnswered = true
            showButtons()
        }
    }
    
    func setCallStatus(text:String) {
        
    }
    
    func showButtons() {
        if callAnswered {
            declineButton.isHidden = true
            endCallButton.isHidden = false
            callButton.isHidden = true
            muteButton.isHidden = false
            speakerButton.isHidden = false
        }else {
            declineButton.isHidden = false
            endCallButton.isHidden = true
            callButton.isHidden = false
            muteButton.isHidden = true
            speakerButton.isHidden = true
        }
    }
    
    func audioController() -> SINAudioController {
        return appDelegate._client.audioController()
    }
    
    func setCall(call:SINCall) {
        _call = call
        _call.delegate = self
    }
    
    func pathForSound(soundName:String) -> String {
        return Bundle.main.path(forResource: soundName, ofType: "wav")!
    }

    @IBAction func tapMuteButton(_ sender: Any) {
        if mute {
            mute = false
            audioController().unmute()
            muteButton.setImage(#imageLiteral(resourceName: "mute"), for: .normal)
        }else {
            mute = true
            audioController().mute()
            muteButton.setImage(#imageLiteral(resourceName: "muteSelected"), for: .normal)
        }
    }
    @IBAction func tapSpeakerButton(_ sender: Any) {
        
        if !speaker {
            speaker  = true
            audioController().enableSpeaker()
            speakerButton.setImage(#imageLiteral(resourceName: "speakerSelected"), for: .normal)
        }else{
            speaker  = true
            audioController().disableSpeaker()
            speakerButton.setImage(#imageLiteral(resourceName: "speaker"), for: .normal)
        }
    }
    @IBAction func tapCallButton(_ sender: Any) {
        callAnswered = true
        showButtons()
        _call.answer()
    }
    @IBAction func tapEndCallButton(_ sender: Any) {
        _call.hangup()
        self.dismiss(animated: true, completion: nil)
    }
    @IBAction func tapDeclineButton(_ sender: Any) {
        _call.hangup()
        self.dismiss(animated: true, completion: nil)
    }
    
    func callDidProgress(_ call: SINCall!) {
        setCallStatus(text: "Ringing...")
        audioController().startPlayingSoundFile("ringback", loop: true)
    }
    
    func callDidEstablish(_ call: SINCall!) {
        startCallDurationTimer()
        showButtons()
        audioController().stopPlayingSoundFile()
    }
    
    func callDidEnd(_ call: SINCall!) {
        audioController().stopPlayingSoundFile()
        stopCallDurationTimer()
        dismiss(animated: true, completion: nil)
    }
    
    @objc func onDuration() {
        let duration = Date().timeIntervalSince(_call.details.establishedTime)
        updateTimerLabel(seconds: Int(duration))
    }
    
    func updateTimerLabel(seconds:Int){
        
        let min = String(format: "%02d", seconds/60)
        let sec = String(format: "%02d", seconds%60)
        setCallStatus(text: "\(min) : \(sec)")
    }
    
    func startCallDurationTimer() {
        self.durationTimer = Timer.scheduledTimer(timeInterval: 0.5, target: self,selector: #selector(self.onDuration),userInfo: nil, repeats: true)
    }
    
    func stopCallDurationTimer() {
        if durationTimer != nil {
            durationTimer.invalidate()
            durationTimer = nil
        }
    }
    
    

}
