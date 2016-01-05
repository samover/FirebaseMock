//
//  MockFirebase.swift
//  changr
//
//  Created by Samuel Overloop on 30/12/15.
//  Copyright © 2015 Samuel Overloop. All rights reserved.
//

import Foundation
import Firebase

class MockFirebase: Firebase {
    
    var authError:NSError? = NSError(domain: "User authentication", code: 1, userInfo: nil)
    var user: User!
    var users: [User] = []
    var current_user: User?
    var snapshot: Snapshot?
    var url: String?
    var rootUrl: String?
    var parentUrl: String?
    var locationKey: String?
    
    override var authData: FAuthData? {
        get {
            if let authUserData = current_user {
                return authUserData
            } else {
                return nil
            }
        }
    }
    
    override init?(url: String!) {
        super.init()
        self.url = url
    }
    
    /** @name Retrieving String Representation */
     
     /**
     * Gets the absolute URL of this Firebase location.
     *
     * @return The absolute URL of the referenced Firebase location.
     */
    override func description() -> String! {
        return self.url
    }
    
    override var parent: Firebase! {
        get {
            return MockFirebase(url: parentUrl)
        }
    }
    
    /**
     * Get a Firebase reference for the root location
     *
     * @return A new Firebase reference to root location.
     */
    
    override var root: Firebase! {
        get {
            return MockFirebase(url: rootUrl)
        }
    }
    
    /**
     * Gets last token in a Firebase location (e.g. 'fred' in https://SampleChat.firebaseIO-demo.com/users/fred)
     *
     * @return The key of the location this reference points to.
     */
    
    override var key: String! {
        get {
            return locationKey
        }
    }
    
    override func observeEventType(eventType: FEventType, andPreviousSiblingKeyWithBlock block: ((FDataSnapshot!, String!) -> Void)!) -> UInt {
        block(snapshot, nil)
        return 1
    }
    
    override func childByAppendingPath(pathString: String!) -> Firebase! {
        return MockFirebase(url: "\(self.url)/\(pathString)")
    }
    
    override func updateChildValues(values: [NSObject : AnyObject]!) {
        print("You rock")
    }
    
    // Mark: AUTHENTICATION
    override func authUser(email: String!, password: String!, withCompletionBlock block: ((NSError!, FAuthData!) -> Void)!) {
        var error = authError
        
        for user in users {
            if(user.email! == email && user.password == password) {
                current_user = user
                error = nil
            }
        }
        
        block(error, authData)
    }
    
    override func createUser(email: String!, password: String!, withCompletionBlock block: ((NSError!) -> Void)!) {
        var error = authError
        var exists = false
        
        for existingUser in users {
            if (existingUser.email == email) {
                exists = true
            }
        }
        
        if(!exists) {
            user = User(email: email, password: password)
            users += [user]
            error = nil
        }
        
        block(error)
    }
    
    override func unauth() {
        current_user = nil
    }
    
    func getParentUrl() -> String! {
        return "string"
    }
}

class User: FAuthData {
    var email: String!
    var password: String!
    
    init?(email: String, password: String) {
        super.init()
        
        if(email == "" || password == "") { return nil }
        self.email = email
        self.password = password
    }
    
    override var uid: String {
        get {
            return "a8cfdc95-e221-4108-967a-7ac7e3d48b6d"
        }
    }
    
    override var provider: String {
        get {
            return "password"
        }
    }
    
    override var expires: NSNumber {
        get {
            return 1451558993
        }
    }
    
    override var auth: [NSObject: AnyObject] {
        get {
            return [ "uid": uid, "provider": provider]
        }
    }
    
    override var token: String {
        get {
            return "eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJ2IjowLCJkIjp7InByb3ZpZGVyIjoicGFzc3dvcmQiLCJ1aWQiOiJhOGNmZGM5NS1lMjIxLTQxMDgtOTY3YS03YWM3ZTNkNDhiNmQifSwiaWF0IjoxNDUxNDcyNTkzfQ.JcT_Pu7pbfjNTNrgvdct1rCG9z_sftYoRTRtUtM423Q"
        }
    }
    
    override var providerData: [NSObject: AnyObject] {
        get {
            return [
                "profileImageURL": "https://secure.gravatar.com/avatar/8da15a9afec4c29790fff3a0a2b45608?d=retro",
                "isTemporaryPassword": 0,
                "email": email
            ]
        }
    }
}

class Snapshot: FDataSnapshot {
    var FBref: MockFirebase!
    var data: AnyObject?
    
    init?(FBref: MockFirebase!, data: AnyObject?) {
        self.FBref = FBref
        if data is NSDictionary { self.data = data as! NSDictionary }
        else if data is NSArray { self.data = data as! NSArray }
        else if data is NSInteger { self.data = data as! NSInteger }
        else if data is NSString {
            print("This is a STRING")
            self.data = data as! NSString
        }
        else { self.data = nil }
    }
    
    // TEST
    override func childSnapshotForPath(childPathString: String!) -> FDataSnapshot! {
        return Snapshot(FBref: self.FBref, data: self.data![childPathString]) //as Snapshot!
    }
    
    override func hasChild(childPathString: String!) -> Bool {
        return (self.data != nil && self.data![childPathString] != nil)
    }
    
    override func hasChildren() -> Bool {
        return (childrenCount > 0)
    }
    
    override func exists() -> Bool {
        return (self.data != nil)
    }
    
    /** @name Data export */
     
     /**
     * Returns the raw value at this location, coupled with any metadata, such as priority.
     *
     * Priorities, where they exist, are accessible under the ".priority" key in instances of NSDictionary.
     * For leaf locations with priorities, the value will be under the ".value" key.
     */
     //    override func valueInExportFormat() -> AnyObject! {
     //        return self
     //    }
     
     /** @name Properties */
     
     /**
     * Returns the contents of this data snapshot as native types.
     *
     * Data types returned:
     * * NSDictionary
     * * NSArray
     * * NSNumber (also includes booleans)
     * * NSString
     *
     * @return The data as a native object.
     */
    override var value: AnyObject! {
        get {
            print(self.data as? NSDictionary)
            return self.data
        }
    }
    
    override var childrenCount: UInt {
        get {
            return self.data != nil ? UInt(self.data!.count) : 0
        }
    }
    
    override var ref: Firebase! {
        get {
            return self.FBref
        }
    }
    
    /**
     * The key of the location that generated this FDataSnapshot.
     *
     * @return An NSString containing the key for the location of this FDataSnapshot.
     */
    override var key: String! {
        get {
            return "/"
        }
    }
    
    /**
     * An iterator for snapshots of the child nodes in this snapshot.
     * You can use the native for..in syntax:
     *
     * for (FDataSnapshot* child in snapshot.children) {
     *     ...
     * }
     *
     * @return An NSEnumerator of the children
     */
    override var children: NSEnumerator! {
        get {
            if(hasChildren()) {
                let array:NSMutableArray = []
                let data = self.data as? NSDictionary
                
                data!.forEach { item in
                    array.addObject(childSnapshotForPath(item.key as! String) as! Snapshot)
                }
                
                return (array as NSArray!).objectEnumerator()
            }
            else {
                return nil
            }
        }
    }
    
    /**
     * The priority of the data in this FDataSnapshot.
     *
     * @return The priority as a string, or nil if no priority was set.
     */
    override var priority: AnyObject! {
        get {
            return nil
        }
    }
}
