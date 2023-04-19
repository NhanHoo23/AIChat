//
//  ImageCollectionViewCell.swift
//  Dalle-E
//
//  Created by Nhan Ho on 10/02/2023.
//

import MTSDK

class ImageCollectionViewCell: UICollectionViewCell {
    
    
    //Variables
    var containerView: UIView!
    let imgDisplay = UIImageView()
}


//MARK: Functions
extension ImageCollectionViewCell {
    func configsCell(image: UIImage, contextMenu: VipMenu) {
        if containerView == nil {
            self.setupView()
        }
        self.imgDisplay.image = image
        self.addGestureRecognizer(contextMenu.build(cell: self))
    }
    
    private func setupView() {
        backgroundColor = .clear
        contentView.backgroundColor = .clear
        contentView.layer.cornerRadius = 15
        contentView.layer.masksToBounds = true
        
        containerView = UIView()
        containerView >>> contentView >>> {
            $0.snp.makeConstraints {
                $0.edges.equalToSuperview()
            }
            $0.backgroundColor = .clear
        }
        
        imgDisplay >>> containerView >>> {
            $0.snp.makeConstraints {
                $0.edges.equalToSuperview()
            }
            $0.contentMode = .scaleAspectFit
        }
    }

}
