//
//  ADBoundTableViewDataSource.swift
//  ActionData iOS
//
//  Created by Kevin Mullins on 5/3/18.
//

import Foundation

/**
 A `ADBoundTableViewDataSource` provides data for a `ADBoundTableView` for an array of Swift objects that conform to the `Codeable` protocol. The `ADBoundTableViewDataSource` has the ability to support grouping the object into sections based on a given field from the provided Swift objects (or based on a formula in a SQL like syntax).
 
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
 
 // Create storage for the table's data
 let info = ADBoundTableViewDataSource<Category>()
 
 // Add data to the table's data source
 for n in 1...10 {
     let category = Category(name: "Category \(n)", description: "Description for category \(n).")
     info.data.append(category)
 }
 
 // Attach to table
 info.parentTableView = boundTableView
 ```
 */
open class ADBoundTableViewDataSource<T:Codable>: NSObject, UITableViewDataSource, ADBindingDataSource {
    
    // MARK: - Private Variables
    /// The internal encoder used to convert the data model into a `ADRecord` for working with the bounds controls.
    private let encoder = ADSQLEncoder()
    
    /// The internal decoder used to convert the `ADRecord` back into a data model with the values from the bound controls.
    private let decoder = ADSQLDecoder()
    
    /// If the data source is grouping the data into sections, the section definitions will be collected here.
    private var sections: [String:ADBoundTableSection] = [:]
    
    /// If `true`, the data source is currently providing filtered results based on a user search.
    private var insideOfSearch = false
    
    // MARK: - Computed Properties
    /**
     Provides the data for the `ADBoundTableViewDataSource` as an array of Swfit objects conforming to the `Codeable` protocol.
     
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
     
     // Create storage for the table's data
     let info = ADBoundTableViewDataSource<Category>()
     
     // Add data to the table's data source
     for n in 1...10 {
         let category = Category(name: "Category \(n)", description: "Description for category \(n).")
         info.data.append(category)
     }
     
     ```
    */
    public var data: [T] = []
    
    /**
     Attaches the `ADBoundTableViewDataSource` to a `ADBoundTableView` and automatically displays any data from the source.
     
     ## Example:
     ```swift
     // Create storage for the table's data
     let info = ADBoundTableViewDataSource<Category>()
     
     // Add data to the table's data source
     for n in 1...10 {
         let category = Category(name: "Category \(n)", description: "Description for category \(n).")
         info.data.append(category)
     }
     
     // Attach to table
     info.parentTableView = boundTableView
     ```
    */
    public var parentTableView: ADBoundTableView? {
        didSet {
            // Attach to table if available
            if let boundTableView = parentTableView {
                // Attach to parent table and display results
                boundTableView.dataSource = self
                reloadData()
            }
        }
    }

    // MARK: - Functions
    /**
     Returns a Table View Cell for the given Reuse Identifier and Index Path. If possible, this function will dequeue a reuesable cell from the table view, else it will attempt to create a new cell.
     
     - Parameters:
         - tableView: The Table View that the cell is being built for.
         - reuseIdentifier: The Reuse Identifier for the cell.
         - index: The index that the cell is bein built for.
         - buildBoundCell: If `true`, `dequeueReusableCell` will attempt to create or dequeue a `ADBoundTableViewCell`, else it will create or dequeue a `UITableViewCell`.
     
     - Returns: Either a `ADBoundTableViewCell` or a `UITableViewCell` based on the state of the `buildBoundCell` parameter.
    */
    private func dequeueReusableCell(_ tableView: UITableView, withIdentifier reuseIdentifier: String, for index: IndexPath, buildBoundCell: Bool = true) -> UITableViewCell {
        
        // Bound or unbound cell?
        if buildBoundCell {
            // Attempt to retrieve a Bound Table View Cell first
            if let cell = tableView.dequeueReusableCell(withIdentifier: reuseIdentifier) as? ADBoundTableViewCell {
                // Return new cell
                return cell
            }
            
            // Create generic bound cell
            let cell = ADBoundTableViewCell(style: .default, reuseIdentifier: reuseIdentifier)
            return cell
        } else {
            // Attempt to retrieve a generic cell first
            if let cell = tableView.dequeueReusableCell(withIdentifier: reuseIdentifier) {
                // Return new cell
                return cell
            }
            
            // Create generic cell
            let cell = UITableViewCell(style: .default, reuseIdentifier: reuseIdentifier)
            return cell
        }
    }
    
