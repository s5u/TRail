
import UIKit
import Parse

class NewTaskViewController: UIViewController, UITextFieldDelegate {
    @IBOutlet weak var taskPrioritySegment: UISegmentedControl!
    @IBOutlet weak var taskDescriptionView: UITextView!
    @IBOutlet weak var taskField: UITextField!
//    let taskCollection = TaskCollection()
    var target: Target?

    override func viewDidLoad() {
        super.viewDidLoad()
        taskDescriptionView.layer.cornerRadius = 5
        taskDescriptionView.layer.borderColor = UIColor(red: 0.9, green: 0.9, blue: 0.9, alpha: 1).CGColor
        taskDescriptionView.layer.borderWidth = 1
        let tapRecognizer = UITapGestureRecognizer(target: self, action: "tapGesture:")
        self.view.addGestureRecognizer(tapRecognizer)
        taskField.delegate = self
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController!.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName: UIColor.whiteColor()]
        self.navigationController!.navigationBar.tintColor = UIColor.whiteColor()
        self.navigationController?.navigationBar.barTintColor = UIColor(red: 1, green: 165/255, blue: 0, alpha: 1)
        self.navigationController?.navigationBar.translucent = false
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(named: "check"), style: UIBarButtonItemStyle.Plain, target: self, action: "save")
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(image: UIImage(named: "close"), style: UIBarButtonItemStyle.Plain, target: self, action: "close")
    }
    
    func close() {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func save() {
        if taskField.text!.isEmpty {
            let alertView = UIAlertController(title: "ERROR", message: "Please enter a New Task", preferredStyle: UIAlertControllerStyle.Alert)
            alertView.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: nil))
            self.presentViewController(alertView, animated: true, completion: nil)
        } else {
            UIApplication.sharedApplication().networkActivityIndicatorVisible = true
            let query = PFQuery(className: "Task")
            query.findObjectsInBackgroundWithBlock { (objects, error) in
                if error == nil {
                    for object in objects! {
                        var objectOrder = object["order"] as! Int
                        objectOrder += 1
                        object["order"] = objectOrder
                        object.saveInBackgroundWithBlock { (success, error) in
                            if success {
                                print("task order saved")
                            }
                        }
                    }
                    self.saveTask()
                }
            }
        }
    }
    
    func saveTask() {
        let task = PFObject(className: "Task")
        task["title"] = taskField.text!
        task["descript"] = taskDescriptionView.text
        task["priority"] = taskPrioritySegment.selectedSegmentIndex
        task["achieve"] = false
        task["target_id"] = target?.id
        task["order"] = 0
        let relation = task.relationForKey("user")
        relation.addObject(PFUser.currentUser()!)
        task.saveInBackgroundWithBlock { (success, error) in
            if success {
                print("task saved")
            }
            self.dismissViewControllerAnimated(true, completion: nil)
            UIApplication.sharedApplication().networkActivityIndicatorVisible = false
        }
    }
    
    func tapGesture(sender: UITapGestureRecognizer) {
        taskField.resignFirstResponder()
        taskDescriptionView.resignFirstResponder()
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        taskField.resignFirstResponder()
        return true
    }


    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

}
