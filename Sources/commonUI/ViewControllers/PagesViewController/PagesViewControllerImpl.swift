//
//  PagesViewControllerImpl.swift
//  Inspire me
//
//  Created by Vitaliy Teleusov on 09.01.2022.
//

import UIKit
import SnapKit

open class PagesViewControllerImpl: UIViewController, PagesViewController {

    private lazy var pagesView: PagesView = {
        let pView = PagesViewImpl()
        pView.delegate = self
        pView.dataSource = self
        pView.layoutDelegate = self
        return pView
    }()
    
    public var rootView: UIView! {
        get {
            return view
        }
        set {
            view = newValue
        }
    }
    
    private var _viewControllers: [UIViewController]?
    
    public var viewControllers: [UIViewController]? {
        get {
            return _viewControllers
        }
        set {

            //Delete old child view controllers
            let oldViews = _viewControllers ?? [UIViewController]()
            _viewControllers?.removeAll()
            
            for vc in oldViews { vc.willMove(toParent: nil) }
            pagesView.reloadData()
            for vc in oldViews { vc.removeFromParent() }
            
            //Add new child view controllers
            _viewControllers = newValue
            
            for vc in _viewControllers ?? [UIViewController]() { addChild(vc) }
            pagesView.reloadData()
            for vc in _viewControllers ?? [UIViewController]() { vc.didMove(toParent: self) }
        }
    }

    unowned(unsafe) open var selectedViewController: UIViewController? {
        
        guard let vc = _viewControllers,
              selectedIndex != NSNotFound,
              selectedIndex < vc.count  else { return nil }

        return vc[selectedIndex]
    }
    
    open var selectedIndex: Int {
        get {
            return pagesView.selectedPageIndex
        }
        set {
            pagesView.selectedPageIndex = newValue
        }
    }
    
    open var isScrollEnabled: Bool {
        get {
            return pagesView.isScrollEnabled
        }
        set {
            pagesView.isScrollEnabled = newValue
        }
    }
    
    open var contentOffset: CGPoint {
        get {
            return pagesView.contentOffset
        }
        set {
            pagesView.contentOffset = newValue
        }
    }
    
    open var contentSize: CGSize {
        return pagesView.contentSize
    }
    
    open var scrollBehavior: ScrollBehavior {
        get {
            return pagesView.scrollBehavior
        }
        set {
            pagesView.scrollBehavior = newValue
        }
    }
    
    open var isClickable: Bool {
        get {
            return pagesView.isClickable
        }
        set {
            pagesView.isClickable = newValue
        }
    }
    
    public func selectPage(at index: Int, animated: Bool) {
        
        pagesView.selectPage(at: index, animated: animated)
    }
    
    public func selectNextPage(animated: Bool) {
        
        pagesView.selectNextPage(animated: animated)
    }
    
    public func selectPreviousPage(animated: Bool) {
        
        pagesView.selectPreviousPage(animated: animated)
    }

    weak open var delegate: PagesViewControllerDelegate?
    weak open var layoutDelegate: PagesLayoutDelegate?
    
    override open func viewDidLoad() {
        view.addSubview(pagesView.view)

        pagesView.view.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
    
    override open func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        ///Should call to setup right page sizes at initial displaying
        pagesView.reloadData()
    }
}

extension PagesViewControllerImpl: PagesViewDataSource {

    public func pagesCount() -> Int {
        return _viewControllers?.count ?? 0
    }
    
    public func pageView(at index: Int) -> UIView {
        let vc = _viewControllers ?? [UIViewController]()
        return vc[index].view
    }
}

extension PagesViewControllerImpl: PagesViewDelegate {
    
    public func didScroll(to pageIndex: Int) {
        delegate?.didSelect(self, pageAtIndex: pageIndex)
    }
    
    public func didScroll(contentOffset: CGPoint) {
        delegate?.didScroll(self, contentOffset: contentOffset)
    }
    
    public func didEndDecelerating(contentOffset: CGPoint) {
        delegate?.didEndDecelerating(self, contentOffset: contentOffset)
    }
    
    public func didClickOnRightPageSide() {
        pagesView.selectNextPage(animated: true)
    }
    
    public func didClickOnLeftPageSide() {
        pagesView.selectPreviousPage(animated: true)
    }
}

extension PagesViewControllerImpl: PagesViewLayoutDelegate {

    public func viewSize() -> CGSize {
        return self.view.frame.size
    }
    
    public func leftPageSize() -> PageSize {

        guard let layoutDelegate = layoutDelegate else { return PageSize.full }

        let width = viewSize().width * layoutDelegate.leftPageSizeRatio(self).widthRatio
        let height = viewSize().height * layoutDelegate.leftPageSizeRatio(self).heightRatio

        return PageSize.specified(size: CGSize(width: width, height: height))
    }

    public func middlePageSize() -> PageSize {

        guard let layoutDelegate = layoutDelegate else { return PageSize.full }
        
        let width = viewSize().width * layoutDelegate.middlePageSizeRatio(self).widthRatio
        let height = viewSize().height * layoutDelegate.middlePageSizeRatio(self).heightRatio

        return PageSize.specified(size: CGSize(width: width, height: height))
    }

    public func rightPageSize() -> PageSize {

        guard let layoutDelegate = layoutDelegate else { return PageSize.full }
        
        let width = viewSize().width * layoutDelegate.rightPageSizeRatio(self).widthRatio
        let height = viewSize().height * layoutDelegate.rightPageSizeRatio(self).heightRatio

        return PageSize.specified(size: CGSize(width: width, height: height))
    }

    public func horizontalPagesSpaces() -> CGFloat {
        guard let layoutDelegate = layoutDelegate else { return 0 }
        return layoutDelegate.horizontalPagesSpaces(self)
    }

    public func verticalPagesAlignment() -> VerticalPagesAlignment {
        guard let layoutDelegate = layoutDelegate else { return .middle }
        return layoutDelegate.verticalPagesAlignment(self)
    }

    public func pagesCornerRadius() -> CGFloat {
        guard let layoutDelegate = layoutDelegate else { return 0 }
        return layoutDelegate.pagesCornerRadius(self)
    }
}