    /**
     Returns the Swift object from the `data` store for the given Index Path.
     
     - Parameter index: The index path to return the data for.
     
     - Returns: The Swift object for the given Index Path.
    */
    private func dataForIndex(_ index: IndexPath) -> T {
        
        // Are we attached to a bound view?
        if let boundTableView = parentTableView {
            // Is the table using grouping?
            if boundTableView.groupData {
                // Convert keys to array
                let keyArray = [String](sections.keys)
                
                // Get the section containing the data reference
                if let section = sections[keyArray[index.section]] {
                    // Return data for section row
                    return data[section.index[index.row]]
                }
            }
        }
        
        // Default to raw data source
        return data[index.row]
    }
    
    /**
     Causes the `ADBoundTableViewDataSource` to reload data from the attached `data` store to the attached Parent Table View. If the data source is grouping data into sections, the sections will be recreated based on the state of the current array of Swift objects that provide its base data.
    */
    public func reloadData() {
        
        // Clear section data
        sections = [:]
        
        // Are we attached to a bound view?
        if let boundTableView = parentTableView {
            // Is the table using grouping?
            if boundTableView.groupData {
                // Yes, sort data into groups
                var n: Int = 0
                for item in data {
                    // Handle any errors
                    do {
                        // Convert model to a record instance
                        let model = try encoder.encode(item)
                        if let record = model as? ADRecord {
                            // Get the name of the field to group on
                            if let groupBy = try ADBoundPathProcessor.evaluate(path: boundTableView.groupPath, against: record) as? String {
                                // Has a section already been created for this group?
                                if sections.keys.contains(groupBy) {
                                    // Yes, add reference to data to existing group
                                    sections[groupBy]?.index.append(n)
                                } else {
                                    // No, build a new section for this group and save the index to this item
                                    sections[groupBy] = ADBoundTableSection()
                                    
                                    // Attempt to set title
                                    if let groupTitle = try ADBoundPathProcessor.evaluate(path: boundTableView.groupTitlePath, against: record) as? String {
                                        // Set new title
                                        sections[groupBy]?.title = groupTitle
                                    }
                                    
                                    // Attempt to set footer title
                                    if let groupFooter = try ADBoundPathProcessor.evaluate(path: boundTableView.groupFooterPath, against: record) as? String {
                                        // Set new title
                                        sections[groupBy]?.footer = groupFooter
                                    }
                                    
                                    // Add reference to data
                                    sections[groupBy]?.index.append(n)
                                }
                            }
                        }
                    } catch {
                        // Report error
                        print("Unable to group data by \(boundTableView.groupPath): \(error)")
                    }
                    
                    // Increment
                    n += 1
                }
            }
            
            // Ask table to reload as well
            boundTableView.reloadData()
        }
        
        // No longer filtering data
        insideOfSearch = false
    }
    
    /**
     Filters the data displayed in the Bound Table based on the field (specified by the `searchPath` property of the `ADBoundTableView`) containing the given search text and being within the optional scope.
     
     - Parameters:
     - text: The text to search for.
     - scope: The optional scope to limit the search on.
    */
    public func filterData(onSearchText text: String, scope: String = "") {
        // Clear section data
        sections = [:]
        
        // Are we attached to a bound view?
        if let boundTableView = parentTableView {
            // Switch to lower case for search
            let filter = text.lowercased()
            let scopeFilter = scope.lowercased()
            
            // Create section for search results
            let section = ADBoundTableSection()
            
            // Yes, sort data into groups
            var n: Int = 0
            for item in data {
                // Handle any errors
                do {
                    // Convert model to a record instance
                    let model = try encoder.encode(item)
                    if let record = model as? ADRecord {
                        // Attempt to get field
                        if let field = try ADBoundPathProcessor.evaluate(path: boundTableView.searchPath, against: record) as? String {
                            var good = true
                            
                            // Are we checking scope?
                            if scope == "" {
                                // No, does the field contain the search term?
                                good = good && field.lowercased().contains(filter)
                            } else {
                                // Yes, attempt to get scope field
                                if let scopeField = try ADBoundPathProcessor.evaluate(path: boundTableView.searchScopePath, against: record) as? String {
                                    // Does the scope match?
                                    good = good && (scopeField.lowercased() == scopeFilter)
                                }
                                
                                // Has text been provided?
                                if filter != "" {
                                    // Yes, does the field contain the search term?
                                    good = good && field.lowercased().contains(filter)
                                }
                            }
                            
                            // Is this item a good match?
                            if good {
                                // Yes, add reference
                                section.index.append(n)
                            }
                        }
                    }
                } catch {
                    // Report error
                    print("Unable to filter data on \(boundTableView.searchPath): \(error)")
                }
                
                // Increment
                n += 1
            }
            
            // Add section to collection
            sections["matches"] = section
            
            // Get counts
            let totalItems = "\(data.count)"
            let matchingItems = "\(section.index.count)"
            
            // Set search results title
            section.title = boundTableView.searchTitle
            section.title = section.title.replacingOccurrences(of: "$0", with: totalItems)
            section.title = section.title.replacingOccurrences(of: "$1", with: matchingItems)
            
            // Set search results footer
            section.footer = boundTableView.searchFooter
            section.footer = section.footer.replacingOccurrences(of: "$0", with: totalItems)
            section.footer = section.footer.replacingOccurrences(of: "$1", with: matchingItems)
            
            // Ask table to reload as well
            boundTableView.reloadData()
        }
        
        // Filtering data
        insideOfSearch = true
    }
    
