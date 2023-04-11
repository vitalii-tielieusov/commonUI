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
    var isSelected: (isGroupSelected: Bool, selectedTabBarItemIndex: Int?) { get set }
    var tabBarItemViews: [TabBarSubItemView] { get }
    var delegate: TabBarGroupItemViewDelegate? { get set }

    init(
        title: String?,
        font: UIFont?,
        textColor: UIColor?,
        textBackgroundImage: UIImage?,
        collapsedGroupImage: UIImage?,
        subItems: [TabBarSubItem]
    )
}

public class TabBarGroupItemViewImpl: UIView, TabBarGroupItemView {
    
    public var tabBarItemViews: [TabBarSubItemView] {
        allTabBarSubItems().filter({ $0.id != collapsedGroupSubItem.id })
    }

    public var isSelected: (isGroupSelected: Bool, selectedTabBarItemIndex: Int?) = (isGroupSelected: false, selectedTabBarItemIndex: nil) {
        didSet {
            guard oldValue != isSelected else { return }

            setupAsSelected(isGroupSelected: isSelected.0, selectedTabBarItemIndex: isSelected.1)
        }
    }

    private let title: String?
    private let font: UIFont?
    private let textColor: UIColor?
    private var textBackgroundImage: UIImage?
    private let subItems: [TabBarSubItem]
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
        stackView.spacing = 0
        stackView.axis = .vertical
        return stackView
    }()

    private lazy var imageView: UIImageView = {
        let imageView = UIImageView()
        return imageView
    }()

    private lazy var label: UILabel = {
        let label = UILabel()
        label.font = Constants.labelFont
        return label
    }()

    private lazy var titleView: UIView = {
        let view = UIView()
        view.addSubview(imageView)
        view.addSubview(label)
        
        imageView.snp.makeConstraints { make in
            make.bottom.equalToSuperview()
            make.centerX.equalToSuperview()
        }
        
        label.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(10)
            make.centerX.equalToSuperview()
        }
        
        return imageView
    }()
    
    required public init(
        title: String?,
        font: UIFont?,
        textColor: UIColor?,
        textBackgroundImage: UIImage?,
        collapsedGroupImage: UIImage?,
        subItems: [TabBarSubItem]
    ) {
        self.title = title
        self.font = font
        self.textColor = textColor
        self.textBackgroundImage = textBackgroundImage
        self.collapsedGroupSubItem = TabBarSubItemViewImpl(
            tabBarItemImage: collapsedGroupImage,
            selectedTabBarItemImage: collapsedGroupImage
        )
        
        self.subItems = subItems

        super.init(frame: .zero)

        setupViews()
        setupLayouts()
        
        setupContentStackView()
        setupAsSelected(isGroupSelected: false, selectedTabBarItemIndex: nil, animate: false)
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
        imageView.image = textBackgroundImage
        
        setupTabBarSubItemsStackView()
    }
    
    private func setupTabBarSubItemsStackView() {
        
        for tabBarItem in subItems {
            let tabBarItemView = TabBarSubItemViewImpl(
                tabBarItemImage: tabBarItem.image,
                selectedTabBarItemImage: tabBarItem.selectedImage
            )
            tabBarItemView.isSelected = false
            tabBarItemView.delegate = self

            subItemsStackView.addArrangedSubview(tabBarItemView)
        }
        
        subItemsStackView.addArrangedSubview(collapsedGroupSubItem)
        collapsedGroupSubItem.delegate = self
    }

    private func setupAsSelected(
        isGroupSelected: Bool,
        selectedTabBarItemIndex: Int?,
        animate: Bool = true) {
        
        if isGroupSelected {
            titleView.isHidden = false
            expandGroup(true)
            if let index = selectedTabBarItemIndex {
                selectTabBarItem(atIndex: index)
            }
        } else {
            titleView.isHidden = true
            expandGroup(false)
        }
    }
    
    private func allTabBarSubItems() -> [TabBarSubItemView & UIView] {
        guard let subviews = subItemsStackView.arrangedSubviews as? [TabBarSubItemView & UIView] else {
            return []
        }
        
        return subviews
    }
    
    private func expandGroup(_ expande: Bool) {
        allTabBarSubItems().forEach { tabBarSubItemView in
            if expande {
                tabBarSubItemView.isHidden = tabBarSubItemView.id == collapsedGroupSubItem.id
            } else {
                tabBarSubItemView.isHidden = tabBarSubItemView.id != collapsedGroupSubItem.id
            }
        }
    }
    
    func selectTabBarItem(atIndex index: Int) {
        for (i, view) in allTabBarSubItems().enumerated() {
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
            if let selectedItemId = allTabBarSubItems().filter({ $0.id != collapsedGroupSubItem.id && $0.isSelected }).first?.id ??  allTabBarSubItems().filter({ $0.id != collapsedGroupSubItem.id }).first?.id {
                delegate?.didClickItem(withId: selectedItemId)
            }
        } else {
            delegate?.didClickItem(withId: id)
        }
    }
}
