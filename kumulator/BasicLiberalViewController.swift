//
//  BasicLiberalViewController.swift
//  kumulator
//
//  Created by 강현준 on 2022/09/04.
//

import Foundation
import UIKit
import FirebaseAuth
import FirebaseDatabase

class BasicLiberalViewController: UIViewController{
    
    var UserDataList = UserStruct()
    var ref = Database.database().reference()
    var uid = Auth.auth().currentUser?.uid
    var LiberalKUPersonalityList = LiberalKUPersonality()
    var LiberalWritingList = LiberalWriting()
    var LiberalDiscussionList = LiberalDiscussion()
    var LiberalBasicForeignList = LiberalBasicForeign()
    var LiberalBasicHumanitiesList = kumulator.LiberalBasicHumanities()
    var LiberalBasicScienceList = kumulator.LiberalBasicScience()
    
    @IBOutlet weak var KUPersonalityJudgementLabel: UILabel!
    @IBOutlet weak var WritingJudgementLabel: UILabel!
    @IBOutlet weak var DiscussionJudgementLabel: UILabel!
    @IBOutlet weak var ForeignJudgementLabel: UILabel!
    @IBOutlet weak var HumanitiesJudgementLabel: UILabel!
    @IBOutlet weak var ScienceJudgementLabel: UILabel!
    @IBOutlet weak var KUPersonalityDescriptionLabel: UILabel!
    @IBOutlet weak var WritingDescriptionLabel: UILabel!
    @IBOutlet weak var DiscussionDescriptionLabel: UILabel!
    @IBOutlet weak var ForeignDescriptionLabel: UILabel!
    @IBOutlet weak var HumanitiesDescriptionLabel: UILabel!
    @IBOutlet weak var ScienceDescriptionLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        DispatchQueue.global().async {
            self.ReadAllData()
            self.Description(StudentNumber: self.UserDataList.StudentNumber)
            self.LiberalKUPersonalityJudgement(StudentNumber: self.UserDataList.StudentNumber)
            self.WritingJudgement()
            self.DiscussionJudgement()
            self.ForeignJudgement()
            self.HumanitiesJudgement()
            self.ScienceJudgement()
        }
        
    }
    
    @IBAction func LiberalKUPersounalityButton(_ sender: UIButton){
        guard let storyboard = self.storyboard?.instantiateViewController(withIdentifier: "LiberalKUPersonalityInputViewController") as? LiberalKUPersonalityInputViewController else { return }
        storyboard.modalPresentationStyle = .fullScreen
        self.present(storyboard, animated: true, completion: nil)
    }
    
    @IBAction func LiberalWritingButton(_ sender: UIButton){
        guard let storyboard = self.storyboard?.instantiateViewController(withIdentifier: "LiberalWritingInputViewController") as? LiberalWritingInputViewController else { return }
        storyboard.modalPresentationStyle = .fullScreen
        self.present(storyboard, animated: true, completion: nil)
    }
    
    @IBAction func LiberalDiscussionButton(_ sender: UIButton){
        guard let storyboard = self.storyboard?.instantiateViewController(withIdentifier: "LiberalDiscussionInputViewController") as? LiberalDiscussionInputViewController else { return }
        storyboard.modalPresentationStyle = .fullScreen
        self.present(storyboard, animated: true, completion: nil)
    }
    
    @IBAction func LiberalBasicForeignInputViewController(_ sender: UIButton){
        guard let storyboard = self.storyboard?.instantiateViewController(withIdentifier: "LiberalBasicForeignInputViewController") as? LiberalBasicForeignInputViewController else { return }
        storyboard.modalPresentationStyle = .fullScreen
        self.present(storyboard, animated: true, completion: nil)
    }
    
    @IBAction func LiberalBasicHumanities(_ sender: UIButton){
        guard let storyboard = self.storyboard?.instantiateViewController(withIdentifier: "LiberalBasicHumanitiesInputViewController") as? LiberalBasicHumanitiesInputViewController else { return }
        storyboard.modalPresentationStyle = .fullScreen
        self.present(storyboard, animated: true, completion: nil)
    }
    
    @IBAction func LiberalBasicScience(_ sender: UIButton){
        guard let storyboard = self.storyboard?.instantiateViewController(withIdentifier: "LiberalBasicScienceInputViewController") as? LiberalBasicScienceInputViewController else { return }
        storyboard.modalPresentationStyle = .fullScreen
        self.present(storyboard, animated: true, completion: nil)
    }
    @IBAction func BackButton(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }
    
    func Description(StudentNumber: String){
        if (StudentNumber == "18" || StudentNumber == "19"){
            DispatchQueue.main.async {
                self.KUPersonalityDescriptionLabel.numberOfLines = 0
                self.KUPersonalityDescriptionLabel.text = "성신의대학생활지도1 또는 성신의대학생활지도, 성신의대학생활지도2 또는 K-project + 2학점 1과목 이상."
            }
        }else{
            DispatchQueue.main.async {
                self.KUPersonalityDescriptionLabel.numberOfLines = 0
                self.KUPersonalityDescriptionLabel.text = "성신의 대학생활지도 + 2학점 1과목 이상"
            }
        }
        
        DispatchQueue.main.async {
            self.WritingDescriptionLabel.text = "1과목 이상 수강"
            self.DiscussionDescriptionLabel.text = "1과목 이상 수강"
            self.ForeignDescriptionLabel.text = "KUGEP1 + 1과목 이상 수강"
            self.HumanitiesDescriptionLabel.text = "1과목 이상 수강"
            self.ScienceDescriptionLabel.text = "1과목 이상 수강"
        }
    }
    
    //과학기초 판단
    func ScienceJudgement(){
        var list = [String]()
        var hadcredit = 0
        
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
            DispatchQueue.main.async {
                self.ScienceJudgementLabel.text = "Pass"
                self.ScienceJudgementLabel.textColor = .blue
                self.UserDataList.Judgement.LiberalBasicScience = true
            }
        }else{
            DispatchQueue.main.async {
                self.ScienceJudgementLabel.text = "NonPass"
                self.ScienceJudgementLabel.textColor = .red
                self.UserDataList.Judgement.LiberalBasicScience = false

            }
        }
    }
    
    //외국어기초 판단
    func ForeignJudgement(){
        var list = [String]()
        var hadcredit = 0
        for i in UserDataList.LiberalBasicForeign{
            list.append(i.SubjectName)
            hadcredit += i.SubjectCredit
        }
        
        let Kugep1 = list.contains{ $0 == "KUGEP1" }
        
        if(Kugep1 && hadcredit >= 6){
            DispatchQueue.main.async {
                self.ForeignJudgementLabel.text = "Pass"
                self.ForeignJudgementLabel.textColor = .blue
                self.UserDataList.Judgement.LiberalBasicForeign = true
            }
        }else{
            DispatchQueue.main.async {
                self.ForeignJudgementLabel.text = "NonPass"
                self.ForeignJudgementLabel.textColor = .red
                self.UserDataList.Judgement.LiberalBasicForeign = false

            }
        
        }
    }
    
    //인문기초 판단
    func HumanitiesJudgement(){
        var list = [String]()
        var hadcredit = 0
        
        for i in UserDataList.LiberalBasicHumanities{
            list.append(i.SubjectName)
            hadcredit += i.SubjectCredit
        }
        
        let ansgkr = list.contains{ $0 == "문학의고전"}
        let durtk = list.contains{ $0 == "역사의고전"}
        let cjfgkr = list.contains{ $0 == "철학의고전"}
        
        if(ansgkr || cjfgkr || durtk){
            DispatchQueue.main.async {
                self.HumanitiesJudgementLabel.text = "Pass"
                self.HumanitiesJudgementLabel.textColor = .blue
                self.UserDataList.Judgement.LiberalBasicHumanities = true
            }
        }else{
            DispatchQueue.main.async {
                self.HumanitiesJudgementLabel.text = "NonPass"
                self.HumanitiesJudgementLabel.textColor = .red
                self.UserDataList.Judgement.LiberalBasicHumanities = false

            }
        }
    }
    
    //발표와토론판단
    func DiscussionJudgement(){
        var list = [String]()
        
        for i in UserDataList.LiberalDiscussion{
            list.append(i.SubjectName)
        }
        
        let guqfur = list.contains{ $0 == "협력적사고와토의"}
        let rhdrka = list.contains{ $0 == "공감적소통과발표"}
        let duffls = list.contains{ $0 == "열린사고와실용적말하기"}
        let qlvks = list.contains{ $0 == "비판적사고와토론"}
        
        if(guqfur || rhdrka || duffls || qlvks){
            DispatchQueue.main.async {
                self.DiscussionJudgementLabel.text = "Pass"
                self.DiscussionJudgementLabel.textColor = .blue
                self.UserDataList.Judgement.LiberalDiscussion = true
            }
        }else{
            DispatchQueue.main.async {
                self.DiscussionJudgementLabel.text = "NonPass"
                self.DiscussionJudgementLabel.textColor = .red
                self.UserDataList.Judgement.LiberalDiscussion = false

            }
        
        }
    }
    
    //글쓰기 판단
    func WritingJudgement(){
        var list = [String]()
        var hadcredit = 0
        
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
            DispatchQueue.main.async {
                self.WritingJudgementLabel.text = "Pass"
                self.WritingJudgementLabel.textColor = .blue
                self.UserDataList.Judgement.LiberalWriting = true
            }
        }else{
            DispatchQueue.main.async {
                self.WritingJudgementLabel.text = "NonPass"
                self.WritingJudgementLabel.textColor = .red
                self.UserDataList.Judgement.LiberalWriting = false

            }
        }
        
    }
    
    //KU인성 판단
    func LiberalKUPersonalityJudgement(StudentNumber: String){
        var run = true
        
        var list = [String]()
        var hadcredit = 0
        
        
        for i in UserDataList.LiberalKUPersonality{
            list.append(i.SubjectName)
            hadcredit += i.SubjectCredit
        }
        
        if(StudentNumber == "18" || StudentNumber == "19"){
            
            let SungSin = list.contains{ $0 == "성신의대학생활지도" }
            let SungSin1 = list.contains{ $0 == "성신의대학생활지도1" }
            let SungSin2 = list.contains{ $0 == "성신의대학생활지도2" }
            let Kproject = list.contains{ $0 == "K-project" }
            
            if ((SungSin || SungSin1) && (SungSin2 || Kproject) && (hadcredit >= 4)){
                DispatchQueue.main.async {
                    self.KUPersonalityJudgementLabel.text = "Pass"
                    self.KUPersonalityJudgementLabel.textColor = .blue
                    self.UserDataList.Judgement.LiberalKUPersonality = true
                }
            }else{
                DispatchQueue.main.async {
                    self.KUPersonalityJudgementLabel.text = "NonPass"
                    self.KUPersonalityJudgementLabel.textColor = .red
                    self.UserDataList.Judgement.LiberalKUPersonality = false

                }
            }
            
            
            run = false
        }else{
            let SungSin = list.contains{ $0 == "성신의대학생활지도" }
            
            if (SungSin && (hadcredit >= 3)){
                DispatchQueue.main.async {
                    self.KUPersonalityJudgementLabel.text = "Pass"
                    self.KUPersonalityJudgementLabel.textColor = .blue
                    self.UserDataList.Judgement.LiberalKUPersonality = true
                }
            }else{
                DispatchQueue.main.async {
                    self.KUPersonalityJudgementLabel.text = "NonPass"
                    self.KUPersonalityJudgementLabel.textColor = .red
                    self.UserDataList.Judgement.LiberalKUPersonality = false

                }
            }
            
            
            run = false
        }
        
        while run{
            
        }
        
    }
    
    //교양 데이터를 읽어오는 함수
    func ReadAllData(){
        self.UserDataList = UserStruct()
        var run = true
        
        ref.queryOrderedByKey().observeSingleEvent(of:.value){ snapshot, err in
            guard let value = snapshot.value else { return }
            
            
            let LiberalKUPersonalitySnapshot = snapshot.childSnapshot(forPath: "LiberalKUPersonality").childSnapshot(forPath: self.uid!)
            let LiberalWritingSnapshot = snapshot.childSnapshot(forPath: "LiberalWriting").childSnapshot(forPath: self.uid!)
            let LiberalDiscussionSnapshot = snapshot.childSnapshot(forPath: "LiberalDiscussion").childSnapshot(forPath: self.uid!)
            let LiberalBasicForeignSnapshot = snapshot.childSnapshot(forPath: "LiberalBasicForeign").childSnapshot(forPath: self.uid!)
            let LiberalBasicHumanitiesSnapshot = snapshot.childSnapshot(forPath: "LiberalBasicHumanities").childSnapshot(forPath: self.uid!)
            let LiberalBasicScienceSnapshot = snapshot.childSnapshot(forPath: "LiberalBasicScience").childSnapshot(forPath: self.uid!)

            
            let UserSnapshot = snapshot.childSnapshot(forPath: "User").childSnapshot(forPath: self.uid!)
            
            let UserItem = UserSnapshot.value as? [String: Any] ?? [:]
            self.UserDataList.Id = UserItem["id"] as? String ?? "Error"
            self.UserDataList.StudentNumber = UserItem["StudentNumber"] as? String ?? "Error"
            self.UserDataList.EnteranceClassification = UserItem["EnteranceClassification"] as? String ?? "Error"
            
            let LiberalKUPersonalityItem = LiberalKUPersonalitySnapshot.value as? [String: Any] ?? [:]
            for index in LiberalKUPersonalityItem{
                for i in 0...self.LiberalKUPersonalityList.LiberalKUPersounality.count - 1{
                    if index.value as! String == self.LiberalKUPersonalityList.LiberalKUPersounality[i].SubjectName{
                        self.UserDataList.LiberalKUPersonality.append(Subject(SubjectName: index.value as! String, SubjectCredit: self.LiberalKUPersonalityList.LiberalKUPersounality[i].SubjectCredit))
                    }
                }
            }
            
            let LiberalWritingItem = LiberalWritingSnapshot.value as? [String: Any] ?? [:]
            for index in LiberalWritingItem{
                for i in 0...self.LiberalWritingList.LiberalWriting.count - 1{
                    if index.value as! String == self.LiberalWritingList.LiberalWriting[i].SubjectName{
                        self.UserDataList.LiberalWriting.append(Subject(SubjectName: index.value as! String, SubjectCredit: self.LiberalWritingList.LiberalWriting[i].SubjectCredit))
                    }
                }
            }
            
            let LiberalDiscussionItem = LiberalDiscussionSnapshot.value as? [String: Any] ?? [:]
            for index in LiberalDiscussionItem{
                for i in 0...self.LiberalDiscussionList.LiberalDiscussion.count - 1{
                    if index.value as! String == self.LiberalDiscussionList.LiberalDiscussion[i].SubjectName{
                        self.UserDataList.LiberalDiscussion.append(Subject(SubjectName: index.value as! String, SubjectCredit: self.LiberalDiscussionList.LiberalDiscussion[i].SubjectCredit))
                    }
                }
            }
            
            let LiberalBasicForeignItem = LiberalBasicForeignSnapshot.value as? [String: Any] ?? [:]
            for index in LiberalBasicForeignItem{
                for i in 0...self.LiberalBasicForeignList.LiberalBasicForeign.count - 1{
                    if index.value as! String == self.LiberalBasicForeignList.LiberalBasicForeign[i].SubjectName{
                        self.UserDataList.LiberalBasicForeign.append(Subject(SubjectName: index.value as! String, SubjectCredit: self.LiberalBasicForeignList.LiberalBasicForeign[i].SubjectCredit))
                    }
                }
            }
            
            let LiberalBasicHumanitiesItem = LiberalBasicHumanitiesSnapshot.value as? [String: Any] ?? [:]
            for index in LiberalBasicHumanitiesItem{
                for i in 0...self.LiberalBasicHumanitiesList.LiberalBasicHumanities.count - 1{
                    if index.value as! String == self.LiberalBasicHumanitiesList.LiberalBasicHumanities[i].SubjectName{
                        self.UserDataList.LiberalBasicHumanities.append(Subject(SubjectName: index.value as! String, SubjectCredit: self.LiberalBasicHumanitiesList.LiberalBasicHumanities[i].SubjectCredit))
                    }
                }
            }
            
            let LiberalBasicScienceItem = LiberalBasicScienceSnapshot.value as? [String: Any] ?? [:]
            for index in LiberalBasicScienceItem{
                for i in 0...self.LiberalBasicScienceList.LiberalBasicScience.count - 1{
                    if index.value as! String == self.LiberalBasicScienceList.LiberalBasicScience[i].SubjectName{
                        self.UserDataList.LiberalBasicScience.append(Subject(SubjectName: index.value as! String, SubjectCredit: self.LiberalBasicScienceList.LiberalBasicScience[i].SubjectCredit))
                    }
                }
            }
            
            run = false
        }
        while run{

        }
    }
}
