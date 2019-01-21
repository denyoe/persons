//
//  ViewController.swift
//  persons
//
//  Created by Marcus Ek on 21/01/2019.
//  Copyright © 2019 Marcus Ekon. All rights reserved.
//

import UIKit

class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    
    
    var persons = [Person]()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        loadContacts(endpoint: "https://randomuser.me/api/?results=23&seed=ekon")
    }
    
    private func loadContacts(endpoint: String) {
        
        guard let url = URL(string: endpoint) else {
            print("Error: invalid url")
            return
        }
        
        let urlRequest = URLRequest(url: url)
        
        let session = URLSession.shared
        
        let task = session.dataTask(with: urlRequest) { data, response, error in
            // check for errors
            guard error  == nil else {
                print("Error retrieving contacts")
                print(error!)
                return
            }
            
            // check data
            guard let responseData = data else {
                print("Error: no data received")
                return
            }
            
            // parse JSON result
            do {
                guard let responseJSON = try JSONSerialization.jsonObject(with: responseData, options: [])
                    as? [String: Any] else {
                        print("Error parsing response")
                        return
                }
                
                guard let contacts = responseJSON["results"] as? [[String: Any]] else { return }
                
                for contact in contacts {
                    guard let email = contact["email"] as? String else { return }
                    
                    let newPerson = Person(email: email)
                    
                    if let name = contact["name"] as? [String: Any] {
                        newPerson.fname = name["first"] as? String ?? ""
                        newPerson.lname = name["last"] as? String ?? ""
                        newPerson.title = name["title"] as? String ?? ""
                    }
                    
                    if let location = contact["location"] as? [String: Any] {
                        newPerson.city = location["city"] as? String ?? ""
                        newPerson.street = location["street"] as? String ?? ""
                        newPerson.city = location["city"] as? String ?? ""
                    }
                    
                    newPerson.gender = contact["gender"] as? String ?? ""
                    newPerson.cell = contact["cell"] as? String ?? ""
                    newPerson.phone = contact["phone"] as? String ?? ""
                    
//                    if let picture = contact["picture"] as? [String: Any] {
//                        picture["medium"]
//                        picture["thumbnail"]
//                        newPerson.image_sm = UIImage(named: "thumbnail")
//                        newPerson.image_lg = UIImage(named: "picture")
//                    }
                    
                    
                    self.persons.append(newPerson)
                }
                
            } catch let parsingError {
                print("Error parsing response", parsingError)
                return
            }
            
        }
        
        task.resume()
        
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.persons.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "PersonTableViewCell", for: indexPath) as? PersonTableViewCell else {
            fatalError("The dequeued cell is not an instance of PersonTableViewCell.")
        }
        
        let person = persons[indexPath.row]
        
        cell.nameLabel.text = person.full_name
//        cell.thumbnailImageView.image = person.image_sm
        
        return cell
    }


}

