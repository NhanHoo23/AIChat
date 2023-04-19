//
//  MessageModel.swift
//  Dalle-E
//
//  Created by Nhan Ho on 09/02/2023.
//

import MTSDK

enum Sender {
    case human
    case ai
    
    var displayImage: String {
        return self == .ai ? "img_ai_displayImage" : "ic_human"
    }
}

struct MessageModel {
    let text: String
    let sender: Sender
    let isTyping: Bool
    
    init(text: String, sender: Sender = .human, isTyping: Bool = false) {
        self.text = text
        self.sender = sender
        self.isTyping = isTyping
    }
}
