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

func createTableView<T: UITableViewCell>(
    dataSource: UITableViewDataSource?,
    delegate: UITableViewDelegate? = nil,
    estimatedRowHeight: CGFloat? = 85,
    rowHeight: CGFloat? = UITableView.automaticDimension,
    separatorStyle: UITableViewCell.SeparatorStyle = .none,
    registerCell: T.Type,
    isScrollEnabled: Bool = false) -> UITableView where T: ReusableCell {
        let tableView = UITableView()
        tableView.dataSource = dataSource
        tableView.delegate = delegate
        tableView.separatorStyle = separatorStyle
        tableView.backgroundColor = .white
        if let estimatedRowHeight = estimatedRowHeight {
            tableView.estimatedRowHeight = estimatedRowHeight
        }
        if let rowHeight = rowHeight {
            tableView.rowHeight = rowHeight
        }
        tableView.isScrollEnabled = isScrollEnabled
        tableView.showsHorizontalScrollIndicator = false
        tableView.showsVerticalScrollIndicator = false
        tableView.tableFooterView = UIView()
        tableView.registerReusableCell(T.self)
        
        return tableView
    }

func prepareCollectionView<T: UICollectionViewCell>(
    dataSource: UICollectionViewDataSource?,
    delegate: UICollectionViewDelegate?,
    scrollDirection: UICollectionView.ScrollDirection,
    minimumInteritemSpacing: CGFloat = 12,
    minimumLineSpacing: CGFloat = 12,
    allowsMultipleSelection: Bool = false,
    backgroundColor: UIColor = .white,
    registerCell: T.Type,
    estimatedItemSize: CGSize? = nil,
    isPagingEnabled: Bool = false) -> UICollectionView where T: ReusableCell {
        let collectionViewFlowLayout = prepareCollectionViewFlowLayout(scrollDirection: scrollDirection,
                                                                       minimumInteritemSpacing: minimumInteritemSpacing,
                                                                       minimumLineSpacing: minimumLineSpacing,
                                                                       estimatedItemSize: estimatedItemSize)
        
        let collectionView: UICollectionView = UICollectionView(frame: .zero,
                                                                collectionViewLayout: collectionViewFlowLayout)
        collectionView.dataSource = dataSource
        collectionView.delegate = delegate
        collectionView.allowsMultipleSelection = allowsMultipleSelection
        collectionView.backgroundColor = backgroundColor
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.showsVerticalScrollIndicator = false
        collectionView.registerReusableCell(T.self)
        collectionView.isPagingEnabled = isPagingEnabled
        
        return collectionView
    }

private func prepareCollectionViewFlowLayout(
    scrollDirection: UICollectionView.ScrollDirection,
    minimumInteritemSpacing: CGFloat = 0,
    minimumLineSpacing: CGFloat = 0,
    estimatedItemSize: CGSize? = nil) -> UICollectionViewFlowLayout {
        let layout: UICollectionViewFlowLayout = UICollectionViewFlowLayout()
        layout.scrollDirection = scrollDirection
        layout.minimumInteritemSpacing = minimumInteritemSpacing
        layout.minimumLineSpacing = minimumLineSpacing
        if let size = estimatedItemSize {
            layout.estimatedItemSize = size
        }
        return layout
    }

final class LayoutsHelper {
    
    private struct ScreenSizeByDesign {
        static let width = CGFloat(414)
        static let height = CGFloat(896)
    }
    
    class func scaleByScreenWidth(constraintValue: CGFloat) -> CGFloat {
        return (constraintValue * UIScreen.main.bounds.size.width) / ScreenSizeByDesign.width
    }
    
    class func scaleByScreenHeight(constraintValue: CGFloat) -> CGFloat {
        return (constraintValue * UIScreen.main.bounds.size.height) / ScreenSizeByDesign.height
    }
}
