//
//  TabBarItemViewModel.swift
//  PaintWords
//
//  Created by Vitalii Tielieusov on 07.07.2022.
//

import UIKit

public struct TabBarItemViewModel {
    public var index: Int
    public var tabBarItemImage: UIImage?
    public var selectedTabBarItemImage: UIImage?
    public let title: String?
    
    public init(
        index: Int,
        tabBarItemImage: UIImage?,
        selectedTabBarItemImage: UIImage?,
        title: String?
    ) {
        self.index = index
        self.tabBarItemImage = tabBarItemImage
        self.selectedTabBarItemImage = selectedTabBarItemImage
        self.title = title
    }
}
