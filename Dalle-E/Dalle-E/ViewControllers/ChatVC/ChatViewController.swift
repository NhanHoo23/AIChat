//
//  ChatViewController.swift
//  Dalle-E
//
//  Created by Nhan Ho on 09/02/2023.
//

import MTSDK
import Hero

//MARK: Init and Variables
class ChatViewController: UIViewController {

    //Variables
    let textField = UITextField()
    let textFieldView = UIView()
    let sentBt = UIButton()
    let tableView = UITableView()
    
    var messageArr: [MessageModel] = []
    var yFrame: CGFloat = 0
}

//MARK: Lifecycle
extension ChatViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(true, animated: false)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        self.yFrame = self.textFieldView.frame.origin.y
    }

    override var preferredStatusBarStyle: UIStatusBarStyle {return .lightContent}
}

//MARK: Functions
extension ChatViewController {
    private func setupView() {
        let titleLb = UILabel()
        titleLb >>> view >>> {
            $0.snp.makeConstraints {
                $0.centerX.equalToSuperview()
                $0.top.equalTo(topSafe).offset(20)
            }
            $0.text = "AI Chat"
            $0.textColor = .black
            $0.font = UIFont(name: FNames.demiBold, size: 50)
        }
        
        textFieldView >>> view >>> {
            $0.snp.makeConstraints {
                $0.bottom.equalToSuperview().offset(Const.bottomOffset)
                $0.leading.equalToSuperview().offset(25)
                $0.trailing.equalToSuperview().offset(-25)
                $0.height.greaterThanOrEqualTo(43)
            }
            $0.backgroundColor = .white
            $0.layer.cornerRadius = 10
            $0.addDropShadow(color: .black, shadowOpacity: 0.5, shadowOffset: CGSize(width: 4, height: 4), shadowRadius: 10)
        }
        
        sentBt >>> textFieldView >>> {
            $0.snp.makeConstraints {
                $0.top.trailing.bottom.equalToSuperview()
                $0.width.equalTo(sentBt.snp.height).multipliedBy(1)
            }
            $0.setImage(UIImage(systemName: "paperplane"), for: .normal)
            $0.tintColor = .black
            $0.handle {
                self.view.endEditing(true)
                self.getText()
            }
        }
        
        textField >>> textFieldView >>> {
            $0.snp.makeConstraints {
                $0.top.bottom.equalToSuperview()
                $0.trailing.equalTo(sentBt.snp.leading).offset(-10)
                $0.leading.equalToSuperview().offset(10)
            }
            $0.keyboardType = .alphabet
            $0.clearButtonMode = .whileEditing
            $0.textColor = .black
            $0.attributedPlaceholder = NSAttributedString(string: "Type Here", attributes: [NSAttributedString.Key.foregroundColor: UIColor.from("7f7f7f")])
            
            if let clearButton = textField.value(forKey: "_clearButton") as? UIButton {
                let templateImage = clearButton.imageView?.image?.withRenderingMode(.alwaysTemplate)
                clearButton.setImage(templateImage, for: .normal)
                clearButton.tintColor = .darkGray
            }
        }
        
        tableView >>> view >>> {
            $0.snp.makeConstraints {
                $0.leading.trailing.equalToSuperview()
                $0.bottom.equalTo(textFieldView.snp.top)
                $0.top.equalTo(titleLb.snp.bottom).offset(10)
            }
            $0.delegate = self
            $0.dataSource = self
            $0.registerReusedCell(ChatTableViewCell.self)
            $0.backgroundColor = .clear
            $0.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 10, right: 0)
        }
        
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(self.dismissKeyboard))
        tap.cancelsTouchesInView = false
        tableView.addGestureRecognizer(tap)
    }

}

//MARK: Functions
extension ChatViewController {
    @objc func keyboardWillShow(notification: NSNotification) {
        if let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
            self.textFieldView.snp.updateConstraints {
                $0.bottom.equalToSuperview().offset(-keyboardSize.height - 10)
            }
            UIView.animate(withDuration: 0.3, animations:  {
                self.view.layoutIfNeeded()
            })
            if self.tableView.numberOfRows(inSection: 0) > 0 {
                self.tableView.scrollToRow(at: IndexPath(row: self.tableView.numberOfRows(inSection: 0) - 1, section: 0),
                                           at: .bottom,
                                           animated: true)
            }
            print("keyboardHeight: \(keyboardSize.height)")
        }
    }

    @objc func keyboardWillHide(notification: NSNotification) {
        self.textFieldView.snp.updateConstraints {
            $0.bottom.equalToSuperview().offset(Const.bottomOffset)
        }
        UIView.animate(withDuration: 0.3, animations:  {
            self.view.layoutIfNeeded()
        })
    }
    
    func getText() {
        if let text = textField.text, !text.isEmpty {
            let userMess = MessageModel(text: text)
            let messIndexPath = IndexPath(item: self.messageArr.count, section: 0)
            self.messageArr.append(userMess)
            self.textField.text = ""
            
            let typingMess = MessageModel(text: "", sender: .ai, isTyping: true)
            let typingMessIndexPath = IndexPath(item: self.messageArr.count, section: 0)
            self.messageArr.append(typingMess)
            
            self.sentBt.disable()
            DispatchQueue.main.async {
                self.tableView.insertRows(at: [messIndexPath, typingMessIndexPath], with: .none)
                self.tableView.scrollToRow(at: IndexPath(row: self.tableView.numberOfRows(inSection: 0) - 1, section: 0),
                                           at: .bottom,
                                           animated: true)
            }
            
            Task {
                let result = await API.shared.getResponse(input: text)
                if result == "" {
                    print("fail")
                    self.messageArr.removeLast()
                    
                    let failMess = MessageModel(text: "Error, ChatGPT is currently not available", sender: .ai)
                    self.messageArr.append(failMess)
                    self.sentBt.enable()
                    
                    DispatchQueue.main.async {
                        self.tableView.reloadRows(at: [IndexPath(row: self.messageArr.count - 1, section: 0)], with: .fade)
                        self.tableView.scrollToRow(at: IndexPath(row: self.tableView.numberOfRows(inSection: 0) - 1, section: 0),
                                                   at: .bottom,
                                                   animated: true)
                    }
                    
                    return 
                }
                
                self.messageArr.removeLast()
                
                let AIMess = MessageModel(text: result, sender: .ai)
                self.messageArr.append(AIMess)
                self.sentBt.enable()
                
                DispatchQueue.main.async {
                    self.tableView.reloadRows(at: [IndexPath(row: self.messageArr.count - 1, section: 0)], with: .fade)
                    self.tableView.scrollToRow(at: IndexPath(row: self.tableView.numberOfRows(inSection: 0) - 1, section: 0),
                                               at: .bottom,
                                               animated: true)
                }
            }
        }
    }
}

//MARK: Delegate
extension ChatViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return messageArr.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusable(cellClass: ChatTableViewCell.self, indexPath: indexPath)
        cell.configsCell(message: self.messageArr[indexPath.row])
        cell.selectionStyle = .none
        
        return cell 
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let minHeight: CGFloat = Const.imgDisplayWidth + 20
        let chatheight: CGFloat = messageArr[indexPath.row].text.height(width: maxWidth - Const.imgDisplayWidth - 30 - 10, font: UIFont.boldSystemFont(ofSize: 15)) + 20
        
        return max(minHeight, chatheight)
    }
    
}
