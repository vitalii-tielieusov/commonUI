//
//  PageControl.swift
//  PaintWords
//
//  Created by Vitalii Tielieusov on 05.07.2022.
//

import UIKit

public struct PageControlShadowParams {
    let shadowColor: CGColor?
    let shadowOpacity: Float
    let shadowOffset: CGSize
    let shadowRadius: CGFloat
    public init(
        shadowColor: CGColor?,
        shadowOpacity: Float,
        shadowOffset: CGSize,
        shadowRadius: CGFloat
    ) {
        self.shadowColor = shadowColor
        self.shadowOpacity = shadowOpacity
        self.shadowOffset = shadowOffset
        self.shadowRadius = shadowRadius
    }
}

public protocol PageControlDelegate: AnyObject {
    func didClickPage(atIndex index: Int)
}

public protocol PageControl: AnyObject {
    var numberOfPages: Int { get }
    var currentPage: Int { get set }
    
    var delegate: PageControlDelegate? { get set }
    
    init(
        numberOfPages: Int,
        pageSize: CGSize,
        spacing: CGFloat,
        pageIndicatorImage: UIImage?,
        currentPageIndicatorImage: UIImage?,
        pageIndicatorShadow: PageControlShadowParams?,
        animatePageIndicator: Bool,
        rotatePageIndicator: Bool
    )
}

public class PageControlImpl: UIView, PageControl {
    
    public weak var delegate: PageControlDelegate?
    public private(set) var numberOfPages: Int
    public var currentPage: Int = 0 {
        willSet {
            guard newValue != currentPage else { return }
            
            selectPage(atIndex: newValue)
        }
    }

    private let pageSize: CGSize
    private var spacing: CGFloat
    private var pageIndicatorImage: UIImage?
    private var currentPageIndicatorImage: UIImage?
    private var pageIndicatorShadow: PageControlShadowParams?
    private var animatePageIndicator: Bool
    private var rotatePageIndicator: Bool
    
    private lazy var stackView: UIStackView = {
        let stackView = UIStackView()
        stackView.spacing = 2
        stackView.axis = .horizontal
        return stackView
    }()
    
    required public init(
        numberOfPages: Int,
        pageSize: CGSize,
        spacing: CGFloat,
        pageIndicatorImage: UIImage?,
        currentPageIndicatorImage: UIImage?,
        pageIndicatorShadow: PageControlShadowParams?,
        animatePageIndicator: Bool,
        rotatePageIndicator: Bool
    ) {
        self.numberOfPages = numberOfPages
        self.pageSize = pageSize
        self.spacing = spacing
        self.pageIndicatorImage = pageIndicatorImage
        self.currentPageIndicatorImage = currentPageIndicatorImage
        self.pageIndicatorShadow = pageIndicatorShadow
        self.animatePageIndicator = animatePageIndicator
        self.rotatePageIndicator = rotatePageIndicator
        
        super.init(frame: .zero)
        
        setupViews()
        setupLayouts()
        
        setupStackView()
        selectPage(atIndex: currentPage)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
    }
}

extension PageControlImpl {
    
    private func setupViews() {
        addSubview(stackView)
    }
    
    private func setupLayouts() {
        stackView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
    
    private func setupStackView() {
        stackView.spacing = spacing
        for pageIndex in 0 ..< numberOfPages {
            let pageIndicator = PageIndicatorViewImpl(
                index: pageIndex,
                pageIndicatorImage: pageIndicatorImage,
                currentPageIndicatorImage: currentPageIndicatorImage,
                animatePageIndicator: self.animatePageIndicator,
                rotatePageIndicator: self.rotatePageIndicator)
            pageIndicator.delegate = self
            stackView.addArrangedSubview(pageIndicator)
            
            pageIndicator.snp.makeConstraints { make in
                make.width.equalTo(pageSize.width)
                make.height.equalTo(pageSize.height)
            }
            
            if let pageIndicatorShadow {
                pageIndicator.layer.shadowColor = pageIndicatorShadow.shadowColor
                pageIndicator.layer.shadowOpacity = pageIndicatorShadow.shadowOpacity
                pageIndicator.layer.shadowOffset = pageIndicatorShadow.shadowOffset
                pageIndicator.layer.shadowRadius = pageIndicatorShadow.shadowRadius
            }
        }
    }
    
    private func pageIndicatorViews() -> [PageIndicatorViewImpl] {
        guard let pageIndicators = stackView.arrangedSubviews as? [PageIndicatorViewImpl] else {
            return []
        }
        
        return pageIndicators
    }
    
    func pageIndicatorView(atIndex index: Int) -> PageIndicatorViewImpl? {
        for view in pageIndicatorViews() {
            if view.index == index {
                return view
            }
        }
        
        return nil
    }
    
    func selectPage(atIndex index: Int) {
        for view in pageIndicatorViews() {
            if rotatePageIndicator {
                view.rotationDirection = currentPage < index ? .clockwise : .anticlockwise
            }
            view.isCurrent = view.index == index
        }
    }
}

extension PageControlImpl: PageIndicatorViewDelegate {
    public func didClickPage(atIndex index: Int) {
        currentPage = index
        delegate?.didClickPage(atIndex: index)
    }
}
