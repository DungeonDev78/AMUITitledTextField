//
//  AMUIBaseTextField.swift
//
//  Created with 💪 by Alessandro Manilii.
//  Copyright © 2019 Alessandro Manilii. All rights reserved.
//

import UIKit

public class AMUIBaseTextField: UITextField {

    // MARK: - Enums

    /// Status of the UITextField
    public enum FocusStatus {
        case focused
        case notFocused
    }

    /// Validation status of the UITextField
    public enum ValidationStatus {
        case unknown
        case valid
        case invalid
    }

    // MARK: - Regex Handling
    @IBInspectable var isValidationMandatory: Bool = false
    @IBInspectable var regex: String?

    // MARK: - Toolbar Handling
    @IBInspectable var toolbarEnabled: Bool      = false
    @IBInspectable var toolbarColor: UIColor     = .lightGray
    @IBInspectable var toolbarBtnColor: UIColor  = .black

    @IBOutlet var nextTextField: UITextField?

    public var validationStatus = ValidationStatus.unknown
    public var focusStatus      = FocusStatus.notFocused {
        didSet {
            configureFocusedState(focusStatus)
        }
    }


    // MARK: - Iniatialization
    override public func awakeFromNib() {
        super.awakeFromNib()

        //        self.addTarget(self, action: #selector(textFieldDidChange), for: .editingChanged)
        addTarget(self, action: #selector(textFieldDidBegin), for: .editingDidBegin)
        addTarget(self, action: #selector(textFieldDidEnd), for: .editingDidEnd)
        addTarget(self, action: #selector(textFieldEditingDidEndOnExit), for: .editingDidEndOnExit)

        if toolbarEnabled == true { addToolbar() }
    }

    // MARK: - Validation

    /// Test the validation status of the UITextField
    public func validateTextField() {
        validationStatus = .unknown

        if text?.isEmpty == true {
            updateTextFieldToStatus()
            return
        }

        if let regex = regex, isValidationMandatory == true {
            let validation = NSPredicate(format: "SELF MATCHES %@", regex)
            if validation.evaluate(with: text) {
                // Success
                validationStatus = .valid
                updateTextFieldToStatus()
            } else {
                // Failure
                validationStatus = .invalid
                updateTextFieldToStatus()
            }
        } else {
            validationStatus = .unknown
            updateTextFieldToStatus()
        }
    }

    // MARK: - Must be overridden according to the final subclass
    func configureFocusedState(_ focusState: FocusStatus) {
        assertionFailure("Must be overridden")
    }

    func configureInvalidState() {
        assertionFailure("Must be overridden")
    }

    func configureUnknownState() {
        assertionFailure("Must be overridden")
    }

    func configureValidState() {
        assertionFailure("Must be overridden")
    }
}

// MARK: - TextField Pseudo delegates
extension AMUIBaseTextField {

    @objc private func textFieldDidBegin() {
        focusStatus = .focused
        updateTextFieldToStatus()
    }

    @objc private func textFieldDidEnd() {
        guard let text = text else { return  }
        self.text = text.trimmingCharacters(in: .whitespacesAndNewlines)
        focusStatus = .notFocused
        validateTextField()
    }

    @objc private func textFieldEditingDidEndOnExit() {
        focusOnNextTextField()
        focusStatus = .notFocused
    }
}

// MARK:- Private
private extension AMUIBaseTextField {

    /// Updates the UITextField according to its state
    func updateTextFieldToStatus() {
        switch validationStatus {
        case .invalid   : configureInvalidState()
        case .unknown   : configureUnknownState()
        case .valid     : configureValidState()
        }
    }

    /// Create a toolbar as InputAccessoryView for the keyboard
    func addToolbar() {
        let toolBar = UIToolbar()
        toolBar.backgroundColor = toolbarColor
        toolBar.tintColor = toolbarBtnColor
        toolBar.sizeToFit()

        let toolbarApparance = UIToolbar.appearance()
        toolbarApparance.setBackgroundImage(UIImage.imageWithColor(toolbarColor), forToolbarPosition: .bottom, barMetrics: .default)

        // Adding Button ToolBarpa
        let doneButton = UIBarButtonItem(title: "Done", style: .plain, target: self, action: #selector(focusOnNextTextField))
        let spaceButton = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        //        let cancelButton = UIBarButtonItem(title: "Cancel", style: .plain, target: self, action: #selector(cancelClick))
        //        toolBar.setItems([cancelButton, spaceButton, doneButton], animated: false)
        toolBar.setItems([spaceButton, doneButton], animated: false)
        toolBar.isUserInteractionEnabled = true
        inputAccessoryView = toolBar
    }

    /// Handle the focus for the next UITextField if available
    @objc func focusOnNextTextField() {
        if let nextTextField = nextTextField {
            nextTextField.becomeFirstResponder()
        } else {
            self.resignFirstResponder()
        }
    }
}

extension UIImage {
    /// Create a UIImage with a single color
    ///
    /// - Parameter color: the color for the image
    /// - Returns: the generated UIImage
    class func imageWithColor(_ color: UIColor) -> UIImage? {
        let size = CGSize(width: 1, height: 1)
        let rect = CGRect(x: 0, y: 0, width: 1, height: size.height)
        UIGraphicsBeginImageContextWithOptions(size, false, 0)
        color.setFill()
        UIRectFill(rect)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image
    }
}
