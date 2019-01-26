//
//  Person.swift
//  persons
//
//  Created by Marcus Ek on 21/01/2019.
//  Copyright © 2019 Marcus Ekon. All rights reserved.
//

import Foundation
import UIKit

class Person {
    var title: String
    var fname: String
    var lname: String
    
    var gender: String
    
    var email: String
    
    var thumbnail: UIImage
    var thumb_url: String
    var picture: UIImage
    var pic_url: String
    
    var street: String
    var city: String
    var phone: String
    var cell: String
    
    init(email: String) {
        self.email = email
        self.title = ""
        self.fname = ""
        self.lname = ""
        self.gender = ""
        self.thumbnail = UIImage()
        self.thumb_url = ""
        self.picture = UIImage()
        self.pic_url = ""
        self.street = ""
        self.city = ""
        self.phone = ""
        self.cell = ""
    }
    
    var name: String {
        return (self.fname + " " + self.lname).uppercased()
    }
    
    var full_name: String {
        return self.title + ". " + (self.fname + " " + self.lname).uppercased()
    }
}
