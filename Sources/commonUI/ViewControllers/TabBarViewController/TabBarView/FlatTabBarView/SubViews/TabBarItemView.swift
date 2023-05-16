//
//  TabBarItemView.swift
//  PaintWords
//
//  Created by Vitalii Tielieusov on 06.07.2022.
//

import UIKit

private struct Constants {
    
    private static let iPhone11ScreenWidth = 414.0
    private static let iPhoneSEScreenWidth = 375.0
    
    static var labelFont: UIFont {
        let fontSize = UIScreen.main.bounds.width < Constants.iPhoneSEScreenWidth ? 13.0 : 16.0
        return UIFont(name: "AlegreyaSC-Medium", size: fontSize) ?? UIFont.systemFont(ofSize: 16)
    }
    
    static var labelTextColor: UIColor {
        return UIColor(red: 32.0/255.0, green: 39.0/255.0, blue: 56.0/255.0, alpha: 1)
    }
}

public protocol TabBarItemViewDelegate: AnyObject {
    func didClickItem(withId id: UUID)
}

public protocol TabBarItemView: AnyObject {
    var isSelected: Bool { get set }
    var id: UUID { get }
    var delegate: TabBarItemViewDelegate? { get set }
    
    init(
        tabBarItemImage: UIImage?,
        selectedTabBarItemImage: UIImage?,
        title: String?,
        font: UIFont?,
        textColor: UIColor?
    )
}

public class TabBarItemViewImpl: UIView, TabBarItemView {

    public var isSelected: Bool = false {
        didSet {
            guard oldValue != isSelected else { return }
            
            setupAsSelected(isSelected)
        }
    }

    public private(set) var id = UUID()
    private var tabBarItemImage: UIImage?
    private var selectedTabBarItemImage: UIImage?
    private let title: String?
    private let font: UIFont?
    private let textColor: UIColor?
    
    public weak var delegate: TabBarItemViewDelegate?
    
    private lazy var imageView: UIImageView = {
        let imageView = UIImageView()
        return imageView
    }()
    
    private lazy var label: UILabel = {
        let label = UILabel()
        label.font = Constants.labelFont
        return label
    }()
    
    required public init(
        tabBarItemImage: UIImage?,
        selectedTabBarItemImage: UIImage?,
        title: String?,
        font: UIFont?,
        textColor: UIColor?
    ) {
        self.tabBarItemImage = tabBarItemImage
        self.selectedTabBarItemImage = selectedTabBarItemImage
        self.title = title
        self.font = font
        self.textColor = textColor
        
        super.init(frame: .zero)
        
        setupViews()
        setupLayouts()
        setupAsSelected(isSelected)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
    }
}

extension TabBarItemViewImpl {
    
    private func setupViews() {
        addSubview(imageView)
        addSubview(label)
        
        label.text = title
        label.textAlignment = .center
        label.textColor = textColor ?? Constants.labelTextColor
        label.font = font ?? Constants.labelFont
        
        addTapGestureRecognizer()
    }
    
    func addTapGestureRecognizer() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(self.handleTap(_:)))
        self.addGestureRecognizer(tap)
        self.isUserInteractionEnabled = true
    }
    
    @objc func handleTap(_ sender: UITapGestureRecognizer) {
        delegate?.didClickItem(withId: self.id)
    }
    
    private func setupLayouts() {
        label.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.bottom.equalToSuperview()
        }
        imageView.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalToSuperview()
            make.height.equalTo(imageView.snp.width)
        }
    }
    
    private func setupAsSelected(_ isSelected: Bool, animate: Bool = true) {
        let toImage = isSelected ? selectedTabBarItemImage : tabBarItemImage

        if animate {
            UIView.transition(
                with: self.imageView,
                duration: 0.3,
                options: .curveLinear,
                animations: { [weak self] in
                    self?.imageView.image = toImage
                },
                completion: nil)

        } else {
            imageView.image = isSelected ? selectedTabBarItemImage : tabBarItemImage
        }
    }
}
