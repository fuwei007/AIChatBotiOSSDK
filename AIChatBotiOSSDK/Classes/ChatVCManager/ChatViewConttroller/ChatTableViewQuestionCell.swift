import UIKit

class ChatTableViewQuestionCell: UITableViewCell {
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    @IBOutlet weak var avatarImageV: UIImageView!
    @IBOutlet weak var messageView: UIView!
    @IBOutlet weak var messageViewHeight: NSLayoutConstraint!
    @IBOutlet weak var messageViewWidth: NSLayoutConstraint!
    @IBOutlet weak var messageLabel: UILabel!
    
    var cellDict = [String: Any]()
    
    func initUI(){
        
        self.selectionStyle = .none
        
        messageView.backgroundColor = UIColor(red: 43/255, green: 173/255, blue: 43/255, alpha: 1.0)
        messageView.layer.cornerRadius = 8.0
        
        avatarImageV.image = ChatVCDefaultSetManager.shared.userAvatarImage

        let message = cellDict["content"] as? String ?? ""
        let textHeight = calculateHeight(forText: message, withFont: messageLabel.font, andWidth: kScreen_WIDTH-56-62-20)
        if textHeight < 20.0{
            messageViewHeight.constant = 36.0
            let textWidth = calculateWidth(forText: message, withFont: messageLabel.font, andHeight: textHeight)
            if textWidth >= kScreen_WIDTH-56-62-20{
                messageViewWidth.constant = kScreen_WIDTH-56-62
            }else{
                messageViewWidth.constant = textWidth+20
            }
        }else{
            messageViewHeight.constant = textHeight + 20
            messageViewWidth.constant = kScreen_WIDTH-56-62
        }
        messageLabel.text = message
    }
    
}
