//
//  File.swift
//  
//
//  Created by Vitalii Tielieusov on 24.08.2022.
//

import UIKit

public protocol LevelViewDelegate: AnyObject {
    func didSetLevel(level: CGFloat)
}

public protocol LevelView: AnyObject {
    var level: CGFloat { get set }

    var delegate: LevelViewDelegate? { get set }
    
    init(
        level: CGFloat,
        indicatorsCount: Int,
        fillColor: UIColor,
        emptyColor: UIColor
    )
}

public class LevelViewImpl: UIView, LevelView {
    
    public weak var delegate: LevelViewDelegate?

    private var indicatorsCount: Int
    private var fillColor: UIColor
    private var emptyColor: UIColor
    
    public var level: CGFloat = 0 {
        didSet {
            setUpLevel(level)
        }
    }

    private lazy var stackView: UIStackView = {
        let stackView = UIStackView()
        stackView.spacing = 0
        stackView.axis = .horizontal
        return stackView
    }()
    
    required public init(
        level: CGFloat,
        indicatorsCount: Int,
        fillColor: UIColor,
        emptyColor: UIColor
    ) {
        self.indicatorsCount = indicatorsCount
        self.fillColor = fillColor
        self.emptyColor = emptyColor
        self.level = level
        
        super.init(frame: .zero)
        
        if indicatorsCount <= 2 {
            assertionFailure("Wrong indicators count")
        }
        
        setupViews()
        setupLayouts()
        
        setupStackView()
        setUpLevel(level)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
    }
}

extension LevelViewImpl {
    
    private func setupViews() {
        addSubview(stackView)
    }
    
    private func setupLayouts() {
        stackView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
    
    private func setupStackView() {
        
        for view in stackView.arrangedSubviews {
            view.removeFromSuperview()
        }
        
        for index in 0 ..< indicatorsCount {
            
            let indicatorLevel: CGFloat = {
                let increment = 1.0 / CGFloat(indicatorsCount)
                let currentLevel = increment * CGFloat(index + 1)
                return currentLevel
            }()
            
            let indicatorPosition: IndicatorViewPosition = {
                switch index {
                case 0:
                    return .first
                case indicatorsCount - 1:
                    return .last
                default:
                    return .middle
                }
            }()
            
            let indicatorView = LevelIndicatorViewImpl(
                level: indicatorLevel,
                position: indicatorPosition,
                fillColor: fillColor,
                emptyColor: emptyColor)

            indicatorView.delegate = self
            stackView.addArrangedSubview(indicatorView)
        }
        
        stackView.arrangedSubviews.setupEqualWidth()
    }
    
    private func levelIndicatorViews() -> [LevelIndicatorViewImpl] {
        guard let levelIndicators = stackView.arrangedSubviews as? [LevelIndicatorViewImpl] else {
            return []
        }
        
        return levelIndicators
    }
    
    private func levelIndicatorView(withLevel level: CGFloat) -> LevelIndicatorViewImpl? {
        for view in levelIndicatorViews() {
            if view.level == level {
                return view
            }
        }
        
        return nil
    }
    
    private func setUpLevel(_ level: CGFloat) {
        for view in levelIndicatorViews() {
            if view.isSelected != (view.level <= level) {
                view.isSelected = (view.level <= level)
            }
        }
    }
}

extension LevelViewImpl: LevelIndicatorViewDelegate {
    public func didSelectView(withLevel level: CGFloat) {
        self.level = level
        delegate?.didSetLevel(level: level)
    }
}
