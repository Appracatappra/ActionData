//
//  ADValidatable.swift
//  ActionData iOS
//
//  Created by Kevin Mullins on 5/3/18.
//

import Foundation

/**
 `ADBindable` controls that conform to this protocol can also be automatically validated by requiring a value, ensuring that a value meets the criteria of a validation formula or by using a **Number**, **Date** or **Masked** formatter to validate the value. By setting the `instantValidation` flag to `true`, the control will perform validation when it loses focus. If a `validationMessage` is provided, the control will display the message when the control fails validation.
 */
public protocol ADValidatable {
    
    /// If `true` this control will be required to have a non-empty value (after trimming off any white space characters), else the field is not required to have a value.
    var validationRequired: Bool {get set}
    
    /// Provides a formula in a SQL like syntax that is used to validate the value of the control (for example: `value IN('one','two','three')`). This formula should return a boolean result, however, if the value is an `Int` or `Float` it will be converted to a `Bool` (1 = `true` and 0 = `false`. If the value is a `String` it will be converted to a `Bool` where the string values of "true", "yes" or "1" = `true` and the values of "false", "no" or "0" = `false`.
    var validationFormula: String {get set}
    
    /// Provides the message that will be displayed when the value of this control fails validation (for example:`Please enter one, two or three for this field.`). If this message is not provided, a generic message will be presented.
    var validationMessage: String {get set}
    
    /// If `true`, the value of this control will be validated before the control loses focus and resigns first responder.
    var instantValidation: Bool {get set}
    
    /// Returns `true` if the value in the control is valid, else returns `false` and displays a message about the field failing validation.
    var isValid: Bool {get}
    
}
