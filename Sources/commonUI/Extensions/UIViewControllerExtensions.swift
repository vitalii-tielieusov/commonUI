//
//  UIViewControllerExtensions.swift
//  Inspire me
//
//  Created by Vitaliy Teleusov on 09.01.2022.
//

import UIKit

extension UIViewController {
    
    func add(_ child: UIViewController, on targetView: UIView) {
        addChild(child)
        targetView.addSubview(child.view)
        child.didMove(toParent: self)
    }

    func remove() {
        guard parent != nil else { return }

        willMove(toParent: nil)
        view.removeFromSuperview()
        removeFromParent()
    }
}
