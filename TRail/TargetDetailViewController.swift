
import UIKit
import Parse

class TargetDetailViewController: UIViewController {
    @IBOutlet weak var checkTaskListButton: UIButton!
    @IBOutlet weak var targetPrioritySegment: UISegmentedControl!
    @IBOutlet weak var targetDescriptionView: UITextView!
    @IBOutlet weak var targetField: UITextField!
    var target: Target?

    override func viewDidLoad() {
        targetDescriptionView.layer.cornerRadius = 5
        targetDescriptionView.layer.borderColor = UIColor(red: 0.9, green: 0.9, blue: 0.9, alpha: 1).CGColor
        targetDescriptionView.layer.borderWidth = 1
        checkTaskListButton.layer.cornerRadius = 5
        super.viewDidLoad()

    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController!.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName: UIColor.whiteColor()]
        self.navigationController!.navigationBar.tintColor = UIColor.whiteColor()
        self.navigationController?.navigationBar.barTintColor = UIColor(red: 0, green: 191/255, blue: 1, alpha: 1)
        self.navigationController?.navigationBar.translucent = false
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(named: "check"), style: UIBarButtonItemStyle.Plain, target: self, action: "update")
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(image: UIImage(named: "close"), style: UIBarButtonItemStyle.Plain, target: self, action: "close")
        self.navigationItem.title = target?.title
        self.targetField.text = target?.title
        self.targetDescriptionView.text = target?.descript
        self.targetPrioritySegment.selectedSegmentIndex = (target?.priority.rawValue)!
    }
    
    func close() {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    
    func update() {
        if targetField.text!.isEmpty {
            let alertView = UIAlertController(title: "ERROR", message: "Please enter Target Title", preferredStyle: UIAlertControllerStyle.Alert)
            alertView.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: nil))
            self.presentViewController(alertView, animated: true, completion: nil)
        } else {
            UIApplication.sharedApplication().networkActivityIndicatorVisible = true
            let query = PFQuery(className: "Target")
            query.getObjectInBackgroundWithId((target?.id)!, block: { (updateTarget, error) -> Void in
                if error == nil {
                    updateTarget!["objectId"] = self.target!.id
                    updateTarget!["title"] = self.targetField.text!
                    updateTarget!["descript"] = self.targetDescriptionView.text
                    updateTarget!["priority"] = self.targetPrioritySegment.selectedSegmentIndex
                    updateTarget!.saveInBackgroundWithBlock {(success, error) in
                        if success {
                            print("Updated!")
                            self.showAlert("Updated!")
                            self.title = self.targetField.text
                            
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
    
    //TaskListへの情報受け渡し用の変数
    var selectedTarget: Target?
    
    
    //ボタンを押した時の処理
    @IBAction func tapCheckTaskListButton(sender: UIButton) {
        selectedTarget = target
        self.performSegueWithIdentifier("TaskListTableViewController", sender: nil)
    }

    //遷移先のインスタンスを取得
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "TaskListTableViewController" {
            let taskListTableViewController = segue.destinationViewController as! TaskListTableViewController
            taskListTableViewController.target = self.selectedTarget
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}
