//
//  TabBarView.swift
//  PaintWords
//
//  Created by Vitalii Tielieusov on 07.07.2022.
//

import UIKit

public class TabBarViewImpl: UIView, TabBar, FlatTabBar {
    
    public weak var delegate: TabBarDelegate?
    private var tabBarItemViewModels: [TabBarItem]
    private var tabBarTopOffset: CGFloat
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
        stackView.distribution = .fillEqually
        return stackView
    }()
    
    required public init(tabBarItems: [TabBarItem], tabBarTopOffset: CGFloat) {
        self.tabBarItemViewModels = tabBarItems
        self.tabBarTopOffset = tabBarTopOffset
        
        super.init(frame: .zero)
        
        setupUI()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
    }
}

extension TabBarViewImpl {
    
    private func setupUI() {
        
        setupViews()
        setupLayouts()
        
        setupStackView()
        selectPage(atIndex: selectedTabBarItem)
    }
    
    private func setupViews() {
        addSubview(stackView)
    }
    
    private func setupLayouts() {
        stackView.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(tabBarTopOffset)
            make.left.right.bottom.equalToSuperview()
        }
    }
    
    private func setupStackView() {
        
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
