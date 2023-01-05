//
//  CompulsoryLiberalArtDetailInputViewController.swift
//  kumulator
//
//  Created by 강현준 on 2022/08/04.
//

import Foundation
import UIKit
import FirebaseAuth
import FirebaseDatabase

class CompulsoryLiberalArtDetailInputViewController: UIViewController, UITableViewDelegate, UITableViewDataSource{
    
    var KorLiberalArtsRequirements = ""
    var EngLiberalArtsRequirements = ""
    var StudentNumber = ""
    
//    var knowledge1 = [LiberalArts]()
//    var knowledge2 = [LiberalArts]()
//
//    var elseLiberalArt = [LiberalArts]()
    
    let ref = Database.database().reference()
    let uid = Auth.auth().currentUser?.uid
    
    override func viewDidLoad() {
        super.viewDidLoad()
    
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        switch EngLiberalArtsRequirements{
        case "knowledge":
         
            DispatchQueue.global().async {
                self.makeStudentNumber()
                self.readknowledge2()
                self.readknowledge1()
            }
            break
            
        default:
            self.makeStudentNumber()
            readLibalArt()
            break
        }
    
        
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        return UITableViewCell()
    }
    
    //이전버튼 클릭
    @IBAction func Prebious(_ sender: UIBarButtonItem) {
        self.presentingViewController?.dismiss(animated: true)
    }
    
    func ReadCompulsoryLiberalData(){
        
        
        switch EngLiberalArtsRequirements{
        default:
            
            break
        }
    }
    
    func readknowledge1(){
        var run = true
        
        ref.child("LiberalArtsRequirements").child(StudentNumber).child(EngLiberalArtsRequirements).child("1").observe(.value){ snapshot in
            guard let value = snapshot.value as? NSDictionary else { return }
//            self.knowledge1.append(LiberalArts(Classification: value["Classification"] as? String ?? "",Credit: value["Credit"] as? Int ?? 0, Name: value["Name"] as? String ?? ""))
            run = false
        }
        
        while run{
            
        }
    }
    
    func readknowledge2() {
        
        var run = true
        
        ref.child("LiberalArtsRequirements").child(StudentNumber).child(EngLiberalArtsRequirements).child("소양2").observe(.value){ snapshot in
            guard let value = snapshot.value as? [String: [String: Any]] else { return}
            do{
                let jsonData = try JSONSerialization.data(withJSONObject: value)
//                let decodedata = try JSONDecoder().decode([String: LiberalArts].self, from: jsonData)
//                self.knowledge2 = Array(decodedata.values)
                run = false
            }catch let error{
                print(error)
                run = false
            }
            while run{
                
            }
        }
    }
    
    func readLibalArt() {
        ref.child("LiberalArtsRequirements").child(StudentNumber).child("Basic").child(EngLiberalArtsRequirements).observeSingleEvent(of: .value){ snapshot in
            print(snapshot)
            guard let value = snapshot.value as? [[String: Any]] else { return}
//            print("111")
        }
    }
    
    func makeStudentNumber(){
        if self.StudentNumber == "18" || self.StudentNumber == "19"{
            self.StudentNumber = "18,19"
        }
    }
    
    
}


class CompulsoryLiberalArtCustomCell: UITableViewCell{
    
    @IBOutlet var NameLabel: UILabel!
    @IBOutlet weak var CreditLabel: UILabel!
    @IBOutlet weak var ClassificationLabel: UILabel!
    @IBOutlet weak var InputButton: UIButton!
}
