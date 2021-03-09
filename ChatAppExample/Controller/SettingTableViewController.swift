//
//  SettingTableViewController.swift
//  ChatAppExample
//
//  Created by Fomagran on 2021/03/08.
//

import UIKit

class SettingTableViewController: UITableViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        navigationController?.navigationBar.prefersLargeTitles = true
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return 3
    }
    
    /*테이블뷰 컨트롤러로 만든 후 테이블뷰에서 content mode를 Static으로 바꾸면
     셀에 있는 버튼을 직접 연결할 수 있다.
    */
    @IBAction func tapLogOutButton(_ sender: Any) {
        FUser.logOutCurrentUser { (success) in
            if success {
                self.showLoginView()
            }
        }
    }
    
    func showLoginView(){
        
        let loginVC = UIStoryboard.init(name: "Main", bundle: nil).instantiateViewController(identifier: "LoginViewController") as! LoginViewController
        let nav = UINavigationController.init(rootViewController: loginVC)
        nav.modalPresentationStyle = .fullScreen
        self.present(nav, animated: true, completion: nil)
   
    }

}
