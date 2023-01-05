//
//  MainViewController.swift
//  kumulator
//
//  Created by 강현준 on 2022/03/30.
//

import UIKit
import FirebaseAuth
import FirebaseDatabase
import Charts

class MainViewController: UIViewController  {
    
    var UserDataList: UserStruct = UserStruct()
    var CompulsorySubjectList = CompulsorySubject()
    var ElectiveSubjectList = ElectiveSubject()
    var UndergraduateSubjectList = UndergraduateSubject()
    var LiberalKUPersonalityList = LiberalKUPersonality()
    var LiberalWritingList = LiberalWriting()
    var LiberalDiscussionList = LiberalDiscussion()
    var LiberalBasicForeignList = LiberalBasicForeign()
    var LiberalBasicHumanitiesList = LiberalBasicHumanities()
    var LiberalBasicScienceList = LiberalBasicScience()
    var PracticalKnowledgeList = PracticalKnowledge()
    var PracticalSkillList = PracticalSkill()
    
    var uid = Auth.auth().currentUser?.uid
    var ref: DatabaseReference!
    let id = Auth.auth().currentUser?.email ?? "id"
    let semaphore = DispatchSemaphore(value: 0)
    
    
    var needall = 132
    var Majorneed = 66
    var Liberalartneed = 66
    
    var allhadcredit = 0
    var Majorhadcredit = 0
    var InsufficientMajorCredit = 0
    var InsufficientLiberalartCredit = 0
    var Liberalarthadcredit = 0
    
    
    @IBOutlet weak var MajorPieChartView: PieChartView!
    @IBOutlet weak var LiberalartPieChartView: PieChartView!
    @IBOutlet weak var UnionPieChartView: PieChartView!
    
    @IBOutlet weak var GraduationLanguageJudgementLabel: UILabel!
    @IBOutlet weak var GraduationWorkJudgementLabel: UILabel!
    @IBOutlet weak var StudentNumberLabel: UILabel!
    @IBOutlet weak var DescripResultLabel: UILabel!
    @IBOutlet weak var InsufficientLabel: UILabel!
    
    
    override func viewDidLoad()   {
        super.viewDidLoad()
        
        navigationController?.navigationBar.isHidden = true
        navigationController?.interactivePopGestureRecognizer?.isEnabled = false
        
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        DispatchQueue.global().async {
            self.ReadAllData()
            self.sumCredit()
            self.Judgement(StudentNmber: self.UserDataList.StudentNumber)
            self.Grapics()
            DispatchQueue.main.async {
                self.setChart()
            }
        }
        
    }
    
    func setChart(){
        //전공차트
        if( Majorhadcredit <= 66){
            let MajorData = ["수강", "미수강"]
            let MajorCredit = [Double(Majorhadcredit), Double(InsufficientMajorCredit)]
            self.MajorPieChartView.noDataText = "데이터가 없습니다"
            self.MajorPieChartView.entryLabelColor = .black
            self.MajorPieChartView.legend.enabled = false
            self.MajorPieChartView.noDataFont = .systemFont(ofSize: 10)
            MajorChart(dataPoint: MajorData, values: MajorCredit)
        }
        else if( Majorhadcredit > 66 ){
            let MajorData = ["수강"]
            let MajorCredit = [Double(Majorhadcredit)]
            self.MajorPieChartView.noDataText = "데이터가 없습니다"
            self.MajorPieChartView.entryLabelColor = .black
            self.MajorPieChartView.legend.enabled = false
            self.MajorPieChartView.noDataFont = .systemFont(ofSize: 10)
            MajorChart(dataPoint: MajorData, values: MajorCredit)
        }
        
        
        //교양차트
        if( InsufficientLiberalartCredit >= 0 ){
            let LiberalArtData = ["수강", "미수강"]
            let LIberalArtCredit = [Double(Liberalarthadcredit), Double(InsufficientLiberalartCredit)]
            self.LiberalartPieChartView.noDataText = "데이터가 없습니다"
            self.LiberalartPieChartView.entryLabelColor = .black
            self.LiberalartPieChartView.legend.enabled = false
            self.LiberalartPieChartView.noDataFont = .systemFont(ofSize: 10)
            LiberalArtChart(dataPoint: LiberalArtData, values: LIberalArtCredit)
        }
        else if( InsufficientLiberalartCredit <= 0){
            let LiberalArtData = ["수강"]
            let LIberalArtCredit = [Double(Liberalarthadcredit)]
            self.LiberalartPieChartView.noDataText = "데이터가 없습니다"
            self.LiberalartPieChartView.entryLabelColor = .black
            self.LiberalartPieChartView.legend.enabled = false
            self.LiberalartPieChartView.noDataFont = .systemFont(ofSize: 10)
            LiberalArtChart(dataPoint: LiberalArtData, values: LIberalArtCredit)
        }
        
        
        
        //전체학점
        if(needall - Majorhadcredit - Liberalarthadcredit >= 0){
            let UnionData = ["전공수강", "교양수강", "미수강"]
            let UnionCredit = [Double(Majorhadcredit), Double(Liberalarthadcredit), Double(needall - Majorhadcredit - Liberalarthadcredit )]
            self.UnionPieChartView.noDataText = "데이터가 없습니다"
            self.UnionPieChartView.entryLabelColor = .black
            self.UnionPieChartView.legend.enabled = false
            self.UnionPieChartView.noDataFont = .systemFont(ofSize: 10)
            UnionChart(dataPoint: UnionData, values: UnionCredit)
        }
        else if(needall - Majorhadcredit - Liberalarthadcredit < 0){
            let UnionData = ["전공수강", "교양수강"]
            let UnionCredit = [Double(Majorhadcredit), Double(Liberalarthadcredit)]
            self.UnionPieChartView.noDataText = "데이터가 없습니다"
            self.UnionPieChartView.entryLabelColor = .black
            self.UnionPieChartView.legend.enabled = false
            self.UnionPieChartView.noDataFont = .systemFont(ofSize: 10)
            UnionChart(dataPoint: UnionData, values: UnionCredit)
        }
    }
    
