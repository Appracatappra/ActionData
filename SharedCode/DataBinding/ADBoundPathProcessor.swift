//
//  ADBoundPathParser.swift
//  ActionData iOS
//
//  Created by Kevin Mullins on 4/19/18.
//

import Foundation
import ActionUtilities

/**
 The `ADBoundPathProcessor` evaluates a given **Value Path** from a `ADBindable` control against an `ADRecord` and returns the result of the valuation. The **Value Path** can be either the name of a field from the record or a formula in a syntax simular to a SQL `SELECT` or `WHERE` clause.
 
 ## Example:
 ```swift
 // Given the following class
 class Category: ADDataTable {
 
     enum CategoryType: String, Codable {
         case local
         case web
     }
 
     static var tableName = "Categories"
     static var primaryKey = "id"
     static var primaryKeyType: ADDataTableKeyType = .computedInt
 
     var id = 0
     var added = Date()
     var name = ""
     var description = ""
     var enabled = true
     var highlightColor = UIColor.white.toHex()
     var type: CategoryType = .local
     var icon: Data = UIImage().toData()
 
     required init() {
 
     }
 }
 
 // Bind the label to the name field
 myLabel.dataPath = "'Category: ' + name"
 
 // Get the value of the path
 let value  = ADBoundPathProcessor.evaluate(path: myLabel.dataPath, against: myBoundViewController.record)
 ```
 */
public class ADBoundPathProcessor {
    
    // MARK: - Enumerations
    /// Defines the state of the current parse operation.
    private enum parseState {
        /// Seeking the start of a SQL command
        case seekCommand
        
        /// Creating an index, table, trigger, view or virtual table.
        case creating
        
        /// Creating an index.
        case creatingIndex
        
        /// Creating a new table.
        case creatingTable
        
        /// Creating a new trigger.
        case creatingTrigger
        
        /// Creating a new view.
        case creatingView
        
        /// Seeking column definitions.
        case seekColumnDef
        
        /// Seeking a type definition.
        case seekType
        
        /// Seeking a constraint.
        case seekConstraint
        
        /// Creating a constraint.
        case inConstraint
        
        /// Building a conflict clause.
        case inConflictClause
        
        /// Seeking WHEN clause inside of a CASE statement.
        case seekCaseWhen
        
        /// Seeking THEN clause inside of a CASE statement.
        case seekCaseThen
        
        /// Seeking END clause inside of a CASE statement.
        case seekCaseEnd
        
        /// Seeking list of column names.
        case seekColumnList
        
        /// Inside list of column names.
        case inColumnList
        
        /// Seeking table constraint.
        case seekTableConstraint
        
        /// In table constraint.
        case inTableConstraint
        
        // Seeking Order By clause.
        case seekOrderBy
        
        // In an Order By clause.
        case inOrderBy
    }
    
    /**
     Evaluates a given **Value Path** from a `ADBindable` control against an `ADRecord` and returns the result of the valuation. The **Value Path** can be either the name of a field from the record or a formula in a syntax simular to a SQL `SELECT` or `WHERE` clause.
     
     ## Example:
     ```swift
     // Given the following class
     class Category: ADDataTable {
     
         enum CategoryType: String, Codable {
             case local
             case web
         }
     
         static var tableName = "Categories"
         static var primaryKey = "id"
         static var primaryKeyType: ADDataTableKeyType = .computedInt
     
         var id = 0
         var added = Date()
         var name = ""
         var description = ""
         var enabled = true
         var highlightColor = UIColor.white.toHex()
         var type: CategoryType = .local
         var icon: Data = UIImage().toData()
     
         required init() {
     
         }
     }
     
     // Bind the label to the name field
     myLabel.dataPath = "'Category: ' + name"
     
     // Get the value of the path
     let value  = ADBoundPathProcessor.evaluate(path: myLabel.dataPath, against: myBoundViewController.record)
     ```
     
     - Parameters:
         - path: The name of a field from the given record or a formula (in SQL syntax) to evaluate against the record.
         - record: A `ADRecord` containing the data to evaulate against.
     
     - Returns: The results of the valuation or `nil`.
     */
    public static func evaluate(path: String, against record: ADRecord) throws -> Any? {
        
        // Anything to process
        if path == "" {
            // No, return nothing
            return nil
        }
        
        // Parse the input string
        try ADSQLParseQueue.shared.parse(path)
        
        // Anything returned?
        if ADSQLParseQueue.shared.count > 0 {
            // Read the expression from the path
            let expression = try parseWhereExpression()
            
            // Attempt to evaluate
            return try expression.evaluate(forRecord: record)
        }
        
        // Unable to process
        return nil
    }
    
