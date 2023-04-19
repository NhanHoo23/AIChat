//
//  FavouriteModel.swift
//  Dalle-E
//
//  Created by Nhan Ho on 13/02/2023.
//

import MTSDK
import RealmSwift

class RealmFavouriteModel: Object {
    @Persisted(primaryKey: true) var id: String = UUID().uuidString
    @Persisted var imageData: Data!
    
    convenience init(id: String, imageData: Data) {
        self.init()
        self.id = id
        self.imageData = imageData
    }
    
    convenience init(from: FavouriteModel) {
        self.init()
        self.id = from.id
        self.imageData = from.imageData
    }
}


class FavouriteModel {
    var id: String = UUID().uuidString
    var imageData: Data!
    
    init(imageData: Data) {
        self.imageData = imageData
    }
    
    init(from: RealmFavouriteModel) {
        self.id = from.id
        self.imageData = from.imageData
    }
}

