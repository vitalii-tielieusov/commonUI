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

extension UIView {
    
    public enum Corner {
        case topLeft
        case topRight
        case bottomLeft
        case bottomRight
    }
    
    public func setupCorners(
        cornerRadius: CGFloat,
        borderWidth: CGFloat,
        borderColor: UIColor,
        corners: [Corner]
    ) {
        self.layer.cornerRadius = cornerRadius
        self.layer.borderWidth = borderWidth
        self.layer.borderColor = borderColor.cgColor
        
        self.layer.maskedCorners = convert(corners: corners)
    }
    
    private func convert(corners: [Corner]) -> CACornerMask {
        var result = CACornerMask()
        for corner in corners {
            result.insert(convert(corner: corner))
        }
        return result
    }
    
    private func convert(corner: Corner) -> CACornerMask {
        switch corner {
        case .topLeft:
            return .layerMinXMinYCorner
        case .topRight:
            return .layerMaxXMinYCorner
        case .bottomLeft:
            return .layerMinXMaxYCorner
        case .bottomRight:
            return .layerMaxXMaxYCorner
        }
    }
}
