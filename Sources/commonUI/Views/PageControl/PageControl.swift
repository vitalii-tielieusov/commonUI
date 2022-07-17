//
//  PageControl.swift
//  PaintWords
//
//  Created by Vitalii Tielieusov on 05.07.2022.
//

import UIKit

public protocol PageControlDelegate: AnyObject {
    func didClickPage(atIndex index: Int)
}

public protocol PageControl: AnyObject {
    var numberOfPages: Int { get }
    var currentPage: Int { get set }
    
    var delegate: PageControlDelegate? { get set }
    
    init(
        numberOfPages: Int,
        pageIndicatorImage: UIImage?,
        currentPageIndicatorImage: UIImage?
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

    private var pageIndicatorImage: UIImage?
    private var currentPageIndicatorImage: UIImage?
    
    private lazy var stackView: UIStackView = {
        let stackView = UIStackView()
        stackView.spacing = 2
        stackView.axis = .horizontal
        return stackView
    }()
    
    required public init(
        numberOfPages: Int,
        pageIndicatorImage: UIImage?,
        currentPageIndicatorImage: UIImage?
    ) {
        self.numberOfPages = numberOfPages
        self.pageIndicatorImage = pageIndicatorImage
        self.currentPageIndicatorImage = currentPageIndicatorImage
        
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
        for pageIndex in 0 ..< numberOfPages {
            let pageIndicator = PageIndicatorViewImpl(
                index: pageIndex,
                pageIndicatorImage: pageIndicatorImage,
                currentPageIndicatorImage: currentPageIndicatorImage)
            pageIndicator.delegate = self
            stackView.addArrangedSubview(pageIndicator)
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
            view.rotationDiraction = currentPage < index ? .clockwise : .anticlockwise
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
