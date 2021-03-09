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
    
    func filterContentForSearchText(searchText:String,scope:String = "All") {
        filteredUsers = allUsers.filter{$0.firstname.lowercased().contains(searchText.lowercased())}
        tableView.reloadData()
    }
    
    func updateSearchResults(for searchController: UISearchController) {
        filterContentForSearchText(searchText: searchController.searchBar.text!)
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
      
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
      
        return allUsers.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell") as! UserTableViewCell
        cell.generateCellWith(fUser: allUsers[indexPath.row], indexPath: indexPath)
        return cell
    }


}
