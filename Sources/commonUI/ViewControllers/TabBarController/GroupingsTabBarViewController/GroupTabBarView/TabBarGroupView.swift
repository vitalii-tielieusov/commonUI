//
//  TabBarGroupView.swift
//  
//
//  Created by Vitalii Tielieusov on 06.04.2023.
//

import UIKit

private struct Constants {

    private static let iPhone11ScreenWidth = 414.0
    private static let iPhoneSEScreenWidth = 375.0

    static var labelFont: UIFont {
        let fontSize = UIScreen.main.bounds.width < Constants.iPhoneSEScreenWidth ? 13.0 : 15.0
        return UIFont(name: "AlegreyaSC-Medium", size: fontSize) ?? UIFont.systemFont(ofSize: 15)
    }

    static var labelTextColor: UIColor {
        return .white
    }
}

public protocol TabBarGroupItemViewDelegate: AnyObject {
    func didClickItem(withId id: UUID)
}

public protocol TabBarGroupItemView: AnyObject {
    var isSelected: (isGroupSelected: Bool, selectedTabBarItemIndex: Int?, animate: Bool, duration: TimeInterval) { get set }
    var tabBarItemViews: [TabBarSubItemView] { get }
    var delegate: TabBarGroupItemViewDelegate? { get set }

    init(
        title: String?,
        font: UIFont?,
        textColor: UIColor?,
        collapsedGroupImage: UIImage?,
        subItems: [TabBarSubItem]
    )
}

public class TabBarGroupItemViewImpl: UIView, TabBarGroupItemView {
    
    public var tabBarItemViews: [TabBarSubItemView] {
        expandedGroupSubItems
    }

    public var isSelected: (isGroupSelected: Bool, selectedTabBarItemIndex: Int?, animate: Bool, duration: TimeInterval) = (isGroupSelected: false, selectedTabBarItemIndex: nil, animate: false, duration: 0.3) {
        didSet {
            guard oldValue != isSelected else { return }

            setupAsSelected(isGroupSelected: isSelected.0, selectedTabBarItemIndex: isSelected.1, animate: isSelected.2, duration: isSelected.3)
        }
    }

    private let title: String?
    private let font: UIFont?
    private let textColor: UIColor?
    private let expandedGroupSubItems: [TabBarSubItemViewImpl]
    private let collapsedGroupSubItem: TabBarSubItemViewImpl
    
    public weak var delegate: TabBarGroupItemViewDelegate?
    
    private lazy var subItemsStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.spacing = 0
        stackView.axis = .horizontal
        stackView.distribution = .fillEqually
        return stackView
    }()
    
    private lazy var contentStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.spacing = -10
        stackView.axis = .vertical
        stackView.distribution = .fillEqually
        return stackView
    }()

    private lazy var label: UILabel = {
        let label = UILabel()
        label.font = Constants.labelFont
        return label
    }()

    private lazy var titleView: UIView = {
        let view = PassthroughView()
        view.addSubview(label)
        
        label.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(10)
            make.centerX.equalToSuperview()
        }
        
        return view
    }()
    
    required public init(
        title: String?,
        font: UIFont?,
        textColor: UIColor?,
        collapsedGroupImage: UIImage?,
        subItems: [TabBarSubItem]
    ) {
        self.title = title
        self.font = font
        self.textColor = textColor
        self.collapsedGroupSubItem = TabBarSubItemViewImpl(
            tabBarItemImage: collapsedGroupImage,
            selectedTabBarItemImage: collapsedGroupImage
        )
        
        var tabBarItemViews = [TabBarSubItemViewImpl]()
        for tabBarItem in subItems {
            let tabBarItemView = TabBarSubItemViewImpl(
                tabBarItemImage: tabBarItem.image,
                selectedTabBarItemImage: tabBarItem.selectedImage
            )
            tabBarItemView.isSelected = false
            tabBarItemViews.append(tabBarItemView)
        }
        expandedGroupSubItems = tabBarItemViews

        super.init(frame: .zero)

        setupViews()
        setupLayouts()
        
        setupContentStackView()
        setupAsSelected(isGroupSelected: false, selectedTabBarItemIndex: nil, animate: false, atFirst: true)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    deinit {
    }
}

extension TabBarGroupItemViewImpl {

    private func setupViews() {
        addSubview(contentStackView)
    }

