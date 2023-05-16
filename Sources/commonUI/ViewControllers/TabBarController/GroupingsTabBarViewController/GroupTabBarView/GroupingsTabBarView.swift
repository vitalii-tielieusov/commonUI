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
    private var tabBarWidth: CGFloat
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
        stackView.distribution = .fillProportionally
        return stackView
    }()
    
    private lazy var higlightImageView: UIImageView = {
        let imageView = UIImageView()
        return imageView
    }()

    private lazy var higlightView: UIView = {
        let view = PassthroughView()
        view.addSubview(higlightImageView)
        
        higlightImageView.snp.makeConstraints { make in
            make.bottom.equalToSuperview()
            make.centerX.equalToSuperview()
        }
        
        return view
    }()
    
    required public init(tabBarItems: [TabBarGroupItem], tabBarWidth: CGFloat) {
        self.tabBarItemViewModels = tabBarItems
        self.tabBarWidth = tabBarWidth
        
        super.init(frame: .zero)
    }
    
    //TODO: Should delete or combine with help of enum
    public required init(tabBarItems: [TabBarItem]) {//TODO: Should think about 'init(tabBarItems: [TabBarGroupItem])' and 'init(tabBarItems: [TabBarItem]'
        self.tabBarItemViewModels = []
        self.tabBarWidth = 0
        super.init(frame: .zero)
    }
    
    public func setupUI(tabBarTopOffset: CGFloat) {
        
        self.tabBarTopOffset = tabBarTopOffset
        
        setupViews()
        setupLayouts()
        
        setupStackView()
        selectTabBarItem(atIndex: selectedTabBarItem, animate: false, atFirst: true)
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
        addSubview(higlightView)
    }
    
    private func setupLayouts() {
        stackView.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(tabBarTopOffset)
            make.left.right.bottom.equalToSuperview()
        }
        
        higlightView.snp.makeConstraints { make in
            make.bottom.equalToSuperview()
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
                collapsedGroupImage: tabBarItem.collapsedGroupImage,
                subItems: tabBarItem.subItems)
            tabBarItemView.delegate = self
            
            stackView.addArrangedSubview(tabBarItemView)
            
            if higlightImageView.image == nil {
                higlightImageView.image = tabBarItem.textBackgroundImage
            }
        }
    }
}

extension GroupingsTabBarViewImpl {
    private func groupTabBarItemViews() -> [TabBarGroupItemView & UIView] {
        guard let views = stackView.arrangedSubviews as? [TabBarGroupItemView & UIView] else {
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
    
    func selectTabBarItem(atIndex index: Int, animate: Bool = true, duration: TimeInterval = 0.3, atFirst: Bool = false) {
        var groupSubItemsCount: Int = 0
        for view in groupTabBarItemViews() {
            let tabBarSubItemsCount = view.tabBarItemViews.count
            
            if index >= groupSubItemsCount && index < groupSubItemsCount + tabBarSubItemsCount {
                let tabBarItemIndexInGroup = index - groupSubItemsCount
                view.isSelected = (isGroupSelected: true, selectedTabBarItemIndex: tabBarItemIndexInGroup, animate: animate, duration: duration)
            } else {
                view.isSelected = (isGroupSelected: false, selectedTabBarItemIndex: nil, animate: animate, duration: duration)
            }

            groupSubItemsCount += tabBarSubItemsCount
        }
        remakeConstraintsForTabBarItems(animate: animate, duration: duration, atFirst: atFirst)
    }
    
    private func remakeConstraintsForTabBarItems(animate: Bool = true, duration: TimeInterval = 0.3, atFirst: Bool = false) {
        let visibleTabBarItemsCount: Int = {
            var count = 0
            for view in groupTabBarItemViews() {
                count += view.isSelected.isGroupSelected ? view.tabBarItemViews.count : 1
            }
            return count
        }()
        let visibleTabBarItemWidth: CGFloat = tabBarWidth / CGFloat(visibleTabBarItemsCount)
        
        for (index, view) in groupTabBarItemViews().enumerated() {
            let groupTabBarItemViewWidth = view.isSelected.isGroupSelected ? visibleTabBarItemWidth * CGFloat(view.tabBarItemViews.count) : visibleTabBarItemWidth

            if animate {
                UIView.animate(withDuration: duration, animations: {
                    if atFirst {
                        view.snp.makeConstraints { make in
                            make.width.equalTo(groupTabBarItemViewWidth)
                        }
                    } else {
                        view.snp.updateConstraints { make in
                            make.width.equalTo(groupTabBarItemViewWidth)
                        }
                    }
                    
                    view.superview?.layoutIfNeeded()
                })
            } else {
                if atFirst {
                    view.snp.makeConstraints { make in
                        make.width.equalTo(groupTabBarItemViewWidth)
                    }
                } else {
                    view.snp.updateConstraints { make in
                        make.width.equalTo(groupTabBarItemViewWidth)
                    }
                }
            }
            
            if view.isSelected.isGroupSelected {
                if animate {
                    UIView.animate(withDuration: duration, animations: { [weak self] in
                        if atFirst {
                            self?.higlightView.snp.makeConstraints { make in
                                make.centerX.equalTo(CGFloat(index) * visibleTabBarItemWidth + 0.5 * groupTabBarItemViewWidth)
                            }
                        } else {
                            self?.higlightView.snp.updateConstraints { make in
                                make.centerX.equalTo(CGFloat(index) * visibleTabBarItemWidth + 0.5 * groupTabBarItemViewWidth)
                            }
                        }
                        
                        self?.higlightView.superview?.layoutIfNeeded()
                    })
                    
                } else {
                    
                    if atFirst {
                        higlightView.snp.makeConstraints { make in
                            make.centerX.equalTo(CGFloat(index) * visibleTabBarItemWidth + 0.5 * groupTabBarItemViewWidth)
                        }
                    } else {
                        higlightView.snp.updateConstraints { make in
                            make.centerX.equalTo(CGFloat(index) * visibleTabBarItemWidth + 0.5 * groupTabBarItemViewWidth)
                        }
                    }
                }
            }
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

