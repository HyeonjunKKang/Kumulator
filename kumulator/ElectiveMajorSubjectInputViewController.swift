//
//  ElectiveMajorSubjectInputViewController.swift
//  kumulator
//
//  Created by 강현준 on 2022/09/01.
//

import Foundation
import UIKit
import FirebaseAuth
import FirebaseDatabase

class ElectiveMajorSubjectInputViewController: UIViewController, UITableViewDelegate, UITableViewDataSource{
    
    var SubjectList = ElectiveSubject()
    var Reuse = [ReuseF]()
    
    let uid = Auth.auth().currentUser?.uid
    let ref = Database.database().reference()
    
    @IBOutlet weak var TableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        for i in 0...SubjectList.SubjectNameList.count - 1{
            Reuse.append(ReuseF(names: SubjectList.SubjectNameList[i], isselected: false))
        }

        TableView.dataSource = self
        TableView.delegate = self
    }
    
    @IBAction func OKButton(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }
    
    //스위치가 선택 되었을 때
    @IBAction func SelectSwitch(_ sender: UISwitch) {
        let contentView = sender.superview
        let cell = contentView?.superview as! EleMajorCustomCell
        let indexpath = TableView.indexPath(for: cell)
        let row = indexpath?.row
        
        //스위치가 off에서 On이 되면 데이터베이스에 추가
        if sender.isOn != false{
            ref.child("ElectiveMajorHistory").child(uid!).childByAutoId().setValue(SubjectList.ElectSubjectList[row!].SubjectName)
                //스위치가 On에서 Off가 되면 데이터베이스에서 삭제
        }else{
            ref.child("ElectiveMajorHistory").child(uid!).observeSingleEvent(of: .value){ snapshot in
                let value = snapshot.value
                guard let dic = value as? [String: Any] else { return }
                for index in dic{
                    if(index.value as! String == self.SubjectList.ElectSubjectList[row!].SubjectName){
                        self.ref.child("ElectiveMajorHistory").child(self.uid!).child(index.key).removeValue()
                        self.Reuse[row!].isselected = false
                    }
                }
            }
        }

    }
    
    //테이블뷰에 나타낼 셀의 갯수
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return SubjectList.SubjectNameList.count
    }
    
    //셀의 정보를 리턴함
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell: EleMajorCustomCell = tableView.dequeueReusableCell(withIdentifier: "EleMajorCustomCell", for: indexPath) as? EleMajorCustomCell else { return UITableViewCell() }
        cell.SubjectNameLabel.text = self.SubjectList.ElectSubjectList[indexPath.row].SubjectName
        cell.CreditLavel.text = String(self.SubjectList.ElectSubjectList[indexPath.row].SubjectCredit)
        
//                스위치의 on off상태를 초기화
        ref.child("ElectiveMajorHistory").child(uid!).observe(.value){ snapshot in
            guard let value = snapshot.value as?  [String: Any] else { return }
            for i in 0...self.SubjectList.SubjectNameList.count - 1{
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
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 50
    }
}

class EleMajorCustomCell: UITableViewCell{
    @IBOutlet weak var SubjectNameLabel: UILabel!
    @IBOutlet weak var CreditLavel: UILabel!
    @IBOutlet weak var SelectSwitch: UISwitch!
    
    override func prepareForReuse() {
        super.prepareForReuse()
        SubjectNameLabel.text = nil
        CreditLavel.text = nil
        
    }
}
