//
//  PagesViewController.swift
//  Inspire me
//
//  Created by Vitaliy Teleusov on 08.01.2022.
//

import UIKit

public protocol PagesViewController: NSObjectProtocol {
    var rootView: UIView! { get set }
    var viewControllers: [UIViewController]? { get set }
    var selectedViewController: UIViewController? { get }
    var selectedIndex: Int { get set }
    var isScrollEnabled: Bool { get set }
    var scrollBehavior: ScrollBehavior { get set }
    var isClickable: Bool { get set }
    
    func selectPage(at index: Int, animated: Bool)
    func selectNextPage(animated: Bool)
    func selectPreviousPage(animated: Bool)
    
    var delegate: PagesViewControllerDelegate? { get set }
    var layoutDelegate: PagesLayoutDelegate? { get set }
}

public protocol PagesViewControllerDelegate: NSObjectProtocol {
    func didSelect(pageAtIndex: Int)
}

public extension PagesViewControllerDelegate {
    func didSelect(pageAtIndex: Int) { }
}

public struct SizeRatio {
    public var widthRatio: CGFloat = 1
    public var heightRatio: CGFloat = 1
    public init() { }
    public init(widthRatio: CGFloat, heightRatio: CGFloat) {
        self.widthRatio = widthRatio
        self.heightRatio = heightRatio
    }
}

public extension SizeRatio {
    static var equal: SizeRatio { SizeRatio(widthRatio: 1.0, heightRatio: 1.0) }
}

/*
 SizeRatio property values must be between 0 and 1
 */
public protocol PagesLayoutDelegate: AnyObject {
    func leftPageSizeRatio(_ pagesController: UIViewController) -> SizeRatio
    func middlePageSizeRatio(_ pagesController: UIViewController) -> SizeRatio
    func rightPageSizeRatio(_ pagesController: UIViewController) -> SizeRatio
    func horizontalPagesSpaces(_ pagesController: UIViewController) -> CGFloat
    func verticalPagesAlignment(_ pagesController: UIViewController) -> VerticalPagesAlignment
    func pagesCornerRadius(_ pagesController: UIViewController) -> CGFloat
}
