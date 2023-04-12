//
//  TabBarGroupItem.swift
//  
//
//  Created by Vitalii Tielieusov on 06.04.2023.
//

import UIKit

public struct TabBarGroupItem: TabBarItemViewBase {
    public let title: String?
    public let textColor: UIColor?
    public let font: UIFont?
    public var textBackgroundImage: UIImage?
    public var collapsedGroupImage: UIImage?
    public var subItems: [TabBarSubItem]
    
    public init(
        title: String?,
        textColor: UIColor?,
        font: UIFont?,
        textBackgroundImage: UIImage?,
        collapsedGroupImage: UIImage?,
        subItems: [TabBarSubItem]
    ) {
        self.title = title
        self.textColor = textColor
        self.font = font
        self.textBackgroundImage = textBackgroundImage
        self.collapsedGroupImage = collapsedGroupImage
        self.subItems = subItems
    }
}

public struct TabBarSubItem {
    public var image: UIImage?
    public var selectedImage: UIImage?
    public var width: CGFloat?
    
    public init(
        tabBarItemImage: UIImage?,
        selectedTabBarItemImage: UIImage?,
        width: CGFloat? = nil
    ) {
        self.image = tabBarItemImage
        self.selectedImage = selectedTabBarItemImage
        self.width = width
    }
}
