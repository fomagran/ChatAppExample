//
//  ChatsViewController.swift
//  ChatAppExample
//
//  Created by Fomagran on 2021/03/09.
//

import UIKit
import FirebaseFirestore

class ChattingRoomViewController: UIViewController,UISearchResultsUpdating {

    @IBOutlet weak var table: UITableView!
    
    var recentChats:[NSDictionary] = []
    var filteredChats:[NSDictionary] = []
    
    var recentListener:ListenerRegistration!
    
    let searchController = UISearchController(searchResultsController: nil)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationItem.searchController = searchController
        navigationItem.hidesSearchBarWhenScrolling = true
        searchController.searchResultsUpdater = self
        searchController.obscuresBackgroundDuringPresentation  = false
        definesPresentationContext = true
       
    }
    
    override func viewWillAppear(_ animated: Bool) {
        setTableViewHeader()
        loadRecentChats()
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        recentListener.remove()
    }
    
    @IBAction func createNewChat(_ sender: Any) {
        let userVC = UIStoryboard.init(name:"Main",bundle: nil).instantiateViewController(identifier: "UserTableViewController") as! UserTableViewController
        
        self.navigationController?.pushViewController(userVC, animated: true)
    }
    
    func loadRecentChats() {
        recentListener = reference(.Recent).whereField(kUSERID, isEqualTo: FUser.currentId()).addSnapshotListener({ (snapshot, error) in
            guard let snapshot = snapshot else {return}
            self.recentChats = []
            
            if !snapshot.isEmpty {
                
                let sorted = ((dictionaryFromSnapshots(snapshots: snapshot.documents) as NSArray).sortedArray(using: [NSSortDescriptor(key: kDATE, ascending: false)])) as! [NSDictionary]
                
                for recent in sorted {
                    if recent[kLASTMESSAGE] as! String != "" && recent[kCHATROOMID] != nil && recent[kRECENTID] != nil {
                        self.recentChats.append(recent)
                }
                
            }
                self.table.reloadData()
            }
        })
    }
    
    func setTableViewHeader() {
        let headerView = UIView(frame: CGRect(x: 0, y: 0, width: self.table.frame.width, height: 45))
        let groupButton = UIButton(frame: CGRect(x: table.frame.width - 130, y: 10, width: 100, height: 30))
        groupButton.addTarget(self, action: #selector(self.tapGroupButton), for: .touchUpInside)
        groupButton.setTitle("New Group", for: .normal)
        groupButton.setTitleColor(.link, for: .normal)
        
        headerView.addSubview(groupButton)
        
        table.tableHeaderView = headerView
    }
    
    @objc func tapGroupButton() {
        
    }
    
    func updatePushMembers(recent:NSDictionary,mute:Bool) {
        var membersToPush = recent[kMEMBERSTOPUSH] as! [String]
        
        if mute {
            let index = membersToPush.firstIndex(of: FUser.currentId())!
            membersToPush.remove(at: index)
        }else{
            membersToPush.append(FUser.currentId())
        }
        
        updateExistingRecentWithNewValues(chatRoomId: recent[kCHATROOMID] as! String, members: recent[kMEMBERS] as! [String], withValues: [kMEMBERSTOPUSH:membersToPush])
    }
    
    
    
    

}


extension ChattingRoomViewController:UITableViewDelegate,UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if searchController.isActive && searchController.searchBar.text != "" {
            return filteredChats.count
        }
        return recentChats.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = table.dequeueReusableCell(withIdentifier: "RecentChatTableViewCell") as! RecentChatTableViewCell
        cell.delegate = self
        var recent = NSDictionary()
        if searchController.isActive && searchController.searchBar.text != "" {
         recent = filteredChats[indexPath.row]
        }else{
            recent = recentChats[indexPath.row]
        }
        cell.generateCell(recentChat: recent, indexPath: indexPath)
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        
        var tempRecent:NSDictionary!
        if searchController.isActive && searchController.searchBar.text != "" {
            tempRecent = filteredChats[indexPath.row]
        }else{
            tempRecent = recentChats[indexPath.row]
        }
        
        var muteTitle = "Unmute"
        var mute = false
        
        if (tempRecent[kMEMBERSTOPUSH] as! [String]).contains(FUser.currentId()) {
            muteTitle = "Mute"
            mute = true
        }
        
        
        let deleteItem = UIContextualAction(style: .destructive, title: "Delete") {  (contextualAction, view, boolValue) in
            self.recentChats.remove(at: indexPath.row)
            deleteRecentChat(recentChatDictionary: tempRecent)
            self.table.reloadData()
        }
        let muteItem = UIContextualAction(style: .destructive, title: muteTitle) {  (contextualAction, view, boolValue) in
            self.updatePushMembers(recent: tempRecent, mute: mute)
        }
        muteItem.backgroundColor = .orange
        let swipeActions = UISwipeActionsConfiguration(actions: [deleteItem,muteItem])

        
        return swipeActions
       
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.table.deselectRow(at: indexPath, animated: true)
        
        var recent:NSDictionary!
        if searchController.isActive && searchController.searchBar.text != "" {
            recent = filteredChats[indexPath.row]
        }else{
            recent = recentChats[indexPath.row]
        }
        
        restartRecentChat(recent: recent)
        
        let chatVC = ChatViewController()
        chatVC.hidesBottomBarWhenPushed = true
        chatVC.membersToPush = (recent[kMEMBERSTOPUSH] as? [String])!
        chatVC.memberIds = (recent[kMEMBERS] as? [String])!
        chatVC.chatRoomId = (recent[kCHATROOMID] as? String)!
        chatVC.titleName = (recent[kWITHUSERFULLNAME] as? String)!
        chatVC.isGroup = false
        
        
        self.navigationController?.pushViewController(chatVC, animated: true)
    }
}


extension ChattingRoomViewController:RecentChatTableViewCellDelegate {
    
    func didTapProfile(indexPath: IndexPath) {
        var recentChat = NSDictionary()
        if searchController.isActive && searchController.searchBar.text != "" {
            recentChat = filteredChats[indexPath.row]
        }else{
            recentChat = recentChats[indexPath.row]
        } 
        
        if recentChat[kTYPE] as! String == kPRIVATE {
            reference(.User).document(recentChat[kWITHUSERUSERID] as! String).getDocument { (snapshot, error) in
                guard let snapshot = snapshot else {return}
                
                if snapshot.exists {
                    let userDictionary = snapshot.data()! as NSDictionary
                    
                    let tempUser = FUser(_dictionary: userDictionary)
                    
                    self.showUserProfile(user: tempUser)
                }
            }
        }
    }
    
    func showUserProfile(user:FUser) {
        let profileVC = UIStoryboard.init(name: "Main", bundle: nil).instantiateViewController(identifier: "ProfileTableViewController") as! ProfileTableViewController
        
        profileVC.user = user
        
        self.navigationController?.pushViewController(profileVC, animated: true)
    }
    
    func filterContentForSearchText(searchText:String,scope:String = "All") {
        filteredChats = recentChats.filter{($0[kWITHUSERFULLNAME] as! String).lowercased().contains(searchText.lowercased())}
        table.reloadData()
    }
    
    func updateSearchResults(for searchController: UISearchController) {
        filterContentForSearchText(searchText: searchController.searchBar.text!)
    }
}
