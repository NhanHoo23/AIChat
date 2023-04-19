//
//  MainViewController.swift
//  Dalle-E
//
//  Created by Nhan Ho on 09/02/2023.
//

import MTSDK

//MARK: Init and Variables
class MainViewController: UIViewController {

    //Variables
    let containerView = UIView()
    let bottomView = UIView()
    let tabbarView = TabbarView()
    var collectionView: UICollectionView!
    
    let chatVC = ChatViewController()
    let imageVC = ImageViewController()
    let favVC = FavouriteViewController()
    
    var viewControllers: [UIViewController] = []
    var selectedIndex: Int = -1
}

//MARK: Lifecycle
extension MainViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        viewControllers = [chatVC, imageVC, favVC] //
        setupView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(true, animated: false)
    }

    override var preferredStatusBarStyle: UIStatusBarStyle {return .lightContent}
}

//MARK: SetupView
extension MainViewController {
    private func setupView() {
        let bg = UIImageView()
        bg >>> view >>> {
            $0.snp.makeConstraints {
                $0.edges.equalToSuperview()
            }
            $0.image = UIImage(named: "img_background")
        }
        
        tabbarView >>> view >>> {
            $0.snp.makeConstraints {
                $0.centerX.equalToSuperview()
                $0.bottom.equalTo(botSafe).offset(-20)
                $0.height.equalTo(Const.tabbarHeight)
                $0.width.equalTo(maxWidth * 0.6)
            }
            $0.delegate = self
        }
        
        containerView >>> view >>> {
            $0.snp.makeConstraints {
                $0.edges.equalToSuperview()
            }
        }
        
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView >>> containerView >>> {
            $0.snp.makeConstraints {
                $0.edges.equalToSuperview()
            }
            $0.delegate = self
            $0.dataSource = self
            $0.registerReusedCell(MainCollectionViewCell.self)
            $0.backgroundColor = .clear
            $0.isScrollEnabled = false
        }
        
        setupTabbar()
        setSelectedView(index: 0)
    }

}

//MARK: Functions
extension MainViewController {
    func setupTabbar() {
        let chatItem = TabbarItemView(imageName: "message", selectedImageName: "message")
        self.tabbarView.addItem(item: chatItem)
        
        let imageItem = TabbarItemView(imageName: "photo.on.rectangle.angled", selectedImageName: "photo.on.rectangle.angled")
        self.tabbarView.addItem(item: imageItem)
        
        let favItem = TabbarItemView(imageName: "heart.fill", selectedImageName: "heart.fill")
        self.tabbarView.addItem(item: favItem)
    }
    
    func setSelectedView(index: Int) {
//        if self.selectedIndex >= 0 {
//            viewControllers[self.selectedIndex].remove()
//        }
//        self.selectedIndex = index
//        let viewcontroller = self.viewControllers[index]
//        self.add(viewcontroller)
        guard let cv = self.collectionView else {return}
        cv.scrollToItem(at: IndexPath(item: index, section: 0), at: .centeredHorizontally, animated: true)
        
//        viewcontroller.view.snp.makeConstraints {
//            $0.top.leading.trailing.bottom.equalTo(self.containerView)
//        }
        self.view.bringSubviewToFront(tabbarView)
    }
}

//MARK: Delegate
extension MainViewController: TabbarViewDelegate {
    func didSelectAt(index: Int) {
//        if selectedIndex == index {return}
        if index == 2 {
            self.favVC.loadData()
        }
        self.setSelectedView(index: index)
    }
}

extension MainViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.viewControllers.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusable(cellClass: MainCollectionViewCell.self, indexPath: indexPath)
        cell.configsCell(vc: self.viewControllers[indexPath.item])
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: maxWidth, height: maxHeight)
    }
}
