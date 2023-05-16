//
//  File.swift
//  
//
//  Created by Vitalii Tielieusov on 23.07.2022.
//

import UIKit

public protocol TabBarItemViewController: UIViewController {
    var hidesTabBar: Bool { get }
}

public extension TabBarItemViewController {
    var hidesTabBar: Bool { return false }
}

public protocol TabBarViewControllerDelegate: NSObjectProtocol {
    func tabBarController(tabBarController: TabBarViewController,
                          didSelect: UIViewController)
}

public extension TabBarViewControllerDelegate {
    func tabBarController(tabBarController: TabBarViewController,
                          didSelect: UIViewController) { }
}

public enum TabBarItems {
    case flat(items: [TabBarItem]?)
    case group(items: [TabBarGroupItem]?)
}

public protocol TabBarViewController {
    var rootView: UIView { get }
    var viewControllers: [UIViewController]? { get }
    var selectedViewController: UIViewController? { get }
    var selectedIndex: Int { get set }
    
    init?(viewControllers: [TabBarItemViewController]?,
          tabBarItems: TabBarItems,
          tabBarSize: CGSize,
          tabBarTopInset: CGFloat,
          tabBarBackgroundColor: UIColor?,
          hideNavigationBar: Bool)
    
    var delegate: TabBarViewControllerDelegate? { get set }
}

public class TabBarViewControllerImpl: UIViewController, TabBarViewController {
    
    private lazy var pagesView: PagesViewController = {
        let pView = PagesViewControllerImpl()
        pView.delegate = self
        pView.isScrollEnabled = false
        pView.isClickable = false
        return pView
    }()
    
    private let tabBarView: TabBar & UIView
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
    
    weak public var delegate: TabBarViewControllerDelegate?
    
    required public init?(
        viewControllers: [TabBarItemViewController]?,
        tabBarItems: TabBarItems,
        tabBarSize: CGSize,
        tabBarTopInset: CGFloat = 0,
        tabBarBackgroundColor: UIColor?,
        hideNavigationBar: Bool
    ) {
        guard let vcs = viewControllers,
              !vcs.isEmpty else {
            return nil
        }

        switch tabBarItems {
        case .flat(let flatTabBarItems):
            guard let tbis = flatTabBarItems,
                  vcs.count == tbis.count else {
                return nil
            }
            self.tabBarView = TabBarViewImpl(tabBarItems: tbis)
        case .group(let groupTabBarItems):
            guard let groupTbis = groupTabBarItems else { return nil }
            
            let tbis = groupTbis.flatMap( { $0.subItems } )
            
            guard vcs.count == tbis.count else {
                return nil
            }
            
            self.tabBarView = GroupingsTabBarViewImpl(tabBarItems: groupTbis, tabBarWidth: tabBarSize.width)
        }

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
}

extension TabBarViewControllerImpl: PagesViewControllerDelegate {
    public func didSelect(pageAtIndex: Int) {
        guard tabBarView.selectedTabBarItem != pageAtIndex else { return }
        
        tabBarView.selectedTabBarItem = pageAtIndex
        
        informTabBarDelegateDidSelectViewController(atIndex: pageAtIndex)
    }
}

extension TabBarViewControllerImpl: TabBarDelegate {
    public func didClickTabBarItem(atIndex index: Int) {
        guard pagesView.selectedIndex != index else { return }
        
        pagesView.selectPage(at: index, animated: false)
        
        informTabBarDelegateDidSelectViewController(atIndex: index)
    }
}

extension TabBarViewControllerImpl {
    private func informTabBarDelegateDidSelectViewController(atIndex index: Int) {
        guard let vcs = pagesView.viewControllers,
                vcs.count > index else { return }
        
        let selecedVC = vcs[index]
        
        self.delegate?.tabBarController(tabBarController: self, didSelect: selecedVC)
    }
}

extension TabBarViewControllerImpl: UINavigationControllerDelegate {
    public func navigationController(_ navigationController: UINavigationController, willShow viewController: UIViewController, animated: Bool) {

        guard pagesView.selectedViewController == navigationController,
              let vc = viewController as? TabBarItemViewController
        else { return }
        
        hideTabBar(hide: vc.hidesTabBar)
    }
    
    public func navigationController(_ navigationController: UINavigationController, didShow viewController: UIViewController, animated: Bool) {
        
        guard pagesView.selectedViewController == navigationController,
              let vc = viewController as? TabBarItemViewController
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
