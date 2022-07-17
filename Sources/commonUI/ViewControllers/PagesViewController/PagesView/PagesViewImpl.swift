//
//  PagesViewImpl.swift
//  Inspire me
//
//  Created by Vitaliy Teleusov on 08.01.2022.
//

import UIKit
import SnapKit
import math

final class PagesViewImpl: UIView {
    
    private var previousSelectedPageIndex: Int = NSNotFound
    
    weak var dataSource: PagesViewDataSource?
    weak var delegate: PagesViewDelegate?
    
    weak var layoutDelegate: PagesViewLayoutDelegate?
    
    var shouldKillScroll: Bool = false
    
    public lazy var scrollView: UIScrollView = {
        let scrollView = UIHelper.prepareScrollView()
        scrollView.delegate = self
        return scrollView
    }()
    
    private lazy var scrollContentView: UIView = {
        return UIView()
    }()
    
    private var shouldAddTapGestureRecognizer = false
    
    private lazy var tapGestureRecognizer: UITapGestureRecognizer = {
        let gestureRecognizer = UITapGestureRecognizer(target: self,
                                                       action: #selector(PagesViewImpl.didTap(_:)))
        return gestureRecognizer
    }()
    
    @objc func didTap(_ sender: UITapGestureRecognizer) {
        let point = sender.location(in: self)
        if point.x < 0.5 * self.view.frame.size.width {
            delegate?.didClickOnLeftPageSide()
        } else {
            delegate?.didClickOnRightPageSide()
        }
    }
    
    init() {
        super.init(frame: .zero)
        backgroundColor = .white
        
        setupViews()
        setupLayouts()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
    }
    
    private func setupViews() {
        addSubview(scrollView)
        scrollView.addSubview(scrollContentView)
        
        addTapGestureRecognizerIdNeed()
    }
    
    private func addTapGestureRecognizerIdNeed() {
        if shouldAddTapGestureRecognizer {
            scrollView.addGestureRecognizer(tapGestureRecognizer)
        }
    }
    
    private func removeTapGestureRecognizer() {
        scrollView.removeGestureRecognizer(tapGestureRecognizer)
    }
    
    private func setupLayouts() {
        scrollView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        scrollContentView.snp.makeConstraints { make in
            make.top.bottom.equalTo(self)
            make.width.equalTo(scrollContentViewWidth())
            make.left.right.equalTo(scrollView)
        }
    }
    
    public func viewSize() -> CGSize {
        return self.frame.size
    }
    
    private func scrollContentViewWidth() -> CGFloat {
        guard let dataSource = dataSource else { return 0 }

        let pagesCount = dataSource.pagesCount()
        let pagesViewWidth = viewSize().width
        
        if pagesCount > 0 {
            return pagesViewWidth * CGFloat(pagesCount)
        }
        
        return 0
    }
    
    private func setupContent() {
        
        previousSelectedPageIndex = NSNotFound
        for subView in scrollContentView.subviews {
            subView.removeFromSuperview()
        }
        
        scrollContentView.snp.updateConstraints { make in
            make.width.equalTo(scrollContentViewWidth())
        }
        
        guard let dataSource = dataSource else { return }
        
        let pagesCount = dataSource.pagesCount()
        guard pagesCount > 0 else { return }
        
        let pagesViewWidth = viewSize().width
        let pagesCornerRadius = layoutDelegate?.pagesCornerRadius() ?? 0
        
        for index in 0 ..< pagesCount {
            
            let pageView = dataSource.pageView(at: index)
            scrollContentView.addSubview(pageView)
            
            let pageLeftOffset = pagesViewWidth * CGFloat(index)
            
            pageView.snp.makeConstraints { make in
                make.top.bottom.equalToSuperview()
                make.width.equalTo(pagesViewWidth)
                make.left.equalToSuperview().offset(pageLeftOffset)
            }
            
            pageView.layer.cornerRadius = pagesCornerRadius
        }
    }
}

//Pages custom size
extension PagesViewImpl {
    
