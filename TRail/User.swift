
import UIKit
import Parse

class User: NSObject {
    var name: String
    var password: String
    
    init(name: String, password: String) {
        self.name = name
        self.password = password
    }
    
    func signUp(callback: (message: String?) -> Void) {
        let user = PFUser()
        user.username = name
        user.password = password
        user.signUpInBackgroundWithBlock { (success, error) in
            callback(message: error?.userInfo["error"] as? String)
        }
    }
    
    func login(callback: (message: String?) -> Void) {
        PFUser.logInWithUsernameInBackground(name, password: password) { (user, error) in
            callback(message: error?.userInfo["error"] as? String)
        }
    }

}
