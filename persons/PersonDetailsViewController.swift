//
//  PersonDetailsViewController.swift
//  persons
//
//  Created by Marcus Ek on 26/01/2019.
//  Copyright © 2019 Marcus Ekon. All rights reserved.
//

import UIKit

class PersonDetailsViewController: UIViewController {
    
    @IBOutlet weak var picture: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var telLabel: UILabel!
    @IBOutlet weak var addressLabel: UILabel!
    @IBOutlet weak var emailLabel: UILabel!
    
    var person: Person?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let screenSize: CGRect = UIScreen.main.bounds
        picture.frame = CGRect(x: 0, y: 0, width: 100, height: screenSize.height * 0.2)

        if let person = person {
            let pic_url: URL = URL(string: person.pic_url)!
            
            let imageData:NSData = NSData(contentsOf: pic_url)!
            
            person.picture = UIImage(data: imageData as Data)!
            
            picture.image = person.picture
            nameLabel.text = person.full_name
            telLabel.text = person.tel
            emailLabel.text = person.email
            addressLabel.text = person.address
        }
    }

}
