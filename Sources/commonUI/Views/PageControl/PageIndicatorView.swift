//
//  PageIndicatorView.swift
//  PaintWords
//
//  Created by Vitalii Tielieusov on 05.07.2022.
//

import UIKit

public enum RotationDirection {
    case clockwise
    case anticlockwise
    
    var rotationAngle: CGFloat {
        switch self {
        case .clockwise:
            return (.pi / 2)
        case .anticlockwise:
            return -(.pi / 2)
        }
    }
}

public protocol PageIndicatorViewDelegate: AnyObject {
    func didClickPage(atIndex index: Int)
}

public protocol PageIndicatorView: AnyObject {
    var isCurrent: Bool { get set }
    var index: Int { get }
    var rotationDirection: RotationDirection { get set }
    var delegate: PageIndicatorViewDelegate? { get set }
    
    init(
        index: Int,
        pageIndicatorImage: UIImage?,
        currentPageIndicatorImage: UIImage?,
        animatePageIndicator: Bool,
        rotatePageIndicator: Bool
    )
}

public class PageIndicatorViewImpl: UIView, PageIndicatorView {
    public var isCurrent: Bool = false {
        didSet {
            guard oldValue != isCurrent else { return }
            
            setupAsCurrent(isCurrent, animate: self.animatePageIndicator, rotate: self.rotatePageIndicator)
        }
    }

    public private(set) var index: Int
    public var rotationDirection: RotationDirection = .clockwise
    private var pageIndicatorImage: UIImage?
    private var currentPageIndicatorImage: UIImage?
    private let animatePageIndicator: Bool
    private let rotatePageIndicator: Bool
    
    public weak var delegate: PageIndicatorViewDelegate?
    
    private lazy var imageView: UIImageView = {
        let imageView = UIImageView()
        return imageView
    }()
    
    required public init(
        index: Int,
        pageIndicatorImage: UIImage?,
        currentPageIndicatorImage: UIImage?,
        animatePageIndicator: Bool,
        rotatePageIndicator: Bool
    ) {
        self.index = index
        self.pageIndicatorImage = pageIndicatorImage
        self.currentPageIndicatorImage = currentPageIndicatorImage
        self.animatePageIndicator = animatePageIndicator
        self.rotatePageIndicator = rotatePageIndicator
        
        super.init(frame: .zero)
        
        setupViews()
        setupLayouts()
        setupAsCurrent(isCurrent, animate: self.animatePageIndicator, rotate: self.rotatePageIndicator)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
    }
}

extension PageIndicatorViewImpl {
    
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
        delegate?.didClickPage(atIndex: self.index)
    }
    
    private func setupLayouts() {
        imageView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
            if let imageSize = imageView.image?.size {
                make.width.equalTo(imageSize.width)
                make.height.equalTo(imageSize.height)
            }
        }
    }
    
    private func setupAsCurrent(_ isCurrent: Bool, animate: Bool = true, rotate: Bool = true) {
        let toImage = isCurrent ? currentPageIndicatorImage : pageIndicatorImage

        if animate {
            
            if isCurrent {
                DispatchQueue.main.asyncAfter(deadline: .now() + (animate ? 0.3 : 0.0)) { [weak self] in

                    guard let self = self else { return }

                    if rotate {
                        let angle = self.rotationDirection.rotationAngle
                        self.imageView.rotate(angle: angle, duration: (animate ? 0.3 : 0.0))
                    }

                UIView.transition(
                    with: self.imageView,
                    duration: (animate ? 0.3 : 0.0),
                    options: .curveLinear,
                    animations: { [weak self] in
                        self?.imageView.image = toImage
                    },
                    completion: nil)
                }
            } else {
                if rotate {
                    let angle = rotationDirection.rotationAngle
                    imageView.rotate(angle: angle, duration: (animate ? 0.6 : 0.0))
                }

                DispatchQueue.main.asyncAfter(deadline: .now() + (animate ? 0.3 : 0.0)) { [weak self] in

                    guard let imageView = self?.imageView else { return }

                    UIView.transition(
                        with: imageView,
                        duration: (animate ? 0.3 : 0.0),
                        options: .curveLinear,
                        animations: { [weak self] in
                            self?.imageView.image = toImage
                        },
                        completion: nil)
                }
            }
        } else {

            if rotate {
                let angle = self.rotationDirection.rotationAngle
                self.imageView.rotate(angle: angle, duration:  0.0)
            }

            imageView.image = isCurrent ? currentPageIndicatorImage : pageIndicatorImage
        }
    }
}

extension UIView {
    func rotate(angle: CGFloat, duration: CFTimeInterval) {
        let rotation : CABasicAnimation = CABasicAnimation(keyPath: "transform.rotation.z")
        rotation.toValue = NSNumber(value: angle)
        rotation.duration = duration
        rotation.isCumulative = true
        rotation.repeatCount = 1
        self.layer.add(rotation, forKey: "rotationAnimation")
    }
}
