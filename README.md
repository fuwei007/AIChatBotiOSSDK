# AIChatBotiOSSDK

[![CI Status](https://img.shields.io/travis/Frank Fu/AIChatBotiOSSDK.svg?style=flat)](https://travis-ci.org/Frank Fu/AIChatBotiOSSDK)
[![Version](https://img.shields.io/cocoapods/v/AIChatBotiOSSDK.svg?style=flat)](https://cocoapods.org/pods/AIChatBotiOSSDK)
[![License](https://img.shields.io/cocoapods/l/AIChatBotiOSSDK.svg?style=flat)](https://cocoapods.org/pods/AIChatBotiOSSDK)
[![Platform](https://img.shields.io/cocoapods/p/AIChatBotiOSSDK.svg?style=flat)](https://cocoapods.org/pods/AIChatBotiOSSDK)


## Installation

AIChatBotiOSSDK is available through [CocoaPods](https://cocoapods.org). To install
it, simply add the following line to your Podfile:

```ruby
pod 'AIChatBotiOSSDK'
```

## Xcode configuration

1.Minimum project version: 15.0

2.Add privacy permission requests in Target –> Info:
  Privacy - Microphone Usage Description
  We need access to your microphone to record audio.

## Usage
![Chat Interface Screenshot](Assets/ChatShot.png)

1.Import the header file at the top of the file where the chat interface will be displayed:
```ruby
  import AIChatBotiOSSDK
```

2.OpenAI available App Key (required):
```ruby
ChatVCDefaultSetManager.shared.your_openAI_Appkey = "*******"
```

3.Initialize parameters (optional):

  3.1.Page color
  ```ruby
  ChatVCDefaultSetManager.shared.backgroundColor = .black
  ```
  
  3.2.Show logo
  ```ruby
  ChatVCDefaultSetManager.shared.isShowLogo = true
  ChatVCDefaultSetManager.shared.logoImage = UIImage(named: "***")
  ```
  
  3.3.User avatar
  ```ruby
  ChatVCDefaultSetManager.shared.userAvatarImage = UIImage(named: "***")
  ```
  
  3.4.AI avatar
  ```ruby
  ChatVCDefaultSetManager.shared.AIAvatarImage = UIImage(named: "***")
  ```
  
  3.5.Support for real-time voice chat
  ```ruby
  ChatVCDefaultSetManager.shared.isSupportAudioRealTimeChat = false
  ```
  
  3.6.Clear local chat history (clear previous chat data when entering the chat interface)
  ```ruby
  ChatVCDefaultSetManager.shared.isClearLocalChatMessagesData = true
  ```
  
  3.7.Clear remote chat history (whether to send historical chat data to OpenAI each time connecting to the OpenAI server)
  ```ruby
  ChatVCDefaultSetManager.shared.isClearOpenAIChatMessagesData = true
  ```
  
4.FunctionCall related:
  
  (1).Add FunctionCall
  ```ruby
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
  ```
  
  (2).Trigger FunctionCall
  ```ruby
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
  ```
    
5.Navigate to the chat interface
  ```ruby
  ChatVCDefaultSetManager.shared.showChatVC(fromVC: self)
  ```
      
## Author

Frank Fu, fuwei007@gmail.com

## License

AIChatBotiOSSDK is available under the MIT license. See the LICENSE file for more info.
