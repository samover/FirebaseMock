//
//  mockFirebaseSpec.swift
//  changr
//
//  Created by Samuel Overloop on 30/12/15.
//  Copyright © 2015 Samuel Overloop. All rights reserved.
//

import Quick
import Nimble

class mockFirebaseSpec: QuickSpec {
    
    
    override func spec() {
        var ref: MockFirebase!
        
        describe("Initialization") {
            beforeEach {
                ref = MockFirebase(url: "mock.this")
            }
            
            describe("#root") {
                
            }
        }
        
        describe("Auth") {
            beforeEach {
                ref = MockFirebase(url: "mock.this")
            }
            
            describe("#authData") {
                
                
                it("returns nil when a user is not logged in") {
                    expect(ref.authData).to(beNil())
                }
                
                it("returns not nil when a user is logged in") {
                    self.createUserAndSignIn(ref)
                    expect(ref.authData).notTo(beNil())
                }
            }
            
            describe("#createUser") {
                it("does not return an error") {
                    ref.createUser("donor@gmail.com", password: "password") { (error: NSError!) in
                        expect(error).to(beNil())
                    }
                }
                
                it("creates a user") {
                    ref.createUser("donor@gmail.com", password: "password") { (error: NSError?) in
                        expect(ref.user.providerData["email"]! as? String).to(equal("donor@gmail.com"))
                    }
                }
                
                it("stores a user in users array") {
                    self.createUserAndSignIn(ref)
                    expect(ref.users.count).to(equal(1))
                }
                
                it("throws an error when user already exists") {
                    self.createUserAndSignIn(ref)
                    ref.unauth()
                    ref.createUser("donor@gmail.com", password: "password") { (error: NSError!) in
                        expect(error).notTo(beNil())
                    }
                }
            }
            
            describe("#unauth()") {
                it("destroys the current_user") {
                    self.createUserAndSignIn(ref)
                    expect(ref.authData).notTo(beNil())
                    ref.unauth()
                    expect(ref.authData).to(beNil())
                }
            }
            
            describe("#authUser") {
                
                it("does not return an error when valid login") {
                    ref.createUser("donor@gmail.com", password: "password") { (error: NSError!) in
                        if(error != nil) {
                            ref.authUser("donor@gmail.com", password: "password") { (error, auth) in
                                expect(error).to(beNil())
                            }
                        }
                    }
                }
                
                it("returns an error when unregistered user") {
                    expect(ref.authData).to(beNil())
                    
                    ref.authUser("donor@gmail.com", password: "password") { (error: NSError!, auth) in
                        expect(error).notTo(beNil())
                    }
                }
                
                it("returns an error when invalid login") {
                    ref.createUser("donor@gmail.com", password: "password") {
                        (error: NSError!) in
                        if(error != nil) {
                            ref.authUser("receiver@gmail.com", password: "password") {
                                (error, auth) in
                                expect(error).notTo(beNil())
                            }
                        }
                    }
                }
            }
        }
        
        describe("#FDataSnapshot") {
            beforeEach {
                ref = MockFirebase(url: "mock.this")
            }
            
            var data: NSDictionary?
            var snapshot: Snapshot!
            var snapshotEmpty: Snapshot!
            
            beforeEach{
                data = [
                    "users": [
                        "user1": "Samuel",
                        "user2": "Hamza"
                    ],
                    "beacons": [
                        "beacon1": [
                            "uuid": "12345",
                            "name": "Sam's Beacon"
                        ],
                        "beacon2": [
                            "uuid": "67890",
                            "name": "Hamza's Beacon"
                        ]
                    ]
                ]
                
                snapshot = Snapshot(FBref: ref, data: data!)!
                snapshotEmpty = Snapshot(FBref: ref, data: nil)
            }
            
            describe("#init") {
                it("it has data when initialized with data") {
                    expect(snapshot.data as? NSDictionary).to(equal(data))
                }
                
                it("has no data when initialized with no data") {
                    expect(snapshotEmpty.data).to(beNil())
                }
                
                it("has a firebase ref") {
                    expect(snapshot.ref).to(equal(ref))
                }
            }
            
            describe("#hasChild") {
                it("has a child 'users'") {
                    expect(snapshot.hasChild("users")).to(equal(true))
                }
                it("has no child 'child'") {
                    expect(snapshot.hasChild("child")).to(equal(false))
                }
                it("has no children when no data is given") {
                    expect(snapshotEmpty.hasChild("child")).to(equal(false))
                }
            }
            
            describe("#childrenCount") {
                it("has two children") {
                    expect(snapshot.childrenCount).to(equal(2))
                }
                it("has no children when data is not provided") {
                    expect(snapshotEmpty.childrenCount).to(equal(0))
                }
            }
            
            describe("#hasChildren") {
                it("returns true with children") {
                    expect(snapshot.hasChildren()).to(equal(true))
                }
                it("returns false with no children") {
                    expect(snapshotEmpty.hasChildren()).to(equal(false))
                }
            }
            
            describe("#exists") {
                it("returns true when a datasnapshot exists") {
                    expect(snapshot.exists()).to(equal(true))
                }
                
                it("returns false when a datasnapshot does not exist") {
                    expect(snapshotEmpty.exists()).to(equal(false))
                }
            }
            
            describe("value") {
                it("returns the data in its native type") {
                    expect(snapshot.value as? NSDictionary).to(equal(data))
                }
                
                it("allows to access values through key") {
                    let userData = [
                        "user1": "Samuel",
                        "user2": "Hamza"
                    ]
                    expect(snapshot.value["users"]).to(equal(userData))
                }
            }
            
            describe("#ref") {
                it("returns the firebase ref of the location of the datasnapshot") {
                    expect(snapshot.ref).to(equal(ref))
                }
            }
            
            describe("#childSnapshotForPath") {
                it("returns a snapshot for path users") {
                    let childSnapshot = snapshot.childSnapshotForPath("users")
                    let userData = [
                        "user1": "Samuel",
                        "user2": "Hamza"
                    ]
                    expect(childSnapshot.value as? NSDictionary).to(equal(userData))
                }
            }
            
            describe("#children") {
                it("calls the callback with each child") {
                    let snapshot = Snapshot(FBref: ref, data: [ "foo": "bar", "baz": "bar" ])
                    for item in snapshot!.children {
                        let child = item as! Snapshot
                        expect(child.value as? String).to(equal("bar"))
                    }
                }
                
                //                it("returns array of childSnapshots") {
                //                    for item in snapshot.children {
                //                        expect(item.exists).to(equal(true))
                //                    }
                //                }
                
                it("allows for weird stuff") {
                    let userData = [
                        "users": [
                            "user1": "Samuel",
                            "user2": "Hamza"
                        ]
                    ]
                    
                    let snapshot = Snapshot(FBref: ref, data: userData)
                    for item in snapshot!.children {
                        let child = item as! Snapshot
                        let value = child.value as! NSDictionary
                        expect(value["user2"] as? String ).to(equal("Hamza"))
                    }
                }
            }
        }
    }
    
    func createUserAndSignIn(ref: MockFirebase!) -> Void {
        ref.createUser("donor@gmail.com", password: "password") { (error: NSError!) in
            ref.authUser("donor@gmail.com", password: "password") { (error: NSError!, auth) in
                print("user 'donor@gmail.com' is logged in")
            }
        }
    }
}