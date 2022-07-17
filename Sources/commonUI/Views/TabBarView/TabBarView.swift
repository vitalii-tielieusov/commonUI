//
//  TabBarView.swift
//  PaintWords
//
//  Created by Vitalii Tielieusov on 07.07.2022.
//

import UIKit

public protocol TabBarDelegate: AnyObject {
    func didClickTabBarItem(atIndex index: Int)
}

public protocol TabBar: AnyObject {
    var selectedTabBarItem: Int { get set }
    
    var delegate: TabBarDelegate? { get set }
    
    init(tabBarItems: [TabBarItemViewModel])
    
    func setupUI(tabBarItemWidth: CGFloat)
}

public class TabBarViewImpl: UIView, TabBar {
    
    public weak var delegate: TabBarDelegate?
    private var tabBarItemViewModels: [TabBarItemViewModel]
    private var tabBarItemViews = [TabBarItemView & UIView]()
    public var selectedTabBarItem: Int = 0 {
        willSet {
            guard newValue != selectedTabBarItem else { return }
            
            selectPage(atIndex: newValue)
        }
    }
    
    private lazy var stackView: UIStackView = {
        let stackView = UIStackView()
        stackView.spacing = 0
        stackView.axis = .horizontal
        return stackView
    }()
    
    required public init(tabBarItems: [TabBarItemViewModel]) {
        self.tabBarItemViewModels = tabBarItems
        
        super.init(frame: .zero)
    }
    
    public func setupUI(tabBarItemWidth: CGFloat) {
        
        setupViews()
        setupLayouts()
        
        setupStackView(tabBarItemWidth: tabBarItemWidth)
        selectPage(atIndex: selectedTabBarItem)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
    }
}

extension TabBarViewImpl {
    
    private func setupViews() {
        addSubview(stackView)
    }
    
    private func setupLayouts() {
        stackView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
    
    private func setupStackView(tabBarItemWidth: CGFloat) {
        
        for view in stackView.arrangedSubviews {
            view.removeFromSuperview()
        }
        
        for (index, tabBarItem) in tabBarItemViewModels.enumerated() {
            let tabBarItemView = TabBarItemViewImpl(
                index: index,
                tabBarItemImage: tabBarItem.tabBarItemImage,
                selectedTabBarItemImage: tabBarItem.selectedTabBarItemImage,
                title: tabBarItem.title)
            tabBarItemView.isSelected = (index == selectedTabBarItem)
            tabBarItemView.delegate = self
            
            tabBarItemView.snp.makeConstraints { make in
                make.width.equalTo(tabBarItemWidth)
            }
            
            stackView.addArrangedSubview(tabBarItemView)
        }
    }
    
    private func pageIndicatorViews() -> [TabBarItemViewImpl] {
        guard let pageIndicators = stackView.arrangedSubviews as? [TabBarItemViewImpl] else {
            return []
        }
        
        return pageIndicators
    }
    
    func pageIndicatorView(atIndex index: Int) -> TabBarItemViewImpl? {
        for view in pageIndicatorViews() {
            if view.index == index {
                return view
            }
        }
        
        return nil
    }
    
    func selectPage(atIndex index: Int) {
        for view in pageIndicatorViews() {
            view.isSelected = view.index == index
        }
    }
}

extension TabBarViewImpl: TabBarItemViewDelegate {
    public func didClickItem(atIndex index: Int) {
        selectedTabBarItem = index
        delegate?.didClickTabBarItem(atIndex: index)
    }
}
