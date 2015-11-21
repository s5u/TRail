
import UIKit
import Parse

@objc protocol TargetCollectionDelegate {
    func didFinishedFetchData()
}

class TargetCollection: NSObject {
    static let sharedInstance = TargetCollection()
    var targets:[Target] = []
    
    weak var customDelegate: TargetCollectionDelegate?
    
    func fetchTargets() {
        let query = PFQuery(className: "Target")
        if let _ = PFUser.currentUser() {
            query.whereKey("user", containedIn: [PFUser.currentUser()!])
        }
        query.orderByAscending("order")
        query.findObjectsInBackgroundWithBlock { (objects, error) in
            if error == nil {
                self.targets = []
                for object in objects! {
                    let target = Target(title: object["title"] as! String, descript: object["descript"] as? String, priority: object["priority"] as! Int, achieve: object["achieve"] as! Bool, id: object.objectId!, order: object["order"] as? Int)
                    self.targets.append(target)
                    self.customDelegate?.didFinishedFetchData()
                }
            }
       }
        
    }

}