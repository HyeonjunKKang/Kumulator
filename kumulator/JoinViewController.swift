//
//  JoinViewController.swift
//  kumulator
//
//  Created by 강현준 on 2022/03/30.
//

import UIKit
import FirebaseAuth
import FirebaseDatabase

class JoinViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource {
    
    @IBOutlet weak var JoinIDField: UITextField!
    @IBOutlet weak var JoinPWField: UITextField!
    @IBOutlet weak var RegistrationButton: UIButton!
    @IBOutlet weak var ErrorLabel: UILabel!
    @IBOutlet weak var StudentListEnterancePickerView: UIPickerView!
    
    var StudentnumberList = UseableStudentnumber
    var Enterance = EnteranceClassification 
    
    lazy var SelectedStudentnumber = StudentnumberList[0]
    lazy var SelectedEnterance = Enterance[0]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationController?.navigationBar.isHidden = false
        RegistrationButton.isEnabled = false
        JoinIDField.delegate = self
        JoinPWField.delegate = self
        
        StudentListEnterancePickerView.dataSource = self
        StudentListEnterancePickerView.delegate = self
    }
    
    @IBAction func RegistrationTap(_ sender: UIButton) {
        let email = JoinIDField.text ?? ""
        let password = JoinPWField.text ?? ""
        
        //회원가입 처리
        Auth.auth().createUser(withEmail: email, password: password) { [weak self]authResult, error in
            guard let self = self else { return }
            
            //회원가입 에러처리
            if let error = error{
                let code = (error as NSError).code
                self.ErrorLabel.textColor = .red
                switch code{
                    
                case 17008:
                    self.ErrorLabel.text = "이메일 형식을 맞춰주세요."
                    debugPrint(code)
                    break
                case 17007:
                    self.ErrorLabel.text = "이미 사용중인 이메일입니다."
                    break
                default:
                    debugPrint(code)
                    self.ErrorLabel.text = error.localizedDescription
                }
                //회원가입 성공 처리
            }else{
                
                //회원가입시 데이터베이스에 user데이터 생성
                let uid = Auth.auth().currentUser?.uid
                let id = Auth.auth().currentUser?.email ?? "id"
                let ref = Database.database().reference()
                
                let NewUserData = ["id": id,
                                   "StudentNumber": String(self.SelectedStudentnumber),
                                   "EnteranceClassification": String(self.SelectedEnterance)]
                
                ref.child("User").child(uid!).setValue(NewUserData)
                
                
                //회원가입시 User의 수강내역을 저장할 데이터베이스 생성
                ref.child("ElectiveMajorHistory").child(uid!).setValue("")
                ref.child("CompulsoryMajorHistory").child(uid!).setValue("")
                ref.child("UndergraduateMajorHistory").child(uid!).setValue("")
                ref.child("LiberalKUPersonality").child(uid!).setValue("")
                ref.child("LiberalWriting").child(uid!).setValue("")
                ref.child("LiberalDiscussion").child(uid!).setValue("")
                ref.child("LiberalBasicForeign").child(uid!).setValue("")
                ref.child("LiberalBasicHumanities").child(uid!).setValue("")
                ref.child("LiberalBasicScience").child(uid!).setValue("")
                ref.child("PracticalSkill").child(uid!).setValue("")
                ref.child("PracticalKnowledge").child(uid!).setValue("")
                ref.child("GraduationLanguage").child(uid!).setValue("")
                ref.child("GraduationWork").child(uid!).setValue("")
                
                let DepthLiberal = ["GlobalLanguage": 0,
                                    "HumanAndSocial": 0,
                                    "ScienceandTechnology": 0,
                                    "ArtsAndPhysicalEducation": 0,
                                    "Convergence": 0]
                
                

                //여기까지
                
                let alert = UIAlertController(title: "성공", message: "회원가입 완료!", preferredStyle: UIAlertController.Style.alert)
                let okAction = UIAlertAction(title: "확인", style: .default) {(action) in
                    self.showMainController()
                    return
                }
                alert.addAction(okAction)
                self.present(alert, animated: true, completion: nil)
                
            }
        }
    }
    
    
    //로그인 화면으로 전환함수
    private func showMainController(){
        let storyboard = UIStoryboard(name: "Main", bundle: Bundle.main)
        let ViewController = storyboard.instantiateViewController(withIdentifier: "ViewController")
        ViewController.modalPresentationStyle = .fullScreen
        self.dismiss(animated: true, completion: nil)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
}

//텍스트필드 입력에따른 회원가입버튼 활성화?불활성화
extension JoinViewController: UITextFieldDelegate{
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        view.endEditing(true)
        return false
    }

    func textFieldDidEndEditing(_ textField: UITextField) {
        let isEmailpass: Bool = JoinIDField.text != ""
        var ispasswordpass: Bool{
            if JoinPWField.text!.count >= 8{
                return true
            }else{
                return false
            }
        }
        self.RegistrationButton.isEnabled = ispasswordpass && isEmailpass
    }
    
    
    //피커뷰 열의 갯수
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 2
    }
    
    //각 컴포넌트에 들어갈 행의 갯수를 리턴. 첫번째엔 학번, 두번째엔 입학구분
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        if component == 0{
            return StudentnumberList.count
        }else{
            return Enterance.count
        }
    }
    
    //각 컴포넌트의 행마다 어떤 문자열을 보여줄지에 대한 코드를 작성한다.
    private func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String {
        if component == 0{
            return StudentnumberList[row]
        }else{
            return Enterance[row]
        }
    }
    
    //피커뷰의 스크롤을 움직여서 값이 선택 되었을 때 호출되는 메서드
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if component == 0{
            SelectedStudentnumber = StudentnumberList[row]
            print(SelectedStudentnumber)
        }else{
            SelectedEnterance = Enterance[row]
            print(SelectedEnterance)
        }
        
    }
    
    
    
    
    
}


