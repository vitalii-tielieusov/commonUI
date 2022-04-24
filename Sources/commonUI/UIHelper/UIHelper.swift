//
//  UIHelper.swift
//  Inspire me
//
//  Created by Vitalii Tielieusov on 08.01.2022.
//

import UIKit

func prepareScrollView(disableContentInsetAdjustmentBehavior: Bool = true) -> UIScrollView {
    let scrollView = UIScrollView()
    if disableContentInsetAdjustmentBehavior,
       #available(iOS 11.0, *) {
        scrollView.contentInsetAdjustmentBehavior = .never
    }
    
    scrollView.showsHorizontalScrollIndicator = false
    scrollView.showsVerticalScrollIndicator = false
    return scrollView
}
