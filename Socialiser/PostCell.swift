//
//  PostCell.swift
//  Socialiser
//
//  Created by Amr Sami on 2/7/16.
//  Copyright © 2016 Amr Sami. All rights reserved.
//

import UIKit
import Alamofire
import Firebase

class PostCell: UITableViewCell {
    
    @IBOutlet weak var profileImg: RoundedImage!
    @IBOutlet weak var socialiserImg: UIImageView!
    @IBOutlet weak var descriptionText: UITextView!
    @IBOutlet weak var likesLbl: UILabel!
    @IBOutlet weak var likeImg: UIImageView!
    @IBOutlet weak var usernameLbl: UILabel!
    
    var post: Post!
    
    var request: Request?
    var profileRequest: Request?
    
    var likeRef: Firebase!
    var userRef: Firebase!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        let tap = UITapGestureRecognizer(target: self, action: "likeTapped:")
        tap.numberOfTapsRequired = 1
        likeImg.addGestureRecognizer(tap)
        likeImg.userInteractionEnabled = true
    }

    override func drawRect(rect: CGRect) {
        
        socialiserImg.clipsToBounds = true
    }
    
    func configerCell(post: Post, user: User, img: UIImage?, profImg: UIImage?) {

        self.post = post
        self.likeRef = DataService.ds.REF_USER_CURRENT.childByAppendingPath("likes").childByAppendingPath(post.postKey)
        self.descriptionText.text = post.postDescription
        self.likesLbl.text = "\(post.likes)"
        
        
        if post.imageUrl != nil {
            
            if img != nil {
                self.socialiserImg.image = img
            } else {
                request = Alamofire.request(.GET, post.imageUrl!).validate(contentType: ["image/*"]).response(completionHandler: { (request, response, data, error) -> Void in
                    
                    if error == nil {
                        let img = UIImage(data: data!)!
                        self.socialiserImg.image = img
                        FeedVC.imageCache.setObject(img, forKey: self.post.imageUrl!)
                    }
                })
            }
            
        } else {
            self.socialiserImg.hidden = true
        }
        
        user.downloadUserData { () -> () in
            self.usernameLbl.text = user.username
            if profImg != nil {
                self.profileImg.image = profImg
            } else {
                self.profileRequest = Alamofire.request(.GET, user.profileImageUrl).validate(contentType: ["image/*"]).response(completionHandler: { (request, response, data, error) -> Void in
                    
                    if error == nil {
                        let img = UIImage(data: data!)!
                        self.profileImg.image = img
                        FeedVC.imageCache.setObject(img, forKey: user.profileImageUrl)
                    }
                })
                
            }

        }
        
        
        likeRef.observeSingleEventOfType(.Value, withBlock: { snapshot in
            if snapshot.value is NSNull {
                //this is mean you have not liked this specific post
                self.likeImg.image = UIImage(named: "heart-empty")
            } else {
                self.likeImg.image = UIImage(named: "heart-full")
            }
        })
    }
    
    func likeTapped (sender: UITapGestureRecognizer)  {
        
        likeRef.observeSingleEventOfType(.Value, withBlock: { snapshot in
            if snapshot.value is NSNull {
                //this is mean you have not liked this specific post
                self.likeImg.image = UIImage(named: "heart-full")
                self.post.adjustLikes(true)
                self.likeRef.setValue(true)
            } else {
                self.likeImg.image = UIImage(named: "heart-empty")
                self.post.adjustLikes(false)
                self.likeRef.removeValue()
            }
        })

        
    }
}
