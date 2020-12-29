//
//  InputViewController.swift
//  taskapp2
//
//  Created by takashimakenichi on 2020/12/29.
//  Copyright © 2020 takashimakenichi. All rights reserved.
//

import UIKit
import RealmSwift

class InputViewController: UIViewController {
    @IBOutlet weak var titleTextField: UITextField!
    @IBOutlet weak var contentsTextView: UITextView!
    @IBOutlet weak var datePicker: UIDatePicker!
    
    let realm = try! Realm()
    var task: Task!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        // 背景のタップ時にdismissKeyboardメソッドを呼ぶ
        let tapGesture: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        view.addGestureRecognizer(tapGesture)
        
        // taskインスタンスには前画面のprepareメソッド内で、新規タスクor編集するタスクを設定済み
        titleTextField.text = task.title
        contentsTextView.text = task.contents
        datePicker.date = task.date // 新規タスクの場合はインスタンス生成した日時が入る
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        // タスク内容を上書きする(画面遷移により非表示になるタイミング)
        try! realm.write {
            task.title = titleTextField.text!
            task.contents = contentsTextView.text
            task.date = datePicker.date
            realm.add(task, update: .modified)
        }
        
        super.viewWillDisappear(animated)
    }
    
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
