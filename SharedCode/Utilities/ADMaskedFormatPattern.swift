//
//  ADMaskedFormatPattern.swift
//  ActionData iOS
//
//  Created by Kevin Mullins on 4/24/18.
//

import Foundation

/**
 Holds information about a character pattern read from the formatting string of a `ADMaskedStringFormatter`. For example: `(###) ###-####` for a US phone number.
 */
public enum ADMaskedFormatPattern {
    /// No character will be output for the given position.
    case none
    
    /// The `#` character represents number that will be shown if a numeric value exists in the character position, else the position will be blank.
    case number
    
    /// The `0` character represents a fixed number that will show the numeric value for the current character position if one exists or will show `0` if no number exists in the given position.
    case fixedNumber
    
    /// The `X` character represents an upper case letter (A-Z).
    case uppercaseLetter
    
    /// The `x` character represents a lower case letter (a-z).
    case lowercaseLetter
    
    /// The `*` character represents any letter, upper or lower case (A-Z or a-z).
    case letter
    
    /// The `_` character represents any character that can be typed.
    case anyCharacter
    
    /// Represents a character that will be included in the formatted output.
    case litteralCharacter(String)
}
