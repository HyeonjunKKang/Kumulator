//
//  SelectYearViewController.swift
//  kumulator
//
//  Created by 강현준 on 2022/07/20.
//

import Foundation
import UIKit
import FirebaseDatabase
import FirebaseAuth

class SelectYearViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource{
    
    @IBOutlet weak var LoadingMessageLabel: UILabel!
    @IBOutlet weak var LoadActivityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var SelectButton: UIButton!
    @IBOutlet weak var YearSemesterPickerView: UIPickerView!
    @IBOutlet weak var navbar: UINavigationItem!
    
    var GrandeAndSemester: String = ""
    var ref: DatabaseReference!
    var uid = Auth.auth().currentUser?.uid
    var opend = [YearAndSemester]()
    var SelectedYear = ""
    var SelectedSemester = ""
    
    
    var grade: String{
        var tmp = ""
        switch GrandeAndSemester{
        case "1학년 1학기", "1학년 2학기":
            tmp = "1"
        case "2학년 1학기", "2학년 2학기":
            tmp = "2"
        case "3학년 1학기", "3학년 2학기":
            tmp = "3"
        case "4학년 1학기", "4학년 2학기":
            tmp = "4"
        default:
            break
        }
        return tmp
    }
    
    var semester: String{
        var tmp = ""
        switch GrandeAndSemester{
        case "1학년 1학기", "2학년 1학기", "3학년 1학기", "4학년 1학기":
            tmp = "1"
        case "1학년 2학기", "2학년 2학기", "3학년 2학기", "4학년 2학기":
            tmp = "2"
        default:
            break
        }
        return tmp
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //로드되기전에 피커뷰를 숨김
        YearSemesterPickerView.isHidden = true
        //학년과 학기를 메인타이틀에 지정
        self.navbar.title = GrandeAndSemester
        //firebase 연동은 비동기이기 때문에 동기처리
        DispatchQueue.global().async(){
            self.OpendYearAndSemester()
            //view와 관련된 것들은 메인큐에서 처리해야함.
            DispatchQueue.main.sync {
                //로딩이 완료된 후 처리
                self.YearSemesterPickerView.dataSource = self
                self.YearSemesterPickerView.delegate = self
                self.LoadingMessageLabel.isHidden = true
                self.LoadActivityIndicator.isHidden = true
                self.YearSemesterPickerView.isHidden = false
            }
        }
    }
    
    //이전 버튼 클릭
    @IBAction func ExitButton(_ sender: UIBarButtonItem) {
        self.presentingViewController?.dismiss(animated: true)
    }
    
    @IBAction func SelectButton(_ sender: UIButton) {
        print("Seleted year: \(SelectedYear), selected Semester: \(SelectedSemester)")
        guard let storyboard = storyboard?.instantiateViewController(withIdentifier: "CourseDataInputViewController") as? CourseDataInputViewController else { return }
        storyboard.Grade = grade
        storyboard.SelectedSemester = SelectedSemester
        storyboard.Semester = semester
        storyboard.year = SelectedYear
        storyboard.GradeAndSemester = GrandeAndSemester
        storyboard.modalPresentationStyle = .fullScreen
        self.present(storyboard, animated: true)
        
        
    }
    
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 2
    }
    
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        if component == 0{
            return opend.count
        }else{
            return 2
        }
    }
    
    private func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String {
        if component == 0{
            return String(opend[row].year)
        }else{
            let selectedStudentNumber = YearSemesterPickerView.selectedRow(inComponent: 0)
            return String(opend[row].Semester[row])
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        switch component{
        case 0:
            SelectedYear = String(opend[row].year)
        case 1:
            SelectedSemester = String(opend[row].Semester[row])
        default:
            break
        }
    }
    //자신의 학번부터 현재까지 개설된 년도와 학기를 생성
    func OpendYearAndSemester(){
        
        var run = true
        
        ref = Database.database().reference()
        ref.child("User").child(self.uid!).child("StudentNumber").observe(.value){ [self] snapshot in
            guard let value = snapshot.value as? String else { return }
            self.SelectedYear = value
            self.SelectedSemester = "1"
            var StudentNumber: Int?{
                return Int(value)
            }
            let formatter = DateFormatter()
            formatter.dateFormat = "yy"
            let currrent_year_string = Int(formatter.string(from: Date()))
            
            for i in StudentNumber!...currrent_year_string!{
                self.opend.append(YearAndSemester(year: i, Semester: [1, 2]))
            }
            run = false
        }
        while run{
            
        }
    }
}
