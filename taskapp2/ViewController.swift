//
//  ViewController.swift
//  taskapp2
//
//  Created by takashimakenichi on 2020/12/29.
//  Copyright © 2020 takashimakenichi. All rights reserved.
//

import UIKit
import RealmSwift
import UserNotifications

class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    @IBOutlet weak var tableView: UITableView!
    
    // realmインスタンス
    let realm = try! Realm()
    
    // DB内のタスクを格納するリスト、日付の近い順でソート
    // 以降内容をアップデートするとリスト内は自動的に更新される
    var taskArray = try! Realm().objects(Task.self).sorted(byKeyPath: "date", ascending: true)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        tableView.delegate = self
        tableView.dataSource = self
    }
    
    // 入力画面から戻ってきた時に呼ばれる
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        // tableViewを更新する
        tableView.reloadData()
    }

    // 表示するセル数を返す
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return taskArray.count
    }
    
    // 各セルの内容を返す,各行ごと（indexPathが位置情報を持つ）
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // cellインスタンス取得
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        
        // cellに値を設定
        let task = taskArray[indexPath.row]
        // textLabelはオプショナルのため？必要
        cell.textLabel?.text = task.title
        
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm"
        let dateString: String = formatter.string(from: task.date)
        // subtitleスタイルのcellではtextLabelの下に表示される詳細テキストラベル
        cell.detailTextLabel?.text = dateString
        
        return cell
    }
    
    // 各cell選択時に実行されるdelegateメソッド
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // segue(id:cellSegue)による画面遷移
        performSegue(withIdentifier: "cellSegue", sender: nil)
    }

    // セルの編集内容を返す
    func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle {
        // 削除可能
        return .delete
    }
    
    // 編集内容の実行時に呼ばれる
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        
        if editingStyle == .delete {
            
            // 削除するタスクを取得し、ローカル通知をキャンセル
            let task = taskArray[indexPath.row]
            let center = UNUserNotificationCenter.current()
            center.removePendingNotificationRequests(withIdentifiers: [String(task.id)])
            
            // データベースからタスク削除
            try! realm.write {
                realm.delete(taskArray[indexPath.row])
                // tableViewから削除
                tableView.deleteRows(at: [indexPath], with: .fade)
            }
            
            // 未通知のローカル通知一覧を表示
            center.getPendingNotificationRequests {(requests: [UNNotificationRequest]) in
                for request in requests {
                    print("/----------------")
                    print(request)
                    print("/----------------")
                }
            }
            
        }
    }
    
    // segueで画面遷移する際に呼ばれる
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // 遷移先のviewControllerインスタンス取得
        let inputViewController: InputViewController = segue.destination as! InputViewController
        
        // tableViewの各セルタップ時（タスク編集）
        if segue.identifier == "cellSegue" {
            let indexPath = tableView.indexPathForSelectedRow
            // 遷移先のtaskプロパティに編集するタスクを設定
            inputViewController.task = taskArray[indexPath!.row]
            
        // +(barButtonItem)での遷移時
        } else {
            // Taskクラスのインスタンス生成（新規タスク）
            let task = Task()
            
            let allTasks = realm.objects(Task.self)
            if allTasks.count != 0 {
                // 存在するタスクidの最大値を取得、+1した値を新規タスクのidに設定
                task.id = allTasks.max(ofProperty: "id")! + 1
            }
            // 遷移先のtaskプロパティに設定
            inputViewController.task = task
        }
    }
}

