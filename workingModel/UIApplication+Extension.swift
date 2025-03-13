//
//  UIApplication+Extension.swift
//  ThriveUp
//
//  Created by palak seth on 13/03/25.
//
import UIKit

extension UIApplication {
    func dismissKeyboard() {
        sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}

