//
//  VipMenuItem.swift
//  Dalle-E
//
//  Created by Nhan Ho on 10/02/2023.
//

import MTSDK

class VipMenuItem: UIView {
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented")}
    init(id: Int, title: String, icon: UIImage?, data: Any? = nil) {
        super.init(frame: CGRect(x: 0, y: 0, width: VipMenuItem.itemWidth, height: VipMenuItem.itemHeight))
        self.setupView()
        
        self.id = id
        self.data = data
        self.title = title
        self.icon.image = icon
    }
    
    //Variables
    private static let itemWidth = 55
    private static let itemHeight = 55
    
    var id: Int?
    var title: String = ""
    var data: Any?
    var angle: CGFloat = 0
    var isActive: Bool = false
    private let icon: UIImageView = {
        let icon = UIImageView()
        icon.contentMode = .scaleAspectFit
        icon.translatesAutoresizingMaskIntoConstraints = false
        return icon
    }()
    
    private let button: UIButton = {
        let button = UIButton(frame: CGRect(x: 0, y: 0, width: VipMenuItem.itemWidth, height: VipMenuItem.itemHeight))
        button.fullCircle = true
        button.addDropShadow(color: .black, shadowOpacity: 0.6, shadowOffset: CGSize(width: 0, height: 2), shadowRadius: 2)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    let wrapper: UIView = {
        let view = UIView(frame: CGRect(x: 0, y: 0, width: VipMenuItem.itemWidth, height: VipMenuItem.itemHeight))
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
}


//MARK: SetupView
extension VipMenuItem {
    private func setupView() {
        wrapper >>> self >>> {
            $0.snp.makeConstraints {
                $0.edges.equalToSuperview()
            }
        }
        
        button >>> wrapper >>> {
            $0.snp.makeConstraints {
                $0.edges.equalToSuperview()
            }
        }
        
        icon >>> wrapper >>> {
            $0.snp.makeConstraints {
                $0.center.equalToSuperview()
                $0.width.height.equalTo(25)
            }
        }
    }

}

//MARK: Functions
extension VipMenuItem {
    @objc func setItemColorTo(_ itemColor: UIColor, iconColor: UIColor? = nil) {
        if let color = iconColor {
            let templateImage = icon.image?.withRenderingMode(.alwaysTemplate)
            icon.image = templateImage
            icon.tintColor = color
        } else {
            let templateImage = icon.image?.withRenderingMode(.alwaysOriginal)
            icon.image = templateImage
            icon.tintColor = nil
        }
        button.backgroundColor = itemColor
    }
}
