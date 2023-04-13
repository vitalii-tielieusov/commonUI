//
//  File.swift
//  
//
//  Created by Vitalii Tielieusov on 06.04.2023.
//

import UIKit

public protocol TabBarSubItemViewDelegate: AnyObject {
    func didClickItem(withId id: UUID)
}

public protocol TabBarSubItemView: AnyObject {
    var isSelected: Bool { get set }
    var id: UUID { get }
    var delegate: TabBarSubItemViewDelegate? { get set }
    
    init(
        tabBarItemImage: UIImage?,
        selectedTabBarItemImage: UIImage?
    )
}

public class TabBarSubItemViewImpl: UIView, TabBarSubItemView {

    public var isSelected: Bool = false {
        didSet {
            guard oldValue != isSelected else { return }
            
            setupAsSelected(isSelected)
        }
    }

    public private(set) var id = UUID()
    private var tabBarItemImage: UIImage?
    private var selectedTabBarItemImage: UIImage?
    
    public weak var delegate: TabBarSubItemViewDelegate?
    
    private lazy var imageView: UIImageView = {
        let imageView = UIImageView()
        return imageView
    }()
    
    required public init(
        tabBarItemImage: UIImage?,
        selectedTabBarItemImage: UIImage?
    ) {
        self.tabBarItemImage = tabBarItemImage
        self.selectedTabBarItemImage = selectedTabBarItemImage
        
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

extension TabBarSubItemViewImpl {
    
    private func setupViews() {
        addSubview(imageView)
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
