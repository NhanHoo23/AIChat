//
//  MainViewController.swift
//  Dalle-E
//
//  Created by Nhan Ho on 08/02/2023.
//

import MTSDK
import OpenAIKit


//MARK: Init and Variables
class ImageViewController: UIViewController {

    //Variables
    let button = UIButton()
    let textField = UITextField()
    let imgView = UIImageView()
    let textFieldView = UIView()
    var collectionView: UICollectionView!
    var images = [UIImage]()
    var yFrame: CGFloat = 0
    var options:[VipMenuItem] = []
    var cellSelected: UICollectionViewCell!
}

//MARK: Lifecycle
extension ImageViewController {
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

//MARK: SetupView
extension ImageViewController {
    private func setupView() {
        let titleLb = UILabel()
        titleLb >>> view >>> {
            $0.snp.makeConstraints {
                $0.centerX.equalToSuperview()
                $0.top.equalTo(topSafe).offset(20)
            }
            $0.text = "AI Image"
            $0.textColor = .black
            $0.font = UIFont(name: FNames.demiBold, size: 50)
        }
        
        button >>> view >>> {
            $0.snp.makeConstraints {
                $0.centerX.equalToSuperview()
                $0.bottom.equalToSuperview().offset(Const.bottomOffset)
                $0.width.equalTo(100)
                $0.height.equalTo(50)
            }
            $0.setTitle("Generate", for: .normal)
            $0.titleLabel?.font = UIFont(name: FNames.demiBold, size: 18)
            $0.setTitleColor(.black, for: .normal)
            $0.layer.cornerRadius = 20
            $0.addDropShadow(color: .black, shadowOpacity: 0.5, shadowOffset: CGSize(width: 4, height: 4), shadowRadius: 10)
            $0.backgroundColor = .white
            $0.handle {
                if let text = self.textField.text, !text.trimmingCharacters(in: .whitespaces).isEmpty {
                    self.showLoading(color: .red)
                    Task {
                        let result = await API.shared.generateImage(prompt: text)
                        if result == nil {
                            print("fail")
                        }

                        DispatchQueue.main.async {
                            self.images.removeAll()
                            self.hideLoading()
                            if let result = result {
                                self.images = result
                            }
                            self.collectionView.reloadData()
                        }
                    }
                } else {
                    self.textFieldView.shake(0, direction: .horizontal)
                }
            }
        }
        
        textFieldView >>> view >>> {
            $0.snp.makeConstraints {
                $0.bottom.equalTo(button.snp.top).offset(-20)
                $0.leading.equalToSuperview().offset(25)
                $0.trailing.equalToSuperview().offset(-25)
                $0.height.equalTo(43)
            }
            $0.backgroundColor = .white
            $0.layer.cornerRadius = 10
            $0.addDropShadow(color: .black, shadowOpacity: 0.5, shadowOffset: CGSize(width: 4, height: 4), shadowRadius: 10)
        }
        
        textField >>> textFieldView >>> {
            $0.snp.makeConstraints {
                $0.top.bottom.equalToSuperview()
                $0.leading.equalToSuperview().offset(10)
                $0.trailing.equalToSuperview().offset(-10)
            }
            $0.delegate = self
            $0.clearButtonMode = .whileEditing
            $0.textColor = .black
            $0.attributedPlaceholder = NSAttributedString(string: "Type description to create images", attributes: [NSAttributedString.Key.foregroundColor: UIColor.from("7f7f7f")])
            
            if let clearButton = textField.value(forKey: "_clearButton") as? UIButton {
                let templateImage = clearButton.imageView?.image?.withRenderingMode(.alwaysTemplate)
                clearButton.setImage(templateImage, for: .normal)
                clearButton.tintColor = .darkGray
            }
        }
        
        let layout = UICollectionViewFlowLayout()
        layout.sectionInset = UIEdgeInsets(top: 25, left: 25, bottom: 0, right: 25)
        collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView >>> view >>> {
            $0.snp.makeConstraints {
                $0.top.equalTo(titleLb.snp.bottom)
                $0.leading.equalToSuperview()
                $0.trailing.equalToSuperview()
                $0.bottom.equalToSuperview()
            }
            $0.delegate = self
            $0.dataSource = self
            $0.registerReusedCell(ImageCollectionViewCell.self)
            $0.backgroundColor = .clear
            $0.isScrollEnabled = false
        }
        
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(self.dismissKeyboard))
        tap.cancelsTouchesInView = false
        collectionView.addGestureRecognizer(tap)
        
