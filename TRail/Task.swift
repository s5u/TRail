
import UIKit


class Task: NSObject {
    var title: String
    var descript: String?
    var priority: Priority
    var achieve: Bool
    var id: String
    var target_id: String
    var order: Int?
    var user: User?
    
    init(title: String, descript: String?, priority: Int, achieve: Bool, id: String, target_id: String, order: Int?) {
        self.title = title
        self.descript = descript
        self.priority = Priority(rawValue: priority)!
        self.achieve = achieve
        self.id = id
        self.target_id = target_id
        self.order = order
    }
}

