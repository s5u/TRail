
import UIKit
import Parse

class TodoDetailViewController: UIViewController {
    @IBOutlet weak var todoDoneButton: UIButton!
    @IBOutlet weak var todoPrioritySegment: UISegmentedControl!
    @IBOutlet weak var todoDescriptionView: UITextView!
    @IBOutlet weak var todoField: UITextField!
    var target: Target?
    var task: Task?
    var todo: Todo?

    override func viewDidLoad() {
        todoDescriptionView.layer.cornerRadius = 5
        todoDescriptionView.layer.borderColor = UIColor(red: 0.9, green: 0.9, blue: 0.9, alpha: 1).CGColor
        todoDescriptionView.layer.borderWidth = 1
        todoDoneButton.layer.cornerRadius = 5
        super.viewDidLoad()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController!.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName: UIColor.whiteColor()]
        self.navigationController!.navigationBar.tintColor = UIColor.whiteColor()
        self.navigationController?.navigationBar.barTintColor = UIColor(red: 0, green: 1, blue: 0, alpha: 1)
        self.navigationController?.navigationBar.translucent = false
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(named: "check"), style: UIBarButtonItemStyle.Plain, target: self, action: "update")
        self.navigationItem.title = todo?.title
        self.todoField.text = todo?.title
        self.todoDescriptionView.text = todo?.descript
        self.todoPrioritySegment.selectedSegmentIndex = (todo?.priority.rawValue)!
    }
    
    func update() {
        if todoField.text!.isEmpty {
            let alertView = UIAlertController(title: "ERROR", message: "Please enter Todo Title", preferredStyle: UIAlertControllerStyle.Alert)
            alertView.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: nil))
            self.presentViewController(alertView, animated: true, completion: nil)
        } else {
            UIApplication.sharedApplication().networkActivityIndicatorVisible = true
            let query = PFQuery(className: "Todo")
            query.getObjectInBackgroundWithId((todo?.id)!, block: { (updateTodo, error) -> Void in
                if error == nil {
                    updateTodo!["objectId"] = self.todo!.id
                    updateTodo!["title"] = self.todoField.text!
                    updateTodo!["descript"] = self.todoDescriptionView.text
                    updateTodo!["priority"] = self.todoPrioritySegment.selectedSegmentIndex
                    updateTodo!.saveInBackgroundWithBlock { (success, error) in
                        if success {
                            self.showAlert("Updated!")
                            self.title = self.todoField.text
                        }
                        UIApplication.sharedApplication().networkActivityIndicatorVisible = false
                    }
                }
            })
        }
    }
    
    func showAlert(text: String){
        let alertController = UIAlertController(title: text, message: nil , preferredStyle: UIAlertControllerStyle.Alert)
        let action = UIAlertAction(title: "OK", style: UIAlertActionStyle.Default) { (action) -> Void in
        //self.backgroundView.removeFromSuperview()
        }
        alertController.addAction(action)
        self.presentViewController(alertController, animated: true, completion: nil)
    }
    
    @IBAction func tapTodoDoneButton(sender: UIButton) {
        UIApplication.sharedApplication().networkActivityIndicatorVisible = true
        let query = PFQuery(className: "Todo")
        query.getObjectInBackgroundWithId((todo?.id)!, block: { (doneTodo, error) -> Void in
            if error == nil {
                doneTodo!["objectId"] = self.todo!.id
                doneTodo!["achieve"] = self.todo?.achieve == false
                doneTodo!.saveInBackgroundWithBlock { (success, error) in
                    if success {
                        if doneTodo!["achieve"] as? Bool == true {
                            self.showAlert("Done!")
                        }
                    }
                }
            }
        })
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}
