//
//  GroupingsTabBarViewController.swift
//  
//
//  Created by Vitalii Tielieusov on 10.04.2023.
//

import UIKit

public protocol GroupingsTabBarItemViewController: UIViewController {
    var hidesTabBar: Bool { get }
}

public extension GroupingsTabBarItemViewController {
    var hidesTabBar: Bool { return false }
}

public protocol GroupingsTabBarViewControllerDelegate: NSObjectProtocol {
    func tabBarController(tabBarController: GroupingsTabBarViewController,
                          didSelect: UIViewController)
}

public extension GroupingsTabBarViewControllerDelegate {
    func tabBarController(tabBarController: GroupingsTabBarViewController,
                          didSelect: UIViewController) { }
}

public protocol GroupingsTabBarViewController {
    var rootView: UIView { get }
    var viewControllers: [UIViewController]? { get }
    var selectedViewController: UIViewController? { get }
    var selectedIndex: Int { get set }
    
    init?(viewControllers: [GroupingsTabBarItemViewController]?,
          tabBarItems: [TabBarGroupItem]?,
          tabBarSize: CGSize,
          tabBarTopInset: CGFloat,
          tabBarBackgroundColor: UIColor?,
          hideNavigationBar: Bool)
    
    var delegate: GroupingsTabBarViewControllerDelegate? { get set }
}

public class GroupingsTabBarViewControllerImpl: UIViewController, GroupingsTabBarViewController {
    
    private lazy var pagesView: PagesViewController = {
        let pView = PagesViewControllerImpl()
        pView.delegate = self
        pView.isScrollEnabled = false
        pView.isClickable = false
        return pView
    }()
    
    private let tabBarView: GroupingsTabBarViewImpl
    private var _viewControllers: [UIViewController]
    private let hideNavigationBar: Bool
    private let tabBarSize: CGSize
    private let tabBarViewTopInset: CGFloat
    private let tabBarBackgroundColor: UIColor?
    
    public var viewControllers: [UIViewController]? {
        return pagesView.viewControllers
    }

    public var selectedViewController: UIViewController? {
        return pagesView.selectedViewController
    }
    
    public var selectedIndex: Int {
        get {
            return pagesView.selectedIndex
        }
        set {
            pagesView.selectedIndex = newValue
        }
    }
    
    public var rootView: UIView {
        return self.view
    }
    
    weak public var delegate: GroupingsTabBarViewControllerDelegate?
    