    /// Pops the next available keyword off of the parser queue and throws an error if it does not match the expected keyword.
    /// - Parameter keyword: The next SQL keyword expected to be in the command string.
    private static func ensureNextElementMatches(keyword: ADSQLKeyword) throws {
        let element = ADSQLParseQueue.shared.pop()
        if let nextKeyword = ADSQLKeyword.get(fromString: element) {
            if keyword != nextKeyword {
                throw ADSQLParseError.invalidKeyword(message: "Expected `\(keyword.rawValue)` but found `\(nextKeyword.rawValue)`")
            }
        } else {
            // Found unknown keyword
            throw ADSQLParseError.unknownKeyword(message: "`\(element)` is not a recognized SQL keyword.")
        }
    }
    
    /// Parses a WHERE clause properly handling AND and OR statements.
    /// - Returns a binary expression representing the WHERE clause.
    private static func parseWhereExpression() throws -> ADSQLExpression {
        var done = false
        var expression: ADSQLExpression = try parseExpression()
        
        while !done {
            let nextElement = ADSQLParseQueue.shared.lookAhead().lowercased()
            switch nextElement {
            case "and":
                // Consume key
                ADSQLParseQueue.shared.pop()
                
                // Get next expression
                let rightExpression = try parseExpression()
                
                // Assemble binary expression
                expression = ADSQLBinaryExpression(leftValue: expression, operation: .and, rightValue: rightExpression)
            case "or":
                // Consume key
                ADSQLParseQueue.shared.pop()
                
                // Get next expression
                let rightExpression = try parseExpression()
                
                // Assemble binary expression
                expression = ADSQLBinaryExpression(leftValue: expression, operation: .or, rightValue: rightExpression)
            default:
                done = true
            }
        }
        
        return expression
    }
    
    /// Parses an expression in a SQL instruction.
    /// - Returns: A `ADSQLExpression` representing the expression.
    private static func parseExpression() throws -> ADSQLExpression {
        var expression: ADSQLExpression
        
        // Get the next element
        let element = ADSQLParseQueue.shared.pop()
        
        // Is this a keyword
        if let keyword = ADSQLKeyword.get(fromString: element) {
            switch(keyword) {
            case .plus:
                expression = ADSQLUnaryExpression(operation: .positive, value: try parseExpression())
            case .minus:
                expression = ADSQLUnaryExpression(operation: .negative, value: try parseExpression())
            case .notKey:
                expression = ADSQLUnaryExpression(operation: .not, value: try parseExpression())
            case .asterisk:
                expression = ADSQLLiteralExpression(value: "*")
            case .openParenthesis:
                // Create group
                expression = ADSQLUnaryExpression(operation: .group, value: try parseExpression())
                
                // The next word must be )
                try ensureNextElementMatches(keyword: ADSQLKeyword.closedParenthesis)
            case .castKey:
                // The next word must be (
                try ensureNextElementMatches(keyword: ADSQLKeyword.openParenthesis)
                let leftValue = try parseExpression()
                // The next word must be AS
                try ensureNextElementMatches(keyword: ADSQLKeyword.asKey)
                let rightValue = try parseExpression()
                // The next word must be )
                try ensureNextElementMatches(keyword: ADSQLKeyword.closedParenthesis)
                expression = ADSQLBinaryExpression(leftValue: leftValue, operation: .castTo, rightValue: rightValue)
            case .caseKey:
                expression = try parseCaseExpression()
            case .nullKey:
                expression = ADSQLLiteralExpression(value: "")
            case .emptyStringKey:
                expression = ADSQLLiteralExpression(value: "")
            default:
                // Invalid keyword
                throw ADSQLParseError.invalidKeyword(message: "Unexpected keyword `\(element)` found parsing expression.")
            }
        } else if let function = ADSQLFunction.get(fromString: element) {
            expression = ADSQLFunctionExpression(functionType: function, parameters: try parseFunctionParameters())
        } else {
            expression = ADSQLLiteralExpression(value: element)
        }
        
        // Continue parsing
        return try continueParsingExpression(expression)
    }
    
    /// Continues parsing an expression seeing if it is part of a larger expression.
    /// - Returns: A `ADSQLExpression` representing the expression.
    private static func continueParsingExpression(_ expression: ADSQLExpression) throws -> ADSQLExpression {
        // Anything left to process?
        if (ADSQLParseQueue.shared.count > 0) {
            // Possibly, look ahead to next element
            let nextElement = ADSQLParseQueue.shared.lookAhead().lowercased()
            switch(nextElement){
            case ";", ",", ")", "as", "from", "natural", "left", "inner", "cross", "join", "where", "group", "having", "order", "limit", "when", "then", "else", "begin", "end", "asc", "desc", "and", "or":
                // Done processing
                return expression
            default:
                // Continue on with the expression
                return try parseBinaryExpression(continuing: expression)
            }
        } else {
            // No, expression is final so return
            return expression
        }
    }
    