    //전공차트설정
    func MajorChart(dataPoint: [String], values : [Double]){
        var dataEntries: [PieChartDataEntry] = []
        for i in 0..<dataPoint.count{
            let dataEntry = PieChartDataEntry(value: values[i], label: dataPoint[i])
            dataEntries.append(dataEntry)
        }
        let pieChartDataSet = PieChartDataSet(entries: dataEntries, label: "전공수강정보")
        let pieChartData = PieChartData(dataSet: pieChartDataSet)
        pieChartData.notifyDataChanged()
        MajorPieChartView.data = pieChartData
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
    
    //교양수강차트설정함수
    func LiberalArtChart(dataPoint: [String], values : [Double]){
        var dataEntries: [PieChartDataEntry] = []
        for i in 0..<dataPoint.count{
            let dataEntry = PieChartDataEntry(value: values[i], label: dataPoint[i])
            dataEntries.append(dataEntry)
        }
        let pieChartDataSet = PieChartDataSet(entries: dataEntries, label: "교양수강정보")
        let pieChartData = PieChartData(dataSet: pieChartDataSet)
        pieChartData.notifyDataChanged()
        LiberalartPieChartView.data = pieChartData
        pieChartData.setValueTextColor(.black)
        
        var colors: [UIColor] = []
        for _ in 0..<dataPoint.count {
            let red = Double(arc4random_uniform(256))
            let green = Double(arc4random_uniform(256))
            let blue = Double(arc4random_uniform(256))
            
            let color = UIColor(red: CGFloat(red/255), green: CGFloat(green/255), blue: CGFloat(blue/255), alpha: 1)
            colors.append(color)
        }
        pieChartDataSet.colors = [.systemOrange, .systemGray]
        
    }
    
    //전체차트설정
    func UnionChart(dataPoint: [String], values : [Double]){
        var dataEntries: [PieChartDataEntry] = []
        for i in 0..<dataPoint.count{
            let dataEntry = PieChartDataEntry(value: values[i], label: dataPoint[i])
            dataEntries.append(dataEntry)
        }
        let pieChartDataSet = PieChartDataSet(entries: dataEntries, label: "전체정보")
        let pieChartData = PieChartData(dataSet: pieChartDataSet)
        pieChartData.notifyDataChanged()
        UnionPieChartView.data = pieChartData
        pieChartData.setValueTextColor(.black)
        
        var colors: [UIColor] = []
        for _ in 0..<dataPoint.count {
            let red = Double(arc4random_uniform(256))
            let green = Double(arc4random_uniform(256))
            let blue = Double(arc4random_uniform(256))
            
            let color = UIColor(red: CGFloat(red/255), green: CGFloat(green/255), blue: CGFloat(blue/255), alpha: 1)
            colors.append(color)
        }
        pieChartDataSet.colors = [.systemGreen, .orange, .systemGray]
        
    }
    
    
    override func viewWillDisappear(_ animated: Bool) {
    }
    
    
    //전공 입력화면 이동 버튼
    @IBAction func GoToMajorSubjectButton(_ sender: UIButton) {
        guard let storyboard = self.storyboard?.instantiateViewController(identifier: "MajorSubjectView") as? MajorSubjectView else { return }
        storyboard.modalPresentationStyle = .fullScreen
        self.present(storyboard, animated: true, completion: nil)
    }
    
    //기초교양 입력화면 이동버튼
    @IBAction func BasicLiberalButton(_ sender: UIButton) {
        guard let storyboard = self.storyboard?.instantiateViewController(withIdentifier: "BasicLiberalViewController") as? BasicLiberalViewController else { return }
        storyboard.modalPresentationStyle = .fullScreen
        self.present(storyboard, animated: true, completion: nil)
    }
    
    //심화교양 입력화면 이동버튼
    @IBAction func DepthLiberalButton(_ sender: UIButton) {
        guard let storyboard = self.storyboard?.instantiateViewController(withIdentifier: "DepthLiberalInputViewController") as? DepthLiberalInputViewController else { return }
        storyboard.modalPresentationStyle = .fullScreen
        self.present(storyboard, animated: true, completion: nil)
    }
    
    //KU소양 입력화면 이동버튼
    @IBAction func KUKnowledButton(_ sender: UIButton) {
        guard let storyboard = self.storyboard?.instantiateViewController(withIdentifier: "KUKnowledgeViewController") as? KUKnowledgeViewController else { return }
        storyboard.modalPresentationStyle = .fullScreen
        self.present(storyboard, animated: true, completion: nil)
    }
    
    //졸업요건 언어영역 이동보튼
    @IBAction func GraduationLanguageButton(_ sender: UIButton) {
        guard let storyboard = self.storyboard?.instantiateViewController(withIdentifier: "GraduationLanguageViewController") as? GraduationLanguageViewController else { return }
        storyboard.modalPresentationStyle = .fullScreen
        self.present(storyboard, animated: true, completion: nil)
    }
    
    //졸업작품 이동버튼
    @IBAction func GraduationWorkButton(_ sender: UIButton) {
        guard let storyboard = self.storyboard?.instantiateViewController(withIdentifier: "GraduationWorkViewController") as? GraduationWorkViewController else { return }
        storyboard.modalPresentationStyle = .fullScreen
        self.present(storyboard, animated: true, completion: nil)
    }
    
    @IBAction func GotoInsertDataViewButton(_ sender: UIButton) {
        let storyboard = UIStoryboard(name: "Main", bundle: Bundle.main)
        let InsertUserDataVIewController = storyboard.instantiateViewController(withIdentifier: "InsertUserDataVIewController")
        InsertUserDataVIewController.modalPresentationStyle = .fullScreen
        navigationController?.show(InsertUserDataVIewController, sender: nil)
    }
    
    //사용자 데이터 읽기ver.1
    func ReadUserDatafromFireBase()  {
        ref =  Database.database().reference()
        
        DispatchQueue.global().sync {
            ref.child("User").child(self.uid!).observe(.value){ snapshot in
                guard let value =  snapshot.value as? [String: Any] else { return }
                do{
                    let jsonData =  try JSONSerialization.data(withJSONObject: value)
                    let userData = try JSONDecoder().decode(UserStruct.self, from: jsonData)
                    
                    let userlist = userData
                    
                    DispatchQueue.main.sync {
                        self.UserDataList = userlist
                    }
                    
                }catch let error{
                    print("Error Json parsing \(error.localizedDescription)")
                }
            }
        }
    }
    
    //사용자 데이터 읽기ver.2
    func ReadUserDatafromFireBase2()  {
        
        //run = 동기처리
        var run = true
        ref = Database.database().reference()
        ref.child("User").child(self.uid!).observe(.value){ snapshot in
            guard let value =  snapshot.value as? NSDictionary else {return}
            self.UserDataList.Id = value["id"] as? String ?? "No string"
            self.UserDataList.StudentNumber = value["StudentNumber"] as? String ?? "No StudentNumber"
            //            self.UserDataList.PhoneNumber = value["PhoneNumber"] as? String ?? "No PhoneNumber"
            run = false
        }
        while run{
            
        }
    }
    
    //수강한 학점을 구하는 함수
    func sumCredit(){
        //전공 학점 합치기
        Majorhadcredit = 0
        Liberalarthadcredit = 0
        
        for i in self.UserDataList.CompulsorySubjectList{
            Majorhadcredit += i.SubjectCredit
        }
        for i in self.UserDataList.ElectiveSubjectList{
            Majorhadcredit += i.SubjectCredit
        }
        for i in self.UserDataList.UndergraduateSubject{
            Majorhadcredit += i.SubjectCredit
        }
        
        //교양 학점 합치기
        for i in self.UserDataList.PracticalSkill{
            Liberalarthadcredit += i.SubjectCredit
        }
        for i in self.UserDataList.PracticalKnowledge{
            Liberalarthadcredit += i.SubjectCredit
        }
        for i in self.UserDataList.LiberalBasicForeign{
            Liberalarthadcredit += i.SubjectCredit
        }
        for i in self.UserDataList.LiberalBasicScience{
            Liberalarthadcredit += i.SubjectCredit
        }
        for i in self.UserDataList.LiberalBasicHumanities{
            Liberalarthadcredit += i.SubjectCredit
        }
        for i in self.UserDataList.LiberalDiscussion{
            Liberalarthadcredit += i.SubjectCredit
        }
        for i in self.UserDataList.LiberalKUPersonality{
            Liberalarthadcredit += i.SubjectCredit
        }
        for i in self.UserDataList.LiberalWriting{
            Liberalarthadcredit += i.SubjectCredit
        }
        
        let i = UserDataList
        
        Liberalarthadcredit = Liberalarthadcredit + i.GlobalLanguage + i.HumanAndSocial + i.ScienceandTechnology + i.ArtsAndPhysicalEducation + i.Convergence
        
        InsufficientMajorCredit = Majorneed - Majorhadcredit
        InsufficientLiberalartCredit = needall - Majorhadcredit - Liberalarthadcredit
        
    }
    
    //사용자  유저데이터 읽기 ver.1.메인
    private func ReadUserDataFromFirebase3() {
        var run = true
        ref = Database.database().reference()
        //사용자의 유저정보를 가져옴
        ref.child("User").child(uid!).observe(.value){ snapshot in
            guard let value = snapshot.value as? NSDictionary else { return }
            self.UserDataList.Id = value["id"] as? String ?? "error"
            self.UserDataList.StudentNumber = value["StudentNumber"] as? String ?? "error"
            self.UserDataList.EnteranceClassification = value["EnteranceClassification"] as? String ?? "error"
            run = false
        }
    }
    
    //판단을 통한 그래픽 정리
    func Grapics(){
        
        //외국어 영역 그래피
        if self.UserDataList.Judgement.GraduationLanguage{
            DispatchQueue.main.async {
                self.GraduationLanguageJudgementLabel.text = "Pass"
                self.GraduationLanguageJudgementLabel.textColor = .blue
            }
        }else{
            DispatchQueue.main.async {
                self.GraduationLanguageJudgementLabel.text = "NonPass"
                self.GraduationLanguageJudgementLabel.textColor = .red
                
            }
        }
        
        //졸업작품 그래픽
        if self.UserDataList.Judgement.GraduationWork{
            DispatchQueue.main.async {
                self.GraduationWorkJudgementLabel.text = "Pass"
                self.GraduationWorkJudgementLabel.textColor = .blue
            }
        }else{
            DispatchQueue.main.async {
                self.GraduationWorkJudgementLabel.text = "NonPass"
                self.GraduationWorkJudgementLabel.textColor = .red
                
            }
        }
        
        if(UserDataList.Judgement.allpassnonpass == true){
            DispatchQueue.main.async {
                self.DescripResultLabel.text = "Pass"
                self.DescripResultLabel.textColor = .blue
                self.InsufficientLabel.isHidden = true
                self.DescripResultLabel.textAlignment = .center
                self.DescripResultLabel.font = UIFont.systemFont(ofSize: 20)
            }
        }else{
            DispatchQueue.main.async {
                self.InsufficientLabel.isHidden = false
                self.DescripResultLabel.text = ""
                self.DescripResultLabel.textAlignment = .left
                self.DescripResultLabel.textColor = .red
                self.DescripResultLabel.font = UIFont.systemFont(ofSize: 15)
            }
            
            if(UserDataList.Judgement.CompulsorySubject == false){
                DispatchQueue.main.async {
                    self.DescripResultLabel.text?.append(" 전공필수")
                }
            }
            if(UserDataList.Judgement.ElectiveSubject == false){
                DispatchQueue.main.async {
                    self.DescripResultLabel.text?.append(" 전공선택")
                }
            }
            if(UserDataList.Judgement.UndergraduateSubject == false){
                DispatchQueue.main.async {
                    self.DescripResultLabel.text?.append(" 학부공통")
                }
            }
            if(UserDataList.Judgement.LiberalKUPersonality == false){
                DispatchQueue.main.async {
                    self.DescripResultLabel.text?.append(" KU인성")
                }
            }
            if(UserDataList.Judgement.LiberalWriting == false){
                DispatchQueue.main.async {
                    self.DescripResultLabel.text?.append(" 글쓰기")
                }
            }
            if(UserDataList.Judgement.LiberalDiscussion == false){
                DispatchQueue.main.async {
                    self.DescripResultLabel.text?.append(" 발표와토론")
                }
            }
            if(UserDataList.Judgement.LiberalBasicForeign == false){
                DispatchQueue.main.async {
                    self.DescripResultLabel.text?.append(" 외국어기초")
                }
            }
            if(UserDataList.Judgement.LiberalBasicHumanities == false){
                DispatchQueue.main.async {
                    self.DescripResultLabel.text?.append(" 인문기초")
                }
            }
            if(UserDataList.Judgement.LiberalBasicScience == false){
                DispatchQueue.main.async {
                    self.DescripResultLabel.text?.append(" 과학기초")
                }
            }
            if(UserDataList.Judgement.PracticalKnowledge == false){
                DispatchQueue.main.async {
                    self.DescripResultLabel.text?.append(" 실무소양")
                }
            }
            if(UserDataList.Judgement.PracticalSkill == false){
                DispatchQueue.main.async {
                    self.DescripResultLabel.text?.append(" 실기소양")
                }
            }
            if(UserDataList.Judgement.DepthLiberal == false){
                DispatchQueue.main.async {
                    self.DescripResultLabel.text?.append(" 심화교양")
                }
            }
            if(UserDataList.Judgement.GraduationWork == false){
                DispatchQueue.main.async {
                    self.DescripResultLabel.text?.append(" 졸업작품")
                }
            }
            if(UserDataList.Judgement.GraduationLanguage == false){
                DispatchQueue.main.async {
                    self.DescripResultLabel.text?.append(" 외국어인증")
                }
            }
            if(Majorhadcredit + Liberalarthadcredit < 132){
                DispatchQueue.main.async {
                    self.DescripResultLabel.text?.append(" 학점부족")
                }
            }
            
        }
        
    }
    func ReadAllData(){
        //데이터를 읽기전에 구조체를 초기화한다. 배열에 append(하기때문에 읽을 때 마다 요소들이 축가되어 중복됨)
        self.UserDataList = UserStruct()
        
        ref = Database.database().reference()
        var run = true
        
        ref.queryOrderedByKey().observe(.value){ snapshot, err in
            guard let value = snapshot.value else { return }
            
            let CompulsorySubjectSnapshot = snapshot.childSnapshot(forPath: "CompulsoryMajorHistory").childSnapshot(forPath: self.uid!)
            let ElectiveSubjectListSnapshot = snapshot.childSnapshot(forPath: "ElectiveMajorHistory").childSnapshot(forPath: self.uid!)
            let UndergraduateSubjectSnapshot = snapshot.childSnapshot(forPath: "UndergraduateMajorHistory").childSnapshot(forPath: self.uid!)
            let LiberalKUPersonalitySnapshot = snapshot.childSnapshot(forPath: "LiberalKUPersonality").childSnapshot(forPath: self.uid!)
            let LiberalWritingSnapshot = snapshot.childSnapshot(forPath: "LiberalWriting").childSnapshot(forPath: self.uid!)
            let LiberalDiscussionSnapshot = snapshot.childSnapshot(forPath: "LiberalDiscussion").childSnapshot(forPath: self.uid!)
            let LiberalBasicForeignSnapshot = snapshot.childSnapshot(forPath: "LiberalBasicForeign").childSnapshot(forPath: self.uid!)
            let LiberalBasicHumanitiesSnapshot = snapshot.childSnapshot(forPath: "LiberalBasicHumanities").childSnapshot(forPath: self.uid!)
            let LiberalBasicScienceSnapshot = snapshot.childSnapshot(forPath: "LiberalBasicScience").childSnapshot(forPath: self.uid!)
            let PracticalKnowledgeSnapshot = snapshot.childSnapshot(forPath: "PracticalKnowledge").childSnapshot(forPath: self.uid!)
            let PracticalSkillSnapshot = snapshot.childSnapshot(forPath: "PracticalSkill").childSnapshot(forPath: self.uid!)
            let DepthLiberalSnapshot = snapshot.childSnapshot(forPath: "DepthLiberal").childSnapshot(forPath: self.uid!)
            let UserSnapshot = snapshot.childSnapshot(forPath: "User").childSnapshot(forPath: self.uid!)
            
            //전공필수
            let ComplusorySubjectItem = CompulsorySubjectSnapshot.value as? [String: Any] ?? [:]
            for index in ComplusorySubjectItem{
                for i in 0...self.CompulsorySubjectList.CompulsorySubjectList.count - 1{
                    if index.value as! String == self.CompulsorySubjectList.CompulsorySubjectList[i].SubjectName{
                        self.UserDataList.CompulsorySubjectList.append(Subject(SubjectName: index.value as! String, SubjectCredit: self.CompulsorySubjectList.CompulsorySubjectList[i].SubjectCredit))
                    }
                }
            }
            
            //전공선택
            let ElectiveSubjectItem = ElectiveSubjectListSnapshot.value as? [String: Any] ?? [:]
            for index in ElectiveSubjectItem{
                for i in 0...self.ElectiveSubjectList.ElectSubjectList.count - 1{
                    if index.value as! String == self.ElectiveSubjectList.ElectSubjectList[i].SubjectName{
                        self.UserDataList.ElectiveSubjectList.append(Subject(SubjectName: index.value as! String, SubjectCredit: self.ElectiveSubjectList.ElectSubjectList[i].SubjectCredit))
                    }
                }
            }
            
            //학부공통
            let UndergraduateSubjectItem = UndergraduateSubjectSnapshot.value as? [String: Any] ?? [:]
            for index in UndergraduateSubjectItem{
                for i in 0...self.UndergraduateSubjectList.UndergraduateSubjectList.count - 1{
                    if index.value as! String == self.UndergraduateSubjectList.UndergraduateSubjectList[i].SubjectName{
                        self.UserDataList.UndergraduateSubject.append(Subject(SubjectName: index.value as! String, SubjectCredit: self.UndergraduateSubjectList.UndergraduateSubjectList[i].SubjectCredit))
                    }
                }
            }
            
            //KU소양
            let LiberalKUPersonalityItem = LiberalKUPersonalitySnapshot.value as? [String: Any] ?? [:]
            for index in LiberalKUPersonalityItem{
                for i in 0...self.LiberalKUPersonalityList.LiberalKUPersounality.count - 1{
                    if index.value as! String == self.LiberalKUPersonalityList.LiberalKUPersounality[i].SubjectName{
                        self.UserDataList.LiberalKUPersonality.append(Subject(SubjectName: index.value as! String, SubjectCredit: self.LiberalKUPersonalityList.LiberalKUPersounality[i].SubjectCredit))
                    }
                }
            }
            
            //글쓰기
            let LiberalWritingItem = LiberalWritingSnapshot.value as? [String: Any] ?? [:]
            for index in LiberalWritingItem{
                for i in 0...self.LiberalWritingList.LiberalWriting.count - 1{
                    if index.value as! String == self.LiberalWritingList.LiberalWriting[i].SubjectName{
                        self.UserDataList.LiberalWriting.append(Subject(SubjectName: index.value as! String, SubjectCredit: self.LiberalWritingList.LiberalWriting[i].SubjectCredit))
                    }
                }
            }
            
            //발표와토론
            let LiberalDiscussionItem = LiberalDiscussionSnapshot.value as? [String: Any] ?? [:]
            for index in LiberalDiscussionItem{
                for i in 0...self.LiberalDiscussionList.LiberalDiscussion.count - 1{
                    if index.value as! String == self.LiberalDiscussionList.LiberalDiscussion[i].SubjectName{
                        self.UserDataList.LiberalDiscussion.append(Subject(SubjectName: index.value as! String, SubjectCredit: self.LiberalDiscussionList.LiberalDiscussion[i].SubjectCredit))
                    }
                }
            }
            
            //외국어기초
            let LiberalBasicForeignItem = LiberalBasicForeignSnapshot.value as? [String: Any] ?? [:]
            for index in LiberalBasicForeignItem{
                for i in 0...self.LiberalBasicForeignList.LiberalBasicForeign.count - 1{
                    if index.value as! String == self.LiberalBasicForeignList.LiberalBasicForeign[i].SubjectName{
                        self.UserDataList.LiberalBasicForeign.append(Subject(SubjectName: index.value as! String, SubjectCredit: self.LiberalBasicForeignList.LiberalBasicForeign[i].SubjectCredit))
                    }
                }
            }
            
            //인문기초
            let LiberalBasicHumanitiesItem = LiberalBasicHumanitiesSnapshot.value as? [String: Any] ?? [:]
            for index in LiberalBasicHumanitiesItem{
                for i in 0...self.LiberalBasicHumanitiesList.LiberalBasicHumanities.count - 1{
                    if index.value as! String == self.LiberalBasicHumanitiesList.LiberalBasicHumanities[i].SubjectName{
                        self.UserDataList.LiberalBasicHumanities.append(Subject(SubjectName: index.value as! String, SubjectCredit: self.LiberalBasicHumanitiesList.LiberalBasicHumanities[i].SubjectCredit))
                    }
                }
            }
            
            //과학기초
            let LiberalBasicScienceItem = LiberalBasicScienceSnapshot.value as? [String: Any] ?? [:]
            for index in LiberalBasicScienceItem{
                for i in 0...self.LiberalBasicScienceList.LiberalBasicScience.count - 1{
                    if index.value as! String == self.LiberalBasicScienceList.LiberalBasicScience[i].SubjectName{
                        self.UserDataList.LiberalBasicScience.append(Subject(SubjectName: index.value as! String, SubjectCredit: self.LiberalBasicScienceList.LiberalBasicScience[i].SubjectCredit))
                    }
                }
            }
            
            //실무소양
            let PracticalKnowledgeItem = PracticalKnowledgeSnapshot.value as? [String: Any] ?? [:]
            for index in PracticalKnowledgeItem{
                for i in 0...self.PracticalKnowledgeList.PracticalKnowledge.count - 1{
                    if index.value as! String == self.PracticalKnowledgeList.PracticalKnowledge[i].SubjectName{
                        self.UserDataList.PracticalKnowledge.append(Subject(SubjectName: index.value as! String, SubjectCredit: self.PracticalKnowledgeList.PracticalKnowledge[i].SubjectCredit))
                    }
                }
            }
            
            //실기소양
            let PracticalSkillItem = PracticalSkillSnapshot.value as? [String: Any] ?? [:]
            for index in PracticalSkillItem{
                for i in 0...self.PracticalSkillList.PracticalSkill.count - 1{
                    if index.value as! String == self.PracticalSkillList.PracticalSkill[i].SubjectName{
                        self.UserDataList.PracticalSkill.append(Subject(SubjectName: index.value as! String, SubjectCredit: self.PracticalSkillList.PracticalSkill[i].SubjectCredit))
                    }
                }
            }
            
            //외국어 인증
            let LaguagueItem = snapshot.childSnapshot(forPath: "GraduationLanguage").childSnapshot(forPath: self.uid!).value as? [String: Any] ?? [:]
            
            if LaguagueItem["Pass"] as? String ?? "false" == "true"{
                self.UserDataList.Judgement.GraduationLanguage = true
            }else{
                self.UserDataList.Judgement.GraduationLanguage = false
            }
            
            //졸업작품
            let WorkItem = snapshot.childSnapshot(forPath: "GraduationWork").childSnapshot(forPath: self.uid!).value as? [String: Any] ?? [:]
            if WorkItem["Pass"] as? String ?? "false" == "true"{
                self.UserDataList.Judgement.GraduationWork = true
            } else {
                self.UserDataList.Judgement.GraduationWork = false
            }
            
            
            
            //User정보
            let UserItem = UserSnapshot.value as? [String: Any] ?? [:]
            self.UserDataList.Id = UserItem["id"] as? String ?? "Error"
            self.UserDataList.StudentNumber = UserItem["StudentNumber"] as? String ?? "Error"
            self.UserDataList.EnteranceClassification = UserItem["EnteranceClassification"] as? String ?? "Error"
            
            let DepthLiberalItem = DepthLiberalSnapshot.value as? [String: Any] ?? [:]
            let GlobalLanguageitem = DepthLiberalItem["GlobalLanguage"] as? String ?? "nil";
            let HumanAndSocialitem = DepthLiberalItem["HumanAndSocial"] as? String ?? "nil";
            let ScienceandTechnologyitem = DepthLiberalItem["ScienceandTechnology"] as? String ?? "nil";
            let ArtsAndPhysicalEducationitem = DepthLiberalItem["ArtsAndPhysicalEducation"] as? String ?? "nil";
            let Convergenceitem = DepthLiberalItem["Convergence"] as? String ?? "nil";
            self.UserDataList.GlobalLanguage = Int(GlobalLanguageitem) ?? 0
            self.UserDataList.HumanAndSocial = Int(HumanAndSocialitem) ?? 0
            self.UserDataList.ScienceandTechnology = Int(ScienceandTechnologyitem) ?? 0
            self.UserDataList.ArtsAndPhysicalEducation = Int(ArtsAndPhysicalEducationitem) ?? 0
            self.UserDataList.Convergence = Int(Convergenceitem) ?? 0
            self.StudentNumberLabel.text = self.UserDataList.StudentNumber
            
            run = false
        }
        while run{
            
        }
    }
    
    // 전체영역을 이수를 판단하는
    func Judgement(StudentNmber: String){
        //전공필수//////////////////////////////////////
        //18 19 20학번의 경우
        if(StudentNmber == "18" || StudentNmber == "19" || StudentNmber == "20"){
            
            var list = [String]()
            
            for i in UserDataList.CompulsorySubjectList{
                list.append(i.SubjectName)
            }
            let DataStructure = list.contains{ $0 == "자료구조"}
            let CS = list.contains{ $0 == "컴퓨터구조"}
            let OS = list.contains{ $0 == "운영체제"}
            let DB = list.contains{ $0 == "데이터베이스"}
            
            //모두 수강하였을 경우 pass
            if DataStructure && CS && OS && DB{
                self.UserDataList.Judgement.CompulsorySubject = true
            }else{
                self.UserDataList.Judgement.CompulsorySubject = false
            }
        }else if(StudentNmber == "21" || StudentNmber == "22"){
            var list = [String]()
            for i in UserDataList.CompulsorySubjectList{
                list.append(i.SubjectName)
            }
            
            let DataStructure = list.contains{ $0 == "자료구조"}
            let CS = list.contains{ $0 == "컴퓨터구조"}
            let OS = list.contains{ $0 == "운영체제"}
            let DB = list.contains{ $0 == "데이터베이스"}
            let ICE = list.contains{ $0 == "컴퓨터공학개론"}
            
            //모두 수강하였을 경우 pass
            if DataStructure && CS && OS && DB && ICE{
                self.UserDataList.Judgement.CompulsorySubject = true
            }
        }else{
            self.UserDataList.Judgement.CompulsorySubject = false
        }
        
        
        //전공선택////////////////////////////////////
        if(StudentNmber == "18"){
            //전공선택 필요학점 설명
            var count = 0
            
            for i in UserDataList.ElectiveSubjectList{
                count += i.SubjectCredit
            }
            //필요학점 이상일 경우
            if count >= ElectiveRequirement18{
                
                
                self.UserDataList.Judgement.ElectiveSubject = true
                
            }else{
                
                self.UserDataList.Judgement.ElectiveSubject = false
            }
            
        }else if(StudentNmber == "19" || StudentNmber == "20"){
            var count = 0
            
            for i in UserDataList.ElectiveSubjectList{
                count += i.SubjectCredit
            }
            
            //필요학점 이상일 경우
            if count >= ElectiveRequirement19to20{
                self.UserDataList.Judgement.ElectiveSubject = true
            }else{
                self.UserDataList.Judgement.ElectiveSubject = false
            }
            
            
        }else if(StudentNmber == "21" || StudentNmber == "22") {
            
            var count = 0
            
            for i in UserDataList.ElectiveSubjectList{
                count += i.SubjectCredit
            }
            
            //필요학점 이상일 경우
            if count >= ElectiveRequirement21to22{
                self.UserDataList.Judgement.ElectiveSubject = true
            }else{
                self.UserDataList.Judgement.ElectiveSubject = false
                
                
            }
        }
        
        //학부공통////////////////////////////////////////////////////////////////////////
        //18학번의 경우
        if(StudentNmber == "18"){
            
            var count = 0
            
            for i in UserDataList.UndergraduateSubject{
                count += i.SubjectCredit
            }
            
            //필요학점 이상일 경우
            if count >= UndergradateRequirement18{
                self.UserDataList.Judgement.UndergraduateSubject = true
            }else{
                self.UserDataList.Judgement.UndergraduateSubject = false
            }
        }else{
            
            var count = 0
            
            for i in UserDataList.UndergraduateSubject{
                count += i.SubjectCredit
            }
            
            //필요학점 이상일 경우
            if count >= UndergradateRequirement19to22{
                self.UserDataList.Judgement.UndergraduateSubject = true
            }else{
                self.UserDataList.Judgement.UndergraduateSubject = false
            }
        }
        
        //KU인성 판단////////////////////////////////////
        var list = [String]()
        var hadcredit = 0
        
        
        for i in UserDataList.LiberalKUPersonality{
            list.append(i.SubjectName)
            hadcredit += i.SubjectCredit
        }
        
        if(StudentNmber == "18" || StudentNmber == "19"){
            
            let SungSin = list.contains{ $0 == "성신의대학생활지도" }
            let SungSin1 = list.contains{ $0 == "성신의대학생활지도1" }
            let SungSin2 = list.contains{ $0 == "성신의대학생활지도2" }
            let Kproject = list.contains{ $0 == "K-project" }
            
            if ((SungSin || SungSin1) && (SungSin2 || Kproject) && (hadcredit >= 4)){
                self.UserDataList.Judgement.LiberalKUPersonality = true
                
            }else{
                self.UserDataList.Judgement.LiberalKUPersonality = false
            }
        }else{
            let SungSin = list.contains{ $0 == "성신의대학생활지도" }
            
            if (SungSin && (hadcredit >= 3)){
                self.UserDataList.Judgement.LiberalKUPersonality = true
            }else{
                self.UserDataList.Judgement.LiberalKUPersonality = false
            }
        }
        
        //글쓰기 판단///////////////////////////////
        list = [String]()
        hadcredit = 0
        
        for i in UserDataList.LiberalWriting{
            list.append(i.SubjectName)
            hadcredit += i.SubjectCredit
        }
        
        let silyong = list.contains{ $0 == "실용글쓰기"}
        let sungchal = list.contains{ $0 == "성찰글쓰기"}
        let chan = list.contains{ $0 == "창의글쓰기"}
        let midea = list.contains{ $0 == "미디어글쓰기"}
        let gle1 = list.contains{ $0 == "글쓰기1"}
        let gle2 = list.contains{ $0 == "글쓰기2"}
        
        if(silyong || sungchal || chan || midea || gle1 || gle2){
            self.UserDataList.Judgement.LiberalWriting = true
        }else{
            self.UserDataList.Judgement.LiberalWriting = false
        }
        
        //발표와 토론 판단//////////////////////////////////////
        list = [String]()
        
        for i in UserDataList.LiberalDiscussion{
            list.append(i.SubjectName)
        }
        
        let guqfur = list.contains{ $0 == "협력적사고와토의"}
        let rhdrka = list.contains{ $0 == "공감적소통과발표"}
        let duffls = list.contains{ $0 == "열린사고와실용적말하기"}
        let qlvks = list.contains{ $0 == "비판적사고와토론"}
        
        if(guqfur || rhdrka || duffls || qlvks){
            self.UserDataList.Judgement.LiberalDiscussion = true
        }else{
            self.UserDataList.Judgement.LiberalDiscussion = false
        }
        
        //외국어 기초 판단////////////////////////////////////
        list = [String]()
        hadcredit = 0
        for i in UserDataList.LiberalBasicForeign{
            list.append(i.SubjectName)
            hadcredit += i.SubjectCredit
        }
        
        let Kugep1 = list.contains{ $0 == "KUGEP1" }
        
        if(Kugep1 && hadcredit >= 6){
            self.UserDataList.Judgement.LiberalBasicForeign = true
        }else{
            self.UserDataList.Judgement.LiberalBasicForeign = false
        }
        
        //인문 기초 판단////////////////////////////////////
        list = [String]()
        hadcredit = 0
        
        for i in UserDataList.LiberalBasicHumanities{
            list.append(i.SubjectName)
            hadcredit += i.SubjectCredit
        }
        
        let ansgkr = list.contains{ $0 == "문학의고전"}
        let durtk = list.contains{ $0 == "역사의고전"}
        let cjfgkr = list.contains{ $0 == "철학의고전"}
        
        if(ansgkr || cjfgkr || durtk){
            self.UserDataList.Judgement.LiberalBasicHumanities = true
        }else{
            self.UserDataList.Judgement.LiberalBasicHumanities = false
        }
        
        //과학 기초 판단 ///////////////////////////////
        list = [String]()
        hadcredit = 0
        
        for i in UserDataList.LiberalBasicScience{
            list.append(i.SubjectName)
            hadcredit += i.SubjectCredit
        }
        
        let rlchxhdrP = list.contains{ $0 == "기초통계학" }
        let anfflgkr = list.contains{ $0 == "대학기초물리학" }
        let todanfgkr = list.contains{ $0 == "대학기초생물학" }
        let tngkr = list.contains{ $0 == "대학기초수학" }
        let ghkgkr = list.contains{ $0 == "대학기초화학" }
        let zjavbxld = list.contains{ $0 == "컴퓨팅적사고" }
        let rhkgkrrhk = list.contains{ $0 == "과학과예술" }
        
        if(rlchxhdrP || anfflgkr || todanfgkr || tngkr || ghkgkr || zjavbxld || rhkgkrrhk){
            self.UserDataList.Judgement.LiberalBasicScience = true
        }else{
            self.UserDataList.Judgement.LiberalBasicScience = false
        }
        
        //심화교양 판단/////////////////////////////////////////
        var judgement = [Bool]()
        //수강 학점 합
        hadcredit = 0
        //수강 영역 합
        var Check = 0
        judgement.append((self.UserDataList.GlobalLanguage != 0))
        judgement.append((self.UserDataList.HumanAndSocial != 0))
        judgement.append((self.UserDataList.ScienceandTechnology != 0))
        judgement.append((self.UserDataList.ArtsAndPhysicalEducation != 0))
        judgement.append((self.UserDataList.Convergence) != 0)
        
        for i in judgement{
            if i == true{
                Check += 1
            }
        }
        hadcredit = self.UserDataList.GlobalLanguage + self.UserDataList.HumanAndSocial + self.UserDataList.ScienceandTechnology + self.UserDataList.ArtsAndPhysicalEducation + self.UserDataList.Convergence
        
        if(hadcredit >= 8 && Check >= 4){
            self.UserDataList.Judgement.DepthLiberal = true
        }else{
            self.UserDataList.Judgement.DepthLiberal = false
        }
        
        //실무소양 판단////////////////////////////////
        list = [String]()
        var count = 0
        
        for i in UserDataList.PracticalKnowledge{
            list.append(i.SubjectName)
            count += i.SubjectCredit
        }
        
        let cnlwjstn = list.contains{ $0 == "취업전략수립및역량개발1"}
        
        if cnlwjstn && count >= 4{
            self.UserDataList.Judgement.PracticalKnowledge = true
        }else{
            self.UserDataList.Judgement.PracticalKnowledge = false
        }
        
        //실기소양 판단
        var list2 = [String]()
        var count2 = 0
        
        for i in UserDataList.PracticalSkill{
            list2.append(i.SubjectName)
            count2 += i.SubjectCredit
        }
        
        if count2 >= 2 {
            self.UserDataList.Judgement.PracticalSkill = true
        }else{
            self.UserDataList.Judgement.PracticalSkill = false
        }
        
        //총 판단////////////////////////////////
        if(
            UserDataList.Judgement.PracticalKnowledge && UserDataList.Judgement.LiberalWriting &&
            UserDataList.Judgement.LiberalKUPersonality && UserDataList.Judgement.UndergraduateSubject && UserDataList.Judgement.ElectiveSubject && UserDataList.Judgement.CompulsorySubject && UserDataList.Judgement.LiberalDiscussion && UserDataList.Judgement.LiberalBasicHumanities && UserDataList.Judgement.LiberalBasicScience && UserDataList.Judgement.LiberalBasicForeign && UserDataList.Judgement.PracticalSkill && UserDataList.Judgement.GraduationWork && UserDataList.Judgement.GraduationLanguage && UserDataList.Judgement.DepthLiberal && (Majorhadcredit + Liberalarthadcredit) >= 132){
            self.UserDataList.Judgement.allpassnonpass = true
        }else{
            self.UserDataList.Judgement.allpassnonpass = false
        }
    }


//전필수강 내역을 가지고 오는..
func ReadCompulsoryHistory(){
    var run = true
    let ref = Database.database().reference()
    ref.child("CompulsoryMajorHistory").child(uid!).observe(.value){ snapshot in
        //사용자의 수강정보를 가져옴
        guard let value = snapshot.value else { return }
        guard let dic = value as? [String: Any] else { return }
        for index in dic.values{
            let a = index as! String
            if let i = self.CompulsorySubjectList.CompulsorySubjectList.firstIndex(where: { $0.SubjectName == a}){
                let TmpSubName = self.CompulsorySubjectList.CompulsorySubjectList[i].SubjectName
                let TmpSubCredit = self.CompulsorySubjectList.CompulsorySubjectList[i].SubjectCredit
                self.UserDataList.CompulsorySubjectList.append(Subject(SubjectName: TmpSubName, SubjectCredit: TmpSubCredit))
            }
        }
        run = false
    }
    while run
    {
        
    }
}

//    func GetUserDataFromFirebase(
//         completionHandler: @escaping (Result<UserStruct, Error>) -> Void
//    ) {
//        ref = Database.database().reference()
//        ref.child("User").child(uid!).observe(.value){  response in
//            do{
//                guard let value = response.value as? NSDictionary else { return }
//                self.UserDataList.Id = value["id"] as? String ?? "error"
//                self.UserDataList.StudentNumber = value["StudentNumber"] as? String ?? "error"
//                self.UserDataList.EnteranceClassification = value["EnteranceClassification"] as? String ?? "error"
//                completionHandler(.success(self.UserDataList))
//            } catch let error{
//                completionHandler(.failure(error))
//            }
//        }
//    }

//    func GetCompulsoryHistory(
//        completionHandler: @escaping (Result<UserStruct, Error>) -> Void
//    ) {
//        ref = Database.database().reference()
//        ref.child("CompulsoryMajorHistory").child(uid!).observe(.value){ response in
//            do{
//                guard let value = response.value else { return }
//                let dic = value as! [String: Any]
//                for index in dic.values{
//                    let a = index as! String
//                    if let i = self.CompulsorySubjectList.CompulsorySubjectList.firstIndex(where: { $0.SubjectName == a}){
//                        let TmpSubName = self.CompulsorySubjectList.CompulsorySubjectList[i].SubjectName
//                        let TmpSubCredit = self.CompulsorySubjectList.CompulsorySubjectList[i].SubjectCredit
//                        self.UserDataList.CompulsorySubjectList.append(Subject(SubjectName: TmpSubName, SubjectCredit: TmpSubCredit, i))
//                    }
//                    completionHandler(.success(self.UserDataList))
//                }
//            } catch let error {
//                completionHandler(.failure(error))
//            }
//        }
//
//    }





//로그아웃 버튼
func LogoutButtontap(_ sender: UIButton) {
    let firebaseAuth = Auth.auth()
    do{
        try firebaseAuth.signOut()
        
        self.navigationController?.popToRootViewController(animated: true)
    }catch let signOutError as NSError{
        
    }
}

}


