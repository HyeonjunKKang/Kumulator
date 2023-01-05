//
//  GraduationWorkViewController.swift
//  kumulator
//
//  Created by 강현준 on 2022/09/30.
//

import Foundation
import UIKit
import FirebaseAuth
import FirebaseDatabase

class GraduationWorkViewController: UIViewController{
    
    let ref = Database.database().reference()
    let uid = Auth.auth().currentUser?.uid
    
    @IBOutlet weak var WorkSwitch: UISwitch!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        SetSwitch()
    }
    //스위치가 켜지면 pass, 꺼지면 false 저장
    @IBAction func GraduationWorkSwitch(_ sender: UISwitch) {
        if sender.isOn == true{
            ref.child("GraduationWork").child(uid!).setValue(["Pass":"true"])
        }
        else{
            ref.child("GraduationWork").child(uid!).setValue(["Pass":"false"])
        }
    }
    
    @IBAction func BackButton(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }
    
    //스위치의 초기상태 가져옴
    func SetSwitch(){
        ref.queryOrderedByKey().observeSingleEvent(of: .value){ snapshot, err in
            guard let value = snapshot.value else { return }
            
            let GraduationWorkSnapshot = snapshot.childSnapshot(forPath: "GraduationWork").childSnapshot(forPath: self.uid!)
            
            let GradationWorkItem = GraduationWorkSnapshot.value as? [String: Any] ?? [:]
            if GradationWorkItem["Pass"] as? String ?? "Error" == "true"{
                self.WorkSwitch.isOn = true
            } else {
                self.WorkSwitch.isOn = false
            }
        }
    }
    
}
