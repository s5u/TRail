
import UIKit
import Parse


@objc protocol TodoCollectionDelegate {
    func didFinishedFetchData()
}

class TodoCollection: NSObject {
    static let shareInstance = TodoCollection()
    var todos:[Todo] = []
    
    weak var customDelegate: TodoCollectionDelegate?
    
    func fetchTodos() {
        let query = PFQuery(className: "Todo")
        query.orderByAscending("order")
        query.findObjectsInBackgroundWithBlock { (objects, error) in
            if error == nil {
                self.todos = []
                for object in objects! {
                    let todo = Todo(title: object["title"] as! String, descript: object["descript"] as? String, priority: object["priority"] as! Int, achieve: object["achieve"] as! Bool, id: object.objectId!, target_id: object["target_id"] as! String, task_id: object["task_id"] as! String,order: object["order"] as? Int)
                    self.todos.append(todo)
                    self.customDelegate?.didFinishedFetchData()
                }
            }
        }
    }

    
}

