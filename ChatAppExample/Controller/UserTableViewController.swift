//
//  UserTableViewController.swift
//  ChatAppExample
//
//  Created by Fomagran on 2021/03/09.
//

import UIKit
import Firebase
import ProgressHUD

class UserTableViewController: UITableViewController,UISearchResultsUpdating {

    @IBOutlet weak var segment: UISegmentedControl!
    @IBOutlet weak var headerView: UIView!
    
    var allUsers:[FUser] = []
    var filteredUsers:[FUser] = []
    var allUsersGroupped = NSDictionary() as! [String:[FUser]]
    var sectionTitleList:[String] = []
    
    let searchController = UISearchController(searchResultsController: nil)
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "User"
        navigationItem.largeTitleDisplayMode = .never
        navigationItem.searchController = searchController
        
        searchController.searchResultsUpdater = self
        searchController.obscuresBackgroundDuringPresentation = false
        definesPresentationContext = true
        loadUsers(filter: kCITY)

    }
    
    func loadUsers(filter:String) {
        ProgressHUD.show()
        
        //firebase 쿼리를 뜻함
        var query:Query!
        
        switch filter {
        case kCITY:
            query = reference(.User).whereField(kCITY, isEqualTo: FUser.currentUser()!.city).order(by: kFIRSTNAME,descending: false)
        case kCOUNTRY:
            query = reference(.User).whereField(kCOUNTRY, isEqualTo: FUser.currentUser()!.country).order(by: kFIRSTNAME,descending: false)
        default:
            query = reference(.User).order(by: kFIRSTNAME,descending: false)
        }
        
        query.getDocuments { (snapshot, error) in
            self.allUsers = []
            self.sectionTitleList = []
            self.allUsersGroupped = [:]
            
            if error != nil {
                print(error!.localizedDescription)
                ProgressHUD.dismiss()
                self.tableView.reloadData()
                return
            }
            
            guard let snapshot = snapshot else {
                ProgressHUD.dismiss()
                return
            }
            if !snapshot.isEmpty {
                for userDic in snapshot.documents {
                    let userDictionary = userDic.data() as NSDictionary
                    let fUser = FUser(_dictionary: userDictionary)
                    if fUser.objectId != FUser.currentId() {
                        self.allUsers.append(fUser)
                    }
                }
            }
            self.tableView.reloadData()
            ProgressHUD.dismiss()
        }
    }
    
    @IBAction func filterBySegment(_ sender: UISegmentedControl) {
        switch sender.selectedSegmentIndex{
        case 0:
            loadUsers(filter: kCITY)
        case 1:
            loadUsers(filter: kCOUNTRY)
        case 2:
            loadUsers(filter: "")
        default:
            return
        }
    }
    func filterContentForSearchText(searchText:String,scope:String = "All") {
        filteredUsers = allUsers.filter{$0.firstname.lowercased().contains(searchText.lowercased())}
        tableView.reloadData()
    }
    
    func updateSearchResults(for searchController: UISearchController) {
        filterContentForSearchText(searchText: searchController.searchBar.text!)
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
      
        if searchController.isActive && searchController.searchBar.text != "" {
            return 1
        }else{
            return allUsersGroupped.count
        }
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if searchController.isActive && searchController.searchBar.text != "" {
            return filteredUsers.count
        }else{
            let sectionTitle = self.sectionTitleList[section]
            let users = self.allUsersGroupped[sectionTitle]
            return users!.count
        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell") as! UserTableViewCell
        var user:FUser
        if searchController.isActive && searchController.searchBar.text != "" {
            user = filteredUsers[indexPath.row]
        }else{
            let sectionTitle = self.sectionTitleList[indexPath.row]
            let users = self.allUsersGroupped[sectionTitle]
            
            user = users![indexPath.row]
        }
        cell.generateCellWith(fUser: user, indexPath: indexPath)
        return cell
    }


}
