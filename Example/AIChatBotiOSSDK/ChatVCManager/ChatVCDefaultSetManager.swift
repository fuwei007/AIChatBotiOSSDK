
import Foundation
import UIKit
import IQKeyboardManagerSwift

public class ChatVCDefaultSetManager: NSObject{
    
    //MARK: 1.init
    public static let shared = ChatVCDefaultSetManager()
    private override init(){
        super.init()
        initIQKeyboardManagerSwift()
    }
    func initIQKeyboardManagerSwift(){
        DispatchQueue.main.async {
            IQKeyboardManager.shared.isEnabled = true
            IQKeyboardManager.shared.enableAutoToolbar = true
        }
    }
    //MARK: 2.Param
    public var your_openAI_Appkey = ""
    public var backgroundColor = UIColor.black
    public var isShowLogo = false
    public var logoImage = UIImage(named: "AIChatBotiOSSDK_LOGO",in: Bundle(for: ChatVCDefaultSetManager.self), with: nil)
    public var userAvatarImage = UIImage(named: "chat_user_avatar",in: Bundle(for: ChatVCDefaultSetManager.self), with: nil)
    public var AIAvatarImage = UIImage(named: "chat_bot_avatar",in: Bundle(for: ChatVCDefaultSetManager.self), with: nil)
    public var isSupportAudioRealTimeChat = true
    public var isClearLocalChatMessagesData = false
    public var isClearOpenAIChatMessagesData = false
    //alloy, ash, coral, echo, fable, onyx, nova, sage, shimmer
    public var chatAudioVoiceType = "alloy"
    //gpt-4o-realtime-preview-2024-12-17 / gpt-4o-mini-realtime-preview-2024-12-17
    public var RealtimeAPIGPTModel = "gpt-4o-mini-realtime-preview-2024-12-17"
    //The type of connect GPT: WebSocket/WebRTC
    public var typeOfConnectGPT = "WebSocket"
    //You can fully customize the session’s configuration statement. Once you set this content, optional parameters will become invalid.
    public var sessionConfigurationStatement = [String: Any]()
  
    //MARK:3.Show Chat View
    public var currentChatVC: ChatViewController!
    //public var currentChatVC: ChatBotViewController!
    public func showChatVC(fromVC: UIViewController){
        if your_openAI_Appkey.count == 0{
            let alertVC = UIAlertController(title: "Please set your openAI appkey first!", message: "", preferredStyle: .alert)
            alertVC.addAction(UIAlertAction(title: "Cancel", style: .cancel))
            fromVC.present(alertVC, animated: true)
            return
        }
        if typeOfConnectGPT != "WebSocket" && typeOfConnectGPT != "WebRTC"{
            let alertVC = UIAlertController(title: "Please set your typeOfConnectGPT to WebSocket/WebRTC ", message: "", preferredStyle: .alert)
            alertVC.addAction(UIAlertAction(title: "Cancel", style: .cancel))
            fromVC.present(alertVC, animated: true)
            return
        }
        let vc = ChatViewController()
        currentChatVC = vc
        let nc = UINavigationController(rootViewController: vc)
        nc.modalPresentationStyle = .fullScreen
        fromVC.present(nc, animated: true)
    }
    
    //MARK: 4.FunctionCall
    public var all_function_array = [[String: Any]]()
    public func addFunctionCall(functionCallName: String, functionCallDescription: String, functionCallProperties:[[String: Any]]){
        let function_dict: [String : Any] = ["functionCall_Name": functionCallName, "functionCall_Description": functionCallDescription, "functionCall_Properties": functionCallProperties]
        all_function_array.append(function_dict)
    }
    public var handleFunctionCallFromSDK: (([String: Any])->())?
    
   
    //MARK: 5.Handle message list
    public func getAllMessagesListData() -> [[String: Any]]{
        var messagesListModels = [[String: Any]]()
        if let localMessageList = UserDefaults.standard.value(forKey: "localMessageList_AIChatBotiOSSDK") as? [[String: Any]],
           localMessageList.count > 0{
            messagesListModels.append(contentsOf: localMessageList)
        }
        return messagesListModels
    }
    public func saveMessageWithDictData(message: [String: Any]){
        var messagesListModels = [[String: Any]]()
        if let localMessageList = UserDefaults.standard.value(forKey: "localMessageList_AIChatBotiOSSDK") as? [[String: Any]],
           localMessageList.count > 0{
            messagesListModels.append(contentsOf: localMessageList)
        }
        messagesListModels.append(message)
        UserDefaults.standard.set(messagesListModels, forKey: "localMessageList_AIChatBotiOSSDK")
        UserDefaults.standard.synchronize()
    }
    public func removeMessagesInLocal(){
        UserDefaults.standard.removeObject(forKey: "localMessageList_AIChatBotiOSSDK")
        UserDefaults.standard.synchronize()
    }
}

