//
//  LiberalKUPersonalityViewController.swift
//  kumulator
//
//  Created by 강현준 on 2022/09/04.
//

import Foundation
import UIKit

class LiberalKUPersonalityViewController: UIViewController, UITableViewDelegate, UITableViewDataSource{
    
    var whatisLiberal = ""
    
    
    
    
    var @IBOutlet TableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    @IBAction func OKButton(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        <#code#>
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        <#code#>
    }
    

}

class LiberalCustomCell: UITableViewCell{
    @IBOutlet weak var SubjectNameLabel: UILabel!
    @IBOutlet weak var CreditLabel: UILabel!
    @IBOutlet weak var SelectSwitch: UISwitch!
    
}
