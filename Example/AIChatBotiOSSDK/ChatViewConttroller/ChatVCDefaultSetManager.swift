
import Foundation
import UIKit

class ChatVCDefaultSetManager: NSObject{
    
    //MARK: 1.init
    static let shared = ChatVCDefaultSetManager()
    private override init(){
        super.init()
    }
    //MARK: 2.
    var your_openAI_Appkey = ""
    var backgroundColor = UIColor.black
    var isShowLogo = false
    var logoImage = UIImage(contentsOfFile: Bundle.main.path(forResource: "AIChatBotiOSSDK_LOGO", ofType: "png") ?? "")
    var userAvatarImage = UIImage(contentsOfFile: Bundle.main.path(forResource: "chat_user_avatar", ofType: "png") ?? "")
    var AIAvatarImage = UIImage(contentsOfFile: Bundle.main.path(forResource: "chat_bot_avatar", ofType: "png") ?? "")
    var isSupportAudioRealTimeChat = true
    var isClearLocalChatMessagesData = false
    var isClearOpenAIChatMessagesData = false
    
    //MARK:
    var currentChatVC: ChatViewController!
    func showChatVC(fromVC: UIViewController){
        if your_openAI_Appkey.count == 0{
            let alertVC = UIAlertController(title: "Please set your openAI appkey first!", message: "", preferredStyle: .alert)
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
    //4.1.
    var all_function_array = [[String: Any]]()
    func addFunctionCall(functionName: String, triggerKeyword: String){
        let function_dict = ["function_Name": functionName, "triggerKeyword": triggerKeyword]
        all_function_array.append(function_dict)
    }
    //4.2.
    var handleFunctionCallFromSDK: ((String)->())?
   
    //MARK: 5.
    func getAllMessagesListData() -> [[String: Any]]{
        var messagesListModels = [[String: Any]]()
        if let localMessageList = UserDefaults.standard.value(forKey: "localMessageList_AIChatBotiOSSDK") as? [[String: Any]],
           localMessageList.count > 0{
            messagesListModels.append(contentsOf: localMessageList)
        }
        return messagesListModels
    }
    func saveMessageWithDictData(message: [String: Any]){
        var messagesListModels = [[String: Any]]()
        if let localMessageList = UserDefaults.standard.value(forKey: "localMessageList_AIChatBotiOSSDK") as? [[String: Any]],
           localMessageList.count > 0{
            messagesListModels.append(contentsOf: localMessageList)
        }
        messagesListModels.append(message)
        UserDefaults.standard.set(messagesListModels, forKey: "localMessageList_AIChatBotiOSSDK")
        UserDefaults.standard.synchronize()
    }
    func removeMessagesInLocal(){
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

