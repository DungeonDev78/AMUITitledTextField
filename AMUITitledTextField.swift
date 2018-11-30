    //
    //  AMUITitledTextField.swift
    //
    //  Created with 💪 by Alessandro Manilii.
    //  Copyright © 2018 Alessandro Manilii. All rights reserved.
    //

    import UIKit

    @IBDesignable
    class AMUITitledTextField: UITextField {

        // MARK: - IBInspectables
        @IBInspectable var title: String = "" {
            didSet { self.updateTextViewBorder() }
        }

        @IBInspectable var titleColor: UIColor = UIColor.black {
            didSet { updateTextViewBorder() }
        }

        @IBInspectable var borderWidth: CGFloat = 0.0 {
            didSet { updateTextViewBorder() }
        }

        @IBInspectable var borderColor: UIColor = UIColor.clear {
            didSet { updateTextViewBorder() }
        }

        @IBInspectable var cornerRadius: CGFloat = 0.0 {
            didSet { updateTextViewBorder() }
        }

        @IBInspectable var placeholderColor: UIColor = .lightGray {
            didSet { setValue(placeholderColor, forKeyPath: "_placeholderLabel.textColor")
     }
        }

        // MARK: - Properties
        private var borderLayer: CAShapeLayer?
        private var sidePadding: CGFloat = 8.0
        private let verticalPadding: CGFloat = 12.0
        private var lblTitle: UILabel?

        var originNew: CGPoint {
            get { return CGPoint(x: cornerRadius + borderWidth/2, y: 0) }
        }

        override func layoutSubviews() {
            super.layoutSubviews()
            updateTextViewBorder()
        }
    }

    extension AMTitledTextField {

        func updateTextViewBorder() {
            borderStyle = .none
            createTitle()
            borderLayer?.removeFromSuperlayer()
            borderLayer = nil
            borderLayer = CAShapeLayer()
            guard let borderLayer = borderLayer else { return }
            borderLayer.path = createPath().cgPath
            borderLayer.strokeColor = borderColor.cgColor
            borderLayer.fillColor = UIColor.clear.cgColor
            borderLayer.lineWidth = borderWidth
            self.layer.addSublayer(borderLayer)
        }
    }

    // MARK: - Rectangles Setup
    extension AMTitledTextField {

        var fullSidePadding : CGFloat { return cornerRadius + sidePadding }
        var topPadding      : CGFloat { return verticalPadding/2 }
        var textPadding     : CGFloat {return sidePadding/2}

        override public func textRect(forBounds bounds: CGRect) -> CGRect {
            return bounds.inset(by: UIEdgeInsets.init(top: topPadding,
                                                      left: fullSidePadding + textPadding,
                                                      bottom: 0,
                                                      right: fullSidePadding))
        }

        override public func editingRect(forBounds bounds: CGRect) -> CGRect {
            return bounds.inset(by: UIEdgeInsets.init(top: topPadding,
                                                      left: fullSidePadding + textPadding,
                                                      bottom: 0,
                                                      right: fullSidePadding))
        }

        override public func placeholderRect(forBounds bounds: CGRect) -> CGRect {
            return bounds.inset(by: UIEdgeInsets.init(top: topPadding,
                                                      left: fullSidePadding + textPadding,
                                                      bottom: 0,
                                                      right: fullSidePadding))
        }

        override public func borderRect(forBounds bounds: CGRect) -> CGRect {
            return bounds.inset(by: UIEdgeInsets.init(top: 0,
                                                      left: fullSidePadding + textPadding,
                                                      bottom: 0,
                                                      right: fullSidePadding))
        }
    }

    private extension AMTitledTextField {

        func setPlaceholderColor(_ color: UIColor) {
            var placeholderText = ""
            if let placeholder = self.placeholder {
                placeholderText = placeholder
            }

            self.attributedPlaceholder = NSAttributedString(string: placeholderText, attributes: [NSAttributedString.Key.foregroundColor: color])
        }

        func createTitle() {
            lblTitle = nil
            lblTitle = UILabel(frame: CGRect(x: originNew.x, y: originNew.y, width: 25, height: 25))
            guard let lblTitle = lblTitle else { return }

            lblTitle.textAlignment = .center
            lblTitle.text = title
            lblTitle.textColor = titleColor
            lblTitle.font = font
            if let fontSize = font?.pointSize {
                lblTitle.font = lblTitle.font.withSize(fontSize * 0.85)
            }

            lblTitle.sizeToFit()
            lblTitle.frame = CGRect(x: lblTitle.frame.origin.x + sidePadding, y: lblTitle.frame.origin.y, width: lblTitle.frame.width + sidePadding, height: lblTitle.frame.height);
            addSubview(lblTitle)
        }

        func createPath() -> UIBezierPath  {
            let path = UIBezierPath()
            guard let lblTitle = lblTitle else { return path }

            let pointA = CGPoint(x: originNew.x + lblTitle.frame.width + sidePadding, y: lblTitle.center.y)
            let pointB = CGPoint(x: frame.width - cornerRadius - borderWidth/2, y: pointA.y)
            let centerUR = CGPoint(x: pointB.x, y: pointA.y + cornerRadius)
            let pointC = CGPoint(x: frame.width - borderWidth/2, y: frame.height - cornerRadius - borderWidth/2)
            let centerBR = CGPoint(x: centerUR.x, y: frame.height - cornerRadius - borderWidth/2)
            let pointD = CGPoint(x: cornerRadius + borderWidth/2, y: frame.height - borderWidth/2)
            let centerBL = CGPoint(x: pointD.x, y: centerBR.y)
            let pointE = CGPoint(x: borderWidth/2, y: centerUR.y)
            let centerUL = CGPoint(x: centerBL.x, y: centerUR.y)
            let pointF = CGPoint(x: pointD.x + sidePadding, y: pointA.y)

            path.move(to: pointA)
            path.addLine(to: pointB)
            path.addArc(withCenter: centerUR, radius: cornerRadius, startAngle: CGFloat(3 * Double.pi/2), endAngle: 0, clockwise: true)
            path.addLine(to: pointC)
            path.addArc(withCenter: centerBR, radius: cornerRadius, startAngle: 0, endAngle: CGFloat(Double.pi/2), clockwise: true)
            path.addLine(to: pointD)
            path.addArc(withCenter: centerBL, radius: cornerRadius, startAngle: CGFloat(Double.pi/2), endAngle: CGFloat(2 * Double.pi/2), clockwise: true)
            path.addLine(to: pointE)
            path.addArc(withCenter: centerUL, radius: cornerRadius, startAngle:  CGFloat(2 * Double.pi/2), endAngle:  CGFloat(3 * Double.pi/2), clockwise: true)
            path.addLine(to: pointF)

            return path
        }
    }
