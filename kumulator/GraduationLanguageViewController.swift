//
//  GraduationLanguageViewController.swift
//  kumulator
//
//  Created by 강현준 on 2022/09/27.
//

import Foundation
import UIKit
import FirebaseAuth
import FirebaseDatabase

class GraduationLanguageViewController: UIViewController{
    
    let ref = Database.database().reference()
    let uid = Auth.auth().currentUser?.uid
    @IBOutlet weak var LanguageSwitch: UISwitch!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        SetSwitch()
        
    }
    
    //스위치가 켜지면 pass, 꺼지면 false 저장
    @IBAction func GraduationLanguageSwitch(_ sender: UISwitch) {
        if sender.isOn == true{
            ref.child("GraduationLanguage").child(uid!).setValue(["Pass":"true"])
        }
        else{
            ref.child("GraduationLanguage").child(uid!).setValue(["Pass":"false"])
        }
    }
    
    @IBAction func BackButton(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }
    
    //스위치의 초기상태 가져옴
    func SetSwitch(){
        ref.queryOrderedByKey().observeSingleEvent(of: .value){ snapshot, err in
            guard let value = snapshot.value else { return }
            
            let GraduationLanguageSnapshot = snapshot.childSnapshot(forPath: "GraduationLanguage").childSnapshot(forPath: self.uid!)
            
            let GradationLanguageItem = GraduationLanguageSnapshot.value as? [String: Any] ?? [:]
            if GradationLanguageItem["Pass"] as? String ?? "Error" == "true"{
                self.LanguageSwitch.isOn = true
            } else {
                self.LanguageSwitch.isOn = false
            }
        }
    }
    
}
