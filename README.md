# Firebase Mock for Swift

This is an ad-hoc mock class for UI testing with Firebase and Swift for a small project I am working on.. 

## How to use
1. You need to [add the Firebase
   framework](https://www.firebase.com/docs/ios/alternate-setup.html) to your project.
2. Add the file `firebase.swift` to your project. Conveniently rename it to
   `MockFirebase.swift` or something.
3. Substitute `Firebase` for `MockFirebase` in your tests.

## How to contribute
1. Fork the repo
2. Add the [Firebase
   framework](https://www.firebase.com/docs/ios/alternate-setup.html) to the project
3. Run `carthage bootstrap` to add testing frameworks Quick/Nimble
2. Add more mock firebase functions and write appropriate tests
3. Create a pull request
