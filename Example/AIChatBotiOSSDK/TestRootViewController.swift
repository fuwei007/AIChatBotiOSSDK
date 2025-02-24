
import UIKit

class TestRootViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    @IBAction func clickChatButton(_ sender: Any) {
  
        //1.Basical Param Data
        ChatVCDefaultSetManager.shared.backgroundColor = .black
        ChatVCDefaultSetManager.shared.isShowLogo = true
        
        ChatVCDefaultSetManager.shared.isClearOpenAIChatMessagesData = true
        ChatVCDefaultSetManager.shared.isClearLocalChatMessagesData = true
        
        
        //Function Call
        //Test 1：
        /*
        var functionCallProperties = [[String: Any]]()
         ChatVCDefaultSetManager.shared.addFunctionCall(functionCallName: "gotoOpenTheMobileBrowser", functionCallDescription: "Open the mobile browser.", functionCallProperties: functionCallProperties)
         ChatVCDefaultSetManager.shared.handleFunctionCallFromSDK = {functioncall_message in
             guard let name = functioncall_message["name"] as? String else{return}
             if name == "gotoOpenTheMobileBrowser"{
                 if let url = URL(string: "https://www.google.com") {
                     if UIApplication.shared.canOpenURL(url) {
                         UIApplication.shared.open(url, options: [:], completionHandler: nil)
                     }
                 }
             }
         }*/
        
        //Test 2:
        /*
        var functionCallProperties = [[String: Any]]()
        let functionCallProperty1: [String: Any] = [
            "property_name": "color",
            "property_type": "string",
            "property_description": "This is a required parameter, used to set the page background color. When returning the parameter, please return its hexadecimal value.",
            "property_isRequired": true
        ]
        functionCallProperties.append(functionCallProperty1)
        ChatVCDefaultSetManager.shared.addFunctionCall(functionCallName: "changeChatViewcontrollerBackgroundColor", functionCallDescription: "Change the background color of the chat interface", functionCallProperties: functionCallProperties)
        ChatVCDefaultSetManager.shared.handleFunctionCallFromSDK = {functioncall_message in
            //print("functionCall_ReturnData:\(functioncall_message)")
            guard let name = functioncall_message["name"] as? String else{return}
            if name == "changeChatViewcontrollerBackgroundColor",
            let arguments = functioncall_message["arguments"] as? [String: Any],
            let color_hex_string = arguments["color"] as? String{
                 //Change Chat Page BackgroundColor
                if let color = self.converHexToColor(hex: color_hex_string){
                    ChatVCDefaultSetManager.shared.currentChatVC.view.backgroundColor = color
                }
            }
        }*/
        
        //Test 3：
        /*
        var functionCallProperties = [[String: Any]]()
        let functionCallProperty1: [String: Any] = [
            "property_name": "number1",
            "property_type": "string",
            "property_description": "This is the first number to be added. This data must be obtained. If this parameter is missing, please ask me: What is the first number?",
            "property_isRequired": true
        ]
        let functionCallProperty2: [String: Any] = [
            "property_name": "number2",
            "property_type": "string",
            "property_description": "This is the second number to be added. This data must be obtained. If this parameter is missing, please ask me: What is the second number?",
            "property_isRequired": true
        ]
        functionCallProperties.append(functionCallProperty1)
        functionCallProperties.append(functionCallProperty2)
         ChatVCDefaultSetManager.shared.addFunctionCall(functionCallName: "thisAddFunction", functionCallDescription: "Please perform addition. Both parameter numbers must be obtained. Once both numbers are retrieved, please directly return their sum.", functionCallProperties: functionCallProperties)
         ChatVCDefaultSetManager.shared.handleFunctionCallFromSDK = {functioncall_message in
             //print("functionCall_ReturnData:\(functioncall_message)")
             guard let name = functioncall_message["name"] as? String else{return}
             if name == "thisAddFunction",
                let arguments = functioncall_message["arguments"] as? [String: Any],
                let number1 = Float(arguments["number1"] as? String ?? ""),
                let number2 = Float(arguments["number2"] as? String ?? ""){
                  print("\n number1=\(number1),number2=\(number2)\n result=\(number1+number2)")
             }
         }
         */
        
        //Test 4：
        /*
        var functionCallProperties = [[String: Any]]()
        let functionCallProperty1: [String: Any] = [
            "property_name": "city",
            "property_type": "string",
            "property_description": "Please tell me the weather conditions for the specified city.",
            "property_isRequired": true
        ]
        functionCallProperties.append(functionCallProperty1)
        ChatVCDefaultSetManager.shared.addFunctionCall(functionCallName: "thisCityFunction", functionCallDescription: "The city is required for search the weather conditions.", functionCallProperties: functionCallProperties)
        ChatVCDefaultSetManager.shared.handleFunctionCallFromSDK = {functioncall_message in
            //print("functionCall_ReturnData:\(functioncall_message)")
            guard let name = functioncall_message["name"] as? String else{return}
            if name == "thisCityFunction"{
                if let arguments = functioncall_message["arguments"] as? [String: Any]{
                    if let city = arguments["city"] as? String{
                        print("go to search the weather conditions for: \(city)")
                    }
                }
            }
        }*/
        
        //3.Go To Chat page
        //3.1.This is must required param. It is the openAI Appkey.
        ChatVCDefaultSetManager.shared.your_openAI_Appkey = ""
        //3.2.Go To Chat page
        ChatVCDefaultSetManager.shared.showChatVC(fromVC: self)
    }
    
    //Convert hexadecimal color string to UIColor
    func converHexToColor(hex: String) -> UIColor? {
        var hexSanitized = hex.trimmingCharacters(in: .whitespacesAndNewlines)
        if hexSanitized.hasPrefix("#") {
            hexSanitized.remove(at: hexSanitized.startIndex)
        }
        if hexSanitized.count == 6 {
            var rgb: UInt64 = 0
            Scanner(string: hexSanitized).scanHexInt64(&rgb)
            let red = CGFloat((rgb & 0xFF0000) >> 16) / 255.0
            let green = CGFloat((rgb & 0x00FF00) >> 8) / 255.0
            let blue = CGFloat(rgb & 0x0000FF) / 255.0
            return UIColor(red: red, green: green, blue: blue, alpha: 1.0)
        }
        return nil
    }
}
