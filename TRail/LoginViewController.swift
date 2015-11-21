
import UIKit

class LoginViewController: UIViewController {
    @IBOutlet weak var signUpButton: UIButton!
    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var nameTextField: UITextField!

    override func viewDidLoad() {
        super.viewDidLoad()

    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController!.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName: UIColor.whiteColor()]
        self.navigationController?.navigationBar.barTintColor = UIColor(red: 30/255, green: 80/255, blue: 162/255, alpha: 1)
        self.navigationController?.navigationBar.translucent = false
        passwordTextField.secureTextEntry = true
        loginButton.layer.cornerRadius = 5
        signUpButton.layer.cornerRadius = 5
    
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func tapSignUpButton(sender: UIButton) {
        let user = User(name: nameTextField.text!, password: passwordTextField.text!)
        user.signUp { (message) in
            if let unwrappedMessage = message {
                self.showAlert(unwrappedMessage)
                print("サインアップ失敗")
            } else {
                self.dismissViewControllerAnimated(true, completion: nil)
                print("サインアップ成功")
            }
        }
    }
    
    @IBAction func tapLoginButton(sender: UIButton) {
        let user = User(name: nameTextField.text!, password: passwordTextField.text!)
        user.login { (message) in
            if let unwrappedMessage = message {
                self.showAlert(unwrappedMessage)
            } else {
                self.dismissViewControllerAnimated(true, completion: nil)
            }
        }
    }
    
    func showAlert(message: String?) {
        let alertController = UIAlertController(title: "ERROR", message: message, preferredStyle: .Alert)
        let action = UIAlertAction(title: "OK", style: .Default, handler: nil)
        alertController.addAction(action)
        presentViewController(alertController, animated: true, completion: nil)
    }
    
    
}
