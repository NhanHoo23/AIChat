//
//  TabbarItem.swift
//  Dalle-E
//
//  Created by Nhan Ho on 09/02/2023.
//

import MTSDK

class TabbarItemView: UIView {
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented")}
    init(itemName: String = "", imageName: String, selectedImageName: String, textColor: UIColor = .white, selectedTextColor: UIColor = .red) {
        super.init(frame: .zero)
        self.setupView()
        
        self.imageName = imageName
//        self.itemName = itemName
        self.selectedImageName = selectedImageName
//        self.textColor = textColor
//        self.selectedTextColor = selectedTextColor
    }
    
    //Variables
    let imageView = UIImageView()
//    let itemNameLb = UILabel()
    let button = UIButton()
    let lineView = UIView()
    
//    var itemName: String!
    
    var imageName: String!
    var selectedImageName: String!
//    var textColor: UIColor!
//    var selectedTextColor: UIColor!
    
    private var action: (() -> Void)?
    
    var isSelected: Bool = false {
        didSet {
            self.updateState()
        }
    }
}


//MARK: Functions
extension TabbarItemView {
    
    private func setupView() {
        self.backgroundColor = .clear
        
//        itemNameLb >>> self >>> {
//            $0.snp.makeConstraints {
//                $0.bottom.equalToSuperview().offset(-8)
//                $0.centerX.equalToSuperview()
//            }
//            $0.backgroundColor = .clear
//            $0.textColor = textColor
//            $0.font = UIFont(name: FNames.bold, size: 12)
//        }
        
        lineView >>> self >>> {
            $0.snp.makeConstraints {
                $0.top.equalToSuperview()
                $0.centerX.equalToSuperview()
                $0.height.equalTo(3)
                $0.width.equalTo(Const.tabbarItemWidth)
            }
            $0.layer.cornerRadius = 1.5
            $0.backgroundColor = .blue.withAlphaComponent(0.6)
        }
        
        imageView >>> self >>> {
            $0.snp.makeConstraints {
                $0.bottom.equalToSuperview().offset(Const.tabbarItemBottomPadding)
//                $0.top.equalToSuperview().offset(20)
//                $0.leading.trailing.equalToSuperview()
                $0.centerX.equalToSuperview()
                $0.width.height.equalTo(Const.tabbarItemWidth)
            }
            $0.backgroundColor = .clear
            $0.contentMode = .scaleAspectFit
        }
        
        button >>> self >>> {
            $0.snp.makeConstraints {
                $0.edges.equalToSuperview()
            }
            $0.handle {
                if self.action != nil {
                    self.action!()
                }
            }
        }
    }
    
    func itemHandle(tap: @escaping() -> Void) {
        self.action = tap
    }
    
    func updateState() {
        let image = self.isSelected ? self.selectedImageName : self.imageName
        self.imageView.image = UIImage(systemName: image!)
        imageView.tintColor = .black
        if self.isSelected {
            if !AppManager.shared.isLoginApp {
                AppManager.shared.isLoginApp = true
                return
            }
            
            DispatchQueue.main.async {
                UIView.animate(withDuration: 0.2, animations: {
                    self.imageView.transform = CGAffineTransform(scaleX: 1.2, y: 1.2)
                    self.lineView.alpha = 1
                })
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.2, execute: {
                    self.imageView.transform = .identity
                })
            }
        } else {
            DispatchQueue.main.async {
                UIView.animate(withDuration: 0.2, animations: {
                    self.lineView.alpha = 0
                })
             
            }
        }
//        self.itemNameLb.text = self.itemName
//        self.itemNameLb.textColor = self.isSelected ? selectedTextColor : textColor
    }

}
