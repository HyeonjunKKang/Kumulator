//
//  KUKnowledgeViewController.swift
//  kumulator
//
//  Created by 강현준 on 2022/09/04.
//

import Foundation
import UIKit
import FirebaseAuth
import FirebaseDatabase

class KUKnowledgeViewController: UIViewController{
    
    let ref = Database.database().reference()
    let uid = Auth.auth().currentUser?.uid
    var UserDataList = UserStruct()
    let PracticalKnowledgeList = PracticalKnowledge()
    let PracticalSkillList = kumulator.PracticalSkill()
    
    @IBOutlet weak var PracticalKnowledgeCountLabel: UILabel!
    @IBOutlet weak var PracticalKnowledgeJudgementLabel: UILabel!
    @IBOutlet weak var PracticalSkillCountLabel: UILabel!
    @IBOutlet weak var PracticalSkillJudgementLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        DispatchQueue.global().async {
            self.ReadData()
            self.KUKnowledgeJudgement()
        }
    }
    
    //실무 소양 입력 버튼
    @IBAction func PracticalKnowledgeButton(_ sender: UIButton) {
        guard let storyboard = self.storyboard?.instantiateViewController(withIdentifier: "PracticalKnowledgeInputViewController") as? PracticalKnowledgeInputViewController
        else { return }
        storyboard.modalPresentationStyle = .fullScreen
        self.present(storyboard, animated: true, completion: nil)
    }
    
    @IBAction func PracticalSkill(_ sender: UIButton) {
        guard let storyboard = self.storyboard?.instantiateViewController(withIdentifier: "PracticalSkillInputViewController") as? PracticalSkillInputViewController else { return }
        storyboard.modalPresentationStyle = .fullScreen
        self.present(storyboard, animated: true, completion: nil)
    }
    
    @IBAction func BackButton(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }
    
    //데이터를 읽어옵니다
    func ReadData(){
        self.UserDataList = UserStruct()
        var run = true
        
        ref.queryOrderedByKey().observeSingleEvent(of: .value){ snapshot, err in
            guard let value  = snapshot.value else { return }
            
            let PracticalKnowledgeSnapshot = snapshot.childSnapshot(forPath: "PracticalKnowledge").childSnapshot(forPath: self.uid!)
            let PracticalSkillSnapshot = snapshot.childSnapshot(forPath: "PracticalSkill").childSnapshot(forPath: self.uid!)
            
            let PracticalKnowledgeItem = PracticalKnowledgeSnapshot.value as? [String: Any] ?? [:]
            for index in PracticalKnowledgeItem{
                for i in 0...self.PracticalKnowledgeList.PracticalKnowledge.count - 1 {
                    if index.value as! String == self.PracticalKnowledgeList.PracticalKnowledge[i].SubjectName{
                        self.UserDataList.PracticalKnowledge.append(Subject(SubjectName: index.value as! String, SubjectCredit: self.PracticalKnowledgeList.PracticalKnowledge[i].SubjectCredit))
                    }
                }
            }
            
            let PracticalSkillItem = PracticalSkillSnapshot.value as? [String: Any] ?? [:]
            for index in PracticalSkillItem{
                for i in 0...self.PracticalSkillList.PracticalSkill.count - 1 {
                    if index.value as! String == self.PracticalSkillList.PracticalSkill[i].SubjectName{
                        self.UserDataList.PracticalSkill.append(Subject(SubjectName: index.value as! String, SubjectCredit: self.PracticalSkillList.PracticalSkill[i].SubjectCredit))
                    }
                }
            }
            run = false
        }
        while run { }
    }
    
    func KUKnowledgeJudgement(){
        var run = true
        var list = [String]()
        var count = 0
    
        for i in UserDataList.PracticalKnowledge{
            list.append(i.SubjectName)
            count += i.SubjectCredit
        }
        
        let cnlwjstn = list.contains{ $0 == "취업전략수립및역량개발1"}
        
        if cnlwjstn && count >= 4{
            DispatchQueue.main.async {
                self.PracticalKnowledgeJudgementLabel.text = "Pass"
                self.PracticalKnowledgeJudgementLabel.textColor = .blue
                self.UserDataList.Judgement.PracticalKnowledge = true
                self.PracticalKnowledgeCountLabel.text = String(count)
            }
        }else{
            DispatchQueue.main.async {
                self.PracticalKnowledgeJudgementLabel.text = "Non Pass"
                self.PracticalKnowledgeJudgementLabel.textColor = .red
                self.UserDataList.Judgement.PracticalKnowledge = false
                self.PracticalKnowledgeCountLabel.text = String(count)
            }
        }
        
        var list2 = [String]()
        var count2 = 0
    
        for i in UserDataList.PracticalSkill{
            list2.append(i.SubjectName)
            count2 += i.SubjectCredit
        }
        
        if count2 >= 2 {
            DispatchQueue.main.async {
                self.PracticalSkillJudgementLabel.text = "Pass"
                self.PracticalSkillJudgementLabel.textColor = .blue
                self.UserDataList.Judgement.PracticalSkill = true
                self.PracticalSkillCountLabel.text = String(count2)
            }
        }else{
            DispatchQueue.main.async {
                self.PracticalSkillJudgementLabel.text = "Non Pass"
                self.PracticalSkillJudgementLabel.textColor = .red
                self.UserDataList.Judgement.PracticalSkill = false
                self.PracticalSkillCountLabel.text = String(count2)
            }
        }
        run = false
        while run {}
    }
}
