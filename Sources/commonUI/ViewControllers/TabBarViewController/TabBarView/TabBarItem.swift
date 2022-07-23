//
//  TabBarItemViewModel.swift
//  PaintWords
//
//  Created by Vitalii Tielieusov on 07.07.2022.
//

import UIKit

public struct TabBarItem {
    public let title: String?
    public var image: UIImage?
    public var selectedImage: UIImage?
    
    public init(
        title: String?,
        tabBarItemImage: UIImage?,
        selectedTabBarItemImage: UIImage?
    ) {
        self.title = title
        self.image = tabBarItemImage
        self.selectedImage = selectedTabBarItemImage
    }
}
