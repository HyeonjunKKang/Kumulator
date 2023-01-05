//
//  ViewController.swift
//  kumulator
//
//  Created by 강현준 on 2022/03/28.
//

import UIKit
import FirebaseAuth
import FirebaseDatabase

class ViewController: UIViewController {

    @IBOutlet weak var IDInputLabel: UITextField!
    @IBOutlet weak var PWInputLable: UITextField!
    @IBOutlet weak var ErrorLabel: UILabel!
    
    
    var UserDataList = UserStruct()
    let uid = Auth.auth().currentUser?.uid
    
    override func viewDidLoad() {
        super.viewDidLoad()
//        PWInputLable.isSecureTextEntry = true
        // Do any additional setup after loading the view.
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        
    }

    @IBAction func LoginButton(_ sender: UIButton) {
        let email = IDInputLabel.text ?? ""
        let password = PWInputLable.text ?? ""
        self.loginUser(withEmail: email, password: password)
    }
    
    private func loginUser(withEmail email: String, password: String){
        Auth.auth().signIn(withEmail: email, password: password) { [weak self] _, error in
            guard let self = self else { return }
            if let error = error{
                let code = (error as NSError).code
                
                self.ErrorLabel.textColor = .red
                
                switch code{
                case 17009:
                    self.ErrorLabel.text = "패스워드 또는 아이디가 잘못되었습니다."
                case 17008:
                    self.ErrorLabel.text = "이메일을 입력해주세요."
                default:
                    self.ErrorLabel.text = error.localizedDescription
                    debugPrint(error)
                }
            }else{
                self.showMainViewController()
            }
        }
    }
    
     func showMainViewController(){
        guard let storyboard = self.storyboard?.instantiateViewController(identifier: "MainViewController") as? MainViewController else { return }
        storyboard.modalPresentationStyle = .fullScreen
        self.present(storyboard, animated: true, completion: nil)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
}

