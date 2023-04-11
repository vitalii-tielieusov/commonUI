//
//  TabBarItemViewModel.swift
//  PaintWords
//
//  Created by Vitalii Tielieusov on 07.07.2022.
//

import UIKit

public protocol TabBarItemViewBase {
}

public struct TabBarItem: TabBarItemViewBase {
    public let title: String?
    public let textColor: UIColor?
    public let font: UIFont?
    public var image: UIImage?
    public var selectedImage: UIImage?
    
    public init(
        title: String?,
        textColor: UIColor?,
        font: UIFont?,
        tabBarItemImage: UIImage?,
        selectedTabBarItemImage: UIImage?
    ) {
        self.title = title
        self.textColor = textColor
        self.font = font
        self.image = tabBarItemImage
        self.selectedImage = selectedTabBarItemImage
    }
}
