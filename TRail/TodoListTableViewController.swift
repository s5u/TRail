
import UIKit
import Parse

class TodoListTableViewController: UITableViewController, TodoCollectionDelegate,UIGestureRecognizerDelegate {
    let todoCollection = TodoCollection.shareInstance
    var target: Target?
    var task: Task?

    override func viewDidLoad() {
        super.viewDidLoad()
        todoCollection.customDelegate = self
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController!.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName: UIColor.whiteColor()]
        self.navigationController!.navigationBar.tintColor = UIColor.whiteColor()
        self.navigationController?.navigationBar.barTintColor = UIColor(red: 0, green: 1, blue: 0, alpha: 1)
        self.navigationController?.navigationBar.translucent = false
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(named: "plus"), style: UIBarButtonItemStyle.Plain, target: self, action: "newTodo")
        self.tableView.reloadData()
        todoCollection.fetchTodos()
        self.taskAchieveJudge(self.task!)
    }
    
    func newTodo() {
        self.performSegueWithIdentifier("PresentNewTodoViewController", sender: self)
    }

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        var rowCount:[Int] = []
        for todo in self.todoCollection.todos {
            if todo.task_id == task?.id {
                rowCount.append(0)
            }
        }
        return rowCount.count
    }

    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let longPressRecognizer = UILongPressGestureRecognizer(target: self, action: "cellLongPressed:")
        longPressRecognizer.delegate = self
        tableView.addGestureRecognizer(longPressRecognizer)
        let cell = UITableViewCell(style: UITableViewCellStyle.Subtitle, reuseIdentifier: "TodoIdentifier")
        var matchedTodos = getMatchTodos()
        let todo = matchedTodos[indexPath.row]
        cell.textLabel?.text = todo.title
        cell.detailTextLabel?.text = todo.descript
        cell.textLabel?.font = UIFont(name: "HirakakuProN-W3", size: 20)
        let priorityIcon = UIView(frame: CGRect(x: 0, y: 0, width: 12, height: 12))
        priorityIcon.layer.cornerRadius = 6
        priorityIcon.backgroundColor = todo.priority.color()
        cell.accessoryView = priorityIcon
        if todo.achieve == true {
            cell.backgroundColor = UIColor(red: 105/255, green: 105/255, blue: 105/255, alpha: 0.7)
        }
        return cell
    }

    
    //swipeでEdit
    override func setEditing(editing: Bool, animated: Bool) {
        super.setEditing(editing, animated: animated)
        tableView.setEditing(editing, animated: animated)
    }
    
    override func tableView(tableView: UITableView, editActionsForRowAtIndexPath indexPath: NSIndexPath) -> [UITableViewRowAction]? {
        //削除
        let delete = UITableViewRowAction(style: .Default, title: "Delete") {
            (action, IndexPath) in
            let todo = self.todoCollection.todos[indexPath.row]
            let todoParse = PFObject(className: "Todo")
            todoParse.objectId = todo.id
            todoParse.deleteInBackground()
            self.todoCollection.todos.removeAtIndex(indexPath.row)
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: UITableViewRowAnimation.Middle)
        }
        return [delete]
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
        let todo = self.todoCollection.todos[sourceIndexPath.row]
        self.todoCollection.todos.removeAtIndex(sourceIndexPath.row)
        self.todoCollection.todos.insert(todo, atIndex: destinationIndexPath.row)
        //Parse側で並べ替え
        for (index, todo) in self.todoCollection.todos.enumerate() {
            let todoParse = PFObject(className: "Todo")
            todoParse.objectId = todo.id
            todoParse["order"] = index
            todoParse.saveInBackground()
        }
        tableView.setEditing(false, animated: true)
    }
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return CGFloat(60)
    }
    
    //TodoDetailへの情報受け渡し用の変数
    var selectedTodo: Todo?
    
    //セルがタップされた時の処理
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        var matchedTodos = getMatchTodos()
        let todo = matchedTodos[indexPath.row]
        selectedTodo = todo
        self.navigationItem.backBarButtonItem = UIBarButtonItem(title: todo.title, style: UIBarButtonItemStyle.Plain, target: self, action: nil)
        performSegueWithIdentifier("TodoDetailViewController", sender: nil)
    }
    
    //遷移先のインスタンスを取得
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "TodoDetailViewController" {
            let todoDetailViewController = segue.destinationViewController as! TodoDetailViewController
            todoDetailViewController.target = target
            todoDetailViewController.task = task
            todoDetailViewController.todo = self.selectedTodo
        } else if segue.identifier == "PresentNewTodoViewController" {
            let navigationController = segue.destinationViewController as! UINavigationController
            let newTodoViewController = navigationController.topViewController as! NewTodoViewController
            newTodoViewController.target = target
            newTodoViewController.task = task
        }
    }
    
    func getMatchTodos() -> Array<Todo> {
        var matchedTodos:[Todo] = []
        for todo in self.todoCollection.todos {
            if todo.task_id == task?.id {
                matchedTodos.append(todo)
            }
        }
        return matchedTodos
    }
    
    func taskAchieveJudge(task: Task) {
        var todos:[Int] = []
        var todosAchieves:[Int] = []
        let todoQuery = PFQuery(className: "Todo")
        todoQuery.whereKey("task_id", containedIn: [task.id])
        todoQuery.findObjectsInBackgroundWithBlock { (objects, error) in
            if error == nil {
                for object in objects! {
                    todos.append(0)
                    if object["achieve"] as! Bool == true {
                        todosAchieves.append(0)
                    }
                }
            }
        }
        let taskQuery = PFQuery(className: "Task")
        taskQuery.getObjectInBackgroundWithId(task.id, block: { (task, error) -> Void in
            if error == nil {
                if todos.count == todosAchieves.count {
                    task!["achieve"] = true
                } else {
                    task!["achieve"] = false
                }
                task!.saveInBackground()
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
