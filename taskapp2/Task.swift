//
//  Task.swift
//  taskapp2
//
//  Created by takashimakenichi on 2020/12/29.
//  Copyright © 2020 takashimakenichi. All rights reserved.
//

import RealmSwift

class Task: Object {
    // 管理用ID.プライマリーキー
    @objc dynamic var id = 0
    // タイトル
    @objc dynamic var title = ""
    //  内容
    @objc dynamic var contents = ""
    // 日時.現在日時取得
    @objc dynamic var date = Date()
    
    // idをプライマリーキーに設定
    override static func primaryKey() -> String? {
        return "id"
    }
    
}
