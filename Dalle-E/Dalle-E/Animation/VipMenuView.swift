//
//  VipMenuView.swift
//  Dalle-E
//
//  Created by Nhan Ho on 10/02/2023.
//

import MTSDK

enum TouchDirection {
    case left
    case right
    case middle
    case up
    case down
}

class VipMenuView: UIView {
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented")}
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    init(_ properties: VipMenu, touchPoint: CGPoint) {
        super.init(frame: UIScreen.main.bounds)
        self.properties = properties
        self.touchPoint = touchPoint
        
        touchPointView = makeTouchPoint()
        currentDirection = calculateDirection(properties.items[0].wrapper.frame.width)
        
        setupView()
        configView()
        displayView()
    }
    
    //Variables
    let label: UILabel = {
        let label = UILabel()
        label.alpha = 0
        label.numberOfLines = 1
        label.textAlignment = .left
        label.adjustsFontSizeToFitWidth = true
        return label
    }()
    
    let background: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    var touchPointView: UIView!
    private var properties: VipMenu!
    private let distanceToTouchPoint: CGFloat = 30
    private var touchPoint: CGPoint!
    private var xDistanceToItem: CGFloat!
    private var yDistanceToItem: CGFloat!
    private var currentDirection: (TouchDirection, TouchDirection)!
}


//MARK: SetupView
extension VipMenuView {
    private func setupView() {
        background >>> self >>> {
            $0.snp.makeConstraints {
                $0.edges.equalToSuperview()
            }
        }
        
        self.addSubview(properties.highlightedView)
        self.addSubview(touchPointView)
        self.addSubview(label)
    }

    private func configView() {
        properties.items.forEach({
            $0.setItemColorTo(properties.buttonsDefaultColor, iconColor: properties.iconsDefaultColor)
        })
        
        touchPointView.borderColor = properties.touchPointColor
        
        background.alpha = properties.backgroundAlpha
        
        background.backgroundColor = properties.backgroundColor
        
        label.textColor = properties.itemsTitleColor
        
        label.font = UIFont.systemFont(ofSize: properties.itemsTitleSize, weight: .heavy)
    }
    
    private func displayView() {
        calculateDistanceToItem()
        resetItemsPosition()
        angleForDirection()
        
        for item in properties.items {
            self.addSubview(item)
            self.animateItem(item)
        }
    }
    
}

//MARK: Functions
extension VipMenuView {
    private func makeTouchPoint() -> UIView {
        let view = UIView(frame: CGRect(x: 0, y: 0, width: 45, height: 45))
        view.center = touchPoint
        view.backgroundColor = .clear
        view.fullCircle = true
        view.borderWidth = 3
        view.alpha = 1
        return view
    }
    
    private func calculateDirection(_ menuItemWidth: CGFloat) -> (TouchDirection, TouchDirection) {
        let touchWidth = distanceToTouchPoint + menuItemWidth + touchPointView.frame.width
        let touchHeight = distanceToTouchPoint + menuItemWidth + touchPointView.frame.height
        
        let verticalDirection = determineVerticalDirection(touchHeight)
        let horizolDirection = determineHorizalDirection(touchWidth)
        
        return (verticalDirection, horizolDirection)
    }
    
    private func determineVerticalDirection(_ size: CGFloat) -> TouchDirection {
        let isBottomBorderOfScreen = touchPoint.y + size > UIScreen.main.bounds.height
        let isTopBorderOfScreen = touchPoint.y - size < 0
        
        if isTopBorderOfScreen {
            return .down
        } else if isBottomBorderOfScreen {
            return .up
        } else {
            return .middle
        }
    }
    
    private func determineHorizalDirection(_ size: CGFloat) -> TouchDirection {
        let isRightBorderOfScreen = touchPoint.x + size > UIScreen.main.bounds.width
        let isLeftBorderOfScreen = touchPoint.x - size < 0
        
        if isLeftBorderOfScreen {
            return .right
        } else if isRightBorderOfScreen {
            return .left
        } else {
            return .middle
        }
    }
    
    private func calculateDistanceToItem() {
        xDistanceToItem = touchPointView.frame.width / 2 + distanceToTouchPoint + CGFloat(properties.items[0].frame.width / 2)
        yDistanceToItem = touchPointView.frame.height / 2 + distanceToTouchPoint + CGFloat(properties.items[0].frame.height / 2)
    }
    
    private func resetItemsPosition() {
        properties.items.forEach {
            $0.center = touchPoint
        }
    }
    
    private func positiveQuorterAngle(startAngle: CGFloat) {
        properties.items.forEach({ item in
            let index = CGFloat(properties.items.firstIndex(of: item)!)
            item.angle = (startAngle + 45 * index)
        })
    }
    
    private func negativeQuorterAngle(startAngle: CGFloat) {
        properties.items.forEach({ item in
            let index = CGFloat(properties.items.firstIndex(of: item)!)
            item.angle = (startAngle - 45 * index)
        })
    }
    
