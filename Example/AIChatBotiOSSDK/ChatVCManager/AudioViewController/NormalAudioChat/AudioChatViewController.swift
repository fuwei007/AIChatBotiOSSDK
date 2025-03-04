
import UIKit
import AVFoundation

class AudioChatViewController: UIViewController {

    lazy var navigationView: UIView = {
        let view = UIView(frame: CGRect(x: 0, y: kStatusBarHeight, width: kScreen_WIDTH-32, height: 44))
        view.backgroundColor = .clear
        if  ChatVCDefaultSetManager.shared.isShowLogo == true
            &&  ChatVCDefaultSetManager.shared.logoImage != nil{
            let imageView = UIImageView(frame: CGRect(x: (kScreen_WIDTH-32)/2-20, y: 44/2-17/2, width: 40, height: 17))
            imageView.contentMode = .scaleAspectFit
            imageView.image = ChatVCDefaultSetManager.shared.logoImage
            view.addSubview(imageView)
        }
        let backButton = EnlargedButton(type: .custom)
        backButton.frame = CGRect(x: 0, y: 44/2-18/2, width: 18, height: 18)
        backButton.setImage(UIImage(named: "AIChatBotiOSSDK_Back", in: Bundle(for: AudioChatViewController.self), with: nil), for: .normal)
        backButton.imageView?.contentMode = .scaleAspectFit
        backButton.addTarget(self, action: #selector(back), for: .touchUpInside)
        view.addSubview(backButton)
        return view
    }()

    var audioStatus = "playing"//playing paused
    lazy var playOrPauseButton = {
        let button = UIButton(type: .custom)
        button.frame = CGRect(x: kScreen_WIDTH/2-48/2, y: kScreen_HEIGHT-safeBottom()-48, width: 48, height: 48)
        button.setImage(UIImage(named: "audio_chat_goPause",in: Bundle(for: AudioChatViewController.self),with: nil), for: .normal)
        button.addTarget(self, action: #selector(clickPlayOrPauseButton), for: .touchUpInside)
        return button
    }()
    
    var volumeView: AudioVlonumCustomView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initUI()
    }
    func initUI(){
        
        view.backgroundColor = ChatVCDefaultSetManager.shared.backgroundColor
        
        navigationItem.titleView = navigationView
        
        if ChatVCDefaultSetManager.shared.typeOfConnectGPT == "WebSocket"{
            NotificationCenter.default.addObserver(self, selector: #selector(notifiAudioVolume(notify:)), name: NSNotification.Name(rawValue: "showMonitorAudioDataView"), object: nil)
            RecordAudioManager.shared.startRecordAudio()
            PlayAudioCotinuouslyManager.shared.isPauseAudio = false
        }
        if ChatVCDefaultSetManager.shared.typeOfConnectGPT == "WebRTC"{
            WebRTCManager.shared.playOrPauseAudio(specifiedStatus: "play")
            gotoGetAudioChange()
        }
        
        volumeView = AudioVlonumCustomView(frame: CGRect(x: UIScreen.main.bounds.size.width/2-300/2, y: UIScreen.main.bounds.size.height/2-100/2, width: 300, height: 100))
        view.addSubview(volumeView)
        
        view.addSubview(playOrPauseButton)
    }
    @objc func notifiAudioVolume(notify: Notification){
        if ChatVCDefaultSetManager.shared.typeOfConnectGPT == "WebSocket"{
            if let object = notify.object as? [String: Any],
               let rmsValue = object["rmsValue"] as? Float{
                DispatchQueue.main.async {
                    self.volumeView.updateCurrentVolumeNmber(volumeNumber: rmsValue*50)
                }
            }
        }
    }
    @objc func clickPlayOrPauseButton(){
        if ChatVCDefaultSetManager.shared.typeOfConnectGPT == "WebSocket"{
            if audioStatus == "playing"{
                audioStatus = "paused"
                RecordAudioManager.shared.stopCollectedAudioData()
                PlayAudioCotinuouslyManager.shared.isPauseAudio = true
                playOrPauseButton.setImage(UIImage(named: "audio_chat_goPlay",in: Bundle(for: AudioChatViewController.self),with: nil), for: .normal)
                
                volumeView.removeFromSuperview()
            }else{
                audioStatus = "playing"
                RecordAudioManager.shared.startRecordAudio()
                PlayAudioCotinuouslyManager.shared.isPauseAudio = false
                playOrPauseButton.setImage(UIImage(named: "audio_chat_goPause",in: Bundle(for: AudioChatViewController.self),with: nil), for: .normal)
                
                volumeView = AudioVlonumCustomView(frame: CGRect(x: UIScreen.main.bounds.size.width/2-300/2, y: UIScreen.main.bounds.size.height/2-100/2, width: 300, height: 100))
                view.addSubview(volumeView)
            }
        }
        if ChatVCDefaultSetManager.shared.typeOfConnectGPT == "WebRTC"{
            if audioStatus == "playing"{
                audioStatus = "paused"
                WebRTCManager.shared.playOrPauseAudio(specifiedStatus: "pause")
                playOrPauseButton.setImage(UIImage(named: "audio_chat_goPlay",in: Bundle(for: AudioChatViewController.self),with: nil), for: .normal)
                volumeView.removeFromSuperview()
            }else{
                audioStatus = "playing"
                WebRTCManager.shared.playOrPauseAudio(specifiedStatus: "play")
                playOrPauseButton.setImage(UIImage(named: "audio_chat_goPause",in: Bundle(for: AudioChatViewController.self),with: nil), for: .normal)
                volumeView = AudioVlonumCustomView(frame: CGRect(x: UIScreen.main.bounds.size.width/2-300/2, y: UIScreen.main.bounds.size.height/2-100/2, width: 300, height: 100))
                view.addSubview(volumeView)
            }
        }
    }
    //MARK:
    @objc func back(){
        NotificationCenter.default.removeObserver(self)
        if ChatVCDefaultSetManager.shared.typeOfConnectGPT == "WebSocket"{
            RecordAudioManager.shared.stopCollectedAudioData()
            PlayAudioCotinuouslyManager.shared.isPauseAudio = true
        }
        if ChatVCDefaultSetManager.shared.typeOfConnectGPT == "WebRTC"{
            WebRTCManager.shared.playOrPauseAudio(specifiedStatus: "pause")
            audioPeadkerChangeTimer?.invalidate()
            audioPeadkerChangeTimer = nil
        }
        dismiss(animated: true)
    }
    
    //MARK: Monitor volume level.
    var audioRecorder: AVAudioRecorder?
    var audioPeadkerChangeTimer: Timer?
    func gotoGetAudioChange(){
        //1.First, request system permissions (don’t forget to set the relevant permissions in the plist file).
        //import AVFoundation
        let audioAuthStatus = AVCaptureDevice.authorizationStatus(for: AVMediaType.audio)
        if audioAuthStatus == AVAuthorizationStatus.notDetermined{
            AVAudioSession.sharedInstance().requestRecordPermission {granted in
                if granted{
                    DispatchQueue.main.async {
                        self.gotoGetAudioChange()
                    }
                }else{}
            }
            return
        }
        
        //2.Start monitoring.
        //refreshVideoPlayerVolum()
        //try? AVAudioSession.sharedInstance().setCategory(AVAudioSession.Category.playAndRecord)
        
        let settings = [
            AVSampleRateKey: NSNumber(floatLiteral: 44100.0),
            AVFormatIDKey: NSNumber(value: kAudioFormatAppleLossless),
            AVNumberOfChannelsKey: NSNumber(value: 2),
            AVEncoderAudioQualityKey: NSNumber(value: AVAudioQuality.max.rawValue)
        ]
        let url = URL(string: "/dev/null")// Only monitoring, no writing, so the address is empty.
        
        self.audioRecorder = try? AVAudioRecorder.init(url: url!, settings: settings)
        if self.audioRecorder == nil{
            print("Initialization of self.audioRecorder failed.")
            return
        }
        self.audioRecorder?.isMeteringEnabled = true
        self.audioRecorder?.prepareToRecord()
        self.audioRecorder?.record()
        /*
        self.displayLink = CADisplayLink.init(target: self, selector: #selector(handleDisplay))
        self.displayLink?.add(to: RunLoop.current, forMode: .common)
         */
        if self.audioPeadkerChangeTimer != nil{
            self.audioPeadkerChangeTimer?.invalidate()
            self.audioPeadkerChangeTimer = nil
        }
      
        // The peakPower value ranges from -160 to 0, but based on testing, background noise is generally below -40.
        // So here, I set the range to -40 to 0.
        // Actual effect: -20
        self.audioPeadkerChangeTimer = Timer.init(timeInterval: 0.01, repeats: true, block: { timer in
            if self.audioRecorder?.isRecording == true{
                self.audioRecorder?.updateMeters()
                let peakPower = self.audioRecorder?.averagePower(forChannel: 0)
                if peakPower! >= -40{
                    if let audioTrack = WebRTCManager.shared.localMediaStream.audioTracks.first,
                       audioTrack.isEnabled == true,
                       peakPower != nil{
                        DispatchQueue.main.async {
                            self.volumeView.updateCurrentVolumeNmber(volumeNumber: Float(self.normalize(value: Double(peakPower!))))
                        }
                    }else{
                        DispatchQueue.main.async {
                            self.volumeView.updateCurrentVolumeNmber(volumeNumber: 0.0)
                        }
                    }
                }else{
                    DispatchQueue.main.async {
                        self.volumeView.updateCurrentVolumeNmber(volumeNumber: 0.0)
                    }
                }
            }
        })
        RunLoop.current.add(self.audioPeadkerChangeTimer!, forMode: RunLoopMode.commonModes)
    }
    func normalize(value: Double, min: Double = -40, max: Double = 0) -> Double {
        return (value - min) / (max - min)
    }
}
