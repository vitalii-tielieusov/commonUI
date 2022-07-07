//
//  ReusableCell.swift
//  
//
//  Created by Vitalii Tielieusov on 07.07.2022.
//

import UIKit

protocol ReusableCell: AnyObject {
    static var reuseIdentifier: String { get }
    static var nib: UINib? { get }
}

extension ReusableCell {
    static var reuseIdentifier: String { return String(describing: Self.self) }
    static var nib: UINib? { return nil }
}

protocol ReusableHeaderFooter: AnyObject {
    static var reuseIdentifier: String { get }
    static var nib: UINib? { get }
}

extension ReusableHeaderFooter {
    static var reuseIdentifier: String { return String(describing: Self.self) }
    static var nib: UINib? { return nil }
}
