//
//  DepthLiberalInputViewController.swift
//  kumulator
//
//  Created by 강현준 on 2022/09/04.
//

import Foundation
import UIKit
import FirebaseAuth
import FirebaseDatabase

class DepthLiberalInputViewController: UIViewController{
    @IBOutlet weak var GlobalLanguage: UITextField!
    @IBOutlet weak var HumanAndSocial: UITextField!
    @IBOutlet weak var ScienceandTechnology: UITextField!
    @IBOutlet weak var ArtsAndPhysicalEducation: UITextField!
    @IBOutlet weak var Convergence: UITextField!
    @IBOutlet weak var DepthLiberalJudgementLabel: UILabel!
    @IBOutlet weak var SumCreditLabel: UILabel!
    @IBOutlet weak var SumCheck: UILabel!
    
    let ref = Database.database().reference()
    let uid = Auth.auth().currentUser?.uid
    var UserDataList = UserStruct()
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        DispatchQueue.global().async {
            self.GetDepthLiberalData()
            self.DepthLiberalJudgement()
        }
        
    }
    
    //심화교양 판단
    func DepthLiberalJudgement(){
        var judgement = [Bool]()
        //수강 학점 합
        var hadcredit = 0
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
            DispatchQueue.main.async {
                self.DepthLiberalJudgementLabel.text = "Pass"
                self.DepthLiberalJudgementLabel.textColor = .blue
                self.UserDataList.Judgement.DepthLiberal = true
                self.SumCheck.text = String(Check)
                self.SumCreditLabel.text = String(hadcredit)
            }
        }else{
            DispatchQueue.main.async {
                self.DepthLiberalJudgementLabel.text = "NonPass"
                self.DepthLiberalJudgementLabel.textColor = .red
                self.UserDataList.Judgement.DepthLiberal = false
                self.SumCheck.text = String(Check)
                self.SumCreditLabel.text = String(hadcredit)

            }
        }
        
        
    }
    
    //입력완료버튼
    @IBAction func OKButton(_ sender: UIButton){
        var data = ["GlobalLanguage": GlobalLanguage.text,
                    "HumanAndSocial": HumanAndSocial.text,
                    "ScienceandTechnology": ScienceandTechnology.text,
                    "ArtsAndPhysicalEducation": ArtsAndPhysicalEducation.text,
                    "Convergence": Convergence.text]
        
        ref.child("DepthLiberal").child(uid!).setValue(data)
        
        DispatchQueue.global().async {
            self.GetDepthLiberalData()
            self.DepthLiberalJudgement()
        }
    }
    
    func GetDepthLiberalData(){
        var run = true
        ref.child("DepthLiberal").child(uid!).observe(.value){ snapshot, err in
            guard let value = snapshot.value as? NSDictionary else { return }
            let GlobalLanguage = value["GlobalLanguage"] as? String ?? "error"
            let HumanAndSocial = value["HumanAndSocial"] as? String ?? "error"
            let ArtsAndPhysicalEducation = value["ArtsAndPhysicalEducation"] as? String ?? "error"
            let ScienceandTechnology = value["ScienceandTechnology"] as? String ?? "error"
            let Convergence = value["Convergence"] as? String ?? "error"
            
            self.UserDataList.GlobalLanguage = Int(GlobalLanguage) ?? 0
            self.UserDataList.HumanAndSocial = Int(HumanAndSocial) ?? 0
            self.UserDataList.ArtsAndPhysicalEducation = Int(ArtsAndPhysicalEducation) ?? 0
            self.UserDataList.ScienceandTechnology = Int(ScienceandTechnology) ?? 0
            self.UserDataList.Convergence = Int(Convergence) ?? 0
            
            DispatchQueue.main.async {
                self.GlobalLanguage.text = GlobalLanguage
                self.HumanAndSocial.text = HumanAndSocial
                self.ArtsAndPhysicalEducation.text = ArtsAndPhysicalEducation
                self.ScienceandTechnology.text = ScienceandTechnology
                self.Convergence.text = Convergence
            }
            run = false
        }
        while run {}
    }
    
    
    //이전버튼
    @IBAction func BackButton(_ sender: UIButton){
        self.dismiss(animated: true, completion: nil)
    }
}

