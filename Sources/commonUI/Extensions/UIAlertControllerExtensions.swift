//
//  UIAlertControllerExtensions.swift
//  Inspire me
//
//  Created by Vitaliy Teleusov on 27.12.2021.
//

import UIKit

extension UIAlertController {
    //Support iPad
    static func actionSheetWith(title: String?, message: String?, sourceView: UIView?) -> UIAlertController {
        let actionController = UIAlertController(title: title, message: message, preferredStyle: .actionSheet)
        if actionController.responds(to: #selector(getter: popoverPresentationController)),
            //Not a good solution but fixes all the cases in one place.
            let sourceView = sourceView ?? UIApplication.topViewController()?.view {
            actionController.popoverPresentationController?.sourceView = sourceView
            actionController.popoverPresentationController?.sourceRect =
                CGRect(x: sourceView.bounds.midX, y: sourceView.bounds.midY, width: 0, height: 0)
        }
        return actionController
    }
    
}

extension UIAlertAction {
    
    static func action(title: String, style: UIAlertAction.Style = .default, handler: ((UIAlertAction) -> Void)? = nil) -> UIAlertAction {
        return UIAlertAction(title: title, style: style, handler: handler)
    }
  
    static func ok(handler: ((UIAlertAction) -> Void)? = nil) -> UIAlertAction {
        return UIAlertAction(title: "Ok", style: .default, handler: handler)
    }
  
    static func logout(handler: ((UIAlertAction) -> Void)? = nil) -> UIAlertAction {
        return UIAlertAction(title: "Log Out", style: .default, handler: handler)
    }
  
    static func delete(handler: ((UIAlertAction) -> Void)? = nil) -> UIAlertAction {
        return UIAlertAction(title: "Delete", style: .default, handler: handler)
    }
    
    static func done(handler: ((UIAlertAction) -> Void)? = nil) -> UIAlertAction {
        return UIAlertAction(title: "Done", style: .default, handler: handler)
    }
    
    static func cancel(handler: ((UIAlertAction) -> Void)? = nil) -> UIAlertAction {
        return UIAlertAction(title: "Cancel", style: .cancel, handler: handler)
    }
    
    static func yes(handler: ((UIAlertAction) -> Void)? = nil) -> UIAlertAction {
        return UIAlertAction(title: "Yes", style: .destructive, handler: handler)
    }
    
    static func no(handler: ((UIAlertAction) -> Void)? = nil) -> UIAlertAction {
        return UIAlertAction(title: "No", style: .default, handler: handler)
    }
}