    required public init?(
        viewControllers: [GroupingsTabBarItemViewController]?,
        tabBarItems: [TabBarGroupItem]?,
        tabBarSize: CGSize,
        tabBarTopInset: CGFloat = 0,
        tabBarBackgroundColor: UIColor?,
        hideNavigationBar: Bool
    ) {
        
        guard let vcs = viewControllers,
              let tbis = tabBarItems,
              vcs.count == tbis.flatMap({ $0.subItems }).count,
              !vcs.isEmpty else {
                  return nil
              }
        
        self.tabBarView = GroupingsTabBarViewImpl(tabBarItems: GroupingsTabBarViewControllerImpl.updateTabBarGroupItems(tbis, forTabBarSize: tabBarSize)
        )
        self._viewControllers = vcs
        self.tabBarSize = tabBarSize
        self.tabBarViewTopInset = tabBarTopInset
        self.tabBarBackgroundColor = tabBarBackgroundColor
        self.hideNavigationBar = hideNavigationBar
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        print("\(#function): \(String(describing: type(of: self)))")
    }
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        
        setupSubviews()
        setupLayouts()
    }
    
    private func setupSubviews() {

        view.addSubview(pagesView.rootView)
        view.addSubview(tabBarView)
        
        view.backgroundColor = tabBarBackgroundColor
        tabBarView.backgroundColor = tabBarBackgroundColor
    }

    private func setupLayouts() {
        
        pagesView.rootView.snp.makeConstraints { make in
            make.top.left.right.equalToSuperview()
            make.bottom.equalTo(tabBarView.snp.top)
        }
        
        tabBarView.snp.makeConstraints { make in
            make.height.equalTo(tabBarSize.height + tabBarViewTopInset)
            make.width.equalTo(tabBarSize.width)
            make.centerX.equalToSuperview()
            make.bottom.equalToSuperview()
        }
        
        setupPagesViewController()
        setupTabBar()
    }

    func setupPagesViewController() {
        var ncs = [UINavigationController]()
        for vc in _viewControllers {
            let nc = UINavigationController(rootViewController: vc)
            
            nc.isNavigationBarHidden = hideNavigationBar
            nc.delegate = self
            ncs.append(nc)
        }
        
        pagesView.viewControllers = ncs
    }
    
    func setupTabBar() {
        tabBarView.delegate = self
        tabBarView.setupUI(tabBarTopOffset: tabBarViewTopInset)
    }
    
    private static func updateTabBarGroupItems(
        _ tabBarItems: [TabBarGroupItem],
        forTabBarSize: CGSize
    ) -> [TabBarGroupItem] {
        let maxVisibleTabBarSubItemsCount: Int = {
            var maxSubItemsCount: Int = 0
            for item in tabBarItems {
                maxSubItemsCount = item.subItems.count > maxSubItemsCount ? item.subItems.count : maxSubItemsCount
            }
            return tabBarItems.count + maxSubItemsCount - 1
        }()
        
        let updatedTabBarItems: [TabBarGroupItem] = {
            var result = [TabBarGroupItem]()
            for item in tabBarItems {
                let subItems = item.subItems.map({
                    TabBarSubItem(
                        tabBarItemImage: $0.image,
                        selectedTabBarItemImage: $0.selectedImage,
                        width: tabBarSize.width / CGFloat(maxVisibleTabBarSubItemsCount)
                    )
                })
                let updatedItem = TabBarGroupItem(
                    title: item.title,
                    textColor: item.textColor,
                    font: item.font,
                    textBackgroundImage: item.textBackgroundImage,
                    collapsedGroupImage: item.collapsedGroupImage,
                    subItems: subItems)
                result.append(updatedItem)
            }
            return result
        }()
        
        return updatedTabBarItems
    }
}

extension GroupingsTabBarViewControllerImpl: PagesViewControllerDelegate {
    public func didSelect(pageAtIndex: Int) {
        guard tabBarView.selectedTabBarItem != pageAtIndex else { return }
        
        tabBarView.selectedTabBarItem = pageAtIndex
        
        informTabBarDelegateDidSelectViewController(atIndex: pageAtIndex)
    }
}

extension GroupingsTabBarViewControllerImpl: TabBarDelegate {
    public func didClickTabBarItem(atIndex index: Int) {
        guard pagesView.selectedIndex != index else { return }
        
        pagesView.selectPage(at: index, animated: false)
        
        informTabBarDelegateDidSelectViewController(atIndex: index)
    }
}

extension GroupingsTabBarViewControllerImpl {
    private func informTabBarDelegateDidSelectViewController(atIndex index: Int) {
        guard let vcs = pagesView.viewControllers,
                vcs.count > index else { return }
        
        let selecedVC = vcs[index]
        
        self.delegate?.tabBarController(tabBarController: self, didSelect: selecedVC)
    }
}
//------------------------------------------------

extension GroupingsTabBarViewControllerImpl: UINavigationControllerDelegate {
    public func navigationController(_ navigationController: UINavigationController, willShow viewController: UIViewController, animated: Bool) {

        guard pagesView.selectedViewController == navigationController,
              let vc = viewController as? GroupingsTabBarItemViewController
        else { return }
        
        hideTabBar(hide: vc.hidesTabBar)
    }
    
    public func navigationController(_ navigationController: UINavigationController, didShow viewController: UIViewController, animated: Bool) {
        
        guard pagesView.selectedViewController == navigationController,
              let vc = viewController as? GroupingsTabBarItemViewController
        else { return }
        
        hideTabBar(hide: vc.hidesTabBar)
    }
    
    private func hideTabBar(hide: Bool) {
        
        let bottomInset = hide ? -(tabBarSize.height + tabBarViewTopInset) : 0
        
        tabBarView.snp.updateConstraints { make in
            make.bottom.equalToSuperview().inset(bottomInset)
        }
        tabBarView.isHidden = hide
    }
}
