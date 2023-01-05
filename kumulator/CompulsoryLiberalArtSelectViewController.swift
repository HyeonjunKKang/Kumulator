//
//  CompulsoryLiberalArtSelectViewController.swift
//  kumulator
//
//  Created by 강현준 on 2022/08/04.
//

import Foundation
import UIKit

class CompulsoryLiberalArtSelectViewController: ViewController{
    
    var StudentNumber = ""

    @IBOutlet weak var StudentNumberLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.StudentNumberLabel.text = StudentNumber
        
    }
    
    
    @IBAction func knowledgeInputButton(_ sender: UIButton) {
        StoryboardToInstanceAndSendData(korLiberalArt: "KU소양", engLiberalArt: "knowledge")
    }
    
    @IBAction func WritingInputButton(_ sender: UIButton) {
        StoryboardToInstanceAndSendData(korLiberalArt: "글쓰기", engLiberalArt: "Writing")
    }
    
    @IBAction func PresentationAndDiscussionInputButton(_ sender: UIButton) {
        StoryboardToInstanceAndSendData(korLiberalArt: "발표와토론", engLiberalArt: "PresentationAndDiscussion")
    }
    
    @IBAction func BasicForeignlanguageButton(_ sender: UIButton) {
        StoryboardToInstanceAndSendData(korLiberalArt: "외국어기초", engLiberalArt: "BasicForeignlanguage")
    }
    
    @IBAction func BasicHumanityInputButton(_ sender: UIButton) {
        StoryboardToInstanceAndSendData(korLiberalArt: "인문기초", engLiberalArt: "BasicHumanity")
    }
    
    @IBAction func BasicScienceInputButton(_ sender: UIButton) {
        StoryboardToInstanceAndSendData(korLiberalArt: "과학기초", engLiberalArt: "BasicScience")
    }
    
    
    func StoryboardToInstanceAndSendData(korLiberalArt: String, engLiberalArt: String){
        guard let CompulsoryLiberalArtDetailInputViewController = self.storyboard?.instantiateViewController(withIdentifier: "CompulsoryLiberalArtDetailInputViewController") as? CompulsoryLiberalArtDetailInputViewController else  { return }
        CompulsoryLiberalArtDetailInputViewController.EngLiberalArtsRequirements = engLiberalArt
        CompulsoryLiberalArtDetailInputViewController.KorLiberalArtsRequirements = korLiberalArt
        CompulsoryLiberalArtDetailInputViewController.StudentNumber = StudentNumber
        
        CompulsoryLiberalArtDetailInputViewController.modalPresentationStyle = .fullScreen
        self.present(CompulsoryLiberalArtDetailInputViewController, animated: true)
    }
}