    /// Parses a CASE clause in a SELECT clause in a SQL instruction.
    /// - Returns: A `ADSQLCaseExpression` representing the case clause.
    private static func parseCaseExpression() throws -> ADSQLCaseExpression {
        var state = parseState.seekCaseWhen
        var when: ADSQLExpression?
        var defaultExpression: ADSQLExpression?
        var values: [ADSQLWhenExpression] = []
        
        // Get value to compare
        let compareExpression = try parseExpression()
        
        // Search for all when...then statements
        while ADSQLParseQueue.shared.count > 0 {
            // Get the next element
            let element = ADSQLParseQueue.shared.pop()
            
            if let keyword = ADSQLKeyword.get(fromString: element) {
                switch(keyword){
                case .whenKey:
                    if state == .seekCaseWhen {
                        when = try parseExpression()
                        state = .seekCaseThen
                    } else {
                        throw ADSQLParseError.malformedSQLCommand(message: "Case statement malformed at `\(element)`.")
                    }
                case .thenKey:
                    if state == .seekCaseThen {
                        let then = try parseExpression()
                        values.append(ADSQLWhenExpression(whenValue: when!, thenValue: then))
                        state = .seekCaseWhen
                    } else {
                        throw ADSQLParseError.malformedSQLCommand(message: "Case statement malformed at `\(element)`.")
                    }
                case .elseKey:
                    if state == .seekCaseWhen {
                        defaultExpression = try parseExpression()
                        state = .seekCaseEnd
                    } else {
                        throw ADSQLParseError.malformedSQLCommand(message: "Case statement malformed at `\(element)`.")
                    }
                case .endKey:
                    if state == .seekCaseEnd {
                        if defaultExpression == nil {
                            throw ADSQLParseError.malformedSQLCommand(message: "Case statement is missing ELSE default value.")
                        } else {
                            return ADSQLCaseExpression(compareValue: compareExpression, toValues: values, defaultValue: defaultExpression!)
                        }
                    } else {
                        throw ADSQLParseError.malformedSQLCommand(message: "Case statement malformed at `\(element)`.")
                    }
                default:
                    throw ADSQLParseError.malformedSQLCommand(message: "Case statement malformed at `\(element)`.")
                }
            } else {
                throw ADSQLParseError.malformedSQLCommand(message: "Case statement malformed at `\(element)`.")
            }
        }
        
        // Error
        throw  ADSQLParseError.malformedSQLCommand(message: "Case statement missing END key.")
    }
    
    /// Parses a list of function parameter from a SELECT clause in a SQL instruction.
    /// - Returns: A `ADSQLExpression` array representing the parameters.
    private static func parseFunctionParameters() throws -> [ADSQLExpression] {
        var parameters: [ADSQLExpression] = []
        var expression: ADSQLExpression?
        
        // Process possible parameter list
        while ADSQLParseQueue.shared.count > 0 {
            // Get the next element
            let element = ADSQLParseQueue.shared.pop()
            
            if let keyword = ADSQLKeyword.get(fromString: element) {
                switch(keyword){
                case .openParenthesis:
                    let key = ADSQLParseQueue.shared.lookAhead()
                    if key != ")" {
                        expression = try parseExpression()
                    }
                case .comma:
                    if expression == nil {
                        throw ADSQLParseError.malformedSQLCommand(message: "Found a comma (`,`) but expected an expression while parsing function parameters.")
                    } else {
                        parameters.append(expression!)
                    }
                    
                    // Get next expression
                    expression = try parseExpression()
                case .closedParenthesis:
                    if expression != nil {
                        parameters.append(expression!)
                    }
                    return parameters
                default:
                    // Invalid keyword
                    throw ADSQLParseError.invalidKeyword(message: "Unexpected keyword `\(element)` found.")
                }
            } else {
                throw ADSQLParseError.malformedSQLCommand(message: "At `\(element)` while parsing function parameters")
            }
        }
        
        throw ADSQLParseError.mismatchedParenthesis(message: "Missing ending `)` while parsing the list of function parameters.")
    }
    