    func pageViewXOffset(forPageIndex pageIndex: Int,
                         scrollOffset x: CGFloat,
                         leftPageWidth w1: CGFloat,
                         middlePageWidth w2: CGFloat,
                         rightPageWidth w3: CGFloat,
                         horizontalPagesSpace delta: CGFloat,
                         pagesViewWidth: CGFloat) -> CGFloat {
        
        let pageWidth = pagesViewWidth
        let pageX = pagePositionX(for: pageIndex)
        
        //leftPageOffset
        let t1 = 1.5 * pageWidth - 0.5 * w2 - delta - w1
        //middlePageOffset
        let t2 = 0.5 * (pageWidth - w2)
        //rightPageOffset
        let t3 = -(0.5 * pageWidth - 0.5 * w2 - delta)
        
        if pageX > x + pageWidth {//TODO: Was '>=' Should check workflow
            return t3
        }
        
        if (x < pageX) && ((pageX - x) < pageWidth) {
            let a = pageX - pageWidth
            let b = pageX

            return Math.lineFunctionValue(inArgumentValue: x,
                                          firstFunctionKnownValue: a,
                                          secondFunctionKnownValue: b,
                                          firstFunctionKnownArgument: t3,
                                          secondFunctionKnownArgument: t2)
        }
        
        if pageX == x {
            return t2
        }
        
        if (x > pageX) && ((x - pageX) < pageWidth) {
            let a = pageX
            let b = pageX + pageWidth
            
            return Math.lineFunctionValue(inArgumentValue: x,
                                          firstFunctionKnownValue: a,
                                          secondFunctionKnownValue: b,
                                          firstFunctionKnownArgument: t2,
                                          secondFunctionKnownArgument: t1)
        }
        
        if (x - pageX) > pageWidth {//TODO: Was '>=' Should check workflow
            return t1
        }

        return 0
    }
    
    func pageViewWidth(forPageIndex pageIndex: Int,
                       scrollOffset x: CGFloat,
                       leftPageWidth w1: CGFloat,
                       middlePageWidth w2: CGFloat,
                       rightPageWidth w3: CGFloat,
                       pagesViewWidth: CGFloat) -> CGFloat {

        let pageWidth = pagesViewWidth
        let pageX = pagePositionX(for: pageIndex)

        if pageX >= x + pageWidth {
            return w3
        }
        
        if (x < pageX) && ((pageX - x) < pageWidth) {
            let a = pageX - pageWidth
            let b = pageX

            return Math.lineFunctionValue(inArgumentValue: x,
                                          firstFunctionKnownValue: a,
                                          secondFunctionKnownValue: b,
                                          firstFunctionKnownArgument: w3,
                                          secondFunctionKnownArgument: w2)
        }
        
        if pageX == x {
            return w2
        }
        
        if (x > pageX) && ((x - pageX) < pageWidth) {
            let a = pageX
            let b = pageX + pageWidth
            
            return Math.lineFunctionValue(inArgumentValue: x,
                                          firstFunctionKnownValue: a,
                                          secondFunctionKnownValue: b,
                                          firstFunctionKnownArgument: w2,
                                          secondFunctionKnownArgument: w1)
        }
        
        if (x - pageX) >= pageWidth {
            return w1
        }

        return 0
    }

    func pageViewHeight(forPageIndex pageIndex: Int,
                        scrollOffset x: CGFloat,
                        leftPageHeight h1: CGFloat,
                        middlePageHeight h2: CGFloat,
                        rightPageHeight h3: CGFloat,
                        pagesViewWidth: CGFloat) -> CGFloat {

        let pageWidth = pagesViewWidth
        let pageX = pagePositionX(for: pageIndex)

        if pageX >= x + pageWidth {
            return h3
        }
        
        if (x < pageX) && ((pageX - x) < pageWidth) {
            let a = pageX - pageWidth
            let b = pageX

            return Math.lineFunctionValue(inArgumentValue: x,
                                          firstFunctionKnownValue: a,
                                          secondFunctionKnownValue: b,
                                          firstFunctionKnownArgument: h3,
                                          secondFunctionKnownArgument: h2)
        }
        
        if pageX == x {
            return h2
        }
        
        if (x > pageX) && ((x - pageX) < pageWidth) {
            let a = pageX
            let b = pageX + pageWidth
            
            return Math.lineFunctionValue(inArgumentValue: x,
                                          firstFunctionKnownValue: a,
                                          secondFunctionKnownValue: b,
                                          firstFunctionKnownArgument: h2,
                                          secondFunctionKnownArgument: h1)
        }
        
        if (x - pageX) >= pageWidth {
            return h1
        }

        return 0
    }
    
