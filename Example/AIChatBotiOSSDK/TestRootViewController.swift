
import UIKit

class TestRootViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    @IBAction func clickChatButton(_ sender: Any) {
        //1.
        //1.1.
        ChatVCDefaultSetManager.shared.backgroundColor = .black
        //1.2.
        ChatVCDefaultSetManager.shared.isShowLogo = true
        //ChatVCDefaultSetManager.shared.logoImage = UIImage(named: "AIChatBotiOSSDK_LOGO")
        //1.3.
        //ChatVCDefaultSetManager.shared.userAvatarImage = UIImage(named: "chat_user_avatar")
        //1.4.
        //ChatVCDefaultSetManager.shared.AIAvatarImage = UIImage(named: "chat_bot_avatar")
        //1.5.
        //ChatVCDefaultSetManager.shared.isSupportAudioRealTimeChat = false
        //1.6.
        //ChatVCDefaultSetManager.shared.isClearLocalChatMessagesData = true
        //1.7.
        //ChatVCDefaultSetManager.shared.isClearOpenAIChatMessagesData = true

        //2.FunctionCall
        //2.1.
        //ChatVCDefaultSetManager.shared.addFunctionCall(functionName: "ChangeChatVCBackgroudColorToBlack", triggerKeyword: "")
        //ChatVCDefaultSetManager.shared.addFunctionCall(functionName: "ChangeChatVCBackgroudColorToGray", triggerKeyword: "")
        //2.2.
        ChatVCDefaultSetManager.shared.handleFunctionCallFromSDK = {function_name in
            if function_name == "ChangeChatVCBackgroudColorToBlack"{
                ChatVCDefaultSetManager.shared.backgroundColor = .black
                ChatVCDefaultSetManager.shared.currentChatVC.view.backgroundColor = .black
            }
            if function_name == "ChangeChatVCBackgroudColorToGray"{
                ChatVCDefaultSetManager.shared.backgroundColor = .gray
                ChatVCDefaultSetManager.shared.currentChatVC.view.backgroundColor = .gray
            }
        }
        
        
        //3.
        //3.1.
        ChatVCDefaultSetManager.shared.your_openAI_Appkey = ""
        //3.2.
        ChatVCDefaultSetManager.shared.showChatVC(fromVC: self)
        
        
        
        
    }
}
