//
//  ADImageView.swift
//  ActionData iOS
//
//  Created by Kevin Mullins on 4/13/18.
//

import Foundation
import ActionUtilities

/**
 Creates an image view that can be bound to a value from a data model that conforms to the `Codable` protocol when placed on a `ADBoundViewController` view. Use the `dataPath` property to specify the field from the bound data model to populate the image view from or a formula in a SQL like syntax.
 
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
 
 // Bind the image view to the icon field
 myImage.dataPath = "icon"
 ```
 */
open class ADBoundImageView: UIImageView, ADBindable, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    // MARK: - Private Variables
    /// If `true`, the control is enabled, else it is not.
    private var isEnabled: Bool = true
    
    /// Holds the image picker for this image viewer.
    private var imagePicker = UIImagePickerController()
    
    /// Holds the source of a editable image view's image.
    private var imageSourceType = UIImagePickerControllerSourceType.photoLibrary
    
    // MARK: - Computed Properties
    /// If `true`, the user can select a new image when the user taps the control.
    @IBInspectable public var isEditable: Bool = false {
        didSet {
            // Allow the user to interact with the control.
            isUserInteractionEnabled = isEditable
        }
    }
    
    /// If `true` this switch cause the parent `ADBoundViewController` to update the form as the value changes.
    @IBInspectable public var liveUpdate: Bool = false
    
    /**
     If this `ADBoundImageView` is editable, this property defines the source of the new image as one of the following values:
     
     * **Camera** - Allows the user to take a picture using the device's camera.
     * **Camera Roll** - Allows the user to select a picture from their camera roll.
     * **Photo Library** - Allows the user to select a pciture from their photo library. This is the default action.
    */
    @IBInspectable public var imageSource: String = "Photo Library" {
        didSet {
            switch imageSource.lowercased() {
            case "camera":
                imageSourceType = .camera
            case "camera roll":
                imageSourceType = .savedPhotosAlbum
            default:
                imageSourceType = .photoLibrary
            }
        }
    }
    
    /// If `true` and this `ADBoundImageView` is editable, the user can move and crop the new image after selecting it.
    @IBInspectable public var canCropImage: Bool = false
    
    /**
     The name of the field from the date model used to populate the value from.
     
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
     
     // Bind the image view to the icon field
     myLabel.dataPath = "icon"
     ```
     
     - remark: The case and name of the field specified in the `dataPath` property must match the case and name from the data model bound to the `ADBoundViewController`.
     */
    @IBInspectable public var dataPath: String = ""
    
    /**
     The name of the field from the date model or formula (using SQL syntax) used to set the enabled state from.
     
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
     
     // Bind the image view to the enabled field
     myImageView.enabledPath = "enabled"
     ```
     
     - remark: The case and name of the field specified in the `enabledPath` property must match the case and name from the data model bound to the `ADBoundViewController`. Optionally, the value can be a formula using a subset of the SQL syntax.
     */
    @IBInspectable public var enabledPath: String = ""
    
    /**
     The name of the field from the date model or formula (using SQL syntax) used to set the hidden state from.
     
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
         var quantity = 0
         var highlightColor = UIColor.white.toHex()
         var type: CategoryType = .local
         var icon: Data = UIImage().toData()
     
         required init() {
     
         }
     }
     
     // Set the hidden state based on a formula.
     myImageView.hiddenPath = "quantity > 0"
     ```
     
     - remark: The case and name of the field specified in the `hiddenPath` property must match the case and name from the data model bound to the `ADBoundViewController`. Optionally, the value can be a formula using a subset of the SQL syntax.
     */
    @IBInspectable public var hiddenPath: String = ""
    
    /**
     The name of the field from the date model or formula (using SQL syntax) used to set the tint color from.
     
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
         var quantity = 0
         var highlightColor = UIColor.white.toHex()
         var type: CategoryType = .local
         var icon: Data = UIImage().toData()
     
         required init() {
     
         }
     }
     
     // Set the text color based on a formula.
     myImageView.colorPath = "highlightColor"
     ```
     
     - remark: The case and name of the field specified in the `colorPath` property must match the case and name from the data model bound to the `ADBoundViewController`. Optionally, the value can be a formula using a subset of the SQL syntax.
     */
    @IBInspectable public var colorPath: String = ""
    
    /// Provides a link to the `ADBindingController` that the control is bound to.
    public var controller: ADBindingController?
    
    /**
     Provides a unique ID that is assigned to the control when it is bound to a `ADBoundViewController`.
     - Remark: You should never set or change this number yourself, this value will be managed by the `ADBoundViewController` and is used to handle form and keyboard events.
     */
    public var formID: Int = -1
    
    /// Returns `true` if the value of the control can be edited by the user, else returns `false`.
    public var isMutable: Bool {
        get {return isEditable}
    }
    
    /// If this bindable control is inside of a Sub View, this value is used to calculate the "physical" top of the control on the form. This value is used to determin if the control is being covered by the keyboard and if it should be moved. This value should never be set directly by the developer, it is automatically calculated by the `ADBindingController`.
    public var topOfFormOffset: Float = 0
    
    // MARK: - Initializers
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        // Set self as image picker delegate
        imagePicker.delegate = self
    }
    
    // MARK: - Deinitialization
    deinit {
        // Release memory
        controller = nil
    }
    
    // MARK: - Functions
    /**
     Sets the value of the image view from the given value. If the value is `String`, this function assumes its a Base 64 encoded image and will attempt to decode it.
     
     - Parameter value: The value to set the image to.
     */
    public func setValue(_ value: Any) {
        // Have we been passed a raw image?
        if let img = value as? UIImage {
            image = img
        } else if let data = value as? String {
            // Set the image from a base 64 encoded string
            image = data.uiImage
        } else {
            print("BINDING ERROR: Data path `\(dataPath)` is not a valid type to set an image view from. It must be a `UIImage` or `String` containing a base 64 encoded image.")
        }
    }
    
    /**
     Sets the enabled state of the control from the given value. If the value is an `Int` or `Float`, `0` and `1` will be converted to `false` and `true`. If the value is a `String`, "yes", "on", "true", "1" will be converted to `true`, all other values will result in `false`.
     
     - Parameter value: The value to set the enabled state from.
     */
    public func setEnabledState(_ value: Any) {
        // Try to convert to needed value
        do {
            // Force the value to a boolean
            let state = try ADUtilities.cast(value, to: .boolType) as! Bool
            if state {
                alpha = 1.0
            } else {
                alpha = 0.5
            }
        } catch {
            print("BINDING ERROR: Unable to set image view enabled state from data path `\(dataPath)`.")
        }
    }
    
    /**
     Sets the hidden state of the control from the given value. If the value is an `Int` or `Float`, `0` and `1` will be converted to `false` and `true`. If the value is a `String`, "yes", "on", "true", "1" will be converted to `true`, all other values will result in `false`.
     
     - Parameter value: The value to set the enabled state from.
     */
    public func setHiddenState(_ value: Any) {
        // Try to convert to needed value
        do {
            // Force the value to a boolean
            let state = try ADUtilities.cast(value, to: .boolType) as! Bool
            isHidden = state
        } catch {
            print("BINDING ERROR: Unable to set image view hidden state from data path `\(dataPath)`.")
        }
    }
    
    /**
     Sets the tint color from the given value. If the value is a string, this routine will assume it holds a hex color specification in the form `#RRGGBBAA`.
     
     - Parameter value: The value to set the text color from.
     */
    public func setTintColor(_ value: Any) {
        // Try to convert to needed value
        do {
            // Force the value to a boolean
            let color = try ADUtilities.cast(value, to: .colorType) as! UIColor
            tintColor = color
        } catch {
            print("BINDING ERROR: Unable to set tint color from data path `\(colorPath)`.")
        }
    }
    
    /**
     Sets any control specific bound states (such as colors) with the values from the given `ADRecord`.
     
     - Parameter data: The raw data to bind the additional states to.
     */
    public func setControlSpecificStates(against data: ADRecord) {
        // Set tint color
        do {
            // Attempt to get value for path
            if let value = try ADBoundPathProcessor.evaluate(path: colorPath, against: data) {
                setTintColor(value)
            }
        } catch {
            // Output processing error
            print("Error evaluating tint color path `\(colorPath)`: \(error)")
        }
    }
    
    /**
     Returns the value of the image view as a base 64 encoded string.
     
     - Returns: The value of the image view as a `String`.
     */
    public func getValue() -> Any {
        if image == nil {
            return ""
        } else {
            // Convert the image to a string
            return image!.toString()
        }
    }
    
    /**
     Handles the user starting a touch operation.
     
     - Parameters:
     - touches: An array of touches to handle.
     - event: The event that started the touch.
    */
    open override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        
        // Is the control editable and enabled?
        if isEditable && isEnabled {
            // Yes, Are we connected to a parent controller
            if let viewController = controller as? UIViewController {
                // Are we selecting from the camera?
                if imageSourceType == .camera {
                    // Yes, is the camera present?
                    if UIImagePickerController.isSourceTypeAvailable(.camera) {
                        // Configure picker
                        imagePicker.sourceType = imageSourceType
                        imagePicker.allowsEditing = canCropImage
                        imagePicker.modalPresentationStyle = .overFullScreen
                        
                        // Yes, present the controller.
                        viewController.present(imagePicker, animated: true, completion: nil)
                    }
                } else {
                    // No, can we select from a photo library?
                    if UIImagePickerController.isSourceTypeAvailable(imageSourceType) {
                        // Configure picker
                        imagePicker.sourceType = imageSourceType
                        imagePicker.allowsEditing = canCropImage
                        
                        // Are we running on an iPad device?
                        if HardwareInformation.isPad {
                            // Yes, we need to present this controller in a popover.
                            imagePicker.modalPresentationStyle = .popover
                            imagePicker.popoverPresentationController?.sourceRect = self.bounds
                            imagePicker.popoverPresentationController?.sourceView = self
                            viewController.present(imagePicker, animated: true, completion: nil)
                        } else {
                            // No, just present the controller.
                            imagePicker.modalPresentationStyle = .overFullScreen
                            viewController.present(imagePicker, animated: true, completion: nil)
                        }
                    }
                }
            }
        }
    }
    
    // MARK: - UIImagePickerControllerDelegate
    public func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        var newImage: UIImage? = nil
        
        // Get image from results.
        if canCropImage {
            newImage = info[UIImagePickerControllerEditedImage] as? UIImage
        } else {
            newImage = info[UIImagePickerControllerOriginalImage] as? UIImage
        }
        
        // Run on main UI thread
        DispatchQueue.main.async(execute: {() -> Void in
            
            // Set image
            self.image = newImage
            
            // Is the control live updating?
            if self.liveUpdate {
                if let bindEngine = self.controller {
                    bindEngine.refreshDisplay()
                }
            }
            
        })
        
        // Close picker
        picker.dismiss(animated: true, completion: nil)
    }
}
