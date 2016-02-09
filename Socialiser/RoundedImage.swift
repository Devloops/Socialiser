//
//  RoundedImage.swift
//  Socialiser
//
//  Created by Amr Sami on 2/9/16.
//  Copyright © 2016 Amr Sami. All rights reserved.
//

import UIKit

class RoundedImage: UIImageView {
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.layer.cornerRadius = frame.size.width / 2
        clipsToBounds = true
    }

}
