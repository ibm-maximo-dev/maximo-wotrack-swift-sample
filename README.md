# Swift sample application for work order tracking in Maximo Asset Management

This simple iOS Swift application demonstrates how easily developers and business partners can build their own solutions by leveraging the Maximo REST APIs. This tutorial shows how to use these APIs and provides instructions for building and testing applications.

## Prerequisites

- Cocoapods
- Xcode 9.2
- Maximo 7.6

## Getting started

### Cocoapods installation

Open a terminal session and enter the following command:
```
sudo gem install cocoapods
```

### Add an SSH key to your GitHub account

Generate the RSA key for your GitHub user account:
```
ssh-keygen -t rsa -b 4096 -C git@github.ibm.com
```

Paste the contents of the <i>id_rsa.pub</i> file, which is described here: https://help.github.com/articles/adding-a-new-ssh-key-to-your-github-account/

### Project setup

Install the dependencies for your project by entering the following command in the terminal session:
```
pod install
```

After the dependencies are successfully installed, Cocoapods updates all the references in the  MaximoWOTRACKSample.xcworkspace file and a Pods folder that contains all the project's dependencies is created.
Now, open the .xcworkspace file by using Xcode, and you are ready to go.


## Login / Logout
This feature allows users to log in by using the built-in authentication mechanisms.
The login operation is the first step that any developer must complete to use the Maximo REST APIs.
Users must be authenticated and have the required permissions to perform these operations.

You must have an active Maximo user account to use these APIs.

After this method is called, it maintains a reference to a Maximo user profile that is used to determine whether the logged user is authorized to perform the requested operations.

The following example illustrates how to use this API to authenticate a user:

```swift
var options = Options().user(user: userName).password(password: password).auth(authMode: "maxauth")
options = options.host(host: host).port(port: port).lean(lean: true)
var connector = MaximoConnector(options: options)
try connector.connect()
```

It is strongly advised that you keep only a single instance of the MaximoConnector object on your application, given that it is a stateful object that keeps a reference to the logged-in Maximo user profile. It is not only good practice, but it can save you time and resources from having to reauthenticate every time you invoke another method from the APIs.

To use this method, you need to build an Options object by supplying the following values:
 - User and password credentials
 - Hostname or IP address
 - Port number

Connection or authentication failures can be handled by catching the following exception types: IOException and OslcException.

```swift
do {
    ...
    try connector.connect()
} catch OslcError.invalidConnectorInstance {
    // Handle connection failures here...
} catch {
    // Handle general failures here...
}
```

To end a user session, use the same instance of the MaximoConnector object that was used for the application login.

```swift
try connector.disconnect() // Log out of Maximo
```

## List work orders that are waiting for approval
This feature allows users to list all work orders that are in the Waiting for Approval status and are visible to their organization and site.
This API method provides a set of input parameters that users can supply to select a collection of work orders records.

The following code sample shows how to select a set of work order records by using options like pagination, sorting, and filtering:

```swift
var PAGE_SIZE = 5
// "mxwo" is the Object Structure defined to represent a Work Order object.
val workOrderSet = connector.resourceSet(osName: "mxwo") // This returns a ResourceSet object instance
val resultList : [String: Any] = [:] // Creates an empty array to hold JSON objects.
workOrderSet.paging(type: true) // Enable pagination.
workOrderSet.pageSize(pageSize: PAGE_SIZE) // Set the page size.
// Use the following query to skip tasks and only fetch Work Orders that are "Waiting for Approval"
workOrderSet._where(whereClause: "spi:istask=0 and spi:status=\"WAPPR\"")
workOrderSet.orderBy(orderByProperties: ["spi:wonum"]) // Ordering by Work Order Number
try workOrderSet.fetch()
var i = 0
while (i < PAGE_SIZE) {
    var resource = workOrderSet.member(index: i) // Return a Resource instance
    i += 1
    var jsonObject = resource.toJSON() // Convert a Resource to a JSON representation
    resultList.append(jsonObject) // Add retrieved JSON object to the array
}
```
### ResourceSet component

Developers who built solutions for Maximo Asset Management in the past might notice that the Maximo REST API classes Resource and ResourceSet are similar to the Mbo/MboSet pair that is available in the Maximo business object framework.

By using an instance of the MaximoConnector class, you can fetch a ResourceSet object for any of the object structures that are published in the Maximo REST API.

The following example shows how to obtain an instance of the ResourceSet class for the MXWO object structure that holds the work order records information.
 ```swift
    var workOrderSet = connector.resourceSet(osName: "mxwo") // This returns a ResourceSet object instance
 ```
After you hold an instance of the ResourseSet class, you can perform actions like searching for existing records, ordering records by a specific set of columns, fetching a records page, and more.

