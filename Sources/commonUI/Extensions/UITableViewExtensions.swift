//
//  UITableViewExtensions.swift
//  
//
//  Created by Vitalii Tielieusov on 07.07.2022.
//

import UIKit

//TODO: Should remove unused code

class UITableViewWithReloadCompletion: UITableView {
    
    var reloadDataCompletionBlock: (() -> Void)?
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        reloadDataCompletionBlock?()
        reloadDataCompletionBlock = nil
    }
    
    func reloadDataWithCompletion(completion:@escaping () -> Void) {
        reloadDataCompletionBlock = completion
        super.reloadData()
    }
}

//https://stackoverflow.com/questions/16071503/how-to-tell-when-uitableview-has-completed-reloaddata
extension UITableView {
    func reloadData(completion: @escaping () -> Void) {
        UIView.animate(withDuration: 0, animations: {
            self.reloadData()
        }, completion: { _ in
            completion()
        })
    }
}

extension UITableView {
    //set the tableHeaderView so that the required height can be determined, update the header's frame and set it again
    func setAndLayoutTableHeaderView(header: UIView) {
        header.removeFromSuperview()
        tableHeaderView = nil
        //self.tableHeaderView = header
        header.setNeedsLayout()
        header.layoutIfNeeded()
        let height = header.systemLayoutSizeFitting(UIView.layoutFittingCompressedSize).height
        var frame = header.frame
        frame.size.height = height
        header.frame = frame
        tableHeaderView = header
    }
    
    func setAndLayoutTableFooterView(footer: UIView) {
        footer.removeFromSuperview()
        tableFooterView = nil
        footer.setNeedsLayout()
        footer.layoutIfNeeded()
        let height = footer.systemLayoutSizeFitting(UIView.layoutFittingCompressedSize).height
        var frame = footer.frame
        frame.size.height = height
        footer.frame = frame
        tableFooterView = footer
    }
    
    func setAndLayoutTableFooterView(footer: UIView, frame: CGRect) {
        footer.removeFromSuperview()
        tableFooterView = nil
        footer.setNeedsLayout()
        footer.layoutIfNeeded()
        footer.frame = frame
        tableFooterView = footer
    }
    
    func registerReusableCell<T: UITableViewCell>(_: T.Type) where T: ReusableCell {
        if let nib = T.nib {
            register(nib, forCellReuseIdentifier: T.reuseIdentifier)
        } else {
            register(T.self, forCellReuseIdentifier: T.reuseIdentifier)
        }
    }
    
    func dequeueReusableCell<T: UITableViewCell>(indexPath: IndexPath) -> T where T: ReusableCell {
        guard let cell = dequeueReusableCell(withIdentifier: T.reuseIdentifier, for: indexPath) as? T else {
            fatalError("wrong type cell at index path \(indexPath)")
        }
        return cell
    }
    
    func registerReusableHeaderFooterView<T: UITableViewHeaderFooterView>(_: T.Type) where T: ReusableHeaderFooter {
        if let nib = T.nib {
            register(nib, forHeaderFooterViewReuseIdentifier: T.reuseIdentifier)
        } else {
            register(T.self, forHeaderFooterViewReuseIdentifier: T.reuseIdentifier)
        }
    }
    
    func dequeueReusableHeaderFooterView<T: UITableViewHeaderFooterView>() -> T? where T: ReusableHeaderFooter {
        return dequeueReusableHeaderFooterView(withIdentifier: T.reuseIdentifier) as? T
    }
    
    func updateCellHeights() {
        if #available(iOS 11.0, *) {
            performBatchUpdates(nil, completion: nil)
        } else {
            beginUpdates()
            endUpdates()
        }
    }
}

public protocol Identifiable {
    var identifier: String { get }
}

extension UITableView {
    var allIndexPaths: [IndexPath] {
        var result = [IndexPath]()
        (0..<numberOfSections).forEach { section in
            (0..<numberOfRows(inSection: section)).forEach { row in
                result.append(IndexPath(row: row, section: section))
            }
        }
        return result
    }
}
