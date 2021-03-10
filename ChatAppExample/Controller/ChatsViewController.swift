//
//  ChatsViewController.swift
//  ChatAppExample
//
//  Created by Fomagran on 2021/03/09.
//

import UIKit
import FirebaseFirestore

class ChatsViewController: UIViewController {

    @IBOutlet weak var table: UITableView!
    
    var recentChats:[NSDictionary] = []
    var filteredChats:[NSDictionary] = []
    
    var recentListener:ListenerRegistration!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationController?.navigationBar.prefersLargeTitles = true
       
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

}


extension ChatsViewController:UITableViewDelegate,UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 0
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = table.dequeueReusableCell(withIdentifier: "RecentChatTableViewCell") as! RecentChatTableViewCell
        
        let recent = recentChats[indexPath.row]
        cell.generateCell(recentChat: recent, indexPath: indexPath)
        
        return cell
    }
    
    
}
