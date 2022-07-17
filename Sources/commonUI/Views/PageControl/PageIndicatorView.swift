//
//  PageIndicatorView.swift
//  PaintWords
//
//  Created by Vitalii Tielieusov on 05.07.2022.
//

import UIKit

public enum RotationDiraction {
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
    var rotationDiraction: RotationDiraction { get set }
    var delegate: PageIndicatorViewDelegate? { get set }
    
    init(
        index: Int,
        pageIndicatorImage: UIImage?,
        currentPageIndicatorImage: UIImage?
    )
}

public class PageIndicatorViewImpl: UIView, PageIndicatorView {

    public var isCurrent: Bool = false {
        didSet {
            guard oldValue != isCurrent else { return }
            
            setupAsCurrent(isCurrent)
        }
    }

    public private(set) var index: Int
    public var rotationDiraction: RotationDiraction = .clockwise
    private var pageIndicatorImage: UIImage?
    private var currentPageIndicatorImage: UIImage?
    
    public weak var delegate: PageIndicatorViewDelegate?
    
    private lazy var imageView: UIImageView = {
        let imageView = UIImageView()
        return imageView
    }()
    
    required public init(
        index: Int,
        pageIndicatorImage: UIImage?,
        currentPageIndicatorImage: UIImage?
    ) {
        self.index = index
        self.pageIndicatorImage = pageIndicatorImage
        self.currentPageIndicatorImage = currentPageIndicatorImage
        
        super.init(frame: .zero)
        
        setupViews()
        setupLayouts()
        setupAsCurrent(isCurrent)
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
        }
    }
    
    private func setupAsCurrent(_ isCurrent: Bool, animate: Bool = true) {
        let toImage = isCurrent ? currentPageIndicatorImage : pageIndicatorImage

        if animate {
            
            if isCurrent {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) { [weak self] in

                    guard let self = self else { return }

                    let angle = self.rotationDiraction.rotationAngle
                    self.imageView.rotate(angle: angle, duration: 0.3)

                UIView.transition(
                    with: self.imageView,
                    duration: 0.3,
                    options: .curveLinear,
                    animations: { [weak self] in
                        self?.imageView.image = toImage
                    },
                    completion: nil)
                }
            } else {
                let angle = rotationDiraction.rotationAngle
                imageView.rotate(angle: angle, duration: 0.6)

                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) { [weak self] in

                    guard let imageView = self?.imageView else { return }

                    UIView.transition(
                        with: imageView,
                        duration: 0.3,
                        options: .curveLinear,
                        animations: { [weak self] in
                            self?.imageView.image = toImage
                        },
                        completion: nil)
                }
            }
        } else {
            imageView.image = isCurrent ? currentPageIndicatorImage : pageIndicatorImage
        }
    }
}

extension UIView{
    func rotate(angle: CGFloat, duration: CFTimeInterval) {
        let rotation : CABasicAnimation = CABasicAnimation(keyPath: "transform.rotation.z")
        rotation.toValue = NSNumber(value: angle)
        rotation.duration = duration
        rotation.isCumulative = true
        rotation.repeatCount = 1
        self.layer.add(rotation, forKey: "rotationAnimation")
    }
}
