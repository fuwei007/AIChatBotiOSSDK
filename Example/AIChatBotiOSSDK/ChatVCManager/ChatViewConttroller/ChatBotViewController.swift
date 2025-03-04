import UIKit

public class ChatBotViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UITextViewDelegate{

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
        backButton.imageView?.contentMode = .scaleAspectFit
        
        backButton.setImage(UIImage(named: "AIChatBotiOSSDK_Back", in: Bundle(for: ChatBotViewController.self), with: nil), for: .normal)
        backButton.addTarget(self, action: #selector(back), for: .touchUpInside)
        view.addSubview(backButton)
        
        view.addSubview(openAI_connect_status_button)
        
        return view
    }()
    lazy var openAI_connect_status_button: UIButton = {
        let button = UIButton(type: .custom)
        button.setTitle("not connect", for: .normal)
        button.setTitleColor(.red, for: .normal)
        button.frame = CGRect(x: kScreen_WIDTH-32-120, y: 44/2-20/2, width: 120, height: 20)
        button.titleLabel?.textAlignment = .right
        button.titleLabel?.font = UIFont.systemFont(ofSize: 14)
        return button
    }()
    
    lazy var inputChatView: UIView = {
        let view = UIView(frame: CGRect(x: 0, y: kScreen_HEIGHT-safeBottom()-64, width: kScreen_WIDTH, height: 64))
        view.backgroundColor = .clear
        
        let micphoneButton = UIButton(type: .custom)
        micphoneButton.frame = CGRect(x: 20, y: 64/2-30/2, width: 30, height: 30)
        
        micphoneButton.setImage(UIImage(named: "ChatViewController_micphone", in: Bundle(for: ChatBotViewController.self), with: nil), for: .normal)
        micphoneButton.addTarget(self, action: #selector(changeToAudioType), for: .touchUpInside)
        view.addSubview(micphoneButton)
        micphoneButton.isHidden = !ChatVCDefaultSetManager.shared.isSupportAudioRealTimeChat
        
        let sendButton = UIButton(type: .custom)
        sendButton.frame = CGRect(x: kScreen_WIDTH-20-30, y: 64/2-30/2, width: 30, height: 30)
        sendButton.setImage(UIImage(named: "ChatViewController_sendText", in: Bundle(for: ChatBotViewController.self), with: nil), for: .normal)
        sendButton.addTarget(self, action: #selector(sendTextMessage), for: .touchUpInside)
        view.addSubview(sendButton)
        
        view.addSubview(chatTextView)
        
        return view
    }()

    lazy var chatTextView: UITextView = {
        let textView = UITextView(frame: CGRect(x: 70, y: 64/2-40/2, width: kScreen_WIDTH-140, height: 40))
        if  !ChatVCDefaultSetManager.shared.isSupportAudioRealTimeChat{
            textView.frame = CGRect(x: 20, y: 64/2-40/2, width: kScreen_WIDTH-90, height: 40)
        }
        textView.backgroundColor = .clear
        textView.font = UIFont.systemFont(ofSize: 15)
        textView.textColor = .white
        textView.textAlignment = .left
        textView.addSubview(placeholderLabel)
        placeholderLabel.isHidden = !textView.text.isEmpty
        textView.delegate = self
        
        return textView
    }()
    lazy var placeholderLabel: UILabel = {
        let label = UILabel()
        label.text = "Enter..."
        label.font = UIFont.systemFont(ofSize: 15)
        label.textColor = .gray
        label.isUserInteractionEnabled = false
        label.frame = CGRect(x: 5, y: 8, width: kScreen_WIDTH-140-10, height: 20)
        return label
    }()
    lazy var chatContenTableView = {()->UITableView in
        let tableView = UITableView(frame: CGRect(x: 0, y: kNavBarAndStatusBarHeight, width: kScreen_WIDTH, height: kScreen_HEIGHT-kNavBarAndStatusBarHeight-safeBottom()-64))
        tableView.backgroundColor = .clear
        tableView.register(UINib(nibName: "ChatTableViewQuestionCell", bundle: Bundle(for: ChatBotViewController.self)), forCellReuseIdentifier: "ChatTableViewQuestionCellID")
        tableView.register(UINib(nibName: "ChatTableViewAnswerCell", bundle: Bundle(for: ChatBotViewController.self)), forCellReuseIdentifier: "ChatTableViewAnswerCellID")
        tableView.dataSource = self
        tableView.delegate = self
        tableView.separatorStyle = .none
        return tableView
    }()
    var messagesListModels = [[String: Any]]()
    public override func viewDidLoad() {
        super.viewDidLoad()
        initUI()
        startToConnectOpenAI()
    }
    func initUI(){
        view.backgroundColor = ChatVCDefaultSetManager.shared.backgroundColor
        navigationItem.titleView = navigationView
        view.addSubview(inputChatView)
        view.addSubview(chatContenTableView)
        if ChatVCDefaultSetManager.shared.isClearLocalChatMessagesData{
            ChatVCDefaultSetManager.shared.removeMessagesInLocal()
        }
    }
    public func textViewDidChange(_ textView: UITextView) {
        placeholderLabel.isHidden = !textView.text.isEmpty
    }
    //MARK: 1.Audo Connect GPT
    func startToConnectOpenAI(){
        if ChatVCDefaultSetManager.shared.typeOfConnectGPT == "WebSocket"{
            NotificationCenter.default.addObserver(self, selector: #selector(openAiStatusChanged), name: NSNotification.Name(rawValue: "WebSocketManager_connected_status_changed"), object: nil)
            NotificationCenter.default.addObserver(self, selector: #selector(UserStartToSpeek), name: NSNotification.Name(rawValue: "UserStartToSpeek"), object: nil)
            NotificationCenter.default.addObserver(self, selector: #selector(HaveInputText(notifiction:)), name: NSNotification.Name(rawValue: "HaveInputText"), object: nil)
            NotificationCenter.default.addObserver(self, selector: #selector(HaveOutputText(notifiction:)), name: NSNotification.Name(rawValue: "HaveOutputText"), object: nil)
            if WebSocketManager.shared.connected_status == "not_connected"{
                WebSocketManager.shared.connectWebSocketOfOpenAi()
            }
        }
        if ChatVCDefaultSetManager.shared.typeOfConnectGPT == "WebRTC"{
            NotificationCenter.default.addObserver(self, selector: #selector(WebRTCChangeWebRTCConnectStatus), name: NSNotification.Name(rawValue: "WebRTC_changeWebRTCConnectStatus"), object: nil)
            NotificationCenter.default.addObserver(self, selector: #selector(WebRTCHaveInputText(notifiction:)), name: NSNotification.Name(rawValue: "WebRTC_HaveInputText"), object: nil)
            NotificationCenter.default.addObserver(self, selector: #selector(WebRTCHaveOutputText(notifiction:)), name: NSNotification.Name(rawValue: "WebRTC_HaveOutputText"), object: nil)
            if WebRTCManager.shared.connect_statuse == "not connect"{
                WebRTCManager.shared.initAndStartConnectWebRTC()
            }
        }
    }
    
    //MARK: 2.Connect GPT With WebSocket
    //WebSocket connection state changed：
    @objc func openAiStatusChanged(){
        if WebSocketManager.shared.connected_status == "not_connected"{
            openAI_connect_status_button.setTitle("not connect", for: .normal)
            openAI_connect_status_button.setTitleColor(.red, for: .normal)
            openAI_connect_status_button.isHidden = false
        }else if WebSocketManager.shared.connected_status == "connecting"{
            openAI_connect_status_button.setTitle("connecting", for: .normal)
            openAI_connect_status_button.setTitleColor(.red, for: .normal)
            openAI_connect_status_button.isHidden = false
        }else if WebSocketManager.shared.connected_status == "connected"{
            openAI_connect_status_button.setTitle("connected", for: .normal)
            openAI_connect_status_button.setTitleColor(.green, for: .normal)
            openAI_connect_status_button.isHidden = true
            PlayAudioCotinuouslyManager.shared.isPauseAudio = true
            refreshChatMessageData()
        }
    }
    //User Start To Speek
    @objc func UserStartToSpeek(){
    }
    //Update Input Text
    @objc func HaveInputText(notifiction: Notification){
        if let dict = notifiction.object as? [String: Any] {
            if let transcript = dict["text"] as? String{
                var questionMessage = [String: Any]()
                questionMessage["type"] = "question"
                questionMessage["content"] = transcript
                questionMessage["date"] = getCurrentTime()
                ChatVCDefaultSetManager.shared.saveMessageWithDictData(message: questionMessage)
                messagesListModels.append(questionMessage)
                chatContenTableView.reloadData()
                scrollToBottom(of: chatContenTableView)
            }
        }
    }
    //Update Output Text
    @objc func HaveOutputText(notifiction: Notification){
        if let dict = notifiction.object as? [String: Any] {
            if let transcript = dict["text"] as? String {
                var answerMessage = [String: Any]()
                answerMessage["type"] = "answer"
                answerMessage["content"] = transcript
                answerMessage["date"] = getCurrentTime()
                ChatVCDefaultSetManager.shared.saveMessageWithDictData(message: answerMessage)
                messagesListModels.append(answerMessage)
                chatContenTableView.reloadData()
                scrollToBottom(of: chatContenTableView)
            }
        }
    }
    
    //MARK: 3.Connect GPT With WebRTC
    @objc func WebRTCChangeWebRTCConnectStatus(){
        if WebRTCManager.shared.connect_statuse == "not connect"{
            openAI_connect_status_button.setTitle("not connect", for: .normal)
            openAI_connect_status_button.setTitleColor(.red, for: .normal)
            openAI_connect_status_button.isHidden = false
        }else if WebRTCManager.shared.connect_statuse == "connecting"{
            openAI_connect_status_button.setTitle("connecting", for: .normal)
            openAI_connect_status_button.setTitleColor(.red, for: .normal)
            openAI_connect_status_button.isHidden = false
        }else if WebRTCManager.shared.connect_statuse == "connected"{
            openAI_connect_status_button.setTitle("connected", for: .normal)
            openAI_connect_status_button.setTitleColor(.green, for: .normal)
            openAI_connect_status_button.isHidden = true
            //Pause WebRTC Audio(Local Meida)
            WebRTCManager.shared.playOrPauseAudio(specifiedStatus: "pause")
            refreshChatMessageData()
        }
    }
    //Update Input Text
    @objc func WebRTCHaveInputText(notifiction: Notification){
        if let dict = notifiction.object as? [String: Any] {
            if let transcript = dict["text"] as? String{
                var questionMessage = [String: Any]()
                questionMessage["type"] = "question"
                questionMessage["content"] = transcript
                questionMessage["date"] = getCurrentTime()
                ChatVCDefaultSetManager.shared.saveMessageWithDictData(message: questionMessage)
                messagesListModels.append(questionMessage)
                DispatchQueue.main.async {
                    self.chatContenTableView.reloadData()
                    self.scrollToBottom(of: self.chatContenTableView)
                }
            }
        }
    }
    //Update Output Text
    @objc func WebRTCHaveOutputText(notifiction: Notification){
        if let dict = notifiction.object as? [String: Any] {
            if let transcript = dict["text"] as? String {
                var answerMessage = [String: Any]()
                answerMessage["type"] = "answer"
                answerMessage["content"] = transcript
                answerMessage["date"] = getCurrentTime()
                ChatVCDefaultSetManager.shared.saveMessageWithDictData(message: answerMessage)
                messagesListModels.append(answerMessage)
                DispatchQueue.main.async {
                    self.chatContenTableView.reloadData()
                    self.scrollToBottom(of: self.chatContenTableView)
                }
            }
        }
    }
    //MARK:
    func refreshChatMessageData(){
        DispatchQueue.main.async {
            self.messagesListModels = ChatVCDefaultSetManager.shared.getAllMessagesListData()
            self.chatContenTableView.reloadData()
            self.scrollToBottom(of: self.chatContenTableView)
        }
    }
    func scrollToBottom(of tableView: UITableView) {
        let rows = tableView.numberOfRows(inSection: 0)
        if rows > 0 {
            let indexPath = IndexPath(row: rows - 1, section: 0)
            tableView.scrollToRow(at: indexPath, at: .bottom, animated: true)
        }
    }
    //MARK: UITableViewDelegate, UITableViewDataSource
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return messagesListModels.count
    }
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let current_massage = messagesListModels[indexPath.row]
        let current_message_type = current_massage["type"] as? String ?? ""
        if current_message_type == "question"{
            let cell = tableView.dequeueReusableCell(withIdentifier: "ChatTableViewQuestionCellID", for: indexPath) as! ChatTableViewQuestionCell
            cell.cellDict = current_massage
            cell.initUI()
            return cell
        }else if current_message_type == "answer"{
            let cell = tableView.dequeueReusableCell(withIdentifier: "ChatTableViewAnswerCellID", for: indexPath) as! ChatTableViewAnswerCell
            cell.cellDict = current_massage
            cell.initUI()
            return cell
        }else{
            let cell = UITableViewCell()
            return cell
        }
    }
    //MARK: Go To Audio Chat
    @objc func changeToAudioType(){
        if !ChatVCDefaultSetManager.shared.isSupportAudioRealTimeChat{
            return
        }
        if ChatVCDefaultSetManager.shared.typeOfConnectGPT == "WebSocket"{
            if WebSocketManager.shared.connected_status != "connected"{
                return
            }
        }
        if ChatVCDefaultSetManager.shared.typeOfConnectGPT == "WebRTC"{
            if WebRTCManager.shared.connect_statuse != "connected"{
                return
            }
        }
        chatTextView.resignFirstResponder()
        
        /*
        let audioVC = AudioChatViewController()
        let nc = UINavigationController(rootViewController: audioVC)
        nc.modalPresentationStyle = .fullScreen
        present(nc, animated: true)
         */

        let audioVC = AlertAudioChatViewController()
        let nc = UINavigationController(rootViewController: audioVC)
        nc.modalPresentationStyle = .overCurrentContext
        present(nc, animated: true)
    }
    //MARK: Send Text Message
    @objc func sendTextMessage(){
        if chatTextView.text.count <= 0{
            return
        }
        if ChatVCDefaultSetManager.shared.typeOfConnectGPT == "WebSocket"{
            if WebSocketManager.shared.connected_status != "connected"{
                return
            }
        }
        if ChatVCDefaultSetManager.shared.typeOfConnectGPT == "WebRTC"{
            if WebRTCManager.shared.connect_statuse != "connected"{
                return
            }
        }
        chatTextView.resignFirstResponder()
        let question_content = chatTextView.text!
        chatTextView.text = ""
        placeholderLabel.isHidden = false
        
        var questionMessage = [String: Any]()
        questionMessage["type"] = "question"
        questionMessage["content"] = question_content
        questionMessage["date"] = getCurrentTime()
        ChatVCDefaultSetManager.shared.saveMessageWithDictData(message: questionMessage)
        messagesListModels.append(questionMessage)
        chatContenTableView.reloadData()
        scrollToBottom(of: chatContenTableView)
        
        //Send Message
        if ChatVCDefaultSetManager.shared.typeOfConnectGPT == "WebSocket"{
            WebSocketManager.shared.sendTextMesssage(questionMessage: question_content)
        }
        if ChatVCDefaultSetManager.shared.typeOfConnectGPT == "WebRTC"{
            WebRTCManager.shared.sendTextMessafeByEventChannel(questionMessage: question_content)
        }
    }
    //MARK: Back
    @objc func back(){
        if ChatVCDefaultSetManager.shared.typeOfConnectGPT == "WebSocket"{
            PlayAudioCotinuouslyManager.shared.isPauseAudio = true
            RecordAudioManager.shared.stopCollectedAudioData()
            WebSocketManager.shared.socket.disconnect()
        }
        if ChatVCDefaultSetManager.shared.typeOfConnectGPT == "WebRTC"{
            WebRTCManager.shared.localPeerConnection.close()
        }
        
        NotificationCenter.default.removeObserver(self)
        ChatVCDefaultSetManager.shared.all_function_array.removeAll()
        dismiss(animated: true)
    }
}
