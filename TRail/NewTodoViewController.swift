
import UIKit
import Parse

class NewTodoViewController: UIViewController, UITextFieldDelegate {
    @IBOutlet weak var todoPrioritySegment: UISegmentedControl!
    @IBOutlet weak var todoDescriptionView: UITextView!
    @IBOutlet weak var todoField: UITextField!
//    let todoCollection = TodoCollection()
    var target: Target?
    var task: Task?

    override func viewDidLoad() {
        super.viewDidLoad()
        todoDescriptionView.layer.cornerRadius = 5
        todoDescriptionView.layer.borderColor = UIColor(red: 0.9, green: 0.9, blue: 0.9, alpha: 1).CGColor
        todoDescriptionView.layer.borderWidth = 1
        let tapRecognizer = UITapGestureRecognizer(target: self, action: "tapGesture:")
        self.view.addGestureRecognizer(tapRecognizer)
        todoField.delegate = self
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController!.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName: UIColor.whiteColor()]
        self.navigationController!.navigationBar.tintColor = UIColor.whiteColor()
        self.navigationController?.navigationBar.barTintColor = UIColor(red: 0, green: 1, blue: 0, alpha: 1)
        self.navigationController?.navigationBar.translucent = false
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(named: "check"), style: UIBarButtonItemStyle.Plain, target: self, action: "save")
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(image: UIImage(named: "close"), style: UIBarButtonItemStyle.Plain, target: self, action: "close")
    }
    
    func close() {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func save() {
        if todoField.text!.isEmpty {
            let alertView = UIAlertController(title: "ERROR", message: "Please enter a New Todo", preferredStyle: UIAlertControllerStyle.Alert)
            alertView.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: nil))
            self.presentViewController(alertView, animated: true, completion: nil)
        } else {
            UIApplication.sharedApplication().networkActivityIndicatorVisible = true
            let query = PFQuery(className: "Todo")
            query.findObjectsInBackgroundWithBlock { (objects, error) in
                if error == nil {
                    for object in objects! {
                        var objectOrder = object["order"] as! Int
                        objectOrder += 1
                        object["order"] = objectOrder
                        object.saveInBackgroundWithBlock { (success, error) in
                            if success {
                                print("todo order saved")
                            }
                        }
                    }
                    self.saveTodo()
                }
            }
        }
    }
    
    func saveTodo() {
        let todo = PFObject(className: "Todo")
        todo["title"] = todoField.text!
        todo["descript"] = todoDescriptionView.text
        todo["priority"] = todoPrioritySegment.selectedSegmentIndex
        todo["achieve"] = false
        todo["target_id"] = target?.id
        todo["task_id"] = task?.id
        todo["order"] = 0
        let relation = todo.relationForKey("user")
        relation.addObject(PFUser.currentUser()!)
        todo.saveInBackgroundWithBlock { (success, error) in
            if success {
                print("todo saved")
            }
            self.dismissViewControllerAnimated(true, completion: nil)
            UIApplication.sharedApplication().networkActivityIndicatorVisible = false
        }
    }
    
    func tapGesture(sender: UITapGestureRecognizer) {
        todoField.resignFirstResponder()
        todoDescriptionView.resignFirstResponder()
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        todoField.resignFirstResponder()
        return true
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}
