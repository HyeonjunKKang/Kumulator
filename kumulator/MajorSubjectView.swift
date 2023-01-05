//
//  MajorSubjectView.swift
//  kumulator
//
//  Created by 강현준 on 2022/09/01.
//

import Foundation
import UIKit
import FirebaseDatabase
import FirebaseAuth
import Charts

class MajorSubjectView: UIViewController{
    
    @IBOutlet weak var ComplusrotyJedgementLabel: UILabel!
    @IBOutlet weak var ComplusoryListLabel: UILabel!
    @IBOutlet weak var StudentNumberLabel: UILabel!
    @IBOutlet weak var ElectiveJedgementlabel: UILabel!
    @IBOutlet weak var UndergradatePointLabel: UILabel!
    @IBOutlet weak var UndergradatehadLabel: UILabel!
    @IBOutlet weak var UndergradateJudgementLabel: UILabel!
    
    @IBOutlet weak var ElectivePieChartView: PieChartView!
    @IBOutlet weak var ComplusoryPieChartView: PieChartView!
    var Complusoryhadcredit = 0
    var Electivehadcredit = 0
    
    var UserDataList = UserStruct()
    var CompulsorySubjectList = CompulsorySubject()
    var ElectiveSubjectList = ElectiveSubject()
    var UndergraduateSubjectList = UndergraduateSubject()
    let ref = Database.database().reference()
    let uid = Auth.auth().currentUser?.uid
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        DispatchQueue.global().async {
            self.ReadAllData()
            self.ComplusoryJedgement(StudentNmber: self.UserDataList.StudentNumber)
            self.ElectiveMajorJedgement(StudentNumber: self.UserDataList.StudentNumber)
            self.UnderGradateMajorJudgement(StudentNumber: self.UserDataList.StudentNumber)
            
            DispatchQueue.main.async {
                self.StudentNumberLabel.text = self.UserDataList.StudentNumber
                self.setChart()
            }
        }
    }
    
    @IBAction func GoToCompusorySubject(_ sender: UIButton) {
        guard let storyboard = self.storyboard?.instantiateViewController(withIdentifier: "CompulsoryMajorSubjectInputViewController") as? CompulsoryMajorSubjectInputViewController else { return }
        storyboard.modalPresentationStyle = .fullScreen
        storyboard.switchkeyword = "전공선택"
        self.present(storyboard, animated: true, completion: nil)
    }
    
    @IBAction func GotoElectiveSubject(_ sender: UIButton) {
        guard let storyboard = self.storyboard?.instantiateViewController(withIdentifier: "ElectiveMajorSubjectInputViewController") as? ElectiveMajorSubjectInputViewController else { return }
        storyboard.modalPresentationStyle = .fullScreen
        self.present(storyboard, animated: true, completion: nil)
    }
    
    @IBAction func GoToUndergraduateSubject(_ sender: UIButton) {
        guard let storyboard = self.storyboard?.instantiateViewController(withIdentifier: "UndergraduateMajorSubjectInputViewController") as? UndergraduateMajorSubjectInputViewController else { return }
        storyboard.modalPresentationStyle = .fullScreen
        self.present(storyboard, animated: true, completion: nil)
    }
    
    @IBAction func BackButton(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }
    
    //전공 필수 충족 판단
    func ComplusoryJedgement(StudentNmber: String){
        Complusoryhadcredit = 0
        var run = true
        
        //18 19 20학번의 경우
        if(StudentNmber == "18" || StudentNmber == "19" || StudentNmber == "20"){
            
            //전공 필수 목록 설명
            DispatchQueue.main.async {
                self.ComplusoryListLabel.text = "자료구조, 컴퓨터구조, 데이터베이스, 운영체제"
            }
            
            var list = [String]()
            
            for i in UserDataList.CompulsorySubjectList{
                list.append(i.SubjectName)
                Complusoryhadcredit += i.SubjectCredit
            }
                        
            let DataStructure = list.contains{ $0 == "자료구조"}
            let CS = list.contains{ $0 == "컴퓨터구조"}
            let OS = list.contains{ $0 == "운영체제"}
            let DB = list.contains{ $0 == "데이터베이스"}
            
            //모두 수강하였을 경우 pass
            if DataStructure && CS && OS && DB{
                DispatchQueue.main.async {
                    self.ComplusrotyJedgementLabel.text = "Pass"
                    self.ComplusrotyJedgementLabel.textColor = .blue
                    self.UserDataList.Judgement.CompulsorySubject = true
                }
            }else{
                DispatchQueue.main.async {
                    self.ComplusrotyJedgementLabel.text = "NonPass"
                    self.ComplusrotyJedgementLabel.textColor = .red
                    self.UserDataList.Judgement.CompulsorySubject = false

                }
            }
            run = false
        }else if(StudentNmber == "21" || StudentNmber == "22"){
            //전공 필수 목록 설명
            DispatchQueue.main.async {
                self.ComplusoryListLabel.text = "자료구조, 컴퓨터구조, 데이터베이스, 운영체제, 컴퓨터공학개론"
            }
            
            var list = [String]()
            
            for i in UserDataList.CompulsorySubjectList{
                list.append(i.SubjectName)
                Complusoryhadcredit += i.SubjectCredit
            }
                        
            let DataStructure = list.contains{ $0 == "자료구조"}
            let CS = list.contains{ $0 == "컴퓨터구조"}
            let OS = list.contains{ $0 == "운영체제"}
            let DB = list.contains{ $0 == "데이터베이스"}
            let ICE = list.contains{ $0 == "컴퓨터공학개론"}
            
            //모두 수강하였을 경우 pass
            if DataStructure && CS && OS && DB && ICE{
                DispatchQueue.main.async {
                    self.ComplusrotyJedgementLabel.text = "Pass"
                    self.ComplusrotyJedgementLabel.textColor = .blue
                    self.UserDataList.Judgement.CompulsorySubject = true
                }
            }else{
                DispatchQueue.main.async {
                    self.ComplusrotyJedgementLabel.text = "NonPass"
                    self.ComplusrotyJedgementLabel.textColor = .red
                    self.UserDataList.Judgement.CompulsorySubject = false

                }
            }
            run = false
            
        }else{
            
        }
        
        
        while run { }
    }
    
    func setChart(){
        //전공필수 차트
        var needcom = 0
        var needelective = 0
        
        if (UserDataList.StudentNumber == "18"){
            needcom = 12
            needelective = 42
            
        }else if(UserDataList.StudentNumber == "19" || UserDataList.StudentNumber == "20"){
            needcom = 12
            needelective = 48
        }else if(UserDataList.StudentNumber == "21" || UserDataList.StudentNumber == "22"){
            needcom = 15
            needelective = 45
        }
        
        //전공필수 차트
        if( Complusoryhadcredit < needcom){
            let MajorData = ["수강", "미수강"]
            let MajorCredit = [Double(Complusoryhadcredit), Double(needcom - Complusoryhadcredit)]
            self.ComplusoryPieChartView.noDataText = "데이터가 없습니다"
            self.ComplusoryPieChartView.entryLabelColor = .black
            self.ComplusoryPieChartView.legend.enabled = false
            self.ComplusoryPieChartView.noDataFont = .systemFont(ofSize: 10)
            CompulsoryChart(dataPoint: MajorData, values: MajorCredit)
        }
        else if( Complusoryhadcredit >= needcom ){
            let MajorData = ["수강"]
            let MajorCredit = [Double(Complusoryhadcredit)]
            self.ComplusoryPieChartView.noDataText = "데이터가 없습니다"
            self.ComplusoryPieChartView.entryLabelColor = .black
            self.ComplusoryPieChartView.legend.enabled = false
            self.ComplusoryPieChartView.noDataFont = .systemFont(ofSize: 10)
            CompulsoryChart(dataPoint: MajorData, values: MajorCredit)
        }
        
        //전공선택 차트
        if( Electivehadcredit < needelective){
            let MajorData = ["수강", "미수강"]
            let MajorCredit = [Double(Electivehadcredit), Double(needelective - Electivehadcredit)]
            self.ElectivePieChartView.noDataText = "데이터가 없습니다"
            self.ElectivePieChartView.entryLabelColor = .black
            self.ElectivePieChartView.legend.enabled = false
            self.ElectivePieChartView.noDataFont = .systemFont(ofSize: 10)
            ElectiveChart(dataPoint: MajorData, values: MajorCredit)
        }
        else if( Electivehadcredit >= needelective ){
            let MajorData = ["수강"]
            let MajorCredit = [Double(Electivehadcredit)]
            self.ElectivePieChartView.noDataText = "데이터가 없습니다"
            self.ElectivePieChartView.entryLabelColor = .black
            self.ElectivePieChartView.legend.enabled = false
            self.ElectivePieChartView.noDataFont = .systemFont(ofSize: 10)
            ElectiveChart(dataPoint: MajorData, values: MajorCredit)
        }
    }
    
    //전공필수설정
    func CompulsoryChart(dataPoint: [String], values : [Double]){
        var dataEntries: [PieChartDataEntry] = []
        for i in 0..<dataPoint.count{
            let dataEntry = PieChartDataEntry(value: values[i], label: dataPoint[i])
            dataEntries.append(dataEntry)
        }
        let pieChartDataSet = PieChartDataSet(entries: dataEntries, label: "전필수강정보")
        let pieChartData = PieChartData(dataSet: pieChartDataSet)
        pieChartData.notifyDataChanged()
        ComplusoryPieChartView.data = pieChartData
        pieChartData.setValueTextColor(.black)
        
        
        var colors: [UIColor] = []
        for _ in 0..<dataPoint.count {
            let red = Double(arc4random_uniform(256))
            let green = Double(arc4random_uniform(256))
            let blue = Double(arc4random_uniform(256))
            
            let color = UIColor(red: CGFloat(red/255), green: CGFloat(green/255), blue: CGFloat(blue/255), alpha: 1)
            colors.append(color)
        }
        pieChartDataSet.colors = [.systemGreen, .systemGray]
        
    }
    
    //전공선택차트설정
    func ElectiveChart(dataPoint: [String], values : [Double]){
        var dataEntries: [PieChartDataEntry] = []
        for i in 0..<dataPoint.count{
            let dataEntry = PieChartDataEntry(value: values[i], label: dataPoint[i])
            dataEntries.append(dataEntry)
        }
        let pieChartDataSet = PieChartDataSet(entries: dataEntries, label: "전선수강정보")
        let pieChartData = PieChartData(dataSet: pieChartDataSet)
        pieChartData.notifyDataChanged()
        ElectivePieChartView.data = pieChartData
        pieChartData.setValueTextColor(.black)
        
        
        var colors: [UIColor] = []
        for _ in 0..<dataPoint.count {
            let red = Double(arc4random_uniform(256))
            let green = Double(arc4random_uniform(256))
            let blue = Double(arc4random_uniform(256))
            
            let color = UIColor(red: CGFloat(red/255), green: CGFloat(green/255), blue: CGFloat(blue/255), alpha: 1)
            colors.append(color)
        }
        pieChartDataSet.colors = [.systemGreen, .systemGray]
        
    }
    
    //전공 선택 요건 판단
    func ElectiveMajorJedgement(StudentNumber: String){
        var run = true
        
        Electivehadcredit = 0
        
        //18 19 20학번의 경우
        if(StudentNumber == "18"){
            //전공선택 필요학점 설명
            
            
            var count = 0
                        
            for i in UserDataList.ElectiveSubjectList{
                count += i.SubjectCredit
                Electivehadcredit += i.SubjectCredit
            }
            
            
            
            //필요학점 이상일 경우
            if count >= ElectiveRequirement18{
                DispatchQueue.main.async {
                    self.ElectiveJedgementlabel.text = "Pass"
                    self.ElectiveJedgementlabel.textColor = .blue
                    self.UserDataList.Judgement.ElectiveSubject = true
                }
            }else{
                DispatchQueue.main.async {
                    self.ElectiveJedgementlabel.text = "NonPass"
                    self.ElectiveJedgementlabel.textColor = .red
                    self.UserDataList.Judgement.ElectiveSubject = false

                }
            }
            run = false
        }else if(StudentNumber == "19" || StudentNumber == "20"){
            //전공선택 필요학점 설명
            
            
            var count = 0
                        
            for i in UserDataList.ElectiveSubjectList{
                count += i.SubjectCredit
                Electivehadcredit += i.SubjectCredit
            }
            
            
            
            //필요학점 이상일 경우
            if count >= ElectiveRequirement19to20{
                DispatchQueue.main.async {
                    self.ElectiveJedgementlabel.text = "Pass"
                    self.ElectiveJedgementlabel.textColor = .blue
                    self.UserDataList.Judgement.ElectiveSubject = true
                }
            }else{
                DispatchQueue.main.async {
                    self.ElectiveJedgementlabel.text = "NonPass"
                    self.ElectiveJedgementlabel.textColor = .red
                    self.UserDataList.Judgement.ElectiveSubject = false
                }
            }
            run = false
            
        }else if(StudentNumber == "21" || StudentNumber == "22") {
            //전공선택 필요학점 설명
            
            var count = 0
                        
            for i in UserDataList.ElectiveSubjectList{
                count += i.SubjectCredit
                Electivehadcredit += i.SubjectCredit
            }
            
            //필요학점 이상일 경우
            if count >= ElectiveRequirement21to22{
                DispatchQueue.main.async {
                    self.ElectiveJedgementlabel.text = "Pass"
                    self.ElectiveJedgementlabel.textColor = .blue
                    self.UserDataList.Judgement.ElectiveSubject = true
                }
            }else{
                DispatchQueue.main.async {
                    self.ElectiveJedgementlabel.text = "NonPass"
                    self.ElectiveJedgementlabel.textColor = .red
                    self.UserDataList.Judgement.ElectiveSubject = false

                }
            }
            run = false
        }
        while run { }
    }
    
    //학부공통 졸업요건 판단.
    func UnderGradateMajorJudgement(StudentNumber: String){
        var run = true
        
        //18학번의 경우
        if(StudentNumber == "18"){
            //학부공통 필요학점 설명
            DispatchQueue.main.async {
                self.UndergradatePointLabel.text = "/"+String(UndergradateRequirement18)
            }
            
            var count = 0
                        
            for i in UserDataList.UndergraduateSubject{
                count += i.SubjectCredit
            }
            
            DispatchQueue.main.async {
                self.UndergradatehadLabel.text = String(count)
            }
            
            //필요학점 이상일 경우
            if count >= UndergradateRequirement18{
                DispatchQueue.main.async {
                    self.UndergradateJudgementLabel.text = "Pass"
                    self.UndergradateJudgementLabel.textColor = .blue
                    self.UserDataList.Judgement.UndergraduateSubject = true
                }
            }else{
                DispatchQueue.main.async {
                    self.UndergradateJudgementLabel.text = "NonPass"
                    self.UndergradateJudgementLabel.textColor = .red
                    self.UserDataList.Judgement.UndergraduateSubject = false

                }
            }
            run = false
        }else{
            //학부공통 필요학점 설명
            DispatchQueue.main.async {
                self.UndergradatePointLabel.text = "/"+String(UndergradateRequirement19to22)
            }
            
            var count = 0
                        
            for i in UserDataList.UndergraduateSubject{
                count += i.SubjectCredit
            }
            
            DispatchQueue.main.async {
                self.UndergradatehadLabel.text = String(count)
            }
            
            //필요학점 이상일 경우
            if count >= UndergradateRequirement19to22{
                DispatchQueue.main.async {
                    self.UndergradateJudgementLabel.text = "Pass"
                    self.UndergradateJudgementLabel.textColor = .blue
                    self.UserDataList.Judgement.UndergraduateSubject = true
                }
            }else{
                DispatchQueue.main.async {
                    self.UndergradateJudgementLabel.text = "NonPass"
                    self.UndergradateJudgementLabel.textColor = .red
                    self.UserDataList.Judgement.UndergraduateSubject = false
                }
            }
            run = false
        }
        while run { }
    }

    //데이터를 읽어오는 함수
    func ReadAllData(){
        self.UserDataList = UserStruct()
        var run = true
        
        ref.queryOrderedByKey().observeSingleEvent(of:.value){ snapshot, err in
            guard let value = snapshot.value else { return }
            
            
            let CompulsorySubjectSnapshot = snapshot.childSnapshot(forPath: "CompulsoryMajorHistory").childSnapshot(forPath: self.uid!)
            let ElectiveSubjectListSnapshot = snapshot.childSnapshot(forPath: "ElectiveMajorHistory").childSnapshot(forPath: self.uid!)
            let UndergraduateSubjectSnapshot = snapshot.childSnapshot(forPath: "UndergraduateMajorHistory").childSnapshot(forPath: self.uid!)
            let UserSnapshot = snapshot.childSnapshot(forPath: "User").childSnapshot(forPath: self.uid!)
            
            let UserItem = UserSnapshot.value as? [String: Any] ?? [:]
            self.UserDataList.Id = UserItem["id"] as? String ?? "Error"
            self.UserDataList.StudentNumber = UserItem["StudentNumber"] as? String ?? "Error"
            self.UserDataList.EnteranceClassification = UserItem["EnteranceClassification"] as? String ?? "Error"
            
            let ComplusorySubjectItem = CompulsorySubjectSnapshot.value as? [String: Any] ?? [:]
            for index in ComplusorySubjectItem{
                for i in 0...self.CompulsorySubjectList.CompulsorySubjectList.count - 1{
                    if index.value as! String == self.CompulsorySubjectList.CompulsorySubjectList[i].SubjectName{
                        self.UserDataList.CompulsorySubjectList.append(Subject(SubjectName: index.value as! String, SubjectCredit: self.CompulsorySubjectList.CompulsorySubjectList[i].SubjectCredit))
                    }
                }
            }
            
            let ElectiveSubjectItem = ElectiveSubjectListSnapshot.value as? [String: Any] ?? [:]
            for index in ElectiveSubjectItem{
                for i in 0...self.ElectiveSubjectList.ElectSubjectList.count - 1{
                    if index.value as! String == self.ElectiveSubjectList.ElectSubjectList[i].SubjectName{
                        self.UserDataList.ElectiveSubjectList.append(Subject(SubjectName: index.value as! String, SubjectCredit: self.ElectiveSubjectList.ElectSubjectList[i].SubjectCredit))
                    }
                }
            }
            
            
            let UndergraduateSubjectItem = UndergraduateSubjectSnapshot.value as? [String: Any] ?? [:]
            for index in UndergraduateSubjectItem{
                for i in 0...self.UndergraduateSubjectList.UndergraduateSubjectList.count - 1{
                    if index.value as! String == self.UndergraduateSubjectList.UndergraduateSubjectList[i].SubjectName{
                        self.UserDataList.UndergraduateSubject.append(Subject(SubjectName: index.value as! String, SubjectCredit: self.UndergraduateSubjectList.UndergraduateSubjectList[i].SubjectCredit))
                    }
                }
            }
            
            run = false
        }
        while run{

        }
    }
    
}
