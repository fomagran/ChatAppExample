//
//  ChatsViewController.swift
//  ChatAppExample
//
//  Created by Fomagran on 2021/03/09.
//

import UIKit

class ChatsViewController: UIViewController {


    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationController?.navigationBar.prefersLargeTitles = true
       
    }
    
    @IBAction func createNewChat(_ sender: Any) {
        let userVC = UIStoryboard.init(name:"Main",bundle: nil).instantiateViewController(identifier: "UserTableViewController") as! UserTableViewController
        
        self.navigationController?.pushViewController(userVC, animated: true)
    }
    

}
