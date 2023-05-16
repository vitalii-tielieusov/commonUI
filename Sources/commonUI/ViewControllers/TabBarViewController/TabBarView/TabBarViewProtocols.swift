//
//  File.swift
//  
//
//  Created by Vitalii Tielieusov on 16.05.2023.
//

import Foundation

public protocol TabBarDelegate: AnyObject {
    func didClickTabBarItem(atIndex index: Int)
}

public protocol TabBar: AnyObject {
    var selectedTabBarItem: Int { get set }
    
    var delegate: TabBarDelegate? { get set }
}

public protocol FlatTabBar: AnyObject {
    
    init(tabBarItems: [TabBarItem], tabBarTopOffset: CGFloat)
}

public protocol GroupingsTabBar: AnyObject {
    
    init(tabBarItems: [TabBarGroupItem], tabBarWidth: CGFloat, tabBarTopOffset: CGFloat)
}
