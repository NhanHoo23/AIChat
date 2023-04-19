//
//  VipMenuViewView.swift
//  Dalle-E
//
//  Created by Nhan Ho on 10/02/2023.
//

import MTSDK

protocol VipMenuDelegate {
    func menuOpened()
    func menuClosed()
    func menuItemWasSelected(item:VipMenuItem, cellSelected: UICollectionViewCell)
    func menuItemWasActivated(item:VipMenuItem)
    func menuItemWasDeactivated(item:VipMenuItem)
}

@objc open class VipMenu:NSObject{
    
    /// The delegate to notify the JonContextMenu host when an item is selected
    var delegate:VipMenuDelegate?
    
    /// The items to be displayed
    var items:[VipMenuItem] = []
    
    /// The Background's alpha of the view
    var backgroundAlpha:CGFloat = 0.9
    
    /// The Background's colour of the view
    var backgroundColor:UIColor = .black
    
    /// The items' buttons default colour
    var buttonsDefaultColor:UIColor = .white
    
    /// The items' buttons active colour
    var buttonsActiveColor:UIColor = UIColor.from("c62828") // Red
    
    /// The items' icons default colour
    var iconsDefaultColor:UIColor?
    
    /// The items' icons active colour
    var iconsActiveColor:UIColor = .black
    
    /// The size of the title of the menu items
    var itemsTitleSize:CGFloat = 54
    
    /// The colour of the title of the menu items
    var itemsTitleColor:UIColor = UIColor.white 
    
    /// The colour of the touch location view
    var touchPointColor:UIColor = UIColor.from("212121") // Dark Gray
    
    /// The view selected by the user
    var highlightedView:UIView!
        
    override public init(){
        super.init()
    }
    
    /// Sets the items for the VipMenu
    func setItems(_ items: [VipMenuItem])->VipMenu{
        self.items = items
        return self
    }
    
    /// Sets the delegate for the VipMenu
    func setDelegate(_ delegate: VipMenuDelegate?)->VipMenu{
        self.delegate = delegate
        return self
    }
    
    /// Sets the background of the VipMenu
    func setBackgroundColorTo(_ backgroundColor: UIColor, withAlpha alpha:CGFloat = 0.9)->VipMenu{
        self.backgroundAlpha = alpha
        self.backgroundColor = backgroundColor
        return self
    }
    
    /// Sets the colour of the buttons for when there is no interaction
    func setItemsDefaultColorTo(_ colour: UIColor)->VipMenu{
        self.buttonsDefaultColor = colour
        return self
    }
    
    /// Sets the colour of the buttons for when there is interaction
    func setItemsActiveColorTo(_ colour: UIColor)->VipMenu{
        self.buttonsActiveColor = colour
        return self
    }
    
    /// Sets the colour of the icons for when there is no interaction
    func setIconsDefaultColorTo(_ colour: UIColor?)->VipMenu{
        self.iconsDefaultColor = colour
        return self
    }
    
    /// Sets the colour of the icons for when there is interaction
    func setIconsActiveColorTo(_ colour: UIColor)->VipMenu{
        self.iconsActiveColor = colour
        return self
    }
    
    /// Sets the colour of the VipMenu items title
    func setItemsTitleColorTo(_ color: UIColor)->VipMenu{
        self.itemsTitleColor = color
        return self
    }
    
    /// Sets the size of the VipMenu items title
    func setItemsTitleSizeTo(_ size: CGFloat)->VipMenu{
        self.itemsTitleSize = size
        return self
    }
    
    /// Sets the colour of the VipMenu touch point
    func setTouchPointColorTo(_ color: UIColor)->VipMenu{
        self.touchPointColor = color
        return self
    }
    
    /// Builds the VipMenu
    func build(cell: UICollectionViewCell)->Builder{
        return Builder(self, cell: cell)
    }
    
    class Builder:UILongPressGestureRecognizer{
        
