//
//  ADBindable.swift
//  ActionData
//
//  Created by Kevin Mullins on 4/12/18.
//

import Foundation

/**
 User Interface controls that conform to this protocol can be added to a `ADBoundViewController` view and their value will be automatically set and returned to a data model conforming to the `Codable` protocol based on the field specified in the `dataPath` property.
 */
public protocol ADBindable {
    
    /// Defines the name of a field from the bound data model or a formula that will be used to populate the control. If the control is editable, this is also the field that the value will be written back to.
    var dataPath: String {get set}
    
    /// Defines the name of a field from the bound data model or a formula that will be used to enable or disable the control.
    var enabledPath: String {get set}
    
    /// Defines the name of a field from the bound data model or a formula that will be used to hide or show the control.
    var hiddenPath: String {get set}
    
    /// Provides a link to the `ADBoundViewController` that the control is bound to.
    var controller: ADBoundViewController? {get set}
    
    /// Provides a unique ID that is assigned to the control when it is bound to a `ADBoundViewController`.
    var formID: Int {get set}
    
    /// Returns `true` if the value of the control can be edited by the user, else returns `false`.
    var isMutable: Bool {get}
    
    /**
     Populates the control with the given value. The value will automatically be case to the correct type for the given control.
     
     - Parameter value: The value to set the control to.
    */
    func setValue(_ value: Any)
    
    /**
     Sets the enabled/disabled state of the control with the value of the field from the bound data model or forumla.
     
     - Parameter value: The value to set the control to.
    */
    func setEnabledState(_ value: Any)
    
    /**
     Sets the visible state of the control with the value of the field from the bound data model or forumla.
     
     - Parameter value: The value to set the control to.
     */
    func setHiddenState(_ value: Any)
    
    /**
     Sets any control specific bound states (such as colors) with the values from the given `ADRecord`.
     
     - Parameter data: The raw data to bind the additional states to.
    */
    func setControlSpecificStates(against data: ADRecord)

    /**
     Gets the value from the bound control in the native type that the control handles. For example: `String` for a `UITextField`.
     
     - returns: The current value of the control in its native type.
    */
    func getValue() -> Any
    
}
