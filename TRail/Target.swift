
import UIKit
import Parse

enum Priority: Int {
    case Low = 0
    case Middle = 1
    case High = 2
    
    func color() -> UIColor {
        switch self {
        case .Low:
            return UIColor.greenColor()
        case .Middle:
            return UIColor.yellowColor()
        case .High:
            return UIColor.redColor()
        }
    }
}


class Target: NSObject {    
    var title: String
    var descript: String?
    var priority: Priority
    var achieve: Bool
    var id: String
    var order: Int?
    var user: User?
    
    init(title: String, descript: String?, priority: Int, achieve: Bool, id: String, order: Int?) {
        self.title = title
        self.descript = descript
        self.priority = Priority(rawValue: priority)!
        self.achieve = achieve
        self.id = id
        self.order = order
    }
}