    private func remakeContentConstraints() {

        //dataSource data
        guard let dataSource = dataSource else { return }

        let pagesCount = dataSource.pagesCount()
        guard pagesCount > 0 else { return }
        
        let pagesViewWidth = viewSize().width
        let pagesViewHeight = viewSize().height
        
        let leftPageSize: CGSize = {
            
            switch layoutDelegate?.leftPageSize() ?? PageSize.full {
            case .full:
                return viewSize()
            case .specified(let size):
                return size
            }
        }()
        
        let middlePageSize: CGSize = {
            
            switch layoutDelegate?.middlePageSize() ?? PageSize.full  {
            case .full:
                return viewSize()
            case .specified(let size):
                return size
            }
        }()
        
        let rightPageSize: CGSize = {
            
            switch layoutDelegate?.rightPageSize() ?? PageSize.full  {
            case .full:
                return viewSize()
            case .specified(let size):
                return size
            }
        }()
        
        let horizontalSpaceBetweenPages = layoutDelegate?.horizontalPagesSpaces() ?? 0
        let verticalPagesAlignment = layoutDelegate?.verticalPagesAlignment() ?? .middle
        
        let mostPageHeight: CGFloat = {
            return max(leftPageSize.height, middlePageSize.height, rightPageSize.height)
        }()
        
        
        for index in 0 ..< pagesCount {
            let pageView = dataSource.pageView(at: index)
            
            let x = scrollView.contentOffset.x
            
            let t = pageViewXOffset(forPageIndex: index,
                                    scrollOffset: x,
                                    leftPageWidth: leftPageSize.width,
                                    middlePageWidth: middlePageSize.width,
                                    rightPageWidth: rightPageSize.width,
                                    horizontalPagesSpace: horizontalSpaceBetweenPages,
                                    pagesViewWidth: pagesViewWidth)
            let h = pageViewHeight(forPageIndex: index,
                                   scrollOffset: x,
                                   leftPageHeight: leftPageSize.height,
                                   middlePageHeight: middlePageSize.height,
                                   rightPageHeight: rightPageSize.height,
                                   pagesViewWidth: pagesViewWidth)
            let w = pageViewWidth(forPageIndex: index,
                                  scrollOffset: x,
                                  leftPageWidth: leftPageSize.width,
                                  middlePageWidth: middlePageSize.width,
                                  rightPageWidth: rightPageSize.width,
                                  pagesViewWidth: pagesViewWidth)
            
            let topOffset: CGFloat = {

                switch verticalPagesAlignment {
                case .top:
                    return (pagesViewHeight - mostPageHeight) / 2.0
                case .middle:
                    return (pagesViewHeight - h) / 2.0
                case .bottom:
                    let bottomOffset = (pagesViewHeight - mostPageHeight) / 2.0
                    return (pagesViewHeight - h - bottomOffset)
                }
            }()
            
            pageView.snp.remakeConstraints { make in
                make.top.equalToSuperview().offset(topOffset)
                make.width.equalTo(w)
                make.height.equalTo(h)
                make.left.equalToSuperview().offset(pagesViewWidth * CGFloat(index) + t)
            }
        }
    }
}

extension PagesViewImpl: PagesView {
    
    var view: UIView! {
        get {
            return self
        }
    }
    
    func reloadData() {
        setupContent()
        remakeContentConstraints()
    }
    
    var isScrollEnabled: Bool {
        get {
            return scrollView.isScrollEnabled
        }
        set {
            scrollView.isScrollEnabled = newValue
        }
    }
    
    var isClickable: Bool {
        get {
            return shouldAddTapGestureRecognizer
        }
        set {
            shouldAddTapGestureRecognizer = newValue
            
            if shouldAddTapGestureRecognizer {
                addTapGestureRecognizerIdNeed()
            } else {
                removeTapGestureRecognizer()
            }
        }
    }
    
    var selectedPageIndex: Int {
        get {
            return mostVisiblePageIndex()
        }
        set {
            setSelectedPageIndex(index: newValue, animated: false)
        }
    }
    