    private func angleForDirection() {
        guard let direction = currentDirection else {
            return
        }
        
        print(direction)
        
        switch (direction){
        case (.down, .right):
            positiveQuorterAngle(startAngle: 0)
            break
        case (.down, .middle):
            positiveQuorterAngle(startAngle: 30)
            break
        case (.middle, .right):
            positiveQuorterAngle(startAngle: 315)
            break
        case (.down, .left):
            negativeQuorterAngle(startAngle: 180)
            break
        case (.up, .right):
            negativeQuorterAngle(startAngle: 20)
            break
        case (.up, .middle), (.middle,.middle):
            positiveQuorterAngle(startAngle: 210)
            break
        case (.up, .left):
            positiveQuorterAngle(startAngle: 160)
            break
        case (.middle, .left):
            positiveQuorterAngle(startAngle: 135)
            break
        default:
            break
        }
    }
    
    private func animateItem(_ item: VipMenuItem) {
        UIView.animate(withDuration: 1, delay: 0, usingSpringWithDamping: 0.4, initialSpringVelocity: 0.7, options: [], animations: {
            item.center = self.calculatePointCoordiantes(item.angle)
        }, completion: nil)
    }
    
    private func calculatePointCoordiantes(_ angle: CGFloat) -> CGPoint {
        let x = (touchPoint.x + CGFloat(__cospi(Double(angle/180))) * xDistanceToItem)
        let y = (touchPoint.y + CGFloat(__sinpi(Double(angle/180))) * yDistanceToItem)
        return CGPoint(x: x, y: y)
    }
    
    func activate(_ item: VipMenuItem) {
        item.isActive = true
        item.setItemColorTo(properties.buttonsActiveColor, iconColor: properties.iconsActiveColor)
        
        let newX = (item.wrapper.center.x + CGFloat(__cospi(Double(item.angle/180))) * 25)
        let newY = (item.wrapper.center.y + CGFloat(__sinpi(Double(item.angle/180))) * 25)
        
        showLabel(with: item.title)
        UIView.animate(withDuration: 1, delay: 0, usingSpringWithDamping: 0.4, initialSpringVelocity: 1,options: [], animations: {
            self.label.alpha = 1
            item.wrapper.center = CGPoint(x: newX, y: newY)
            item.wrapper.transform = CGAffineTransform(scaleX: 1.2, y: 1.2)
        }, completion: nil)
    }
    
    func deactivate(_ item: VipMenuItem) {
        item.isActive = false
        item.setItemColorTo(properties.buttonsDefaultColor, iconColor: properties.iconsDefaultColor)
        
        let newX = (item.wrapper.center.x + CGFloat(__cospi(Double(item.angle/180))) * -25)
        let newY = (item.wrapper.center.y + CGFloat(__sinpi(Double(item.angle/180))) * -25)
        
        UIView.animate(withDuration: 0.2, animations: {
            self.label.alpha = 0.0
            item.wrapper.center    = CGPoint(x: newX, y: newY)
            item.wrapper.transform = CGAffineTransform.identity
        })
    }
    
    private func showLabel(with title:String){
        self.label.text = title
        
        let labelWidth  = self.label.intrinsicContentSize.width
        let labelHeight = self.label.intrinsicContentSize.height

        let labelSize   = CGSize(width: labelWidth, height: labelHeight)
        var labelOrigin = CGPoint()
        
        print("touchPointX: \(touchPoint.x)- TouchPointY: \(touchPoint.y)")
        if touchPoint.x > UIScreen.main.bounds.width/2{ // Align on the left
            print("lable Left")
            self.label.textAlignment = .left
            labelOrigin.x = calculateLabelLeftPosition(labelWidth)
        }
        else{ // Align on the right
            print("lable right")
            self.label.textAlignment = .right
            labelOrigin.x = calculateLabelRightPosition(labelWidth)
        }
        
        if touchPoint.y > UIScreen.main.bounds.height/2.7{ //Show Label at the top
            print("lable top")
            let topItem = properties.items.min(by: { (a, b) -> Bool in
                return a.center.y < b.center.y
            })
            labelOrigin.y = topItem!.center.y - (labelHeight + 100)
        }
        else{ // Show Label at the bottom
            print("lable bottom")
            let bottomItem = properties.items.max(by: { (a, b) -> Bool in
                return a.center.y < b.center.y
            })
            labelOrigin.y = bottomItem!.center.y + 120
        }
        label.frame = CGRect(origin: labelOrigin, size: labelSize)
    }
    
    private func calculateLabelLeftPosition(_ labelWidth:CGFloat)->CGFloat{
        if touchPoint.x > (labelWidth + 30){
            return touchPoint.x - (labelWidth + 30)
        }
        else{
            return 10
        }
    }
    
    private func calculateLabelRightPosition(_ labelWidth:CGFloat)->CGFloat{
        if (UIScreen.main.bounds.width - (touchPoint.x + 100)) > labelWidth{
            return touchPoint.x + 100
        }
        else {
            return 10
        }
    }
}
