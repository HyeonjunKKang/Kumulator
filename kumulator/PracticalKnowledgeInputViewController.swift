//
//  PracticalKnowledgeInputViewController.swift
//  kumulator
//
//  Created by 강현준 on 2022/09/04.
//

import Foundation
import UIKit
import FirebaseAuth
import FirebaseDatabase

class PracticalKnowledgeInputViewController: UIViewController, UITableViewDelegate, UITableViewDataSource{
    let SubjectList = PracticalKnowledge()
    var Reuse = [ReuseF]()

    
    let uid = Auth.auth().currentUser?.uid
    let ref = Database.database().reference()
    
    @IBOutlet weak var TableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        for i in 0...SubjectList.PracticalKnowledge.count - 1{
            Reuse.append(ReuseF(names: SubjectList.SubjectNameList[i], isselected: false))
        }
        
        TableView.dataSource = self
        TableView.delegate = self
    }
    
    @IBAction func OkButton(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func SelectSwitch(_ sender: UISwitch) {
        
        //스위치가 위치한 셀의 indexpath row를 가져와서 셀들의 스위치를 다루는 코드
        let contentView = sender.superview
        let cell = contentView?.superview as! PracticalKnowledgeCell
        let indexPath = TableView.indexPath(for: cell)
        let row = indexPath?.row
        
        //스위치가 on일경우에 추가
        if sender.isOn != false{                        //고유 키를 생성해서 추가
            ref.child("PracticalKnowledge").child(uid!).childByAutoId().setValue(SubjectList.PracticalKnowledge[row!].SubjectName)
        }else{
            //스위치가 on일경우 off상태가 되면 데이터베이스에서 삭제
            ref.child("PracticalKnowledge").child(uid!).observeSingleEvent(of: .value){ snapshot in
                let value = snapshot.value
                guard let dic = value as? [String: Any] else { return }
                for index in dic{
                    if(index.value as! String == self.SubjectList.PracticalKnowledge[row!].SubjectName){
                        self.ref.child("PracticalKnowledge").child(self.uid!).child(index.key).removeValue()
                        self.Reuse[row!].isselected = false
                    }
                }
            }
        }
        
    }
    //테이블 뷰에 나타날 셀의 갯수
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return SubjectList.PracticalKnowledge.count
        }
    
    //셀의 정보를 리턴함.
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        guard let cell: PracticalKnowledgeCell = tableView.dequeueReusableCell(withIdentifier: "PracticalKnowledgeCell", for: indexPath) as? PracticalKnowledgeCell else { return UITableViewCell() }
        
        cell.SubjectNameLabel.text = self.SubjectList.PracticalKnowledge[indexPath.row].SubjectName
        cell.CreditLabel.text = String(self.SubjectList.PracticalKnowledge[indexPath.row].SubjectCredit)
        
        //                스위치의 on off상태를 초기화
                ref.child("PracticalKnowledge").child(uid!).observe(.value){ snapshot in
                    guard let value = snapshot.value as?  [String: Any] else { return }
                    for i in 0...self.SubjectList.PracticalKnowledge.count - 1{
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
    
    //셀의 높이를 리턴함
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 50
    }
    
}

class PracticalKnowledgeCell: UITableViewCell{
    @IBOutlet weak var SubjectNameLabel: UILabel!
    @IBOutlet weak var CreditLabel: UILabel!
    @IBOutlet weak var SelectSwitch: UISwitch!
}
