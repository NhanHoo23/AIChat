//
//  AppManager.swift
//  Dalle-E
//
//  Created by Nhan Ho on 09/02/2023.
//

import MTSDK

class AppManager {
    static let shared = AppManager()
    
    var isLoginApp: Bool = false
    
    var favModels: [FavouriteModel] = []
}
