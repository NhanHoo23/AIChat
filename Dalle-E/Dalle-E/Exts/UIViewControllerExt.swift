//
//  UIViewControllerExt.swift
//  Dalle-E
//
//  Created by Nhan Ho on 09/02/2023.
//

import MTSDK

extension UIViewController {
    func hideKeyboardWhenTappedAround() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(UIViewController.dismissKeyboard))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }
}
