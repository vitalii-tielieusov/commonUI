//
//  UIView+Extensions.swift
//  
//
//  Created by Vitalii Tielieusov on 28.08.2022.
//

import UIKit

extension Array where Element: UIView {
    func setupEqualWidth() {
        var previousView: UIView? = nil
        for view in self {
            if let viewBefore = previousView {
                view.widthAnchor.constraint(equalTo: viewBefore.widthAnchor, multiplier: 1.0).isActive = true
            }
            previousView = view
        }
        previousView = nil
    }
}

