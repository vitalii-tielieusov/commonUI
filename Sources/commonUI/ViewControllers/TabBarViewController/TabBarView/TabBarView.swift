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
    
    init(tabBarItems: [TabBarItem])
    
    func setupUI(tabBarTopOffset: CGFloat, tabBarItemWidth: CGFloat)
}

public class TabBarViewImpl: UIView, TabBar {
    
    public weak var delegate: TabBarDelegate?
    private var tabBarItemViewModels: [TabBarItem]
    private var tabBarItemViews = [TabBarItemView & UIView]()
    private var tabBarTopOffset: CGFloat = 0
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
    
    required public init(tabBarItems: [TabBarItem]) {
        self.tabBarItemViewModels = tabBarItems
        
        super.init(frame: .zero)
    }
    
    public func setupUI(tabBarTopOffset: CGFloat, tabBarItemWidth: CGFloat) {
        
        self.tabBarTopOffset = tabBarTopOffset
        
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
            make.top.equalToSuperview().offset(tabBarTopOffset)
            make.left.right.bottom.equalToSuperview()
        }
    }
    
    private func setupStackView(tabBarItemWidth: CGFloat) {
        
        for view in stackView.arrangedSubviews {
            view.removeFromSuperview()
        }
        
        for (index, tabBarItem) in tabBarItemViewModels.enumerated() {
            let tabBarItemView = TabBarItemViewImpl(
                tabBarItemImage: tabBarItem.image,
                selectedTabBarItemImage: tabBarItem.selectedImage,
                title: tabBarItem.title,
                font: tabBarItem.font,
                textColor: tabBarItem.textColor)
            tabBarItemView.isSelected = (index == selectedTabBarItem)
            tabBarItemView.delegate = self
            
            tabBarItemView.snp.makeConstraints { make in
                make.width.equalTo(tabBarItemWidth)
            }
            
            stackView.addArrangedSubview(tabBarItemView)
        }
    }
    
    private func pageIndicatorViews() -> [TabBarItemView] {
        guard let pageIndicators = stackView.arrangedSubviews as? [TabBarItemView] else {
            return []
        }
        
        return pageIndicators
    }
    
    func pageIndicatorView(atIndex index: Int) -> TabBarItemView? {
        guard pageIndicatorViews().count > index else {
            return nil
        }
        
        return pageIndicatorViews()[index]
    }
    
    func selectPage(atIndex index: Int) {
        for (i, view) in pageIndicatorViews().enumerated() {
            view.isSelected = (i == index)
        }
    }
}

extension TabBarViewImpl: TabBarItemViewDelegate {
    public func didClickItem(withId id: UUID) {
        
        let selectedTabBarItemIndex: Int? = {
            for (i, view) in pageIndicatorViews().enumerated() {
                if view.id == id {
                    return i
                }
            }
            
            return nil
        }()
        
        guard let index = selectedTabBarItemIndex else { return }
        
        selectedTabBarItem = index
        delegate?.didClickTabBarItem(atIndex: index)
    }
}
