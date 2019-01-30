//
//  PersonTableViewController.swift
//  persons
//
//  Created by Marcus Ek on 21/01/2019.
//  Copyright © 2019 Marcus Ekon. All rights reserved.
//

import UIKit

class PersonTableViewController: UITableViewController {
    
    var persons = [Person]()
    var currentPerson: Person?
    var searchResults = [Person]()
    
    var searching = false

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.refreshControl?.attributedTitle = NSAttributedString(string: "Pull to refresh")
        self.refreshControl?.addTarget(self, action: #selector(refreshHandler(sender:)), for: UIControl.Event.valueChanged)
        
        // tableView.register(PersonTableViewCell.self, forCellReuseIdentifier: "PersonTableViewCell")
        start()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    @objc func refreshHandler(sender: UIRefreshControl) {
        persons.removeAll()
        self.start()
        self.refreshControl?.endRefreshing()
    }
    
    func start() {
        if Reachability.isConnectedToNetwork() == true {
            fetchContacts(endpoint: "https://randomuser.me/api/?results=23&seed=ekon")
        } else {
            self.showAlert(title: "No Internet Connection", body: "Please check your internet connection and try again.")
        }
    }
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier=="detail_segue"{
            let detailViewController=segue.destination as? PersonDetailsViewController
            detailViewController?.person=currentPerson
        }
    }

}

extension PersonTableViewController {
    // MARK: - Table view data source
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if searching {
            return searchResults.count
        } else {
            return persons.count
        }
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if searching {
            return 40
        } else {
            return tableView.rowHeight
        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        guard let cell = self.tableView.dequeueReusableCell(withIdentifier: "PersonTableViewCell") as? PersonTableViewCell else {
            fatalError("The dequeued cell is not an instance of PersonTableViewCell.")
        }
        
        var personsArray = [Person]()
        
        if searching {
            personsArray = searchResults
        } else {
            personsArray = persons
        }
        
        if personsArray.count >= indexPath.row {
            let person: Person
            
            person = personsArray[indexPath.row]
            
            cell.nameLabel.text = person.name
            cell.emailLabel.text = person.email
            cell.thumbnailImageView.image = person.thumbnail
            
            return cell
        } else {
            return PersonTableViewCell()
        }
        
    }
    
    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        let alpha: Double
        if( indexPath.row % 2 != 0 ) {
            alpha = 0.1
        } else {
            alpha = 0.4
        }
        
        cell.backgroundColor = UIColor(red: 178/255, green: 155/255, blue: 127/255 , alpha:CGFloat(alpha))
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if searching {
            currentPerson = searchResults[indexPath.row]
        } else {
            currentPerson = persons[indexPath.row]
        }
        
        performSegue(withIdentifier: "detail_segue", sender: self)
    }
}

extension PersonTableViewController {
    // MARK: - Helpers
    
    private func fetchContacts(endpoint: String) {
        
        guard let url = URL(string: endpoint) else {
            print("Error: invalid url")
            return
        }
        
        let urlRequest = URLRequest(url: url)
        
        let session = URLSession.shared
        
        let task = session.dataTask(with: urlRequest) { data, response, error in
            
            // check for errors
            guard error  == nil else {
                self.showAlert(title: "Server Unreachable", body: "Please try again later.")
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
                    
                    if let picture = contact["picture"] as? [String: Any] {
                        newPerson.thumb_url = picture["thumbnail"] as! String
                        newPerson.pic_url = picture["large"] as! String
                        
                        let thumbnail_url: URL = URL(string: newPerson.thumb_url)!
                        
                        let imageData:NSData = NSData(contentsOf: thumbnail_url)!
                        
                        newPerson.thumbnail = UIImage(data: imageData as Data)!
                    }
                    
                    self.persons.append(newPerson)
                    
                    DispatchQueue.main.async {
                        self.tableView.reloadData()
                    }
                    
                }
                
            } catch let parsingError {
                print("Error parsing response", parsingError)
                return
            }
            
        }
        
        task.resume()
    }
    
    private func filterContentForSearchText(searchText: String) {
        // Filter the array using the filter method
        if self.persons.count == 0 {
            self.searchResults = []
            return
        }
        
        self.searchResults = self.persons.filter({( aPerson: Person) -> Bool in
            // to start, let's just search by name
            return aPerson.name.lowercased().contains(searchText.lowercased())
        })
    }
    
    private func showAlert(title: String, body: String) {
        let alert = UIAlertController(title: title, message: body, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: NSLocalizedString("Retry", comment: "Reload"), style: .default, handler: { _ in
            self.start()
        }))
        alert.addAction(UIAlertAction(title: NSLocalizedString("Cancel", comment: "Cancel & Quit"), style: .cancel, handler: { _ in
            UIControl().sendAction(#selector(NSXPCConnection.suspend), to: UIApplication.shared, for: nil)
        }))
        
        self.present(alert, animated: true, completion: nil)
    }
    
}


extension PersonTableViewController: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        self.filterContentForSearchText(searchText: searchText)
        searching = true
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
    }
}
