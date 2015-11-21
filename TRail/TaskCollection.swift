
import UIKit
import Parse

@objc protocol TaskCollectionDelegate {
    func didFinishedFetchData()
}


class TaskCollection: NSObject {
    static let sharedInstance = TaskCollection()
    var tasks:[Task] = []
    
    weak var customDelegate: TaskCollectionDelegate?
    
    func fetchTasks() {
        let query = PFQuery(className: "Task")
        query.orderByAscending("order")
        query.findObjectsInBackgroundWithBlock { (objects, error) in
            if error == nil {
                self.tasks = []
                for object in objects! {
                    let task = Task(title: object["title"] as! String, descript: object["descript"] as? String, priority: object["priority"] as! Int, achieve: object["achieve"] as! Bool, id: object.objectId!, target_id: object["target_id"] as! String, order: object["order"] as? Int)
                    self.tasks.append(task)
                    self.customDelegate?.didFinishedFetchData()
                }
            }
        }
    }
}