    private func setupLayouts() {
        contentStackView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
    
    private func setupContentStackView(/*tabBarItemWidth: CGFloat*/) {
        
        for view in contentStackView.arrangedSubviews {
            view.removeFromSuperview()
        }
        
        contentStackView.addArrangedSubview(subItemsStackView)
        contentStackView.addArrangedSubview(titleView)
        
        label.text = title
        label.font = font
        label.textColor = textColor
        
        setupTabBarSubItemsStackView()
    }
    
    private func setupTabBarSubItemsStackView() {
        for tabBarItemView in expandedGroupSubItems {
            tabBarItemView.delegate = self

            subItemsStackView.addArrangedSubview(tabBarItemView)
        }
        
        subItemsStackView.addArrangedSubview(collapsedGroupSubItem)
        collapsedGroupSubItem.delegate = self
    }

    private func setupAsSelected(
        isGroupSelected: Bool,
        selectedTabBarItemIndex: Int?,
        animate: Bool = true,
        duration: TimeInterval = 0.3,
        atFirst: Bool = false
    ) {
//        remakeConstraintsForTitleView(hide: !isGroupSelected, animate: true, duration: duration, atFirst: atFirst)
        if isGroupSelected {
            hideViewTitleView(hide: false, animate: animate, duration: duration)
//            hideView(titleView, hide: false, animate: animate, duration: duration)
            expandGroup(true, animate: animate, duration: duration)
            if let index = selectedTabBarItemIndex {
                selectTabBarItem(atIndex: index)
            }
        } else {
            hideViewTitleView(hide: true, animate: animate, duration: duration)
//            hideView(titleView, hide: true, animate: animate, duration: duration)
            expandGroup(false, animate: animate, duration: duration)
        }
    }
    
    private func remakeConstraintsForTitleView(
        hide: Bool,
        animate: Bool = true,
        duration: TimeInterval = 0.3,
        atFirst: Bool = false
    ) {
        let offste: CGFloat = hide ? 15 : 10
        if animate {
            UIView.transition(with: label, duration: duration,
                              options: .transitionCrossDissolve,
                              animations: { [weak self] in
                if atFirst {
                    self?.label.snp.makeConstraints { make in
                        make.top.equalToSuperview().offset(offste)
                        make.centerX.equalToSuperview()
                    }
                } else {
                    self?.label.snp.updateConstraints { make in
                        make.top.equalToSuperview().offset(offste)
                    }
                }

//                self?.label.superview?.layoutIfNeeded()
            })
//            UIView.transition(with: titleView, duration: duration,
//                              options: .transitionCrossDissolve,
//                              animations: { [weak self] in
//                if atFirst {
//                    self?.titleView.snp.makeConstraints { make in
//                        make.top.equalToSuperview().offset(offste)
//                        make.centerX.equalToSuperview()
//                    }
//                } else {
//                    self?.titleView.snp.updateConstraints { make in
//                        make.top.equalToSuperview().offset(offste)
//                    }
//                }
//
////                self?.titleView.superview?.layoutIfNeeded()
//            })
        } else {
            if atFirst {
                label.snp.makeConstraints { make in
                    make.top.equalToSuperview().offset(offste)
                    make.centerX.equalToSuperview()
                }
            } else {
                label.snp.updateConstraints { make in
                    make.top.equalToSuperview().offset(offste)
                }
            }
//            if atFirst {
//                titleView.snp.makeConstraints { make in
//                    make.top.equalToSuperview().offset(offste)
//                    make.centerX.equalToSuperview()
//                }
//            } else {
//                titleView.snp.updateConstraints { make in
//                    make.top.equalToSuperview().offset(offste)
//                }
//            }
        }
    }

    private func expandGroup(
        _ expande: Bool,
        animate: Bool = true,
        duration: TimeInterval = 0.3
    ) {
        expandedGroupSubItems.forEach { view in
            hideView(view, hide: !expande, animate: animate, duration: duration)
        }
        hideView(collapsedGroupSubItem, hide: expande, animate: animate, duration: duration)
    }
    
    private func hideView(_ view: UIView, hide: Bool, animate: Bool = true, duration: TimeInterval = 0.3) {
        guard view.isHidden != hide else { return }
        
        if animate {
            UIView.animate(withDuration: duration) {
                view.isHidden = hide
                view.superview?.layoutIfNeeded()
            }
//            UIView.transition(with: view, duration: duration,
//                              options: .transitionCrossDissolve,
//                              animations: {
//                             view.isHidden = hide
//                          })
        } else {
            view.isHidden = hide
        }
    }
    
    private func hideViewTitleView(hide: Bool, animate: Bool = true, duration: TimeInterval = 0.3) {
        let textColor = hide ? UIColor.black : textColor
        
        if animate {
            UIView.transition(with: label, duration: duration, options: .transitionCrossDissolve) { [weak self] in
                self?.label.textColor = textColor
            }
        } else {
            label.textColor = textColor
        }
    }
    
    func selectTabBarItem(atIndex index: Int) {
        for (i, view) in expandedGroupSubItems.enumerated() {
            view.isSelected = (i == index)
        }
    }
}

extension TabBarGroupItemViewImpl: TabBarSubItemViewDelegate {
    public func didClickItem(withId id: UUID) {
        /*
         Если кликнули для раскрытия - то раскрываем группу и наружу сообщаем что кликнули по первому элементу данной группы (или возможно по запомненному выбранному в предыдущий раз элементу группы)
         Если кликнули по элементу уже раскрытой группы - сообщаем наружу что кликнули по вьюхе с таким-то id
         */
        if id == collapsedGroupSubItem.id {
            let selectedItemId: UUID? = expandedGroupSubItems.filter({ $0.isSelected }).first?.id
            let firstItemId: UUID? = expandedGroupSubItems.first?.id
            let itemId: UUID? = selectedItemId ?? firstItemId

            if let id = itemId  {
                delegate?.didClickItem(withId: id)
            }
        } else {
            delegate?.didClickItem(withId: id)
        }
    }
}
