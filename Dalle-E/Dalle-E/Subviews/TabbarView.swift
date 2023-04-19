//
//  TabbarView.swift
//  Dalle-E
//
//  Created by Nhan Ho on 09/02/2023.
//

import MTSDK

protocol TabbarViewDelegate {
    func didSelectAt(index: Int)
}

class TabbarView: UIView {
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented")}
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.setupView()
    }
    
    //Variables
    private var selectedIndex = 0
    private var stackView = UIStackView()
    
    var delegate: TabbarViewDelegate?
}


//MARK: Functions
extension TabbarView {
    private func setupView() {
        self.layer.cornerRadius = 25
        
        let blurEffect = UIBlurEffect(style: .light)
        let blurEffectView = UIVisualEffectView(effect: blurEffect)
        blurEffectView >>> self >>> {
            $0.snp.makeConstraints {
                $0.edges.equalToSuperview()
            }
            $0.layer.cornerRadius = 25
            $0.layer.masksToBounds = true
        }
        
        stackView >>> self >>> {
            $0.snp.makeConstraints {
                $0.edges.equalToSuperview()
            }
            $0.spacing = 0
            $0.distribution = .fillEqually
        }
    }

    func addItem(item: TabbarItemView) {
        item.tag = self.stackView.arrangedSubviews.count
        item.isSelected = item.tag == self.selectedIndex
        
        item.itemHandle {
            if self.selectedIndex == item.tag {return}
            self.selectedIndex = item.tag
            self.updateSeleted()
            self.delegate?.didSelectAt(index: item.tag)
        }
        
        self.stackView.addArrangedSubview(item)
    }
    
    private func updateSeleted() {
        for item in self.stackView.arrangedSubviews {
            if let tabbarItem = item as? TabbarItemView {
                tabbarItem.isSelected = tabbarItem.tag == self.selectedIndex
            }
        }
    }

}

