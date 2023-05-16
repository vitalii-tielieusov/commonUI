//
//  File.swift
//  
//
//  Created by Vitalii Tielieusov on 16.05.2023.
//

import UIKit

public protocol TabBarItemViewController: UIViewController {
    var hidesTabBar: Bool { get }
}

public extension TabBarItemViewController {
    var hidesTabBar: Bool { return false }
}

public protocol TabBarViewControllerDelegate: NSObjectProtocol {
    func tabBarController(tabBarController: TabBarViewController,
                          didSelect: UIViewController)
}

public extension TabBarViewControllerDelegate {
    func tabBarController(tabBarController: TabBarViewController,
                          didSelect: UIViewController) { }
}

public enum TabBarItems {
    case flat(items: [TabBarItem]?)
    case group(items: [TabBarGroupItem]?)
}
