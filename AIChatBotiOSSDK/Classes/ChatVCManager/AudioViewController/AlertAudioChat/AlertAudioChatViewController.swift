
import UIKit
import AVFoundation

class AlertAudioChatViewController: UIViewController {
    
    lazy var navigationView: UIView = {
        let view = UIView(frame: CGRect(x: 0, y: kStatusBarHeight, width: kScreen_WIDTH-32, height: 44))
        view.backgroundColor = .clear
        return view
    }()

    var audioStatus = "playing"//playing paused
    
    lazy var playOrPauseButton = {
        let button = UIButton(type: .custom)
        button.frame = CGRect(x: kScreen_WIDTH/2-48/2+50, y: kScreen_HEIGHT-safeBottom()-48-100, width: 48, height: 48)
        button.setImage(UIImage(named: "audio_chat_goPause",in: Bundle(for: AlertAudioChatViewController.self),with: nil), for: .normal)
        button.addTarget(self, action: #selector(clickPlayOrPauseButton), for: .touchUpInside)
        return button
    }()
    
    lazy var stopButton = {
        let button = UIButton(type: .custom)
        button.frame = CGRect(x: kScreen_WIDTH/2-48/2-50, y: kScreen_HEIGHT-safeBottom()-48-100, width: 48, height: 48)
        button.setImage(UIImage(named: "Audio_Chat_Stop",in: Bundle(for: AlertAudioChatViewController.self),with: nil), for: .normal)
        button.addTarget(self, action: #selector(clickStopButton), for: .touchUpInside)
        return button
    }()
    
    var volumeView: AudioVlonumCustomView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initUI()
    }
    func initUI(){
        view.backgroundColor = UIColor(red: 1, green: 1, blue: 1, alpha: 0.3)
        
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
        
        volumeView = AudioVlonumCustomView(frame: CGRect(x: UIScreen.main.bounds.size.width/2-300/2, y: UIScreen.main.bounds.size.height/2-100/2-64, width: 300, height: 100))
        volumeView.layer.shadowColor = UIColor.black.cgColor
        volumeView.layer.shadowOpacity = 0.3
        volumeView.layer.shadowOffset = CGSize(width: 5, height: 5)
        volumeView.layer.shadowRadius = 10
        volumeView.layer.masksToBounds = false
        view.addSubview(volumeView)
        
        view.addSubview(playOrPauseButton)
        view.addSubview(stopButton)
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
                playOrPauseButton.setImage(UIImage(named: "audio_chat_goPlay",in: Bundle(for: AlertAudioChatViewController.self),with: nil), for: .normal)
                volumeView.removeFromSuperview()
            }else{
                audioStatus = "playing"
                RecordAudioManager.shared.startRecordAudio()
                PlayAudioCotinuouslyManager.shared.isPauseAudio = false
                playOrPauseButton.setImage(UIImage(named: "audio_chat_goPause",in: Bundle(for: AlertAudioChatViewController.self),with: nil), for: .normal)
                
                volumeView = AudioVlonumCustomView(frame: CGRect(x: UIScreen.main.bounds.size.width/2-300/2, y: UIScreen.main.bounds.size.height/2-100/2-64, width: 300, height: 100))
                view.addSubview(volumeView)
            }
        }
        if ChatVCDefaultSetManager.shared.typeOfConnectGPT == "WebRTC"{
            if audioStatus == "playing"{
                audioStatus = "paused"
                WebRTCManager.shared.playOrPauseAudio(specifiedStatus: "pause")
                playOrPauseButton.setImage(UIImage(named: "audio_chat_goPlay",in: Bundle(for: AlertAudioChatViewController.self),with: nil), for: .normal)
                volumeView.removeFromSuperview()
            }else{
                audioStatus = "playing"
                WebRTCManager.shared.playOrPauseAudio(specifiedStatus: "play")
                playOrPauseButton.setImage(UIImage(named: "audio_chat_goPause",in: Bundle(for: AlertAudioChatViewController.self),with: nil), for: .normal)
                volumeView = AudioVlonumCustomView(frame: CGRect(x: UIScreen.main.bounds.size.width/2-300/2, y: UIScreen.main.bounds.size.height/2-100/2-64, width: 300, height: 100))
                view.addSubview(volumeView)
            }
        }
    }
    @objc func clickStopButton(){
        back()
    }
    //MARK: Back
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
    
    var audioRecorder: AVAudioRecorder?
    var audioPeadkerChangeTimer: Timer?
    func gotoGetAudioChange(){
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
        
        //refreshVideoPlayerVolum()
        //try? AVAudioSession.sharedInstance().setCategory(AVAudioSession.Category.playAndRecord)
        
        let settings = [
            AVSampleRateKey: NSNumber(floatLiteral: 44100.0),
            AVFormatIDKey: NSNumber(value: kAudioFormatAppleLossless),
            AVNumberOfChannelsKey: NSNumber(value: 2),
            AVEncoderAudioQualityKey: NSNumber(value: AVAudioQuality.max.rawValue)
        ]
        let url = URL(string: "/dev/null")
        
        self.audioRecorder = try? AVAudioRecorder.init(url: url!, settings: settings)
        if self.audioRecorder == nil{
            return
        }
        self.audioRecorder?.isMeteringEnabled = true
        self.audioRecorder?.prepareToRecord()
        self.audioRecorder?.record()

        if self.audioPeadkerChangeTimer != nil{
            self.audioPeadkerChangeTimer?.invalidate()
            self.audioPeadkerChangeTimer = nil
        }
      
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
        RunLoop.current.add(self.audioPeadkerChangeTimer!, forMode: .common)
    }
    func normalize(value: Double, min: Double = -40, max: Double = 0) -> Double {
        return (value - min) / (max - min)
    }
}