        /// The wrapper for the VipMenu
        private var window:UIWindow!
        
        /// The selected menu item
        private var currentItem:VipMenuItem?
        
        /// The JonContextMenu view
        private var contextMenuView:VipMenuView!
        
        /// The properties configuration to add to the VipMenu view
        private var properties:VipMenu!
        
        /// Indicates if there is a menu item active
        private var isItemActive = false
        
        /// Indicates if there is a menu item active
        private var cellSelected: UICollectionViewCell!
        
        @objc  init(_ properties:VipMenu, cell: UICollectionViewCell){
            super.init(target: nil, action: nil)
            guard let window = UIApplication.shared.keyWindow else{
                fatalError("No access to UIApplication Window")
            }
            self.cellSelected = cell
            self.window     = window
            self.properties = properties
            addTarget(self, action: #selector(setupTouchAction))
        }
        
        /// Gets a copy of the touched view to add to the Window
        private func getTouchedView(){
            let highlightedView   = self.view!.snapshotView(afterScreenUpdates: true)!
            highlightedView.frame = self.view!.superview!.convert(self.view!.frame, to: nil)
            highlightedView.layer.cornerRadius = 15
            
            UIView.animate(withDuration: 0.3, animations: {
                highlightedView.transform = CGAffineTransform(scaleX: 1.1, y: 1.1)
            })
            
            properties.highlightedView = highlightedView
        }
        
        /// Handle the touch events on the view
        @objc private func setupTouchAction(){
            let location = self.location(in: window)
            switch self.state {
                case .began:
                    longPressBegan(on: location)
                case .changed:
                    longPressMoved(to: location)
                case .ended:
                    longPressEnded()
                case .cancelled:
                    longPressCancelled()
                default:
                    break
            }
        }
        
        /// Trigger the events for when the touch begins
        private func longPressBegan(on location:CGPoint) {
            getTouchedView()
            showMenu(on: location)
        }
        
        // Triggers the events for when the touch ends
        private func longPressEnded() {
            if let currentItem = currentItem, currentItem.isActive{
                properties.delegate?.menuItemWasSelected(item: currentItem, cellSelected: cellSelected)
            }
            dismissMenu()
        }
        
        // Triggers the events for when the touch is cancelled
        private func longPressCancelled() {
            dismissMenu()
        }
        
        // Triggers the events for when the touch moves
        private func longPressMoved(to location:CGPoint) {
            if let currentItem = currentItem, currentItem.frame.contains(location){
                if !currentItem.isActive{
                    contextMenuView.activate(currentItem)
                    properties.delegate?.menuItemWasActivated(item: currentItem)
                }
            }
            else{
                if let currentItem = currentItem, currentItem.isActive{
                    contextMenuView.deactivate(currentItem)
                    properties.delegate?.menuItemWasDeactivated(item: currentItem)
                }
                for item in properties.items{
                    if item.frame.contains(location){
                        currentItem = item
                        break
                    }
                }
            }
        }
        
        /// Creates the VipMenu view and adds to the Window
        private func showMenu(on location:CGPoint){
            currentItem     = nil
            contextMenuView = VipMenuView(properties, touchPoint: location)
            
            window.addSubview(contextMenuView)
            properties.delegate?.menuOpened()
        }
        
        /// Removes the JonContextMenu view from the Window
        private func dismissMenu(){
            if let currentItem = currentItem{
                contextMenuView.deactivate(currentItem)
            }
            
            UIView.animate(withDuration: 0.2, animations: {
                self.properties.highlightedView.transform  = .identity
                self.contextMenuView.background.alpha = 0
                for item in self.properties.items {
                    item.alpha = 0
                }
            }, completion: { _ in
                self.contextMenuView.background.alpha = 1
                for item in self.properties.items {
                    item.alpha = 1
                }
                self.contextMenuView.removeFromSuperview()
            })
            properties.delegate?.menuClosed()
        }
    }
}
