
import UIKit

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
        let backButton = UIButton(type: .custom)
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
        button.setImage(UIImage(named: "Audio_Chat_Stop",in: Bundle(for: AudioChatViewController.self),with: nil), for: .normal)
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
        
        NotificationCenter.default.addObserver(self, selector: #selector(notifiAudioVolume(notify:)), name: NSNotification.Name(rawValue: "showMonitorAudioDataView"), object: nil)
        RecordAudioManager.shared.startRecordAudio()
        PlayAudioCotinuouslyManager.shared.isPauseAudio = false
        
        volumeView = AudioVlonumCustomView(frame: CGRect(x: UIScreen.main.bounds.size.width/2-300/2, y: UIScreen.main.bounds.size.height/2-100/2, width: 300, height: 100))
        view.addSubview(volumeView)
        
        view.addSubview(playOrPauseButton)
    }
    @objc func notifiAudioVolume(notify: Notification){
        if let object = notify.object as? [String: Any],
           let rmsValue = object["rmsValue"] as? Float{
            DispatchQueue.main.async {
                self.volumeView.updateCurrentVolumeNmber(volumeNumber: rmsValue*50)
            }
        }
    }
    
    @objc func clickPlayOrPauseButton(){
        if audioStatus == "playing"{
            audioStatus = "paused"
            RecordAudioManager.shared.stopCollectedAudioData()
            PlayAudioCotinuouslyManager.shared.isPauseAudio = true
            playOrPauseButton.setImage(UIImage(named: "Audio_Chat_Play",in: Bundle(for: AudioChatViewController.self),with: nil), for: .normal)
            
            volumeView.removeFromSuperview()
        }else{
            audioStatus = "playing"
            RecordAudioManager.shared.startRecordAudio()
            PlayAudioCotinuouslyManager.shared.isPauseAudio = false
            playOrPauseButton.setImage(UIImage(named: "Audio_Chat_Stop",in: Bundle(for: AudioChatViewController.self),with: nil), for: .normal)
            
            volumeView = AudioVlonumCustomView(frame: CGRect(x: UIScreen.main.bounds.size.width/2-300/2, y: UIScreen.main.bounds.size.height/2-100/2, width: 300, height: 100))
            view.addSubview(volumeView)
        }
    }
    //MARK:
    @objc func back(){
        NotificationCenter.default.removeObserver(self)
        RecordAudioManager.shared.stopCollectedAudioData()
        PlayAudioCotinuouslyManager.shared.isPauseAudio = true
        dismiss(animated: true)
    }
    
}
