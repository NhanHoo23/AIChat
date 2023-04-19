//
//  AppContraints.swift
//  Dalle-E
//
//  Created by Nhan Ho on 09/02/2023.
//

import MTSDK

enum DeviceType {
    case iphonePlus
    case ipad
    case iphoneSmall
}

class Device {
    init() {
        if UIDevice.current.userInterfaceIdiom == .pad {
            type = .ipad
        } else if topSafeHeight > 25 {
            type = .iphonePlus
        } else {
            type = .iphoneSmall
        }
    }
    static let shared = Device()
    
    var type: DeviceType = .ipad
}

struct FNames {
    static let regular = "Roboto-Regular"
    static let italic = "Roboto-Italic"
    static let thin = "Roboto-Thin"
    static let light = "Roboto-Light"
    static let bold = "Roboto-Bold"
    static let medium = "Roboto-Medium"
    static let black = "Roboto-Black"
    static let demiBold = "Berlin Sans FB Demi Bold"
}

struct Const {
    static var tabbarItemBottomPadding: CGFloat {
        switch Device.shared.type {
        case .ipad: return -15
        case .iphonePlus: return -8
        case .iphoneSmall: return -20
        }
    }
    
    static var tabbarItemWidth: CGFloat {
        switch Device.shared.type {
        case .ipad: return 45
        case .iphonePlus: return 35
        case .iphoneSmall: return 35
        }
    }
    
    static var tabbarHeight: CGFloat {
        switch Device.shared.type {
        case .ipad: return 80
        case .iphonePlus: return 100 - botSafeHeight
        case .iphoneSmall: return 70 - botSafeHeight
        }
    }
    
    static var imgDisplayWidth: CGFloat {
        switch Device.shared.type {
        case .ipad: return 45
        case .iphonePlus: return 45
        case .iphoneSmall: return 45
        }
    }
    
    static var bottomOffset: CGFloat {
        switch Device.shared.type {
        case .ipad: return -20 - Const.tabbarHeight - 20 - botSafeHeight
        case .iphonePlus: return -20 - Const.tabbarHeight - 20 - botSafeHeight
        case .iphoneSmall: return -20 - Const.tabbarHeight - 20 - botSafeHeight
        }
    }
}

struct Colors {
    static let tabbarColor = UIColor.white
}
