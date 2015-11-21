
import UIKit
import Parse

class NewTargetViewController: UIViewController, UITextFieldDelegate {
    @IBOutlet weak var targetPrioritySegment: UISegmentedControl!
    @IBOutlet weak var targetDescriptionView: UITextView!
    @IBOutlet weak var targetField: UITextField!
//    let targetCollection = TargetCollection()

    override func viewDidLoad() {
        super.viewDidLoad()
        targetDescriptionView.layer.cornerRadius = 5
        targetDescriptionView.layer.borderColor = UIColor(red: 0.9, green: 0.9, blue: 0.9, alpha: 1).CGColor
        targetDescriptionView.layer.borderWidth = 1
        let tapRecognizer = UITapGestureRecognizer(target: self, action: "tapGesture:")
        self.view.addGestureRecognizer(tapRecognizer)
        targetField.delegate = self
       
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController!.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName: UIColor.whiteColor()]
        self.navigationController!.navigationBar.tintColor = UIColor.whiteColor()
        self.navigationController?.navigationBar.barTintColor = UIColor(red: 0, green: 191/255, blue: 255/255, alpha: 1)
        self.navigationController?.navigationBar.translucent = false
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(named: "check"), style: UIBarButtonItemStyle.Plain, target: self, action: "save")
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(image: UIImage(named: "close"), style: UIBarButtonItemStyle.Plain, target: self, action: "close")
    }
    
    func close() {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func save() {
        if targetField.text!.isEmpty {
            let alertView = UIAlertController(title: "ERROR", message: "Please enter a New Target", preferredStyle: UIAlertControllerStyle.Alert)
            alertView.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: nil))
            self.presentViewController(alertView, animated: true, completion: nil)
        } else {
            UIApplication.sharedApplication().networkActivityIndicatorVisible = true
            let query = PFQuery(className: "Target")
            query.findObjectsInBackgroundWithBlock { (objects, error) in
                if error == nil {
                    for object in objects! {
                        var objectOrder = object["order"] as! Int
                        objectOrder += 1
                        object["order"] = objectOrder
                        object.saveInBackgroundWithBlock {(success, error) in
                            if success {
                                print("target order saved")
                            }
                        }
                    }
                    self.saveTarget()
                }
            }
        }
    }
    
    func saveTarget() {
        let target = PFObject(className: "Target")
        target["title"] = targetField.text!
        target["descript"] = targetDescriptionView.text
        target["priority"] = targetPrioritySegment.selectedSegmentIndex
        target["achieve"] = false
        target["order"] = 0
        let relation = target.relationForKey("user")
        relation.addObject(PFUser.currentUser()!)
        target.saveInBackgroundWithBlock {(success, error) in
            if success {
                print("target saved")
            }
            self.dismissViewControllerAnimated(true, completion: nil)
            UIApplication.sharedApplication().networkActivityIndicatorVisible = false
        }
    }
    
    func tapGesture(sender: UITapGestureRecognizer) {
        targetField.resignFirstResponder()
        targetDescriptionView.resignFirstResponder()
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        targetField.resignFirstResponder()
        return true
    }


    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

}