The following list shows the most commonly used actions and input parameters that can be provided to select work order records:
 - fetch(): Fetches a set of records according to the input parameters that are provided.
 - load(): Loads a set of records according to the input parameters that are provided.
 - count(): Returns the count for the current number of records that are loaded into this set.
 - totalCount(): Returns the total count (remote) for all records that are persisted for this set (object structure).
 - nextPage(): Fetches the next page of records for this set.
 - previousPage(): Fetches the previous page of records for this set.
 - member(value : Int): Returns an element that was previously loaded into this set by using the specified index position.
 ```swift
     workOrderSet.fetch()
     workOrderSet.load()
     var count = workOrderSet.count()
     var totalCount = workOrderSet.totalCount()
     workOrderSet.nextPage()
     workOrderSet.previousPage()
     var resourceObject = workOrderSet.member(index: 0)
 ```
 - oslc.select: A String var-args parameter that allows the user to fetch a set of properties for the selected objects instead of loading all their properties. This parameter is useful for applications that are developed for environments that have small memory footprints.
 ```swift
     workOrderSet.select(selectClause: ["spi:wonum", "spi:description", "spi:status"])
 ```
 - oslc.where: A String parameter that allows the user to define a SQL-based where clause to filter the record set.
  ```swift
     workOrderSet._where(whereClause: "spi:istask=0 and spi:status=\"WAPPR\"")
 ```
 - oslc.paging: A flag that enables or disables paging for the selected record set.
  ```swift
     workOrderSet.paging(type: true)
 ```
 - oslc.pageSize: An integer parameter that defines the page size for the selected record set.
  ```swift
     workOrderSet.pageSize(pageSize: 5)
 ```
 - oslc.orderBy: A String var-args parameter that allows the user to define a set of properties that are used to sort the obtained record set.
  ```swift
     workOrderSet.orderBy(orderByProperties: ["spi:wonum"])
 ```
 - oslc.searchTerms: A String var-args parameter that performs record-wide text searchs for the tokens that are specified.
  ```swift
     workOrderSet.hasTerms(terms: ["pump", "broken"])
 ```

After these elements are successfully loaded into the ResourceSet, they must be convered into a friendly data format that is usable inside the application context. That's when JavaScript Object Notation (JSON) objects are used.
 ```swift
     var resourceObject = workOrderSet.member(index: 0) // I am a Resource object
     valr jsonObject = resourceObject.toJSON() // I am a JSON object, 
                                              // much more friendly and human-readable.
 ```
The Resource class is a data object representation of an object structure. It provides several utility methods to update, merge, add or even delete an object structure. It also provides methods to allow conversions to other data types, such as JSON or byte arrays. In the previous example, after a previously loaded Resource object is fetched, it is converted to its JSON object representation.

Up to this point, you are expected to be able to list and view data that is provided by the Maximo REST APIs by using the methods that are shown in this tutorial. The remainder of this tutorial will show you how to modify and create new persistent data records.

## Create/Update a Work Order
Before discussing the actual methods available for updating and creating new data records, this tutorial will provide some background information about how these methods actually work.

### JSON

REST APIs usually rely on the JSON format to transport data between the client and the server.
To modify or create records, you must provide a JSON representation of the record that you want to modify or create as an input for the API method.

Building and modifying JSON structures can be easily accomplished by the use of specific APIs. Almost every modern programming language provides a set of APIs to build and manipulate JSON. This tutorial provides a simple example of how to build JSON objects in the iOS Swift programming language. In Swift, JSON objects are represented by Dictionary instances. Swift uses implicit type casting that allows you to convert a Dictionary object to a JSON data/string and a JSON data/string back into a Dictionary object by using the JSON serializers that are available in the programming language API.

 ```swift
// Adding 'WONUM' attribute to the JSON object.
jsonObject["wonum"] = wonum.text
// Adding 'SITEID' attribute.
jsonObject["siteid"] = MaximoAPI.shared().loggedUser["locationsite"]
// Adding 'ORGID' attribute.
jsonObject["orgid"] = MaximoAPI.shared().loggedUser["locationorg"]
// Converting a JSON structure into a Data object, so it can be sent over the network in a POST request.
let postData : Data = try JSONSerialization.data(withJSONObject: jsonObject, options: [])
// Converting back a Data object into a JSON object.
jsonObject = try JSONSerialization.jsonObject(with: postData, options: []) as! [String : Any]
 ```

### Creating a work order
The process for creating a work order is simple. The most complex piece is building a JSON object that represents a new work order record. This process can sometimes be a little time consuming, given the large number of attributes available in the MXWO object structure. Also, it is important that you observe the following set of rules:

- All Maximo field and attribute rules and validations are also applicable when using the Maximo REST API methods.
- All required fields must have values.
- Domain attributes require special attention so that you don't end up using an invalid value.

If you follow these instructions, you'll likely avoid some exceptions and headaches and also save some time.
Now that you have the JSON object, you need to build the URI that is used as an argument for the create() method. 

The following simplified code example shows how to create a new work order: 

 ```swift
// Building a new Work Order JSON object.
var workOrder = buildWorkOrderJSON()
// Using the MaximoConnector object previously obtained during 
// the Application Login to build the URI string.
var uri = connector.currentURI + "/os/mxwo"
// Invoking the create() method available in the MaximoConnector component.
connector.create(uri: uri, jo: workOrder)
 ```

### Updating a work order
The update method works in the same way that the create method does. Therefore, all the instructions that are provided in the previous section are also applicable here.

This method also takes two arguments as input.
The first argument is the URI, which is used to identify which object is to be updated.
In the update process, the URI is composed by a concatenation of the object structure context path and the object ID.

The following codes shows an example of a URI for a work order object that has ID 1022.
 ```swift
// URI = http://<IP>:<PORT>/maximo/oslc/os/mxwo/1022
var uri = connector.currentURI + "/os/mxwo/" + String(workOrder["workorderid"] as! Int)
 ```

The second argument is an updated copy of the original JsonObject.
Here is another simplified example of how to update an existing work order: 

 ```swift
// Obtaining an updated instance of the Work Order.
var updatedWorkOrder = updateWorkOrder(workOrder: originalWorkOrder)
// Using the MaximoConnector object previously obtained during 
// the Application Login to build the URI string.
var uri = connector.currentURI + "/os/mxwo/" + String(updatedWorkOrder["workorderid"] as! Int)
// Invoking the update() method available in the MaximoConnector component.
connector.update(uri: uri, jo: updatedWorkOrder)
 ```
