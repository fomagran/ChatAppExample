//
//  CallTableViewController.swift
//  ChatAppExample
//
//  Created by Fomagran on 2021/03/25.
//

import UIKit
import ProgressHUD
import FirebaseFirestore

class CallTableViewController: UITableViewController {
    
    var allCalls:[Call] = []
    
    let appDelegate = UIApplication.shared.delegate as! AppDelegate

    var callListener:ListenerRegistration!
    

    override func viewDidLoad() {
        super.viewDidLoad()
        loadCalls()
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
      
    }
    
    
    override func viewWillDisappear(_ animated: Bool) {
        callListener.remove()
    }
    
    func loadCalls() {
  
        callListener = reference(.Call).document(FUser.currentId()).collection(FUser.currentId()).addSnapshotListener{ (snapshot, error) in
            self.allCalls = []
            
            guard let snapshot = snapshot else {return}
            print(snapshot.documents.count)
            
            if !snapshot.isEmpty {
                let sortedDictionary = dictionaryFromSnapshots(snapshots: snapshot.documents)
                
                for callDictionary in sortedDictionary {
                    let call = Call(_dictionary: callDictionary)
                    self.allCalls.append(call)
                    print(self.allCalls.count)
                }
            }
            self.tableView.reloadData()
        }
    }
    


    // MARK: - Table view data source

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
       
        return allCalls.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CallTableViewCell") as! CallTableViewCell
        cell.generateCell(call: allCalls[indexPath.row])
        
        return cell
    }

 

}
