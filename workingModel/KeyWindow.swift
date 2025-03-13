//
//  KeyWindow.swift
//  ThriveUp
//
//  Created by palak seth on 13/03/25.
//
import UIKit

class KeyWindow: UIWindow {
    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        let view = super.hitTest(point, with: event)
        if view == self {
            UIApplication.shared.dismissKeyboard()
        }
        return view
    }
}
