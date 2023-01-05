//
//  LiberalKUPersonalityInputViewController.swift
//  kumulator
//
//  Created by 강현준 on 2022/09/04.
//

import Foundation
import UIKit
import FirebaseAuth
import FirebaseDatabase

class LiberalKUPersonalityInputViewController: UIViewController, UITableViewDelegate, UITableViewDataSource{
    
    var SubjectList = LiberalKUPersonality()
    var Reuse = [ReuseF]()
    
    let uid = Auth.auth().currentUser?.uid
    let ref = Database.database().reference()
    
    @IBOutlet weak var TableVIew: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        for i in 0...SubjectList.LiberalKUPersounality.count - 1{
            Reuse.append(ReuseF(names: SubjectList.LiberalKUPersounality[i].SubjectName, isselected: false))
        }
        
        TableVIew.dataSource = self
        TableVIew.delegate = self
    }
    
    @IBAction func SelectSwitch(_ sender: UISwitch) {
        let contentView = sender.superview
        let cell = contentView?.superview as! KUPersonalityCell
        let indexpath = TableVIew.indexPath(for: cell)
        let row = indexpath?.row
        
        //스위치가 off에서 On이 되면 데이터베이스에 추가
        if sender.isOn != false{
            ref.child("LiberalKUPersonality").child(uid!).childByAutoId().setValue(SubjectList.LiberalKUPersounality[row!].SubjectName)
                //스위치가 On에서 Off가 되면 데이터베이스에서 삭제
        }else{
            ref.child("LiberalKUPersonality").child(uid!).observeSingleEvent(of: .value){ snapshot in
                let value = snapshot.value
                guard let dic = value as? [String: Any] else { return }
                for index in dic{
                    if(index.value as! String == self.SubjectList.LiberalKUPersounality[row!].SubjectName){
                        self.ref.child("LiberalKUPersonality").child(self.uid!).child(index.key).removeValue()
                        self.Reuse[row!].isselected = false
                    }
                }
            }
        }
    }
    
    @IBAction func OKButton(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return SubjectList.LiberalKUPersounality.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell: KUPersonalityCell = tableView.dequeueReusableCell(withIdentifier: "KUPersonalityCell", for: indexPath) as? KUPersonalityCell else { return UITableViewCell() }
        cell.SubjectNameLabel.text = self.SubjectList.LiberalKUPersounality[indexPath.row].SubjectName
        cell.CreditLavel.text = String(self.SubjectList.LiberalKUPersounality[indexPath.row].SubjectCredit)
        
//                스위치의 on off상태를 초기화
        ref.child("LiberalKUPersonality").child(uid!).observe(.value){ snapshot in
            guard let value = snapshot.value as?  [String: Any] else { return }
            for i in 0...self.SubjectList.LiberalKUPersounality.count - 1{
                for j in value.values{
                    if j as! String == self.Reuse[i].names{
                        self.Reuse[i].isselected = true
                    }
                }
            }
            cell.SelectSwitch.isOn = self.Reuse[indexPath.row].isselected
            }
        
        return cell
    }
}

class KUPersonalityCell: UITableViewCell{
    @IBOutlet weak var SubjectNameLabel: UILabel!
    @IBOutlet weak var CreditLavel: UILabel!
    @IBOutlet weak var SelectSwitch: UISwitch!
}
