//
//  File.swift
//  
//
//  Created by Vitalii Tielieusov on 24.08.2022.
//

import UIKit

public protocol LevelIndicatorViewDelegate: AnyObject {
    func didSelectView(withLevel level: CGFloat)
}

public protocol LevelIndicatorView: AnyObject {
    var isSelected: Bool { get set }
    var level: CGFloat { get }
    var delegate: LevelIndicatorViewDelegate? { get set }
    
    init(
        level: CGFloat,
        fillColor: UIColor,
        emptyColor: UIColor
    )
}

public class LevelIndicatorViewImpl: UIView, LevelIndicatorView {

    public let level: CGFloat
    private let fillColor: UIColor
    private let emptyColor: UIColor
    public weak var delegate: LevelIndicatorViewDelegate?
    
    public var isSelected: Bool = false {
        didSet {
            self.levelView.backgroundColor = isSelected ? fillColor : emptyColor
        }
    }
    
    private lazy var levelView: UIView = {
        let view = UIView()
        view.backgroundColor = emptyColor
        view.layer.cornerRadius = 5
        view.layer.borderWidth = 0.5
        view.layer.borderColor = UIColor(red: 10.0/255.0, green: 10.0/255.0, blue: 10.0/255.0, alpha: 1).cgColor
        return view
    }()
    
    required public init(
        level: CGFloat,
        fillColor: UIColor,
        emptyColor: UIColor
    ) {
        self.level = level
        self.fillColor = fillColor
        self.emptyColor = emptyColor
        
        super.init(frame: .zero)
        
        setupViews()
        setupLayouts()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
    }
}

extension LevelIndicatorViewImpl {
    
    private func setupViews() {
        addSubview(levelView)
        
        self.backgroundColor = emptyColor
        
        addTapGestureRecognizer()
    }
    
    private func setupLayouts() {
        levelView.snp.makeConstraints { make in
            make.left.right.bottom.equalToSuperview()
            make.height.equalToSuperview().multipliedBy(level)
        }
    }
    
    func addTapGestureRecognizer() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(self.handleTap(_:)))
        self.addGestureRecognizer(tap)
        self.isUserInteractionEnabled = true
    }
    
    @objc func handleTap(_ sender: UITapGestureRecognizer) {
        delegate?.didSelectView(withLevel: level)
    }
}
