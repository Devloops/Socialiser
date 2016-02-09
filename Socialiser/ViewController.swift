//
//  ViewController.swift
//  Socialiser
//
//  Created by Amr Sami on 2/7/16.
//  Copyright © 2016 Amr Sami. All rights reserved.
//

import UIKit
import FBSDKCoreKit
import FBSDKLoginKit
import Firebase

class ViewController: UIViewController, UITextFieldDelegate {
    
    @IBOutlet weak var emailField: UITextField!
    @IBOutlet weak var passwordField: UITextField!
    
    var activityIndicator = UIActivityIndicatorView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        emailField.delegate = self
        passwordField.delegate = self
    }
    
    override func viewDidAppear(animated: Bool) {
        if NSUserDefaults.standardUserDefaults().valueForKey(KEY_UID) != nil {
            self.performSegueWithIdentifier(SEGUE_LOGGED_IN, sender: nil)
        }
    }
    
    @IBAction func onFbBtnPressed(sender: UIButton!) {
        let facebookLogin = FBSDKLoginManager()
        showActivityIndicator()
        facebookLogin.logInWithReadPermissions(["email"], fromViewController: self) { (facebookResult: FBSDKLoginManagerLoginResult!, facebookError: NSError!) -> Void in
            if facebookError != nil {
                self.showErrorAlert("Facebook Login Faild", msg: "Facebook Login Faild, Please try again")
                self.stopActivityIndicator()
            } else {
                let accessToken = FBSDKAccessToken.currentAccessToken().tokenString
                
                DataService.ds.REF_BAE.authWithOAuthProvider("facebook", token: accessToken, withCompletionBlock: { error, authData in
                    
                    if error != nil {
                        print("login faild, \(error)")
                    } else {
                        print("Logged in \(authData)")
                        
                        let user = ["provider": authData.provider!]
                        
                        DataService.ds.REF_USERS.childByAppendingPath(authData.uid).observeSingleEventOfType(.Value, withBlock:{ snapshot in
                            if snapshot.value is NSNull {
                                self.performSegueWithIdentifier(SEGUE_SIGN_UP, sender: nil)
                                DataService.ds.createFirebaseUser(authData.uid, user: user)
                            } else {
                                self.performSegueWithIdentifier(SEGUE_LOGGED_IN, sender: nil)
                                DataService.ds.createFirebaseUser(authData.uid, user: user)
                            }
                        })
                        
                        NSUserDefaults.standardUserDefaults().setValue(authData.uid, forKey: KEY_UID)
                        self.stopActivityIndicator()
                    }
                    
                })
            }
        }

    }
    
    @IBAction func onEmailBtnPressed(sender: UIButton) {
        if let email = emailField.text where email != "", let pwd = passwordField.text where pwd != "" {
            showActivityIndicator()
            DataService.ds.REF_BAE.authUser(email, password: pwd, withCompletionBlock: { error, authData in
                if error != nil {
                    if error.code == STATUS_ACCOUNT_NONEXIST {
                        DataService.ds.REF_BAE.createUser(email, password: pwd, withValueCompletionBlock: { error, result in
                            if error != nil {
                                self.showErrorAlert("Could not create accout", msg: "problem creating account. Try something else")
                            } else {
                                NSUserDefaults.standardUserDefaults().setValue(result[KEY_UID], forKey: KEY_UID)
                                
                                DataService.ds.REF_BAE.authUser(email, password: pwd, withCompletionBlock: { err, authData in
                                    let user = ["provider": authData.provider!]
                                    DataService.ds.createFirebaseUser(authData.uid, user: user)
                                })
                                self.stopActivityIndicator()
                                self.performSegueWithIdentifier(SEGUE_SIGN_UP, sender: nil)
                            }
                        })
                    } else {
                        self.showErrorAlert("Could not login", msg: "Please check your Email and Password")
                    }
                } else {
                    self.performSegueWithIdentifier(SEGUE_LOGGED_IN, sender: nil)
                }
            })
            
        } else {
            showErrorAlert("Email and Password Required", msg: "You must enter an Email and a Password")
            self.stopActivityIndicator()
        }
    }
    
    func showErrorAlert(title: String, msg: String) {
        let alert = UIAlertController(title: title, message: msg, preferredStyle: .Alert)
        let action = UIAlertAction(title: "OK", style: .Default, handler: nil)
        alert.addAction(action)
        self.presentViewController(alert, animated: true, completion: nil)
    }
    
    func showActivityIndicator() {
        activityIndicator = UIActivityIndicatorView(frame: CGRectMake(0, 0, 50, 50))
        activityIndicator.center = view.center
        activityIndicator.hidesWhenStopped = true
        activityIndicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyle.Gray
        view.addSubview(activityIndicator)
        activityIndicator.startAnimating()
    }
    
    func stopActivityIndicator() {
        activityIndicator.stopAnimating()
    }
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        view.endEditing(true)
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }


}

