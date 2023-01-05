//
//  SelectCourseHistoryViewController.swift
//  kumulator
//
//  Created by 강현준 on 2022/07/19.
//

import Foundation
import UIKit
import FirebaseAuth
import FirebaseDatabase

class SelectCourseHistoryViewController: UIViewController{
    
    let ref = Database.database().reference()
    let uid = Auth.auth().currentUser?.uid
    var SubjectList: [SubjectStruct] = []
    var Major1Count1 = 0
    var Major1Count2 = 0
    var Major2Count1 = 0
    var Major2Count2 = 0
    var Major3Count1 = 0
    var Major3Count2 = 0
    var Major4Count1 = 0
    var Major4Count2 = 0

    @IBOutlet weak var ToTalStackView: UIStackView!
    @IBOutlet weak var ActivitiIndicator: UIActivityIndicatorView!
    
    @IBOutlet weak var grade1semester1Major: UILabel!
    @IBOutlet weak var grade1semester2Major: UILabel!
    @IBOutlet weak var grade2semester1Major: UILabel!
    @IBOutlet weak var grade2semester2Major: UILabel!
    @IBOutlet weak var grade3semester1Major: UILabel!
    @IBOutlet weak var grade3semester2Major: UILabel!
    @IBOutlet weak var grade4semester1Major: UILabel!
    @IBOutlet weak var grade4semester2Major: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        DispatchQueue.global().async {
            self.Major1Count1 = self.readMajorCount(Grade: "1", Semester: "1")
            self.Major1Count2 = self.readMajorCount(Grade: "1", Semester: "2")
            self.Major2Count1 = self.readMajorCount(Grade: "2", Semester: "1")
            self.Major2Count2 = self.readMajorCount(Grade: "2", Semester: "2")
            self.Major3Count1 = self.readMajorCount(Grade: "3", Semester: "1")
            self.Major3Count2 = self.readMajorCount(Grade: "3", Semester: "2")
            self.Major4Count1 = self.readMajorCount(Grade: "4", Semester: "1")
            self.Major4Count2 = self.readMajorCount(Grade: "4", Semester: "2")

            DispatchQueue.main.async {
                self.grade1semester1Major.text = String(self.Major1Count1)
                self.grade1semester2Major.text = String(self.Major1Count2)
                self.grade2semester1Major.text = String(self.Major2Count1)
                self.grade2semester2Major.text = String(self.Major2Count2)
                self.grade3semester1Major.text = String(self.Major3Count1)
                self.grade3semester2Major.text = String(self.Major3Count2)
                self.grade4semester1Major.text = String(self.Major4Count1)
                self.grade4semester2Major.text = String(self.Major4Count2)
                //데이터를 읽어오는 동안 액티비티 인디케이터를 보여줌
                self.ActivitiIndicator.isHidden = true
                self.ToTalStackView.isHidden = false
            }
        }

    }
    override func viewWillDisappear(_ animated: Bool) {
        self.navigationController?.navigationBar.isHidden = false
        self.navigationController?.interactivePopGestureRecognizer?.isEnabled = true
        self.ActivitiIndicator.isHidden = false
        self.ToTalStackView.isHidden = true
        
    }
    
    //이전 버튼 클릭
    @IBAction func Prebious(_ sender: Any) {
        self.navigationController?.navigationBar.isHidden = false
        self.navigationController?.interactivePopGestureRecognizer?.isEnabled = true
        self.presentingViewController?.dismiss(animated: true)
    }

    @IBAction func Grade1Semester1Button(_ sender: UIButton) {
        let ButtonName = "1학년 1학기"
        SelectGradeAndSemesterButton(sender: ButtonName)
    }
    
    @IBAction func Grade1Semester2Button(_ sender: UIButton) {
        let ButtonName = "1학년 2학기"
        SelectGradeAndSemesterButton(sender: ButtonName)
    }
    @IBAction func Grade2Semester1Button(_ sender: UIButton) {
        let ButtonName = "2학년 1학기"
        SelectGradeAndSemesterButton(sender: ButtonName)
    }
    @IBAction func Grade2Semester2Button(_ sender: UIButton) {
        let ButtonName = "2학년 2학기"
        SelectGradeAndSemesterButton(sender: ButtonName)
    }
    
    @IBAction func Grade3Semester1Button(_ sender: UIButton) {
        let ButtonName = "3학년 1학기"
        SelectGradeAndSemesterButton(sender: ButtonName)
    }
    @IBAction func Grade3Semester2Button(_ sender: UIButton) {
        let ButtonName = "3학년 2학기"
        SelectGradeAndSemesterButton(sender: ButtonName)
    }
    @IBAction func Grade4Semester1Button(_ sender: UIButton) {
        let ButtonName = "4학년 1학기"
        SelectGradeAndSemesterButton(sender: ButtonName)
    }
    @IBAction func Grade4Semester2Button(_ sender: UIButton) {
        let ButtonName = "4학년 2학기"
        SelectGradeAndSemesterButton(sender: ButtonName)
    }
    
    //선택한 학년과 학기를 다음 뷰로 전달.
    func SelectGradeAndSemesterButton(sender: String){
        guard let storyboard = self.storyboard?.instantiateViewController(identifier: "SelectYearViewController") as? SelectYearViewController else { return }
        storyboard.GrandeAndSemester = sender
        
        storyboard.modalPresentationStyle = .fullScreen
        self.present(storyboard, animated: true, completion: nil)
    }
    
    //학기별로 입력한 수강 학점을 읽어옴.
    func readMajorCount(Grade: String, Semester: String) -> Int{
        var count = 0
        var run = true
        ref.child("MajorCourseHistory").child(uid!).child(Grade).child(Semester).observe(.value){ snapshot in
            guard let value = snapshot.value as? [String: [String: Any]] else {
                run = false
                return
            }
            do{
                let jsonData = try JSONSerialization.data(withJSONObject: value)
                let subjectData = try JSONDecoder().decode([String: SubjectStruct].self, from: jsonData)
                self.SubjectList = Array(subjectData.values)
                
                let ListCount = self.SubjectList.count
                for i in 0 ... ListCount - 1{
                    count = count + Int(self.SubjectList[i].SubjectCredit)
                    
                }
                
                run = false
            }catch let error{
                print("Error json parsing\(error)")
                run = false
            }
        }
        
        while run{
            
        }
        return count
    }
    
}
