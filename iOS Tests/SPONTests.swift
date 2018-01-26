//
//  SPONTests.swift
//  iOS Tests
//
//  Created by Kevin Mullins on 1/26/18.
//

import XCTest
import ActionUtilities
import ActionData

class SPONTests: XCTestCase {
    
    var provider = ADSPONProvider.shared
    var encoder = ADSPONEncoder()
    var decoder = ADSPONDecoder()
    
    override func setUp() {
        super.setUp()
        
        // Open the database
        do {
            try provider.openSource("Test.spon")
        } catch {
            XCTFail("Unable to open requested sample database 'Test.spon'.")
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
    
    // MARK: - Unit Tests
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
    
}
