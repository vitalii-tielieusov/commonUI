//
//  UIApplicationExtensions.swift
//  Inspire me
//
//  Created by Vitaliy Teleusov on 27.12.2021.
//

import UIKit
import StoreKit
import commonUtils

public extension UIApplication {
    
    class func topViewController(base: UIViewController? = UIApplication.shared.keyWindow?.rootViewController) -> UIViewController? {
        if let nav = base as? UINavigationController {
            return topViewController(base: nav.visibleViewController)
        }
        if let tab = base as? UITabBarController {
            if let selected = tab.selectedViewController {
                return topViewController(base: selected)
            }
        }
        if let presented = base?.presentedViewController {
            return topViewController(base: presented)
        }
        return base
    }
    
    class func rateUs(usingStoreKit: Bool) {
        if usingStoreKit {
            if #available(iOS 10.3, *) {
                SKStoreReviewController.requestReview()
            } else if let url = URL(string: "https://apps.apple.com/app/id" + UIApplication.itunesConnectAppId + "?action=write-review") {
                UIApplication.shared.open(url, options: [:], completionHandler: nil)
            }
        } else {
            if let url = URL(string: "https://apps.apple.com/app/id" + UIApplication.itunesConnectAppId + "?action=write-review") {
                UIApplication.shared.open(url, options: [:], completionHandler: nil)
            }
        }
    }
}

