## Discover Action Data

Thank you for trying our [Action Data](http://appracatappra.com/products/action-data/) collection of time saving functions and utilities for working with data across wide range of mobile and desktop apps. We hope you enjoy using our components and that they become a valuable part of your developer environment. 

This guide is designed to help you get up and running with **Action Data** quickly and easily in your own app projects.

<a name="Adding-Action-Data-to-an-App-Project"></a>
## Adding Action Data to an App Project

Our components were designed to be quickly added to your app's project with a minimum of code, making it easy to add high-quality, professional features and functionality to your apps.

**NOTICE:** In addition to installing the **Action Data** framework, you will need to install the required **Action Utilities** framework that is available for free [here](http://appracatappra.com/products/action-utilities/).

In **Xcode**, do the following:

1. Open an app project or start a new one.
2. Select the **Project** in the **Project Navigator**, select the **General** tab and scroll down to the **Embedded Binaries** section:

	Image 1
3. In **Finder**, open the folder where you unzipped the `ActionUtilitiesFrameworks.zip` file and select the appropriate framework version:

	Image 2
4. Drag the framework into the **Embedded Binaries** section in **Xcode**.
5. Select **Copy items if needed** and click the **Finish** button:

	Image 3
6. Return to **Finder**, open the folder where you unzipped the `ActionDataFrameworks.zip` file and select the appropriate framework version:

	Image 2B
7. Drag the framework into the **Embedded Binaries** section in **Xcode**.
8. Select **Copy items if needed** and click the **Finish** button:

	Image 3
9. The both frameworks will be added to both the **Embedded Binaries** and the **Linked Frameworks and Libraries** sections:

	Image 4

You are now ready to use the **Action Data** suite in your app project. Include the `import ActionData` statement at the top of any class you want use a component from. For example:

```swift
import UIKit
import ActionUtilities
import ActionData

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        do {
        	try ADSQLiteProvider.shared.openSource("MyDatabase.db")
        	...
        } catch {
        	print("Unable to open database.")
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}
```

<a name="Component-Documentation"></a>
## Component Documentation

The [Action Data Developer Center](http://appracatappra.com/developers/action-data-developer/) was designed to help you get the most out of our developer tools by providing a selection of Articles, Guides, Samples and Quick Start References for each component in the suite.

Additionally, each tool in the **Action Data Suite** has a fully documented API, with comments for every element included:

* [iOS API Documentation](http://appracatappra.com/api/actiondata/ios/)
* [tvOS API Documentation](http://appracatappra.com/api/actiondata/tvos/)
* [macOS API Documentation](http://appracatappra.com/api/actiondata/macos/)
