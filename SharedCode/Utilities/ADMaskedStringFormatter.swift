//
//  ADMaskedStringFormatter.swift
//  ActionData iOS
//
//  Created by Kevin Mullins on 4/24/18.
//

import Foundation

/**
 A `ADMaskedStringFormatter` takes a formatting string and applies it as a mask to a given string value. For example, applying format string `(###) ###-####` to `8085551212` would result in `(808) 555-1212`. A `ADMaskedStringFormatter` can also be used to remove a format from a string, using the example above, given `(808) 555-1212` would result in `8085551212`.
 
 ## Supported Format Characters
 
 * **#** - An optional number (0-9). If a number is available at the current character location, the number is emitted, else a space (` `) will be emitted.
 * **0** - A fixed number (0-9). If a number is available at the current character location, the number is emitted, else a zero (`0`) will be emitted.
 * **X** - An uppercased letter (A-Z). If a letter is available, it will be converted to upper case and emitted, else a space (` `) is emitted.
 * **x** - A lowercased letter (a-z). If a letter is available, it will be converted to lower case and emitted, else a space (` `) is emitted.
 * ***** - Any letter (A-Z or a-z). If a letter is available, it will be emitted, else a space (` `) is emitted.
 * **_** - Any character. No matter what the character is, it will be emitted as-is.
 * **\\** - Escapes the next character and includes it in the formatted output. Use `\\` to include a `\\`, `#`, `0`, `X`, `x`, `*` or `_` character in the output.
 
 Any other character in the format string will be output as-is in the formatted string.
 
 ## Example
 
 ```swift
 // Configure formatter
 let formatter = ADMaskedStringFormatter()
 formatter.formatString = "(###) ###-####"
 
 // Convert output
 let output = formatter.applyFormat(to: "8085551212")
 ```
 
 */
public class ADMaskedStringFormatter {
    
    // MARK: - Private Variables
    /// Holds the decomposed formatting instructions read from the formatting string.
    private var formatPattern: [ADMaskedFormatPattern] = []
    
    // MARK: - Computed Properties
    /**
     Defines the mask that will be applied to a given string to create the formatted output.
     
     ## Supported Format Characters
     
     * **#** - An optional number (0-9). If a number is available at the current character location, the number is emitted, else a space (` `) will be emitted.
     * **0** - A fixed number (0-9). If a number is available at the current character location, the number is emitted, else a zero (`0`) will be emitted.
     * **X** - An uppercased letter (A-Z). If a letter is available, it will be converted to upper case and emitted, else a space (` `) is emitted.
     * **x** - A lowercased letter (a-z). If a letter is available, it will be converted to lower case and emitted, else a space (` `) is emitted.
     * ***** - Any letter (A-Z or a-z). If a letter is available, it will be emitted, else a space (` `) is emitted.
     * **_** - Any character. No matter what the character is, it will be emitted as-is.
     * **\\** - Escapes the next character and includes it in the formatted output. Use `\\` to include a `\\`, `#`, `0`, `X`, `x`, `*` or `_` character in the output.
     
     Any other character in the format string will be output as-is in the formatted string.
     
     ## Example
     
     ```swift
     // Configure formatter
     let formatter = ADMaskedStringFormatter()
     formatter.formatString = "(###) ###-####"
     
     // Convert output
     let output = formatter.applyFormat(to: "8085551212")
     ```
    */
    public var formatString: String = "" {
        didSet {
            // Clear current format pattern
            formatPattern = []
            
            // Parse all characters
            var forceLitteral = false
            for c in formatString {
                let char = String(c)
                
                // Forced to be a litteral character?
                if forceLitteral {
                    // Yes, save an clear state
                    formatPattern.append(.litteralCharacter(char))
                    forceLitteral = false
                } else {
                    // Take action based on the character
                    switch char {
                    case "#":
                        // Position holds a number
                        formatPattern.append(.number)
                    case "0":
                        // Position holds a fixed number
                        formatPattern.append(.fixedNumber)
                    case "X":
                        // Position holds an uppercased letter
                        formatPattern.append(.uppercaseLetter)
                    case "x":
                        // Position holds a lowercased letter
                        formatPattern.append(.lowercaseLetter)
                    case "*":
                        // Position holds any letter, upper or lower cased
                        formatPattern.append(.letter)
                    case "_":
                        // Position can take any type of character
                        formatPattern.append(.anyCharacter)
                    case "\\":
                        // The next character is a litteral character
                        forceLitteral = true
                    default:
                        // Position is a litteral character
                        formatPattern.append(.litteralCharacter(char))
                    }
                }
            }
        }
    }
    
    /**
     Returns `true` if the input string given to the `applyFormat` function can be properly formatted against the pattern in the `formatString` property.
     
     ## Example
     
     ```swift
     // Configure formatter
     let formatter = ADMaskedStringFormatter()
     formatter.formatString = "(###) ###-####"
     
     // Convert output
     let output = formatter.applyFormat(to: "8085551212")
     let valid = formatter.validForLastInput
     ```
    */
    public var validForLastInput: Bool = true
    
