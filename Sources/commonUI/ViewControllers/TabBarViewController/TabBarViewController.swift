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

public protocol TabBarViewController {
    var rootView: UIView { get }
    var viewControllers: [UIViewController]? { get }
    var selectedViewController: UIViewController? { get }
    var selectedIndex: Int { get set }
    
    init?(viewControllers: [TabBarItemViewController]?,
          tabBarItems: [TabBarItem]?,
          tabBarSize: CGSize,
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
    
    private let tabBarView: TabBarViewImpl
    private var _viewControllers: [UIViewController]
    private let hideNavigationBar: Bool
    private let tabBarSize: CGSize
    
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
        tabBarItems: [TabBarItem]?,
        tabBarSize: CGSize,
        hideNavigationBar: Bool
    ) {
        
        guard let vcs = viewControllers,
              let tbis = tabBarItems,
              vcs.count == tbis.count,
              !vcs.isEmpty else {
                  return nil
              }
        
        self.tabBarView = TabBarViewImpl(tabBarItems: tbis)
        self._viewControllers = vcs
        self.tabBarSize = tabBarSize
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
        view.backgroundColor = .white
        
        tabBarView.backgroundColor = .white
    }

    private func setupLayouts() {
        
        pagesView.rootView.snp.makeConstraints { make in
            make.top.left.right.equalToSuperview()
            make.bottom.equalTo(tabBarView.snp.top)
        }
        
        tabBarView.snp.makeConstraints { make in
            make.height.equalTo(tabBarSize.height)
            make.width.equalTo(tabBarSize.width)
            make.centerX.equalToSuperview()
            make.bottom.equalToSuperview().inset(16)
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
        
        let tabBarItemWidth: CGFloat = {
            guard _viewControllers.count > 1 else { return tabBarSize.width }
            return tabBarSize.width / CGFloat(_viewControllers.count)
        }()
        
        tabBarView.setupUI(tabBarItemWidth: tabBarItemWidth)
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
//------------------------------------------------

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
        
        let bottomInset = hide ? -tabBarSize.height : 16

//        UIView.animate(withDuration: 2, delay: 0, options: [.repeat, .autoreverse], animations: {
//            self.tabBarView.snp.updateConstraints { make in
//                make.bottom.equalToSuperview().inset(bottomInset)
//            }
//
//            self.tabBarView.layoutIfNeeded()
//        })
        
        tabBarView.snp.updateConstraints { make in
            make.bottom.equalToSuperview().inset(bottomInset)
        }
    }
}