    /**
     Returns a populated Table View Cell for the given Index Path to the given Table View.
     
     - Parameters:
     - tableView: The Table View to return the cell for.
     - indexPath: The Index Path to data used to populate the table cell.
     
     - Returns: A Table Cell populated with the data for the given Index Path.
    */
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // Get the current data model
        let item = dataForIndex(indexPath)
        
        // Are we attached to a bound view?
        if let boundTableView = parentTableView {
            // Handle any errors
            do {
                // Convert model to a record instance
                let model = try encoder.encode(item)
                if let record = model as? ADRecord {
                    // Get the name of the cell reuse identifier
                    if let cellID = try ADBoundPathProcessor.evaluate(path: boundTableView.cellIdPath, against: record) {
                        // Force to a reuse identifier string
                        if let reuseID = try ADUtilities.cast(cellID, to: .textType) as? String {
                            // Get the required cell
                            if let cell = dequeueReusableCell(tableView, withIdentifier: reuseID, for: indexPath) as? ADBoundTableViewCell {
                                // Populate the cell with data
                                cell.record = record
                                cell.updateBindings()
                                
                                // Return newly built and populated cell
                                return cell
                            }
                        }
                    }
                }
            } catch {
                // Report error
                print("Unable to create bound cell for row \(indexPath.row): \(error)")
            }
        }

        // Something went wrong, create generic cell and return it
        let cell = dequeueReusableCell(tableView, withIdentifier: "generic", for: indexPath, buildBoundCell: false)

        // Report error
        cell.textLabel?.text = "Error Binding Row \(indexPath.row)"

        // Return default cell
        return cell
    }

    /**
     Returns the number of section for the given Table View.
     
     - Parameter tableView: The Table View to return the number of sections for.
     - Returns: The number of sections.
    */
    public func numberOfSections(in tableView: UITableView) -> Int {
        // Are we attached to a bound view?
        if let boundTableView = parentTableView {
            // Is the table using grouping?
            if boundTableView.groupData || insideOfSearch {
                // Return the section count
                return sections.count
            }
        }
        
        // Default to a single section
        return 1
    }
    
    /**
     If the data is grouped into section, return the title for the given section.
     
     - Parameters:
     - tableView: The Table View to return the section title for.
     - section: The section to return the title for.
     
     - Returns: The title or the section or `nil` if there is no title.
    */
    public func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        
        // Are we attached to a bound view?
        if let boundTableView = parentTableView {
            // Is the table using grouping?
            if boundTableView.groupData || insideOfSearch {
                // Convert keys to array
                let keyArray = [String](sections.keys)
                
                // Get the section containing the data reference
                if let section = sections[keyArray[section]] {
                   // Return the title for the section
                    return section.title
                }
            }
        }
        
        // Default to no title
        return ""
    }
    
    /**
     If the data is grouped into section, return the footer title for the given section.
     
     - Parameters:
     - tableView: The Table View to return the section title for.
     - section: The section to return the footer title for.
     
     - Returns: The footer title or the section or `nil` if there is no title.
     */
    public func tableView(_ tableView: UITableView, titleForFooterInSection section: Int) -> String? {
        
        // Are we attached to a bound view?
        if let boundTableView = parentTableView {
            // Is the table using grouping?
            if boundTableView.groupData || insideOfSearch {
                // Convert keys to array
                let keyArray = [String](sections.keys)
                
                // Get the section containing the data reference
                if let section = sections[keyArray[section]] {
                    // Return the footer for the section
                    return section.footer
                }
            }
        }
        
        // Default to no footer title
        return ""
    }

    /**
     Returns the number of rows for the given section.
     
     - Parameters:
     - tableView: The Table View to return the number of rows for.
     - section: The section to return the number of rows for.
     
     - Returns: The number of rows.
    */
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        // Are we attached to a bound view?
        if let boundTableView = parentTableView {
            // Is the table using grouping?
            if boundTableView.groupData || insideOfSearch {
                // Convert keys to array
                let keyArray = [String](sections.keys)
                
                // Get the section containing the data reference
                if let section = sections[keyArray[section]] {
                    // Return the number of items in the section
                    return section.index.count
                }
            }
        }
        
        // Default to the raw data count
        return data.count
    }
}
