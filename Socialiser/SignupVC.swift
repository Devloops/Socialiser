//
//  SignupVC.swift
//  Socialiser
//
//  Created by Amr Sami on 2/9/16.
//  Copyright © 2016 Amr Sami. All rights reserved.
//

import UIKit
import Firebase
import Alamofire

class SignupVC: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UITextFieldDelegate {
    
    @IBOutlet weak var profileImg: RoundedImage!
    @IBOutlet weak var usernameField: MaterialTextField!
    
    var isImageSelected = false
    
    var imagePicker: UIImagePickerController!
    
    var activityIndicator = UIActivityIndicatorView()

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        
        usernameField.delegate = self
    }
    
    @IBAction func onSignupBtnPressed(sender: MaterialButton) {
        if let username = usernameField.text where usernameField != "", let profile = profileImg.image where isImageSelected == true {
            showActivityIndicator()
            let urlStr = "https://post.imageshack.us/upload_api.php"
            let url = NSURL(string: urlStr)!
            let imgData = UIImageJPEGRepresentation(profile, 0.2)!
            let keyData = "12DJKPSU5fc3afbd01b1630cc718cae3043220f3".dataUsingEncoding(NSUTF8StringEncoding)!
            let keyJSON = "json".dataUsingEncoding(NSUTF8StringEncoding)!
            
            
            Alamofire.upload(.POST, url, multipartFormData: { multipartFormData in
                
                multipartFormData.appendBodyPart(data: imgData, name:"fileupload", fileName:"image", mimeType: "image/jpg")
                multipartFormData.appendBodyPart(data: keyData, name: "key")
                multipartFormData.appendBodyPart(data: keyJSON, name: "format")
                
                }) { encodingResult in
                    
                    switch encodingResult {
                    case .Success(let upload, _, _):
                        upload.responseJSON(completionHandler: { response in
                            if let info = response.result.value as? Dictionary<String, AnyObject> {
                                
                                if let links = info["links"] as? Dictionary<String, AnyObject> {
                                    if let imgLink = links["image_link"] as? String {
                                        DataService.ds.REF_USER_CURRENT.childByAppendingPath("username").setValue(username)
                                        DataService.ds.REF_USER_CURRENT.childByAppendingPath("profileImageUrl").setValue(imgLink)
                                        self.stopActivityIndicator()
                                        self.performSegueWithIdentifier(SEGUE_SIGN_UP_DONE, sender: nil)
                                    }
                                }
                            }
                        })
                        
                    case .Failure(let error):
                        print(error)
                        self.showErrorAlert("Error Happend", msg: "There is error happend please try again")
                        self.stopActivityIndicator()
                    }
                    
            }
        } else {
            showErrorAlert("Username and Profile Picture Required", msg: "You must enter a Username and choose your Profile Picture")
            stopActivityIndicator()
        }
        
        
    }
    
    func showErrorAlert(title: String, msg: String) {
        let alert = UIAlertController(title: title, message: msg, preferredStyle: .Alert)
        let action = UIAlertAction(title: "OK", style: .Default, handler: nil)
        alert.addAction(action)
        self.presentViewController(alert, animated: true, completion: nil)
    }

    @IBAction func selectProfileImage(sender: UITapGestureRecognizer) {
        presentViewController(imagePicker, animated: true, completion: nil)
    }
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingImage image: UIImage, editingInfo: [String : AnyObject]?) {
        imagePicker.dismissViewControllerAnimated(true, completion: nil)
        profileImg.image = image
        isImageSelected = true
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
