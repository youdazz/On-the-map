//
//  ViewController.swift
//  On the Map
//
//  Created by Youda Zhou on 20/5/24.
//

import UIKit

class LoginViewController: UIViewController {
    
    // MARK: IOBoutlets
    
    @IBOutlet weak var usernameTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    // MARK: Properties

    
    // MARK: functions
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        activityIndicator.isHidden = true
    }
    
    func showErrorLogin(message: String) {
        showAlertController(title: "Login failed", message: message, actions: [.init(title: "Cancel", style: .default)])
    }
    
    func setLoggingIn(_ loggingIn: Bool) {
        loggingIn ? activityIndicator.startAnimating() : activityIndicator.stopAnimating()
        activityIndicator.isHidden = !loggingIn
        usernameTextField.isEnabled = !loggingIn
        passwordTextField.isEnabled = !loggingIn
        loginButton.isEnabled = !loggingIn
    }

    // MARK: actions
    
    @IBAction func loginPressed() {
        setLoggingIn(true)
        let username = usernameTextField.text ?? ""
        let password = passwordTextField.text ?? ""
        UdacityClient.login(username: username, password: password, completion: handleLoginResponse(success:error:))
    }
    
    func handleLoginResponse(success: Bool, error: Error?) {
        setLoggingIn(false)
        if success {
            self.performSegue(withIdentifier: "completeLogin", sender: nil)
        } else {
            showErrorLogin(message: error?.localizedDescription ?? "Unkown Error")
        }
    }
    
}

