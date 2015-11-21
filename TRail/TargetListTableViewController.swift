
import UIKit
import Parse


class TargetListTableViewController: UITableViewController, TargetCollectionDelegate, UIGestureRecognizerDelegate {
    let targetCollection = TargetCollection.sharedInstance
    
    override func viewDidLoad() {
        super.viewDidLoad()
        targetCollection.customDelegate = self
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController!.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName: UIColor.whiteColor()]
        self.navigationController!.navigationBar.tintColor = UIColor.whiteColor()
        self.navigationController?.navigationBar.barTintColor = UIColor(red: 0, green: 191/255, blue: 255/255, alpha: 1)
        self.navigationController?.navigationBar.translucent = false
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(image: UIImage(named: "logout"), style: UIBarButtonItemStyle.Plain, target: self, action: "logout")
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(named: "plus"), style: UIBarButtonItemStyle.Plain, target: self, action: "newTarget")
        self.tableView.reloadData()
        targetCollection.fetchTargets()
    }
    
    func newTarget() {
        self.performSegueWithIdentifier("PresentNewTargetViewController", sender: self)
    }

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.targetCollection.targets.count
    }


    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let longPressRecognizer = UILongPressGestureRecognizer(target: self, action: "cellLongPressed:")
        longPressRecognizer.delegate = self
        tableView.addGestureRecognizer(longPressRecognizer)
        let cell  = UITableViewCell(style: UITableViewCellStyle.Subtitle, reuseIdentifier: "TargetIdentifier")
        let target = self.targetCollection.targets[indexPath.row]
        cell.textLabel?.text = target.title
        cell.detailTextLabel?.text = target.descript
        cell.textLabel?.font = UIFont(name: "HirakakuProN-W3", size: 20)
        let priorityIcon = UIView(frame: CGRect(x: 0, y: 0, width: 12, height: 12))
        priorityIcon.layer.cornerRadius = 6
        priorityIcon.backgroundColor = target.priority.color()
        cell.accessoryView = priorityIcon
        if target.achieve == true {
            cell.backgroundColor = UIColor(red: 105/255, green: 105/255, blue: 105/255, alpha: 0.7)
        }
        return cell
    }

    //swipeでEdit
    override func setEditing(editing: Bool, animated: Bool) {
        super.setEditing(editing, animated: animated)
        tableView.setEditing(editing, animated: animated)
    }
    
    //TagetDetailへの情報受け渡し用の変数
    var selectedTarget: Target?
    
    override func tableView(tableView: UITableView, editActionsForRowAtIndexPath indexPath: NSIndexPath) -> [UITableViewRowAction]? {
        //編集
        let edit = UITableViewRowAction(style: .Normal, title: "Edit") {
            (action, indexPath) in
            let target = self.targetCollection.targets[indexPath.row]
            self.selectedTarget = target
            self.performSegueWithIdentifier("TargetDetailViewController", sender: nil)
            self.tableView.reloadRowsAtIndexPaths([indexPath], withRowAnimation: .Automatic)
        }
        edit.backgroundColor = UIColor(red: 211/255, green: 211/255, blue: 211/255, alpha: 1)
        
        //削除
        let delete = UITableViewRowAction(style: .Default, title: "Delete") {
            (action, indexpath) in
            let target = self.targetCollection.targets[indexPath.row]
            let targetParse = PFObject(className: "Target")
            targetParse.objectId = target.id
            targetParse.deleteInBackground()
            self.targetCollection.targets.removeAtIndex(indexPath.row)
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: UITableViewRowAnimation.Middle)
            
            //紐づくTaskとTodoを削除
            let taskQuery = PFQuery(className: "Task")
            let todoQuery = PFQuery(className: "Todo")
            taskQuery.findObjectsInBackgroundWithBlock({ (objects, error) in
                if error == nil {
                    for object in objects! {
                        if object["target_id"] as? String == target.id {
                            object.deleteInBackground()
                        }
                    }
                }
            })
            todoQuery.findObjectsInBackgroundWithBlock({ (objects, error) in
                if error == nil {
                    for object in objects! {
                        if object["target_id"] as? String == target.id {
                            object.deleteInBackground()
                        }
                    }
                }
            })
        }
        delete.backgroundColor = UIColor.redColor()
        
        return [edit, delete]
    }
    
    //セルが長押しされた時の処理
    func cellLongPressed(recognizer: UILongPressGestureRecognizer) {
        let point = recognizer.locationInView(tableView)
        let indexPath = tableView.indexPathForRowAtPoint(point)
    
        if indexPath == nil {
            
        } else if recognizer.state == UIGestureRecognizerState.Began {
            tableView.setEditing(true, animated: true)
        }
    }
    
    override func tableView(tableView: UITableView, moveRowAtIndexPath sourceIndexPath: NSIndexPath, toIndexPath destinationIndexPath: NSIndexPath) {
        //アプリ側で並べ替え
        let target = self.targetCollection.targets[sourceIndexPath.row]
        self.targetCollection.targets.removeAtIndex(sourceIndexPath.row)
        self.targetCollection.targets.insert(target, atIndex: destinationIndexPath.row)
        //Parse側で並べ替え
        for (index, target) in self.targetCollection.targets.enumerate() {
            let targetParse = PFObject(className: "Target")
            targetParse.objectId = target.id
            targetParse["order"] = index
            targetParse.saveInBackground()
        }
        tableView.setEditing(false, animated: true)
    }
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return CGFloat(60)
    }
    
    
    //セルがタップされた時の処理
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let target = self.targetCollection.targets[indexPath.row]
        selectedTarget = target
        self.navigationItem.backBarButtonItem = UIBarButtonItem(title: target.title, style: UIBarButtonItemStyle.Plain, target: self, action: nil)
        performSegueWithIdentifier("TaskListTableViewControllerFromTargetList", sender: nil)
    }
    
    //遷移先のインスタンスを取得
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
            if segue.identifier == "TargetDetailViewController" {
                let navigationController = segue.destinationViewController as! UINavigationController
                let targetDetailViewController = navigationController.topViewController as! TargetDetailViewController
                targetDetailViewController.target = self.selectedTarget
            } else if segue.identifier == "TaskListTableViewControllerFromTargetList" {
                let taskListTableViewController = segue.destinationViewController as! TaskListTableViewController
                taskListTableViewController.target = self.selectedTarget
        }
    }
    
    func logout() {
        PFUser.logOut()
        performSegueWithIdentifier("modalLoginViewController", sender: self)
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        if PFUser.currentUser() == nil {
            performSegueWithIdentifier("modalLoginViewController", sender: self)
        }
    }
    
    
    func didFinishedFetchData() {
         self.tableView.reloadData()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }



}
