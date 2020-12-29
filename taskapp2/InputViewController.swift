//
//  InputViewController.swift
//  taskapp2
//
//  Created by takashimakenichi on 2020/12/29.
//  Copyright © 2020 takashimakenichi. All rights reserved.
//

import UIKit
import RealmSwift
import UserNotifications

class InputViewController: UIViewController, UITextFieldDelegate {
    @IBOutlet weak var titleTextField: UITextField!
    @IBOutlet weak var contentsTextView: UITextView!
    @IBOutlet weak var categoryTextField: UITextField!
    @IBOutlet weak var datePicker: UIDatePicker!
    @IBOutlet weak var decisionButton: UIButton!
    
    let realm = try! Realm()
    var task: Task!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        // 背景のタップ時にdismissKeyboardメソッドを呼ぶ
        let tapGesture: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        view.addGestureRecognizer(tapGesture)
        
        // taskインスタンスには前画面のprepareメソッド内で、新規タスクor編集するタスクを設定済み
        titleTextField.placeholder = "入力必須です"
        titleTextField.delegate = self
        categoryTextField.delegate = self
        
        titleTextField.text = task.title
        contentsTextView.text = task.contents
        categoryTextField.text = task.category
        datePicker.date = task.date // 新規タスクの場合はインスタンス生成した日時が入る
        
        if task.title == "" {
            decisionButton.setTitle("新規作成", for: .normal)
        } else {
            decisionButton.setTitle("タスク変更", for: .normal)
        }
        
        if titleTextField.text == "" {
            decisionButton.isEnabled = false
            decisionButton.alpha = 0.3
        } else {
            decisionButton.isEnabled = true
            decisionButton.alpha = 1.0
        }
        
    }
    
    /*
    override func viewWillDisappear(_ animated: Bool) {
        // タスク内容を上書きする(画面遷移により非表示になるタイミング)
        try! realm.write {
            task.title = titleTextField.text!
            task.contents = contentsTextView.text
            task.category = categoryTextField.text!
            task.date = datePicker.date
            realm.add(task, update: .modified)
        }
        
        // ローカル通知
        setNotification(task: task)
        
        super.viewWillDisappear(animated)
    }
    */
    
    @IBAction func decisionButtonAction(_ sender: Any) {
        // タスク内容を上書きする(画面遷移により非表示になるタイミング)
        try! realm.write {
            task.title = titleTextField.text!
            task.contents = contentsTextView.text
            task.category = categoryTextField.text!
            task.date = datePicker.date
            realm.add(task, update: .modified)
        }
        // ローカル通知
        setNotification(task: task)
        
        // ひとつ前のviewControllerに戻る
        navigationController?.popViewController(animated: true)
    }
    
    
    // タスクのローカル通知を登録
    func setNotification(task: Task) {
        let content = UNMutableNotificationContent()
        // 通知のタイトルと内容の設定
        if task.title == "" {
            content.title = "(タイトルなし)"
        } else {
            content.title = task.title
        }
        if task.contents == "" {
            content.body = "(内容なし)"
        } else {
            content.body = task.contents
        }
        content.sound = UNNotificationSound.default
        
        // ローカル通知が発動するtrigger（日付マッチ）を作成
        let calendar = Calendar.current
        let dateComponents = calendar.dateComponents([.year, .month, .day, .hour, .minute], from: task.date)
        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: false)
        
        // identifier, content, triggerからローカル通知を作成（identifierが同じ場合はローカル通知上書き）
        let request = UNNotificationRequest(identifier: String(task.id), content: content, trigger: trigger)
        
        // ローカル通知を登録
        let center = UNUserNotificationCenter.current()
        center.add(request) { (error) in
            print(error ?? "ローカル通知OK")  // errorがnilならローカル通知OKと表示
        }
        
        // 未通知のローカル通知一覧をログ出力
        center.getPendingNotificationRequests { (requests: [UNNotificationRequest]) in
            for request in requests {
                print("/--------------------")
                print(request)
                print("/--------------------")
            }
        }
        
        
    }
    
    @objc func dismissKeyboard() {
        view.endEditing(true)
        
        if titleTextField.text == "" {
            decisionButton.isEnabled = false
            decisionButton.alpha = 0.3
        } else {
            decisionButton.isEnabled = true
            decisionButton.alpha = 1.0
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        // キーボードを閉じる
//        textField.resignFirstResponder()
//
//        if titleTextField.text == "" {
//            decisionButton.isEnabled = false
//        } else {
//            decisionButton.isEnabled = true
//        }
        
        dismissKeyboard()
        
        return true
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
