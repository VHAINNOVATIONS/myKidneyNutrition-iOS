//
//  CustomTextField.swift
//  UIComponents
//
//  Created by TCCODER on 12/21/17.
//  Modified by TCCODER on 02/04/18.
//  Copyright © 2017-2018 Topcoder. All rights reserved.
//

import UIKit

/**
 * Text field with some changes according to design
 *
 * - author: TCCODER
 * - version: 1.1
 *
 * changes:
 * 1.1:
 * - UI changes
 */
@IBDesignable public class CustomTextField: UITextField {

    /// the radius of the corners
    @IBInspectable public var cornerRaduis: CGFloat = 3 { didSet { self.setNeedsLayout() } }

    /// the border color
    @IBInspectable public var borderColor: UIColor = Colors.border { didSet { self.setNeedsLayout() } }

    /// the border width
    @IBInspectable public var borderWidth: CGFloat = 0.5 { didSet { self.setNeedsLayout() } }

    /// the background color
    @IBInspectable public var bgColor: UIColor = UIColor.white { didSet { self.setNeedsLayout() } }

    /// the placeholder text color
    @IBInspectable public var customPlaceholderColor: UIColor = UIColor.gray { didSet { self.setNeedsLayout() } }

    /// the left padding
    @IBInspectable public var leftPadding: CGFloat = 0 { didSet { self.setNeedsLayout() } }

    /// Apply UI changes
    public override func layoutSubviews() {
        super.layoutSubviews()
        self.borderStyle = .none
        self.layer.cornerRadius = cornerRaduis
        self.layer.masksToBounds = true
        self.layer.borderColor = borderColor.cgColor
        self.layer.borderWidth = borderWidth
        self.backgroundColor = bgColor
        setPlaceholderColor(customPlaceholderColor)
    }

    /**
     Change placeholder text color

     - parameter aDecoder: decoder

     - returns: the instance
     */
    public override func awakeAfter(using aDecoder: NSCoder) -> Any? {
        setPlaceholderColor(customPlaceholderColor)
        return super.awakeAfter(using: aDecoder)
    }

    /**
     Set placeholder text color

     - parameter color: the color
     */
    func setPlaceholderColor(_ color: UIColor) {
        self.setValue(color, forKeyPath: "_placeholderLabel.textColor")
    }

    /// Text rectangle
    ///
    /// - Parameter bounds: the bounds
    /// - Returns: the rectangle
    override public func textRect(forBounds bounds: CGRect) -> CGRect {
        let originalRect: CGRect = super.editingRect(forBounds: bounds)
        return CGRect(x: originalRect.origin.x + leftPadding, y: originalRect.origin.y, width: originalRect.size.width - leftPadding, height: originalRect.size.height)
    }

    /// Editing rectangle
    ///
    /// - Parameter bounds: the bounds
    /// - Returns: the rectangle
    override public func editingRect(forBounds bounds: CGRect) -> CGRect {
        let originalRect: CGRect = super.editingRect(forBounds: bounds)
        return CGRect(x: originalRect.origin.x + leftPadding, y: originalRect.origin.y, width: originalRect.size.width - leftPadding, height: originalRect.size.height)
    }
}
