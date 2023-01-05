//
//  InsertUserDataVIewController.swift
//  kumulator
//
//  Created by 강현준 on 2022/07/13.
//

import Foundation
import FirebaseAuth
import FirebaseDatabase

class InsertUserDataVIewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource, UITextFieldDelegate{
    
//    var StudentNumberList: StudentNumber = StudentNumber()
    let ref = Database.database().reference()
    var uid = Auth.auth().currentUser?.uid
    var PassStudentNumber = ""
    
    //텍스트 필드를 누르면 피커가 나오게 사용할거임.
    @IBOutlet weak var StudentNumberPicker: UITextField!
    //전화번호를 입력받을 텍스트필드
    @IBOutlet weak var PhoneNumberTextField: UITextField!
    
    
    //피커뷰의 열 개수는 1개
    let pickerViewCnt = 1
    var selectStudentNumber: String = ""
    
    override func viewDidLoad() {
        navigationController?.navigationBar.isHidden = false
        navigationController?.interactivePopGestureRecognizer?.isEnabled = true
        self.navigationItem.title = "정보입력"
        PhoneNumberTextField.delegate = self
        
        ReadStudentNumberFromFirebase()
        ReadStudentDataFromFirebase()
        
        createPickerView()
        dismissPickerView()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        
    }

    override func viewWillDisappear(_ animated: Bool) {
        navigationController?.navigationBar.isHidden = true
        
    }
    
    //수강 과목 등록 버튼
    @IBAction func SelectCourseHistoryButton(_ sender: UIButton) {
        guard let SelectCourseHistoryViewController = self.storyboard?.instantiateViewController(withIdentifier: "SelectCourseHistoryViewController") else { return }
        SelectCourseHistoryViewController.modalPresentationStyle = .fullScreen
        self.present(SelectCourseHistoryViewController, animated: true, completion: nil)
        
    }
    
    //선택 완료 후 저장버튼
    @IBAction func InsertDone(_ sender: UIButton) {
        ref.child("User").child(self.uid!).child("StudentNumber").setValue(selectStudentNumber)
        if PhoneNumberTextField.text?.isEmpty == false{
            ref.child("User").child(self.uid!).child("PhoneNumber").setValue(PhoneNumberTextField.text!)
        }
        
        ReadStudentDataFromFirebase()
        
        let alert = UIAlertController(title: "성공", message: "저장 완료, 수강 내역을 입력하세요", preferredStyle: UIAlertController.Style.alert)
        
        let okaction = UIAlertAction(title: "확인", style: .default){(action) in
            return
        }
        
        alert.addAction(okaction)
        self.present(alert, animated: true, completion: nil)
        
    }
    
    //이전버튼
    @IBAction func BackButton(_ sender: UIBarButtonItem) {
        self.presentingViewController?.dismiss(animated: true)
    }
    
    //필수 교양 과목 입력 버튼
    @IBAction func CompulsoryLiberalArtInputButton(_ sender: UIButton) {
        guard let CompulsoryLiberalArtSelectViewController = self.storyboard?.instantiateViewController(withIdentifier: "CompulsoryLiberalArtSelectViewController") as? CompulsoryLiberalArtSelectViewController else { return }
        
        CompulsoryLiberalArtSelectViewController.modalPresentationStyle = .fullScreen
        CompulsoryLiberalArtSelectViewController.StudentNumber = PassStudentNumber
        
        self.present(CompulsoryLiberalArtSelectViewController, animated: true)
    }
    
    //피커뷰의 열 개수를 넘김
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return pickerViewCnt
    }
    //피커의 항목 개수를 넘김
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
//        return self.StudentNumberList.StudentNumber.count
        return 0
    }
    
    //피커내에 특정한 위치를 가리키게 될 때, 그 위치에 해당하는 문자령를 봔환
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
//        return self.StudentNumberList.StudentNumber[row]
        return "d"
    }
    
    //pickr가 선택됬을 경우
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
//        self.selectStudentNumber = self.StudentNumberList.StudentNumber[row]
        StudentNumberPicker.text = self.selectStudentNumber
    }
    
    //텍스트 필드가 선택되었을때 피커를 생성하는 메소드
    func createPickerView(){
        let pickerView = UIPickerView()
        pickerView.delegate = self
        StudentNumberPicker.inputView = pickerView
    }
    
    @objc func onPickDone(){
        selectStudentNumber = StudentNumberPicker.text!
        StudentNumberPicker.resignFirstResponder()
        print(selectStudentNumber)
    }
    
    //피커가 사라질 때를 정의하는 메서드
    func dismissPickerView(){
        let toolBar = UIToolbar()
        toolBar.sizeToFit()
        let button = UIBarButtonItem(title: "선택", style: .plain, target: self, action: #selector(self.onPickDone))
        toolBar.setItems([button], animated: true)
        toolBar.isUserInteractionEnabled = true
        StudentNumberPicker.inputAccessoryView = toolBar
    }
    
    //학번 리스트를 읽어옴
    func ReadStudentNumberFromFirebase(){
        
        var tmparry = [Int]()
        
        ref.child("StudentNumber").observe(.value) {snapshot in
            guard let value = snapshot.value as? NSDictionary else { return }
            //value의 정렬을 위해 임시 배열에 Int형으로 저장 후
            for i in value.allValues{
                let tmp = Int(i as! String)!
                tmparry.append(tmp)
            }
            //정렬을 한 뒤에
            tmparry.sort()
            //String으로 변환하여 사용
            for i in tmparry{
                let tmp = String(i)
//                self.StudentNumberList.StudentNumber.append(tmp)
            }
//            self.selectStudentNumber = self.StudentNumberList.StudentNumber.first!
        }
    }
    
    //만약 기존에 정보를 등록해 놨다면 텍스트필드에 뿌려놓음
    func ReadStudentDataFromFirebase(){
        ref.child("User").child(self.uid!).observe(.value) { snapshot in
            guard let value = snapshot.value as? NSDictionary else { return }
            
            let StudentNumber = value["StudentNumber"] as? String ?? "ERROR"
            self.PassStudentNumber = StudentNumber
            
            let PhoneNumber = value["PhoneNumber"] as? String ?? "번호를 입력해주세요"
            
            if StudentNumber == "0"{
                self.StudentNumberPicker.text = "학번을 입력해주세요"
            }else{
                self.StudentNumberPicker.text = StudentNumber
            }
            
            if PhoneNumber == "010-0000-0000"{
                self.PhoneNumberTextField.text = "번호를 입력해주세요"
            }else{
                self.PhoneNumberTextField.text = PhoneNumber
            }
        }
    }
    
    //텍스트필드 클릭시 화면 키보드를 띄움
    func textFieldDidBeginEditing(_ textField: UITextField) {
        PhoneNumberTextField.text = ""
        textField.becomeFirstResponder()
    }
    func textFieldDidEndEditing(_ textField: UITextField) {
        self.view.endEditing(true)
    }
    
    //바탕 클릭시 키보드가 내려가게함
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
}


