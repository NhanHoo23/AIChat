//
//  UIViewExt.swift
//  Dalle-E
//
//  Created by Nhan Ho on 09/02/2023.
//

import MTSDK

extension UIView {
    func dropShadow(color: UIColor, opacity: Float = 0.5, offSet: CGSize, radius: CGFloat = 1, scale: Bool = true) {
        layer.masksToBounds = false
        layer.shadowColor = color.cgColor
        layer.shadowOpacity = opacity
        layer.shadowOffset = offSet
        layer.shadowRadius = radius
        
        layer.shadowPath = UIBezierPath(rect: self.bounds).cgPath
        layer.shouldRasterize = true
        layer.rasterizationScale = scale ? UIScreen.main.scale : 1
    }
}

extension UIView {
    var fullCircle: Bool {
        get {
            return layer.cornerRadius == 0 ? false : true
        }
        set {
            if newValue {
                layer.cornerRadius = bounds.size.width / 2
            } else {
                layer.cornerRadius = 0
            }
        }
    }
    
    var borderColor: UIColor?{
        get {
            return UIColor(cgColor: layer.borderColor!)
        }
        set{
            layer.borderColor = newValue?.cgColor
        }
    }
    
    var borderWidth: CGFloat{
        get {
            return layer.borderWidth
        }
        set{
            layer.borderWidth = newValue
            layer.masksToBounds = newValue > 0
        }
    }
}
