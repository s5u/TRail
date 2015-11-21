
import UIKit

class Todo: NSObject {
    var title: String
    var descript: String?
    var priority:Priority
    var achieve: Bool
    var id: String
    var target_id: String
    var task_id: String
    var order: Int?
    var user: User?
    
    init(title: String, descript: String?, priority: Int, achieve: Bool, id: String, target_id: String, task_id: String, order: Int?) {
        self.title = title
        self.descript = descript
        self.priority = Priority(rawValue: priority)!
        self.achieve = achieve
        self.id = id
        self.target_id = target_id
        self.task_id = task_id
        self.order = order
    }
}