//MARK: Define
var kMain_Screen: UIScreen{
    if #available(iOS 13.0.0, *){
        if (UIApplication.shared.connectedScenes.first as? UIWindowScene)?.screen != nil{
            return ((UIApplication.shared.connectedScenes.first as? UIWindowScene)?.screen)!
        }else{
            return UIScreen.main
        }
    }else{
        return UIScreen.main
    }
}
let kScreen_WIDTH = kMain_Screen.bounds.size.width
let kScreen_HEIGHT = kMain_Screen.bounds.size.height

var isFullScreen: Bool {
    if #available(iOS 11, *) {
          guard let w = UIApplication.shared.delegate?.window, let unwrapedWindow = w else {
              return false
          }
          
          if unwrapedWindow.safeAreaInsets.left > 0 || unwrapedWindow.safeAreaInsets.bottom > 0 {
              print(unwrapedWindow.safeAreaInsets)
              return true
          }
    }
    return false
}

let kTabBarHeight: CGFloat = isFullScreen ? (49.0 + 34.0) : (49.0)

let kStatusBarHeight: CGFloat = isFullScreen ? (44.0) : (20.0)

let kNavBarHeight: CGFloat = 44.0

let kNavBarAndStatusBarHeight: CGFloat = isFullScreen ? (88.0) : (64.0)

func safeTop() -> CGFloat {
    if #available(iOS 13.0, *) {
        let scene = UIApplication.shared.connectedScenes.first
        guard let windowScene = scene as? UIWindowScene else { return 0 }
        guard let window = windowScene.windows.first else { return 0 }
        return window.safeAreaInsets.top
    } else if #available(iOS 11.0, *) {
        guard let window = UIApplication.shared.windows.first else { return 0 }
        return window.safeAreaInsets.top
    }
    return 44.0
}
func safeBottom() -> CGFloat {
    if #available(iOS 13.0, *) {
        let scene = UIApplication.shared.connectedScenes.first
        guard let windowScene = scene as? UIWindowScene else { return 0 }
        guard let window = windowScene.windows.first else { return 0 }
        return window.safeAreaInsets.bottom
    } else if #available(iOS 11.0, *) {
        guard let window = UIApplication.shared.windows.first else { return 0 }
        return window.safeAreaInsets.bottom
    }
    return 0
}
func getCurrentTime() -> String {
    let dateformatter = DateFormatter()
    dateformatter.dateFormat = "YYYY-MM-dd HH:mm:ss"
    return dateformatter.string(from: Date())
}
func calculateHeight(forText text: String, withFont font: UIFont, andWidth width: CGFloat) -> CGFloat {
    let constraintRect = CGSize(width: width, height: .greatestFiniteMagnitude)
    let boundingBox = text.boundingRect(with: constraintRect,
                                        options: .usesLineFragmentOrigin,
                                        attributes: [NSAttributedString.Key.font: font],
                                        context: nil)
    return ceil(boundingBox.height)
}
func calculateWidth(forText text: String, withFont font: UIFont, andHeight height: CGFloat) -> CGFloat {
    let constraintSize = CGSize(width: .greatestFiniteMagnitude, height: height)
    let boundingBox = text.boundingRect(with: constraintSize,
                                        options: .usesLineFragmentOrigin,
                                        attributes: [NSAttributedString.Key.font: font],
                                        context: nil)
    return ceil(boundingBox.width)
}

