//
//  PagesView.swift
//  Inspire me
//
//  Created by Vitaliy Teleusov on 08.01.2022.
//

import UIKit

public enum ScrollBehavior {
    case pageByPage
    case continuously
}

public protocol PagesView {
    var view: UIView! { get }
    var selectedPageIndex: Int { get set }
    var isScrollEnabled: Bool { get set }
    var contentOffset: CGPoint { get set }
    var contentSize: CGSize { get }
    var scrollBehavior: ScrollBehavior { get set }
    var isClickable: Bool { get set }

    var dataSource: PagesViewDataSource? { get set }
    var delegate: PagesViewDelegate? { get set }
    var layoutDelegate: PagesViewLayoutDelegate? { get set }
    
    func reloadData()
    func selectPage(at index: Int, animated: Bool)
    func selectNextPage(animated: Bool)
    func selectPreviousPage(animated: Bool)
}

public protocol PagesViewDataSource: AnyObject {
    func pagesCount() -> Int
    func pageView(at index: Int) -> UIView
}

public protocol PagesViewDelegate: AnyObject {
    func didScroll(to pageIndex: Int)
    func didScroll(contentOffset: CGPoint)
    func didEndDecelerating(contentOffset: CGPoint)
    func didClickOnRightPageSide()
    func didClickOnLeftPageSide()
}

public extension PagesViewDelegate {
    func didScroll(contentOffset: CGPoint) { }
    func didEndDecelerating(contentOffset: CGPoint) { }
}

public enum VerticalPagesAlignment {
    case top
    case middle
    case bottom
}

public enum PageSize {
    case full
    case specified(size: CGSize)
}

public protocol PagesViewLayoutDelegate: AnyObject {
    func leftPageSize() -> PageSize
    func middlePageSize() -> PageSize
    func rightPageSize() -> PageSize
    func horizontalPagesSpaces() -> CGFloat
    func verticalPagesAlignment() -> VerticalPagesAlignment
    func pagesCornerRadius() -> CGFloat
}
