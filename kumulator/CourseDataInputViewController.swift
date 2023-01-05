//
//  CourseDataInputViewController.swift
//  kumulator
//
//  Created by 강현준 on 2022/07/22.
//

import Foundation
import UIKit
import FirebaseDatabase
import FirebaseAuth


class CourseDataInputViewController: UIViewController, UITableViewDataSource, UITableViewDelegate{
    
    @IBOutlet weak var navbar: UINavigationItem!
    let ref = Database.database().reference()
    var Grade = ""
    var SelectedSemester = ""
    var Semester = ""
    var year = ""
    var uid = Auth.auth().currentUser?.uid
    var GradeAndSemester = ""
    
    @IBOutlet weak var TableView: UITableView!
    
    var SubjectList: [SubjectStruct] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navbar.title = GradeAndSemester
        
        TableView.delegate = self
        TableView.dataSource = self
        
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        DispatchQueue.global().async {
            self.ReadOpendCourseList()
            DispatchQueue.main.async {
                self.TableView.reloadData()
            }
        }
        
    }
    
    //수강내역 입력 버튼
    @IBAction func InsertCourseToFirebase(_ sender: UIButton) {
        let contentView = sender.superview
        let cell = contentView?.superview as! CustomCell
        let indexpath = TableView.indexPath(for: cell)
        
        let row = indexpath?.row
        
        let NewHadCourseData = ["SubjectNumber" : SubjectList[row!].SubjectNumber,
                                "SubjectName": SubjectList[row!].SubjectName,
                                "SubjectCredit": SubjectList[row!].SubjectCredit,
                                "MajorRequired": SubjectList[row!].MajorRequired] as [String : Any]
        
        let SubjectNumber = SubjectList[row!].SubjectNumber
        ref.child("MajorCourseHistory").child(uid!).child(Grade).child(Semester).child(SubjectNumber).setValue(NewHadCourseData)
        
        
    }
    
    @IBAction func SaveButton(_ sender: UIBarButtonItem) {
        self.presentingViewController?.presentingViewController?.dismiss(animated: false)
    }
    
    //테이블뷰에 나타날 셀의 갯수
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return SubjectList.count
    }
    
    //셀의 정보를 리턴함
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell: CustomCell = tableView.dequeueReusableCell(withIdentifier: "CustomCell", for: indexPath) as? CustomCell else { return UITableViewCell() }
        
                cell.SubjectNameLabel.text = self.SubjectList[indexPath.row].SubjectName
                cell.CreditLabe.text = String(self.SubjectList[indexPath.row].SubjectCredit)
                cell.ClassificationLabel.text = self.SubjectList[indexPath.row].MajorRequired
                
        return cell
    }
    
    //셀의 높이
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 50
    }
    
    //개설강좌목록을 불러옴
    func ReadOpendCourseList(){
        
        var run = true
        ref.child("OpendCourseList").child(year).child(SelectedSemester).observe(.value){ snapshot in
           guard let value = snapshot.value as? [String: [String: Any]] else { return }
           do{
               let jsonData = try JSONSerialization.data(withJSONObject: value)
               let subjectData = try JSONDecoder().decode([String: SubjectStruct].self, from: jsonData)
               self.SubjectList = Array(subjectData.values)
               run = false
           } catch let error{
               print("Error json parsing\(error)")
               run = false
           }
       }
        while run{
            
        }
        
    }
    
    //수강 내역을 불러옴
    func ReadHadCourseList(){
        
        
    
}

}
class CustomCell: UITableViewCell{
    @IBOutlet weak var SubjectNameLabel: UILabel!
    @IBOutlet weak var CreditLabe: UILabel!
    @IBOutlet weak var ClassificationLabel: UILabel!
    @IBOutlet weak var InsertButton: UIButton!
}
