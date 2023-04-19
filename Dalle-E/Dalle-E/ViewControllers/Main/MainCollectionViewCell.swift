//
//  MainCollectionViewCell.swift
//  Dalle-E
//
//  Created by Nhan Ho on 09/02/2023.
//

import MTSDK

class MainCollectionViewCell: UICollectionViewCell {
    
    
    //Variables
    var containerView: UIView!
    var vc: UIViewController!
}


//MARK: Functions
extension MainCollectionViewCell {
    func configsCell(vc: UIViewController) {
        self.vc = vc
        if containerView == nil {
            self.setupView()
        }
    }
    
    private func setupView() {
        backgroundColor = .clear
        contentView.backgroundColor = .clear
        
        containerView = UIView()
        containerView >>> contentView >>> {
            $0.snp.makeConstraints {
                $0.edges.equalToSuperview()
            }
            $0.backgroundColor = .clear
        }
        
        vc.view >>> containerView >>> {
            $0.snp.makeConstraints {
                $0.edges.equalToSuperview()
            }
        }
    }

}