    /// Parses a binary expression in a SQL instruction.
    /// - Parameter baseExpression: The left side of the binary instruction.
    /// - Returns: A `ADSQLExpression` representing the binary expression.
    private static func parseBinaryExpression(continuing baseExpression: ADSQLExpression) throws -> ADSQLExpression {
        var expression: ADSQLExpression
        var negate = false
        
        // Get the next element
        var element = ADSQLParseQueue.shared.pop()
        
        // Negation?
        if element.lowercased() == "not" {
            // Yes, handle and pull next element
            negate = true
            element = ADSQLParseQueue.shared.pop()
        }
        
        // Is this a keyword
        if let keyword = ADSQLKeyword.get(fromString: element) {
            switch(keyword) {
            case .plus:
                expression = ADSQLBinaryExpression(leftValue: baseExpression, operation: .addition, rightValue: try parseExpression())
            case .minus:
                expression = ADSQLBinaryExpression(leftValue: baseExpression, operation: .subtraction, rightValue: try parseExpression())
            case .asterisk:
                expression = ADSQLBinaryExpression(leftValue: baseExpression, operation: .multiplication, rightValue: try parseExpression())
            case .forwardSlash:
                expression = ADSQLBinaryExpression(leftValue: baseExpression, operation: .division, rightValue: try parseExpression())
            case .equal:
                expression = ADSQLBinaryExpression(leftValue: baseExpression, operation: .equalTo, rightValue: try parseExpression())
            case .notEqual:
                expression = ADSQLBinaryExpression(leftValue: baseExpression, operation: .notEqualTo, rightValue: try parseExpression())
            case .lessThan:
                expression = ADSQLBinaryExpression(leftValue: baseExpression, operation: .lessThan, rightValue: try parseExpression())
            case .greaterThan:
                expression = ADSQLBinaryExpression(leftValue: baseExpression, operation: .greaterThan, rightValue: try parseExpression())
            case .lessThanOrEqualTo:
                expression = ADSQLBinaryExpression(leftValue: baseExpression, operation: .lessThanOrEqualTo, rightValue: try parseExpression())
            case .greaterThanOrEqualTo:
                expression = ADSQLBinaryExpression(leftValue: baseExpression, operation: .greaterThanOrEqualTo, rightValue: try parseExpression())
            case .andKey:
                expression = ADSQLBinaryExpression(leftValue: baseExpression, operation: .and, rightValue: try parseExpression())
            case .orKey:
                expression = ADSQLBinaryExpression(leftValue: baseExpression, operation: .or, rightValue: try parseExpression())
            case .collateKey:
                expression = ADSQLBinaryExpression(leftValue: baseExpression, operation: .collate, rightValue: try parseExpression())
            case .likeKey:
                expression = ADSQLBinaryExpression(leftValue: baseExpression, operation: .like, rightValue: try parseExpression(), negate)
            case .globKey:
                expression = ADSQLBinaryExpression(leftValue: baseExpression, operation: .glob, rightValue: try parseExpression(), negate)
            case .regexpKey:
                expression = ADSQLBinaryExpression(leftValue: baseExpression, operation: .regexp, rightValue: try parseExpression(), negate)
            case .matchKey:
                expression = ADSQLBinaryExpression(leftValue: baseExpression, operation: .match, rightValue: try parseExpression(), negate)
            case .isNullKey:
                expression = ADSQLBinaryExpression(leftValue: baseExpression, operation: .equalTo, rightValue: nil, negate)
                expression = try continueParsingExpression(expression)
            case .notNullKey:
                expression = ADSQLBinaryExpression(leftValue: baseExpression, operation: .notEqualTo, rightValue: nil, negate)
                expression = try continueParsingExpression(expression)
            case .nullKey:
                expression = ADSQLBinaryExpression(leftValue: baseExpression, operation: .equalTo, rightValue: nil, negate)
                expression = try continueParsingExpression(expression)
            case .isKey:
                let nextElement = ADSQLParseQueue.shared.lookAhead().lowercased()
                if nextElement == "not" {
                    ADSQLParseQueue.shared.pop()
                    expression = ADSQLBinaryExpression(leftValue: baseExpression, operation: .notEqualTo, rightValue: try parseExpression())
                } else {
                    expression = ADSQLBinaryExpression(leftValue: baseExpression, operation: .equalTo, rightValue: try parseExpression())
                }
            case .betweenKey:
                let lowExpression = try parseExpression()
                // The next word must be AND
                try ensureNextElementMatches(keyword: .andKey)
                let highExpression = try parseExpression()
                expression = ADSQLBetweenExpression(valueIn: baseExpression, lowValue: lowExpression, highValue: highExpression, negate)
            case .inKey:
                // TODO: - Handle Sub SELECT here
                expression = ADSQLInExpression(value: baseExpression, inList: try parseFunctionParameters(), negate)
            default:
                // Invalid keyword
                throw ADSQLParseError.invalidKeyword(message: "Unexpected keyword `\(element)` found.")
            }
        } else {
            // Found unknown keyword
            throw ADSQLParseError.unknownKeyword(message: "`\(element)` is not a recognized SQL keyword.")
        }
        
        return expression
    }
}
