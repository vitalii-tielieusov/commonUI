//
//  ReusableCell.swift
//  
//
//  Created by Vitalii Tielieusov on 07.07.2022.
//

import UIKit

public protocol ReusableCell: AnyObject {
    static var reuseIdentifier: String { get }
    static var nib: UINib? { get }
}

extension ReusableCell {
    public static var reuseIdentifier: String { return String(describing: Self.self) }
    public static var nib: UINib? { return nil }
}

public protocol ReusableHeaderFooter: AnyObject {
    static var reuseIdentifier: String { get }
    static var nib: UINib? { get }
}

extension ReusableHeaderFooter {
    public static var reuseIdentifier: String { return String(describing: Self.self) }
    public static var nib: UINib? { return nil }
}
