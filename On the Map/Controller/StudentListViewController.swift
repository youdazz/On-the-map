//
//  StudentListViewController.swift
//  On the Map
//
//  Created by Youda Zhou on 20/5/24.
//

import UIKit

class StudentListViewController: UITableViewController {

    // MARK: Properties
    
    var students: [StudentLocation] {
        return StudentInformationModel.studentInformation?.locations ?? []
    }
    
    // MARK: Functions
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        UdacityClient.getMyPinLocation { location, error in
            StudentInformationModel.myPin = location
        }
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return students.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "StudentTableViewCell")!
        
        let student = students[indexPath.row]
        
        var title = ""
        if !student.firstName.isEmpty || !student.lastName.isEmpty {
            title = "\(student.firstName) \(student.lastName)"
        } else {
            title = "Student \(indexPath.row)"
        }
        cell.textLabel?.text = title
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let student = students[indexPath.row]
        guard let url = URL(string: student.mediaURL) else {
            errorOpeningLinkAlert()
            return }
        if UIApplication.shared.canOpenURL(url) {
            UIApplication.shared.open(url)
        } else {
            errorOpeningLinkAlert()
        }
    }
    
    func errorOpeningLinkAlert() {
        showAlertController(title: "Link error", message: "Cannot open student link", actions: [.init(title: "Cancel", style: .default)])
    }
    
    // MARK: IBActions
    
    @IBAction func logoutTapped(_ sender: UIBarButtonItem) {
        UdacityClient.logout {
            self.dismiss(animated: true)
        }
    }
    
    @IBAction func postNewInformationTapped(_ sender: UIBarButtonItem) {
        if StudentInformationModel.myPin != nil {
            showOverwritePinAlert()
        } else {
            showCreateNewPinAlert()
        }
    }
    
    func showOverwritePinAlert() {
        showAlertController(title: "Location detected", message: "You Have Already Posted a Student Location. Would You Like to Overwrite Your Current Location?", actions: [
            .init(title: "Overwrite", style: .default, handler: handleCreate_OverwriteAction(action:)),
            .init(title: "Cancel", style: .cancel)
        ])
    }
    
    func handleCreate_OverwriteAction( action: UIAlertAction) {
        performSegue(withIdentifier: "informationPostingView", sender: self)
    }
    
    func showCreateNewPinAlert() {
        showAlertController(title: "No Location detected", message: "You Dont have a Student Location Posted. Would You Like to Create a New One?", actions: [
            .init(title: "Create", style: .default, handler: handleCreate_OverwriteAction(action:)),
            .init(title: "Cancel", style: .cancel)
        ])
    }
    
}
