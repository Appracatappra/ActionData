//
//  AppracatappraLicenseManager.swift
//  ActionData
//
//  Created by Kevin Mullins on 3/8/18.
//

import Foundation
import ActionUtilities

/**
 The Appracatappra License Manager handles verfiying your licensed version of a Appracatappra developer product purchased from our online store. You will need to provide the customer information used to purchase the product, the product license that was sent to you in your purchase receipt and a product activation key. You can generate the activation key at the [Activate License](http://appracatappra.com/checkout/activate-license/) page of the Appracatappra, LLC. website. You have a limited number of product activations so please make a copy of your Activation Key and keep it in a safe place.
 
 Typically, you will provide this information to the `AppracatappraLicenseManager` when the app first starts in the `main` method of the `Main.cs` file.
 
 Failure to include the requested information will result in a Toast style popup being displayed that reads, "Unlicensed Appracatappra Product" whenever an Action Component is used.
 */
public class AppracatappraLicenseManager {
    // MARK: - Private Variables
    /// The verification key.
    private static var key = ""
    
    /// The developer's first name.
    private static var fname = ""
    
    /// The developer's last name.
    private static var lname = ""
    
    /// The developer's email address.
    private static var email = ""
    
    /// The developer's license key.
    private static var lkey = ""
    
    /// The developer's activation key.
    private static var akey = ""
    
    // MARK: - Public Properties
    /**
     Gets or sets the first name of the developer used to purchase the component.
     */
    public static var firstName: String {
        get { return fname}
        set {
            fname = newValue
            UpdateVerification()
        }
    }
    
    /// Gets or sets the last name of the developer used to purchase the component.
    public static var lastName: String {
        get { return lname}
        set {
            lname = newValue
            UpdateVerification()
        }
    }
    
    /// Gets or sets the email address of the developer used to purchase the component.
    public static var emailAddress: String {
        get { return email}
        set {
            email = newValue
            UpdateVerification()
        }
    }
    
    /// Gets or sets the license key that was sent to you when you purchased the product.
    public static var licenseKey: String {
        get { return lkey}
        set {
            lkey = newValue
            UpdateVerification()
        }
    }
    
    /// Gets or sets the activation key generated from your customer information and product license from the [Activate License](http://appracatappra.com/checkout/activate-license/) page of the Appracatappra, LLC. website.
    public static var activationKey: String {
        get { return akey}
        set {
            akey = newValue
            UpdateVerification()
        }
    }
    
    /// Gets a value indicating whether the product license is valid.
    public static var licenseIsValid: Bool {
        get { return (key != "" && key == akey)}
    }
    
    /// Gets the name of the product being licensed.
    public static var productName: String {
        get { return "Action Data"}
    }
    
    // MARK: - Internal Functions
    /// Updated the verification key.
    internal static func UpdateVerification() {
        let a = GoogleAnalyticsTrackingKey(firstName)
        let b = GoogleAnalyticsTrackingKey(lastName)
        let c = GoogleAnalyticsTrackingKey(emailAddress)
        let d = GoogleAnalyticsTrackingKey(licenseKey)
        key = "\(a)-\(b)-\(c)-\(d)"
    }
    
    /**
     Generates a Google Analytic tracking key used to track product usage via the Google Analytic dashboard.
     
     - Parameter track: The ID of the product to generate tracking information for.
     - Returns: A unique analytic tracking key.
    */
    internal static func GoogleAnalyticsTrackingKey(_ track: String) -> Int {
        let phrase = "The quick brown fox jumped spryly over the lazy dog's prized bone."
        let numbers = "9876543210"
        var hash = 0
        
        // Generate a unique tracking key to register product for Google Analytics
        let salt = numbers + productName + phrase
        let key = track.lowercased()
        var i = 0
        for c in key {
            // Find location and adjust hash
            let n = indexOf(char: c, inText: salt)
            hash += (i + 1) * n
            
            // Increment counter
            i += 1
        }
        
        // Return results
        return hash;
    }
    
    /// Validates the license and displays a toast popup if the license isn't valid.
    internal static func validateLicense() {
        // Is the license valid?
        if (!licenseIsValid) {
            // No, display default message
            ACNotify.showMessage(text: "Unlicensed Appracatappra Product")
        }
    }
    
    // MARK: - Private Functions
    /**
     Returns the index of the given character inside of the given text string.
     
     - Parameters:
         - char: The character being sought.
         - text: The string to search for the character in.
     
     - Returns: The position of the character inside of the string or zero if the character could not be found.
    */
    private static func indexOf(char: Character, inText text: String) -> Int {
        var i = 0;
        
        // Scan for matching character
        for c in text {
            // Found match?
            if (c == char) {
                // Yes, return location
                return i
            }
            
            // Increment counter
            i += 1
        }
        
        // Return minus 1 failure
        return -1;
    }
}