    func selectPage(at index: Int, animated: Bool) {

        setSelectedPageIndex(index: index, animated: animated)
    }
    
    func selectNextPage(animated: Bool) {
        
        guard let pagesCount = dataSource?.pagesCount(),
              pagesCount > 0 else {
            return
        }

        if selectedPageIndex < (pagesCount - 1) {
            selectPage(at: selectedPageIndex + 1, animated: animated)
        }
    }
    
    func selectPreviousPage(animated: Bool) {
        
        guard let pagesCount = dataSource?.pagesCount(),
              pagesCount > 0 else {
            return
        }
        
        if selectedPageIndex > 0 {
            selectPage(at: selectedPageIndex - 1, animated: animated)
        }
    }
    
    private func setSelectedPageIndex(index: Int, animated: Bool) {
        
        let pagesViewWidth = viewSize().width
        
        guard scrollContentViewWidth() > 0, pagesViewWidth > 0 else { return }
        let position: Int = Int(scrollContentViewWidth() / pagesViewWidth)
        if position >= index {
            
            let floatPageNumber: CGFloat = CGFloat(index)
            
            scrollView.setContentOffset(CGPoint(x: pagesViewWidth * floatPageNumber, y: 0),
                                        animated: animated)
            delegate?.didScroll(to: index)
            previousSelectedPageIndex = index
        }
    }
}

extension PagesViewImpl: UIScrollViewDelegate {
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
            
        remakeContentConstraints()

        switch scrollView.panGestureRecognizer.state {
        case .possible:
            if shouldKillScroll { killScroll() }

        default:
            break
        }
    }
    
    func scrollViewDidEndScrollingAnimation(_ scrollView: UIScrollView) {
        shouldKillScroll = false
        scrollToMostVisiblePage()
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        if isScrollEnabled {
            scrollToMostVisiblePage()
            notifySelectedPageIndexDidChange()
        }
    }
    
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        shouldKillScroll = true
    }
    
    func scrollViewDidEndDragging(_ scrollView: UIScrollView,
                                  willDecelerate decelerate: Bool) {
        if isScrollEnabled && !decelerate {
            scrollToMostVisiblePage()
            notifySelectedPageIndexDidChange()
        }
    }
    
    private func notifySelectedPageIndexDidChange() {
        if previousSelectedPageIndex != mostVisiblePageIndex() {
            delegate?.didScroll(to: mostVisiblePageIndex())
            previousSelectedPageIndex = mostVisiblePageIndex()
        }
    }
    
    func killScroll() {
        let offset = self.scrollView.contentOffset;
        scrollView.setContentOffset(offset, animated: false)
    }
    
    private func scrollToMostVisiblePage(animated: Bool = true) {
        setSelectedPageIndex(index: mostVisiblePageIndex(),
                             animated: animated)
    }
    
    private func mostVisiblePageIndex() -> Int {

        let pagesViewWidth = viewSize().width
        
        let floatPageIndex: CGFloat = scrollView.contentOffset.x / pagesViewWidth
        var nearestPageIndex: Int = Int(floatPageIndex)
        let diff: CGFloat = floatPageIndex - CGFloat(nearestPageIndex)
        if diff >= 0.5 {
            nearestPageIndex += 1
        }
        
        return nearestPageIndex
    }
    
    private func letfVisiblePageIndex() -> Int? {
        return mostVisiblePageIndex() > 0 ? mostVisiblePageIndex() - 1 : nil
    }
    
    private func rightVisiblePageIndex() -> Int? {
        guard let pagesCount = dataSource?.pagesCount(), mostVisiblePageIndex() < pagesCount - 1 else {
            return nil
        }
        
        return mostVisiblePageIndex() + 1
    }
    
    private func pageOffset(for pageIndex: Int) -> CGFloat? {
        guard let dataSource = dataSource else { return nil }

        let pagesCount = dataSource.pagesCount()
        guard pagesCount > 0, pageIndex < pagesCount else { return nil }

        let pagesViewWidth = viewSize().width
        return scrollView.contentOffset.x - pagesViewWidth * CGFloat(pageIndex)
    }
    
    private func pagePositionX(for pageIndex: Int) -> CGFloat {

        let pagesViewWidth = viewSize().width
        return pagesViewWidth * CGFloat(pageIndex)
    }
}
