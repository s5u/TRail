
import UIKit
import Parse

class TaskDetailViewController: UIViewController {
    @IBOutlet weak var taskDoneButton: UIButton!
    @IBOutlet weak var checkTodoListButton: UIButton!
    @IBOutlet weak var taskPrioritySegment: UISegmentedControl!
    @IBOutlet weak var taskDescriptionView: UITextView!
    @IBOutlet weak var taskField: UITextField!
    var target: Target?
    var task: Task?

    override func viewDidLoad() {
        taskDescriptionView.layer.cornerRadius = 5
        taskDescriptionView.layer.borderColor = UIColor(red: 0.9, green: 0.9, blue: 0.9, alpha: 1).CGColor
        taskDescriptionView.layer.borderWidth = 1
        checkTodoListButton.layer.cornerRadius = 5
        taskDoneButton.layer.cornerRadius = 5
        super.viewDidLoad()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController!.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName: UIColor.whiteColor()]
        self.navigationController!.navigationBar.tintColor = UIColor.whiteColor()
        self.navigationController?.navigationBar.barTintColor = UIColor(red: 1, green: 165/255, blue: 0, alpha: 1)
        self.navigationController?.navigationBar.translucent = false
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(named: "check"), style: UIBarButtonItemStyle.Plain, target: self, action: "update")
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(image: UIImage(named: "close"), style: UIBarButtonItemStyle.Plain, target: self, action: "close")
        self.navigationItem.title = task?.title
        self.taskField.text = task?.title
        self.taskDescriptionView.text = task?.descript
        self.taskPrioritySegment.selectedSegmentIndex = (task?.priority.rawValue)!
    }
    
    func close() {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func update() {
        if taskField.text!.isEmpty {
            let alertView = UIAlertController(title: "ERROR", message: "Please enter Task Title", preferredStyle: UIAlertControllerStyle.Alert)
            alertView.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: nil))
            self.presentViewController(alertView, animated: true, completion: nil)
        } else {
            UIApplication.sharedApplication().networkActivityIndicatorVisible = true
            let query = PFQuery(className: "Task")
            query.getObjectInBackgroundWithId((task?.id)!, block: { (updateTask, error) -> Void in
                if error == nil {
                    updateTask!["objectId"] = self.task!.id
                    updateTask!["title"] = self.taskField.text!
                    updateTask!["descript"] = self.taskDescriptionView.text
                    updateTask!["priority"] = self.taskPrioritySegment.selectedSegmentIndex
                    updateTask!.saveInBackgroundWithBlock { (success, error) in
                        if success {
                            self.showAlert("Updated!")
                            self.title = self.taskField.text
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
    
    //TodoListへの情報受け渡し用の変数//
    var selectedTarget: Target?
    var selectedTask: Task?

    @IBAction func tapCheckTodoList(sender: UIButton) {
        selectedTarget = target
        selectedTask = task
        self.performSegueWithIdentifier("TodoListTableViewController", sender: nil)
    }
    
    //遷移先のインスタンスを取得
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "TodoListTableViewController" {
            let todoListTableViewController = segue.destinationViewController as! TodoListTableViewController
            todoListTableViewController.target = self.selectedTarget
            todoListTableViewController.task = self.selectedTask
        }
    }
    
    @IBAction func tapTodoDoneButton(sender: UIButton) {
        UIApplication.sharedApplication().networkActivityIndicatorVisible = true
        let query = PFQuery(className: "Task")
        query.getObjectInBackgroundWithId((task?.id)!, block: { (doneTask, error) -> Void in
            if error == nil {
                doneTask!["objectId"] = self.task!.id
                doneTask!["achieve"] = self.task?.achieve == false
                doneTask!.saveInBackgroundWithBlock { (success, error) in
                    if success {
                        if doneTask!["achieve"] as? Bool == true {
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