        self.view.bringSubviewToFront(self.textFieldView)
        self.view.bringSubviewToFront(self.button)
    }

}

//MARK: Functions
extension ImageViewController {
    @objc func keyboardWillShow(notification: NSNotification) {
        if let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
            self.textFieldView.snp.removeConstraints()
            self.textFieldView.snp.makeConstraints {
                $0.bottom.equalToSuperview().offset(-keyboardSize.height - 10)
                $0.leading.equalToSuperview().offset(25)
                $0.trailing.equalToSuperview().offset(-25)
                $0.height.equalTo(43)
            }
            UIView.animate(withDuration: 0.3, animations:  {
                self.view.layoutIfNeeded()
            })
            print("keyboardHeight: \(keyboardSize.height)")
        }
    }

    @objc func keyboardWillHide(notification: NSNotification) {
        self.textFieldView.snp.removeConstraints()
        self.textFieldView.snp.makeConstraints {
            $0.bottom.equalTo(button.snp.top).offset(-20)
            $0.leading.equalToSuperview().offset(25)
            $0.trailing.equalToSuperview().offset(-25)
            $0.height.equalTo(43)
        }
        UIView.animate(withDuration: 0.3, animations:  {
            self.view.layoutIfNeeded()
        })
    }
    
    @objc func image(_ image: UIImage, didFinishSavingWithError error: Error?, contextInfo: UnsafeRawPointer) {
        if let error = error {
            print(error.localizedDescription)
        } else {
            print("Download success")
            self.showAlert(message: "Image downloaded!", actionTile: "OK", completion: nil)
        }
    }
}


//MARK: CollectionView
extension ImageViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.images.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusable(cellClass: ImageCollectionViewCell.self, indexPath: indexPath)
        options = [VipMenuItem(id: 1, title: "Share", icon: UIImage(systemName: "square.and.arrow.up")),
                   VipMenuItem(id: 2, title: "Favourite", icon: UIImage(systemName: "heart")),
                   VipMenuItem(id: 3, title: "Download", icon: UIImage(systemName: "arrow.down.app"))
                   
        ]
        var contextMenu: VipMenu!
        contextMenu = VipMenu()
            .setItems(options)
            .setDelegate(self)
            .setIconsDefaultColorTo(UIColor.from("212121"))
            .setBackgroundColorTo(.black)
            .setTouchPointColorTo(.black)
        
        cell.configsCell(image: self.images[indexPath.item], contextMenu: contextMenu)
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = (collectionView.bounds.width - 25 * 3) / 2
        
        return CGSize(width: width, height: width)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 25
    }
    
//    func collectionView(_ collectionView: UICollectionView, contextMenuConfigurationForItemsAt indexPaths: [IndexPath], point: CGPoint) -> UIContextMenuConfiguration? {
//        let config = UIContextMenuConfiguration(identifier: nil, previewProvider: nil) { _ in
//            let open = UIAction(title: "Share",
//                                image: UIImage(systemName: "square.and.arrow.up"),
//                                identifier: nil,
//                                discoverabilityTitle: nil,
//                                state: .off, handler: { _ in
//                                    self.share(items: [self.images[indexPaths[0].item]])
//                                })
//
//            return UIMenu(title: "", image: nil, identifier: nil, options: .displayInline, children: [open])
//        }
//
//        return config
//    }
}

//MARK: Delegate
extension ImageViewController: UITextFieldDelegate, VipMenuDelegate{
    func menuOpened() {
        print("menu open")
    }
    
    func menuClosed() {
        print("menu close")
    }
    
    func menuItemWasSelected(item: VipMenuItem, cellSelected: UICollectionViewCell) {
        guard let indexPath = collectionView.indexPath(for: cellSelected) else { return}
        let image = self.images[indexPath.item]
        if item.id == 1 {
            self.share(items: [image])
        } else if item.id == 2 {
            let model = FavouriteModel(imageData: image.pngData()!)
            AppManager.shared.favModels.append(model)
            let realmModel = RealmFavouriteModel(from: model)
            RealmDB.shared.update(realmModel)
        } else {
            UIImageWriteToSavedPhotosAlbum(image, self, #selector(image(_:didFinishSavingWithError:contextInfo:)), nil)
        }
    }
    
    func menuItemWasActivated(item: VipMenuItem) {
        print("Item \(item.title) was activated")
    }
    
    func menuItemWasDeactivated(item: VipMenuItem) {
        print("Item \(item.title) was deactivated")
    }
    
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.dismissKeyboard()
        
        return true
    }
}
