
import UIKit
import Parse

class TaskListTableViewController: UITableViewController, TaskCollectionDelegate,UIGestureRecognizerDelegate {
    let taskCollection = TaskCollection.sharedInstance
    var target: Target?


    override func viewDidLoad() {
        super.viewDidLoad()
        taskCollection.customDelegate = self
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController!.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName: UIColor.whiteColor()]
        self.navigationController!.navigationBar.tintColor = UIColor.whiteColor()
        self.navigationController?.navigationBar.barTintColor = UIColor(red: 1, green: 165/255, blue: 0, alpha: 1)
        self.navigationController?.navigationBar.translucent = false
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(named: "plus"), style: UIBarButtonItemStyle.Plain, target: self, action: "newTask")
        self.tableView.reloadData()
        taskCollection.fetchTasks()
        self.targetAchieveJudge(self.target!)
    }
    
    func newTask() {
        self.performSegueWithIdentifier("PresentNewTaskViewController", sender: self)
    }

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        var rowCount:[Int] = []
        for task in self.taskCollection.tasks {
            if task.target_id == target?.id {
                rowCount.append(0)
            }
        }
        return rowCount.count
    }

    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let longPressRecognizer = UILongPressGestureRecognizer(target: self, action: "cellLongPressed:")
        longPressRecognizer.delegate = self
        tableView.addGestureRecognizer(longPressRecognizer)
        let cell = UITableViewCell(style: UITableViewCellStyle.Subtitle, reuseIdentifier: "TaskIdentifier")
        var matchedTasks = getMatchTask()
        let task = matchedTasks[indexPath.row]
        cell.textLabel?.text = task.title
        cell.detailTextLabel?.text = task.descript
        cell.textLabel?.font = UIFont(name: "HirakakuProN-W3", size: 20)
        let priorityIcon = UIView(frame: CGRect(x: 0, y: 0, width: 12, height: 12))
        priorityIcon.layer.cornerRadius = 6
        priorityIcon.backgroundColor = task.priority.color()
        cell.accessoryView = priorityIcon
        if task.achieve == true {
            cell.backgroundColor = UIColor(red: 105/255, green: 105/255, blue: 105/255, alpha: 0.7)
        }
        return cell
    }
    
    //swipeでEdit
    override func setEditing(editing: Bool, animated: Bool) {
        super.setEditing(editing, animated: animated)
        tableView.setEditing(editing, animated: animated)
    }
    
    //TaskList,TaskDetailへの情報受け渡し用の変数
    var selectedTarget: Target?
    var selectedTask: Task?
    
    
    override func tableView(tableView: UITableView, editActionsForRowAtIndexPath indexPath: NSIndexPath) -> [UITableViewRowAction]? {
        //編集
        let edit = UITableViewRowAction(style: .Normal, title: "Edit") {
            (action, indexPath) in
            let task = self.taskCollection.tasks[indexPath.row]
            self.selectedTask = task
            self.performSegueWithIdentifier("TaskDetailViewController", sender: nil)
        }
        edit.backgroundColor = UIColor(red: 211/255, green: 211/255, blue: 211/255, alpha: 1)
        
        //削除
        let delete = UITableViewRowAction(style: .Default, title: "Delete") {
            (action, indexpath) in
            let task = self.taskCollection.tasks[indexPath.row]
            let taskParse = PFObject(className: "Task")
            taskParse.objectId = task.id
            taskParse.deleteInBackground()
            self.taskCollection.tasks.removeAtIndex(indexPath.row)
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: UITableViewRowAnimation.Middle)
            
            //紐づくTodoを削除
            let todoQuery = PFQuery(className: "Todo")
            todoQuery.findObjectsInBackgroundWithBlock({ (objects, error) in
                if error == nil {
                    for object in objects! {
                        if object["task_id"] as? String == task.id {
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
        let task = self.taskCollection.tasks[sourceIndexPath.row]
        self.taskCollection.tasks.removeAtIndex(sourceIndexPath.row)
        self.taskCollection.tasks.insert(task, atIndex: destinationIndexPath.row)
        //Parse側で並べ替え
        for (index, task) in self.taskCollection.tasks.enumerate() {
            let taskParse = PFObject(className: "Task")
            taskParse.objectId = task.id
            taskParse["order"] = index
            taskParse.saveInBackground()
        }
        tableView.setEditing(false, animated: true)
    }
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return CGFloat(60)
    }

    
    //セルがタップされた時の処理
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        var matchedTasks = getMatchTask()
        let task = matchedTasks[indexPath.row]
        selectedTarget = target
        selectedTask = task
        self.navigationItem.backBarButtonItem = UIBarButtonItem(title: task.title, style: UIBarButtonItemStyle.Plain, target: self, action: nil)
        performSegueWithIdentifier("TodoListTableViewControllerFromTaskList", sender: nil)
    }
    
   //遷移先のインスタンスを取得
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "TaskDetailViewController" {
            let navigationController = segue.destinationViewController as! UINavigationController
            let taskDetailViewController = navigationController.topViewController as! TaskDetailViewController
            taskDetailViewController.target = target
            taskDetailViewController.task = self.selectedTask
        } else if segue.identifier == "PresentNewTaskViewController" {
            let navigationController = segue.destinationViewController as! UINavigationController
            let newTaskViewController = navigationController.topViewController as! NewTaskViewController
            newTaskViewController.target = target
        } else if segue.identifier == "TodoListTableViewControllerFromTaskList" {
            let todoListTableViewController = segue.destinationViewController as! TodoListTableViewController
            todoListTableViewController.target = self.selectedTarget
            todoListTableViewController.task = self.selectedTask
        }
    }

    func getMatchTask() -> Array<Task> {
        var matchedTasks:[Task] = []
        for task in self.taskCollection.tasks {
            if task.target_id == target?.id {
                matchedTasks.append(task)
            }
        }
        return matchedTasks
    }
    
    func targetAchieveJudge(target: Target) {
        var tasks:[Int] = []
        var tasksAchieves:[Int] = []
        let taskQuery = PFQuery(className: "Task")
        taskQuery.whereKey("target_id", containedIn: [target.id])
        taskQuery.findObjectsInBackgroundWithBlock { (objects, error) in
            if error == nil {
                for object in objects! {
                    tasks.append(0)
                    if object["achieve"] as! Bool == true {
                        tasksAchieves.append(0)
                    }
                }
            }
        }
        let targetQuery = PFQuery(className: "Target")
        targetQuery.getObjectInBackgroundWithId(target.id, block: { (target, error) -> Void in
            if error == nil {
                if tasks.count == tasksAchieves.count {
                    target!["achieve"] = true
                } else {
                    target!["achieve"] = false
                }
                target!.saveInBackground()
            }
        })
    }
    
    func didFinishedFetchData() {
        self.tableView.reloadData()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}
