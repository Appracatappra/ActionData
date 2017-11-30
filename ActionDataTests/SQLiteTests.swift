//
//  ActionDataTests.swift
//  ActionDataTests
//
//  Created by Kevin Mullins on 10/12/17.
//  Copyright © 2017 Appracatappra, LLC. All rights reserved.
//

import XCTest
import ActionUtilities
import ActionData

class SQLiteTests: XCTestCase {
    
    var provider = ADSQLiteProvider.shared
    var encoder = ADSQLEncoder()
    var decoder = ADSQLDecoder()
    
    override func setUp() {
        super.setUp()
        
        // Open the database
        do {
            try provider.openSource("UnitTest.db")
            print("Database Location: \(provider.path)")
        } catch {
            XCTFail("Unable to open requested sample database 'Test.db'.")
        }
    }
    
    override func tearDown() {
        
        // Close open database
        do {
            try provider.closeSource()
        } catch {
            XCTFail("Error: \(error)")
        }
        
        super.tearDown()
    }
    
    // MARK: - Tests
    func testCreateTables() {
        do {
            try provider.updateTableSchema(Category.self)
            
            XCTAssertTrue(try provider.tableExists(Category.tableName), "Failed to create Category Table")
        } catch {
            XCTFail("Error: \(error)")
        }
    }
    
    func testSaveRecord() {
        do {
            for n in 1...5 {
                let category = Category(name: "Category \(n)", description: "Description \(n)")
                let id = try provider.save(category) as! Int
                XCTAssertGreaterThan(id, -1, "Failed to save \(n)")
                print("Saved \(n)")
            }
        } catch {
            XCTFail("Error: \(error)")
        }
    }
    
    func testLoadRecord() {
        do {
            let category = try provider.getRow(ofType: Category.self, forPrimaryKeyValue: 1)
            
            XCTAssertNotNil(category)
        } catch {
            XCTFail("Error: \(error)")
        }
    }
    
    func testUpdateRecord() {
        do {
            let category = try provider.getRow(ofType: Category.self, forPrimaryKeyValue: 1)!
            category.use = .web
            try provider.save(category)
            
            let category2 = try provider.getRow(ofType: Category.self, forPrimaryKeyValue: 1)!
            XCTAssertEqual(category2.use, category.use)
        } catch {
            XCTFail("Error: \(error)")
        }
    }
    
    func testEncodeDecode() {
        do {
            let addr1 = Address(addr1: "PO Box 1234", addr2: "", city: "Houston", state: "TX", zip: "77012")
            let addr2 = Address(addr1: "25 Nasa Rd 1", addr2: "Apt #123", city: "Seabrook", state: "TX", zip: "77586")
            let p1 = Person(firstName: "John", lastName: "Doe", addresses: ["home":addr1, "work":addr2])
            
            let data = try encoder.encode(p1)
            print("Encoded: \(data)")
            
            let p2 = try decoder.decode(Person.self, from: data)
            print(p2.addresses["work"]!)
        } catch {
            XCTFail("Error: \(error)")
        }
    }
    
    func testCrossReference() {
        do {
            let addr1 = Address(addr1: "PO Box 1234", addr2: "", city: "Houston", state: "TX", zip: "77012")
            let addr2 = Address(addr1: "25 Nasa Rd 1", addr2: "Apt #123", city: "Seabrook", state: "TX", zip: "77586")
            
            let p1 = Person(firstName: "John", lastName: "Doe", addresses: ["home":addr1, "work":addr2])
            let p2 = Person(firstName: "Sue", lastName: "Smith", addresses: ["home":addr1, "work":addr2])
            
            let group = Group(name: "Employees", people: [p1, p2])
            try provider.save(group)
            
            let group2 = try provider.getRow(ofType: Group.self, forPrimaryKeyValue: group.id)
            XCTAssertNotNil(group2)
            XCTAssertEqual(group.people.count, group2?.people.count)
        } catch {
            XCTFail("Error: \(error)")
        }
    }
    
}

// MARK: - Supporting Classes
enum CategoryUsage: String, Codable {
    case local
    case web
}

class Category: ADDataTable {
    
    static var tableName = "Categories"
    static var primaryKey = "id"
    static var primaryKeyType: ADDataTableKeyType = .autoIncrementingInt
    
    var id = -1
    var name = ""
    var description = ""
    var highlightColor = UIColor.red.toHex()
    var use = CategoryUsage.local
    var enabled = true
    
    required init() {
        
    }
    
    init(name: String, description: String, highlight: UIColor = UIColor.white, usage: CategoryUsage = .local, enabled: Bool = true) {
        self.name = name
        self.description = description
        self.highlightColor = highlight.toHex()
        self.use = usage
        self.enabled = enabled
    }
}

struct Region: Codable {
    var top = 0
    var bottom = 0
    var left = 0
    var right = 0
}

class Appearance: ADDataTable {
    
    static var tableName = "Appearances"
    static var primaryKey = "id"
    static var primaryKeyType = ADDataTableKeyType.computedInt
    
    var id = ADSQLiteProvider.shared.makeID(Appearance.self) as! Int
    var hasBorder = true
    var borderWidth = 1
    var borderColor = UIColor.gray.toHex()
    var backgroundColor = UIColor.lightGray.toHex()
    var location = Region()
    var keys = [1,2,3,4]
    
    required init() {
        
    }
}

struct Address: Codable {
    var addr1 = ""
    var addr2 = ""
    var city = ""
    var state = ""
    var zip = ""
}

class Person: ADDataTable {
    
    static var tableName = "People"
    static var primaryKey = "id"
    static var primaryKeyType = ADDataTableKeyType.autoUUIDString
    
    var id = UUID().uuidString
    var firstName = ""
    var lastName = ""
    var addresses: [String:Address] = [:]
    var appearance = Appearance()
    
    required init() {
        
    }
    
    init(firstName: String, lastName:String, addresses: [String:Address] = [:]) {
        self.firstName = firstName
        self.lastName = lastName
        self.addresses = addresses
    }
}

class Group: ADDataTable {
    
    static var tableName = "Groups"
    static var primaryKey = "id"
    static var primaryKeyType = ADDataTableKeyType.autoUUIDString
    
    var id = UUID().uuidString
    var name = ""
    var people = ADCrossReference<Person>(name: "PeopleInGroup", leftKeyName: "groupID", rightKeyName: "personID")
    
    required init() {
        
    }
    
    init(name: String, people: [Person] = []) {
        self.name = name
        self.people.storage = people
    }
}
