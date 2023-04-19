//
//  FavouriteViewController.swift
//  Dalle-E
//
//  Created by Nhan Ho on 13/02/2023.
//

import MTSDK

//MARK: Init and Variables
class FavouriteViewController: UIViewController {

    //Variables
    var models: [FavouriteModel] = AppManager.shared.favModels
    var collectionView: UICollectionView!
    var options: [VipMenuItem] = []
}

//MARK: Lifecycle
extension FavouriteViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        loadData()
        setupView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(true, animated: false)
    }

    override var preferredStatusBarStyle: UIStatusBarStyle {return .lightContent}
}

//MARK: Functions
extension FavouriteViewController {
    private func setupView() {
        let titleLb = UILabel()
        titleLb >>> view >>> {
            $0.snp.makeConstraints {
                $0.centerX.equalToSuperview()
                $0.top.equalTo(topSafe).offset(20)
            }
            $0.text = "Favourite"
            $0.textColor = .black
            $0.font = UIFont(name: FNames.demiBold, size: 50)
        }
        
        let layout = UICollectionViewFlowLayout()
        layout.sectionInset = UIEdgeInsets(top: 25, left: 25, bottom: -Const.bottomOffset, right: 25)
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
            $0.alwaysBounceVertical = true
        }
    }

    func loadData() {
        self.models = AppManager.shared.favModels
        
        let object = RealmDB.shared.getObjects(type: RealmFavouriteModel.self)
        self.models = object.compactMap {FavouriteModel(from: $0)}.reversed()
        
        if let cv = self.collectionView {
            cv.reloadData()
        }
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

extension FavouriteViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.models.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusable(cellClass: ImageCollectionViewCell.self, indexPath: indexPath)
        options = [VipMenuItem(id: 1, title: "Share", icon: UIImage(systemName: "square.and.arrow.up")),
                   VipMenuItem(id: 2, title: "Delete", icon: UIImage(systemName: "trash")),
                   VipMenuItem(id: 3, title: "Download", icon: UIImage(systemName: "arrow.down.app"))
                   
        ]
        var contextMenu: VipMenu!
        contextMenu = VipMenu()
            .setItems(options)
            .setDelegate(self)
            .setIconsDefaultColorTo(UIColor.from("212121"))
            .setBackgroundColorTo(.black)
            .setTouchPointColorTo(.black)
        let image = UIImage(data: self.models[indexPath.item].imageData!)
        cell.configsCell(image: image!, contextMenu: contextMenu)
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = (collectionView.bounds.width - 25 * 3) / 2
        
        return CGSize(width: width, height: width)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 25
    }
}

extension FavouriteViewController: VipMenuDelegate {
    func menuOpened() {
        //
    }
    
    func menuClosed() {
        //
    }
    
    func menuItemWasSelected(item: VipMenuItem, cellSelected: UICollectionViewCell) {
        guard let indexPath = collectionView.indexPath(for: cellSelected) else { return}
        let model = self.models[indexPath.item]
        if item.id == 1 {
            self.share(items: [model.imageData!])
        } else if item.id == 2 {
            self.models.removeAll(where: {$0.id == model.id})
            if let cv = self.collectionView {
                cv.deleteItems(at: [indexPath])
            }
            
            let realmModel = RealmFavouriteModel(from: model)
            RealmDB.shared.update(realmModel)
            RealmDB.shared.delete(object: realmModel)
        } else {
            UIImageWriteToSavedPhotosAlbum(UIImage(data: model.imageData)!, self, #selector(image(_:didFinishSavingWithError:contextInfo:)), nil)
        }
    }
    
    func menuItemWasActivated(item: VipMenuItem) {
        //
    }
    
    func menuItemWasDeactivated(item: VipMenuItem) {
        //
    }
    
    
}
