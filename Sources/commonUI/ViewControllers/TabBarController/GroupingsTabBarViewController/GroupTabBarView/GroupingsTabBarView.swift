//
//  GroupingsTabBarView.swift
//  
//
//  Created by Vitalii Tielieusov on 06.04.2023.
//

import UIKit

public class GroupingsTabBarViewImpl: UIView, TabBar {

    public weak var delegate: TabBarDelegate?
    private var tabBarItemViewModels: [TabBarGroupItem]
    private var tabBarTopOffset: CGFloat = 0
    public var selectedTabBarItem: Int = 0 {
        willSet {
            guard newValue != selectedTabBarItem else { return }
            
            selectTabBarItem(atIndex: newValue)
        }
    }
    
    private lazy var stackView: UIStackView = {
        let stackView = UIStackView()
        stackView.spacing = 0
        stackView.axis = .horizontal
        stackView.distribution = .fill
        return stackView
    }()
    
    required public init(tabBarItems: [TabBarGroupItem]) {
        self.tabBarItemViewModels = tabBarItems
        
        super.init(frame: .zero)
    }
    
    //TODO: Should delete or combine with help of enum
    public required init(tabBarItems: [TabBarItem]) {//TODO: Should think about 'init(tabBarItems: [TabBarGroupItem])' and 'init(tabBarItems: [TabBarItem]'
        self.tabBarItemViewModels = []
        super.init(frame: .zero)
    }
    
    public func setupUI(tabBarTopOffset: CGFloat) {
        
        self.tabBarTopOffset = tabBarTopOffset
        
        setupViews()
        setupLayouts()
        
        setupStackView()
        selectTabBarItem(atIndex: selectedTabBarItem)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
    }
}

extension GroupingsTabBarViewImpl {
    
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
        
        for tabBarItem in tabBarItemViewModels {
            let tabBarItemView = TabBarGroupItemViewImpl(
                title: tabBarItem.title,
                font: tabBarItem.font,
                textColor: tabBarItem.textColor,
                textBackgroundImage: tabBarItem.textBackgroundImage,
                collapsedGroupImage: tabBarItem.collapsedGroupImage,
                subItems: tabBarItem.subItems)
            tabBarItemView.delegate = self
            
            stackView.addArrangedSubview(tabBarItemView)
        }
    }
}

extension GroupingsTabBarViewImpl {
    private func groupTabBarItemViews() -> [TabBarGroupItemView] {
        guard let views = stackView.arrangedSubviews as? [TabBarGroupItemView] else {
            return []
        }
        
        return views
    }
    
    private func groupsTabBarSubItemViews() -> [TabBarSubItemView] {
        var subItemViews = [TabBarSubItemView]()
        groupTabBarItemViews().forEach { groupView in
            subItemViews.append(contentsOf: groupView.tabBarItemViews)
        }
        return subItemViews
    }
    
    func tabBarItemView(atIndex index: Int) -> TabBarSubItemView? {//TabBarSubItemView
        guard groupsTabBarSubItemViews().count > index else {
            return nil
        }
        
        return groupsTabBarSubItemViews()[index]
    }
    
    func selectTabBarItem(atIndex index: Int) {
        var groupSubItemsCount: Int = 0
        for (i, view) in groupTabBarItemViews().enumerated() {
            let tabBarSubItemsCount = view.tabBarItemViews.count
            
            if index >= groupSubItemsCount && index < groupSubItemsCount + tabBarSubItemsCount {
                let tabBarItemIndexInGroup = index - groupSubItemsCount
                view.isSelected = (isGroupSelected: true, selectedTabBarItemIndex: tabBarItemIndexInGroup)
            } else {
                view.isSelected = (isGroupSelected: false, selectedTabBarItemIndex: nil)
            }

            groupSubItemsCount += tabBarSubItemsCount
        }
    }
}

extension GroupingsTabBarViewImpl: TabBarGroupItemViewDelegate {
    public func didClickItem(withId id: UUID) {
        
        let selectedTabBarItemIndex: Int? = {
            for (i, view) in groupsTabBarSubItemViews().enumerated() {
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