    // MARK: - Initializers
    /// Initializes a new instance of the `ADMaskedStringFormatter`.
    public init() {
        
    }
    
    // MARK: - Functions
    /**
     Applies the `formatString` to the given string to return a formatted string.
     
     ## Example
     
     ```swift
     // Configure formatter
     let formatter = ADMaskedStringFormatter()
     formatter.formatString = "(###) ###-####"
     
     // Convert output
     let output = formatter.applyFormat(to: "8085551212")
     let valid = formatter.validForLastInput
     ```
     
     - Parameter text: The string to format.
     - Returns: The given string with the format applied to it.
     
     - Remark: Sets the `validForLastInput` to `true` if the format was successfully applied, else it is set to `false`.
    */
    public func applyFormat(to text: String) -> String {
        var result = ""
        
        // Process all characters in input string
        var posn = 0
        validForLastInput = true
        for c in text {
            let char = String(c)
            
            // Apply pattern to character
            let value = applyPattern(toChar: char, atPosition: posn)
            
            // Apply results
            result += value.text
            posn = value.newPosition
        }
        
        // Apply any unused remaining pattern
        while posn < formatPattern.count {
            // Apply pattern to character
            let value = applyPattern(toChar: " ", atPosition: posn)
            
            // Apply results
            result += value.text
            posn = value.newPosition
        }
        
        // Return results
        return result
    }
    
    /**
     Applies the formatting instruction at the given location to the given character.
     
     - Parameters:
         - char: The character to apply the format to.
         - n: The position of the current formatting instruction.
     
     - Returns: A tuple representing the formatted output (`text`) and the current position inside of the formatting instructions (`newPosition`).
    */
    private func applyPattern(toChar char: String, atPosition n: Int) -> (text: String, newPosition: Int) {
        var result = ""
        let pattern = (n < formatPattern.count) ? formatPattern[n] : ADMaskedFormatPattern.none
        var posn = n + 1
        
        // Take action based on the
        switch pattern {
        case .number:
            if "0123456789".contains(char) {
                result += char
            } else {
                result += " "
                validForLastInput = false
            }
        case .fixedNumber:
            if "0123456789".contains(char) {
                result += char
            } else {
                result += "0"
                validForLastInput = false
            }
        case .uppercaseLetter:
            let value = char.uppercased()
            if "ABCDEFGHIJKLMNOPQRSTUVWXYZ".contains(value) {
                result += value
            } else {
                result += " "
                validForLastInput = false
            }
        case .lowercaseLetter:
            let value = char.lowercased()
            if "abcdefghijklmnopqrstuvwxyz".contains(value) {
                result += value
            } else {
                result += " "
                validForLastInput = false
            }
        case .letter:
            if "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz".contains(char) {
                result += char
            } else {
                result += " "
                validForLastInput = false
            }
        case .anyCharacter:
            result += char
        case .litteralCharacter(let character):
            // Include litteral character in output
            result += character
            
            // Any pattern remaining?
            if posn < formatPattern.count {
                // Still in a litteral?
                let value = applyPattern(toChar: char, atPosition: posn)
                
                // Update values
                result += value.text
                posn = value.newPosition
            }
        case .none:
            // Don't include character in output
            break
        }
        
        // Return results
        return (result, posn)
    }

    /**
     Strips the format specified in the `formatString` property from the given string and returns the unformatted value.
     
     ## Example
     
     ```swift
     // Configure formatter
     let formatter = ADMaskedStringFormatter()
     formatter.formatString = "(###) ###-####"
     
     // Convert output
     let output = formatter.applyFormat(to: "8085551212")
     let valid = formatter.validForLastInput
     
     // Strip format
     let result = formatter.removeFormat(from: output)
     ```
     
     - Parameter text: The value to remove the formatting from.
     - Returns: The input string with the formatting removed.
    */
    public func removeFormat(from text: String) -> String {
        var result = ""
        
        // Process all characters
        var posn = 0
        for c in text {
            let char = String(c)
            let pattern = (posn < formatPattern.count) ? formatPattern[posn] : ADMaskedFormatPattern.none
            
            // Take action based on the pattern
            switch pattern {
            case .number:
                if "0123456789".contains(char) {
                    result += char
                }
            case .fixedNumber:
                if "0123456789".contains(char) {
                    result += char
                } else {
                    result += "0"
                }
            case .uppercaseLetter:
                let value = char.uppercased()
                if "ABCDEFGHIJKLMNOPQRSTUVWXYZ".contains(value) {
                    result += value
                }
            case .lowercaseLetter:
                let value = char.lowercased()
                if "abcdefghijklmnopqrstuvwxyz".contains(value) {
                    result += value
                }
            case .letter:
                if "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz".contains(char) {
                    result += char
                }
            case .anyCharacter:
                result += char
            case .litteralCharacter(_):
                // Strip litterals from results
                break
            case .none:
                // Don't include character in output
                break
            }
            
            // Increment position
            posn += 1
        }
        
        // Return results
        return result
    }
    
}
