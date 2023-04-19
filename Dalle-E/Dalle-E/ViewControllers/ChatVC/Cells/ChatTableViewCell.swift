//
//  ChatTableViewCell.swift
//  Dalle-E
//
//  Created by Nhan Ho on 09/02/2023.
//

import MTSDK
import NVActivityIndicatorView

class ChatTableViewCell: UITableViewCell {
    
    
    //Variables
    var containerView: UIView!
    let contentFont = UIFont.boldSystemFont(ofSize: 15)
    let contentLb = UILabel()
    let contentTextView = UIView()
    let imageDisplay = UIImageView()
    let typingView = NVActivityIndicatorView(frame: .zero, type: .ballPulse, color: .white)
}


//MARK: Functions
extension ChatTableViewCell {
    func configsCell(message: MessageModel) {
        if containerView == nil {
            self.setupView()
        }
        if message.text == "Error, ChatGPT is currently not available" {
            self.contentLb.textColor = .red
        } else {
            self.contentLb.textColor = .white
        }
        
        contentLb.text = message.text
        
        if message.sender == .ai {
            imageDisplay.image = UIImage(named: Sender.ai.displayImage)
            if message.isTyping {
                self.typingView.isHidden = false
                self.typingView.startAnimating()
            } else {
                self.typingView.isHidden = true
                self.typingView.stopAnimating()
            }
        } else {
            self.typingView.isHidden = true
            self.typingView.stopAnimating()
            imageDisplay.image = UIImage(named: Sender.human.displayImage)
        }
    }
    
    private func setupView() {
        backgroundColor = .clear
        contentView.backgroundColor = .clear
        
        containerView = UIView()
        containerView >>> contentView >>> {
            $0.snp.makeConstraints {
                $0.top.equalToSuperview().offset(10)
                $0.leading.trailing.equalToSuperview()
                $0.bottom.equalToSuperview().offset(-10)
            }
            $0.backgroundColor = .clear
        }
        
        contentTextView >>> containerView >>> {
            $0.snp.makeConstraints {
                $0.top.bottom.leading.trailing.equalToSuperview()
            }
            $0.layer.masksToBounds = true
        }
        
        imageDisplay >>> contentTextView >>> {
            $0.snp.makeConstraints {
                $0.centerY.equalToSuperview()
                $0.leading.equalToSuperview().offset(15)
                $0.width.height.equalTo(45)
            }
            $0.contentMode = .scaleAspectFit
        }
        
        contentLb >>> contentTextView >>> {
            $0.snp.makeConstraints {
                $0.top.bottom.equalToSuperview()
                $0.leading.equalTo(imageDisplay.snp.trailing).offset(10)
                $0.trailing.equalToSuperview().offset(-15)
            }
            $0.textColor = .white
            $0.numberOfLines = 0
            $0.font = contentFont
        }
        
        typingView >>> contentTextView >>> {
            $0.snp.makeConstraints {
                $0.centerY.equalToSuperview()
                $0.leading.equalTo(imageDisplay.snp.trailing).offset(15)
                $0.height.equalTo(30)
                $0.width.equalTo(30)
            }
        }
    }

}
