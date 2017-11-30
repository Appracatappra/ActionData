//
//  SPONTetst.swift
//  ActionDataTests
//
//  Created by Kevin Mullins on 10/19/17.
//  Copyright © 2017 Appracatappra, LLC. All rights reserved.
//

import XCTest
import ActionUtilities
import ActionData

class SPONTests: XCTestCase {
    
    var encoder = ADSPONEncoder()
    var decoder = ADSPONDecoder()
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    // MARK: - Unit Tests
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
}
