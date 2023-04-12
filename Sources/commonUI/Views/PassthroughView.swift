//
//  PassthroughView.swift
//  
//
//  Created by Vitalii Tielieusov on 12.04.2023.
//

import UIKit

class PassthroughView: UIView {
    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        let view = super.hitTest(point, with: event)
        return view == self ? nil : view
    }
}
