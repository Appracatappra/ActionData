//
//  ADBindingController.swift
//  ActionData iOS
//
//  Created by Kevin Mullins on 5/3/18.
//

import Foundation

/**
 A controller conforming to the `ADBindingController` protocol provides a method to attach it to a data model (any Swift class or structure that conforms to the `Codable` protocol) and any control conforming to the `ADBindable` protocol on any **View** or **SubView** will automatically be populated with the values from the data model based on the `dataPath` property of the control.
 */
public protocol ADBindingController {
    
    /**
     A `ADRecord` representing the attached data model as a set of key/value pairs where the key is the name of the field that the value was read from or is writtne to.
     */
    var record: ADRecord {get set}
    
    /**
     Sets the text of the **Previous** button for `ADBoundTextField` and `ADBoundTextView` controls that show the previous and next accessory buttons.
     */
    var prevButtonText: String {get set}
    
    /**
     Sets the image of the **Previous** button for `ADBoundTextField` and `ADBoundTextView` controls that show the previous and next accessory buttons.
     */
    var prevButtonImage: UIImage? {get set}
    
    /**
     Sets the text of the **Next** button for `ADBoundTextField` and `ADBoundTextView` controls that show the previous and next accessory buttons.
     */
    var nextButtonText: String {get set}
    
    /**
     Sets the image of the **Next** button for `ADBoundTextField` and `ADBoundTextView` controls that show the previous and next accessory buttons.
     */
    var nextButtonImage: UIImage? {get set}
    
    /**
     Sets the text of the **Done** button for `ADBoundTextField`, `ADBoundTextPicker` and `ADBoundTextView` controls that show the done accessory button.
     */
    var doneButtonText: String {get set}
    
    /**
     Sets the image of the **Done** button for `ADBoundTextField`, `ADBoundTextPicker` and `ADBoundTextView` controls that show the done accessory button.
     */
    var doneButtonImage: UIImage? {get set}
    
    /**
     Sets the text of the **Cancel** button for `ADBoundTextPicker` control that show the cancel accessory button.
     */
    var cancelButtonText: String {get set}
    
    /**
     Sets the image of the **Cancel** button for `ADBoundTextPicker` control that show the cancel accessory button.
     */
    var cancelButtonImage: UIImage? {get set}
    
    /// The title of the alert that is displayed when a field fails automatic validation.
    var validationTitle: String {get set}
    
    /// The generic message that is displayed in the alert when a field fails automatic validation. Use `$0` in the message anywhere you want the value of the `dataPath` presenting the message to be inserted.
    var validationMessage: String {get set}
    
    /// The text for the dismiss button that is displayed on the alert when a field fails automatic validation.
    var validationButtonText: String {get set}
    
    /**
     Works with automatic validation to display a message when a field fails validation.
     
     - Parameter message: The message to display when a field fails validation.
     - Parameter isGeneric: If `true` the generic message will be combined with the passed value to present the message on the alert, else the message will be displayed as-is.
     
     - Remark: Any occurrances of `$0` in the `validationMessage` string will be replaced with the passed in message when the `isGeneric` parameter is `true`
     */
    func displayValidationAlert(message: String, isGeneric: Bool)
    
    /**
     Attaches the given data model (any Swift class or structure conforming to the `Codable` protocol) to the `ADBindingController` populating the `record` property and any control conforming to the `ADBindable` protocol on any View or SubView.
     
     - Parameter value: A Swift class or structure conforming to the `Codeable` protocol.
     */
    func setDataModel<T:Encodable>(_ value: T) throws
    
    /**
     Reads the values from any editable control conforming to the `ADBindable` protocol into the given data model (any Swift class or structure conforming to the `Codable` protocol).
     
     - Parameter type: The type of a Swift class or structure conforming to the `Codeable` protocol to read the values into and return.
     
     - Returns: A class of the given type populated with any values read from the control conforming to the `ADBindable` protocol on any View or SubView controlled by this `ADBindingController`.
     */
    func getDataModel<T:Decodable>(_ type: T.Type) throws -> T
    
    /**
     Forces the `ADBindingController` to update the values of any control conforming to the `ADBindable` protocol on any **View** or **SubView** controlled by this `ADBindingController` with the values from the `record` property.
     */
    func updateBindings()
    
    /**
     Forces the `ADBindingController` to update the `record` property with the values from any editable control conforming to the `ADBindable` protocol on any View or SubView controlled by this `ADBindingController`.
     */
    func updateRecord()
    
    /**
     Forces the `ADBindingController` to read the values from any bound control in the `controls` array into the `record` property and write the values back to the bound controls to refresh the view.
     */
    func refreshDisplay()
    
    /**
     Called by a `ADBoundTextField` or `ADBoundTextView` when it becomes first responder to see if the field is under the onscreen keyboard. If the field is under the keyboard, the field will be moved to expose the keyboard. If the view has already been moved and the field is not under the keyboard, the view will be moved back to its original position.
     
     - Parameter fieldFrame: The `GCRect` of the text field or view that has just gained focus.
     */
    func moveViewToExposeField(withFrame fieldFrame: CGRect)
    
    /**
     Called by a `ADBoundTextField` or `ADBoundTextView` to see if another `ADBoundTextField` or `ADBoundTextView` is in a higher location on the form.
     
     - Parameter id: The form ID of the control performing the check.
     - Returns: `true` if there is a previous text field or view, else returns `false`.
     */
    func hasPrevTextFieldOrView(beforeField id: Int) -> Bool
    
    
    /**
     Called by a `ADBoundTextField` or `ADBoundTextView` to see if another `ADBoundTextField` or `ADBoundTextView` is in a lower location on the form.
     
     - Parameter id: The form ID of the control performing the check.
     - Returns: `true` if there is a next text field or view, else returns `false`.
     */
    func hasNextTextFieldOrView(afterField id: Int) -> Bool
    
    /**
     Called by a `ADBoundTextField` or `ADBoundTextView` to move to a previous text field or view.
     
     - Parameter id: The form ID of the control performing the move.
     */
    func moveToPrevTextFieldOrView(beforeField id: Int)
    
    /**
     Called by a `ADBoundTextField` or `ADBoundTextView` to move to a next text field or view.
     
     - Parameter id: The form ID of the control performing the move.
     */
    func moveToNextTextFieldOrView(afterField id: Int)
    
}
