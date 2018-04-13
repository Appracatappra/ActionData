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
    
    /// Defines the name of a field from the bound data model that will be used to populate the control. If the control is editable, this is also the field that the value will be written back to.
    var dataPath: String {get set}
    
    /// Returns `true` if the value of the control can be edited by the user, else returns `false`.
    var isMutable: Bool {get}
    
    /**
     Populates the control with the given value. The value will automatically be case to the correct type for the given control.
     
     - Parameter value: The value to set the control to.
    */
    func setValue(_ value: Any)

    /**
     Gets the value from the bound control in the native type that the control handles. For example: `String` for a `UITextField`.
     
     - returns: The current value of the control in its native type.
    */
    func getValue() -> Any
    
}
