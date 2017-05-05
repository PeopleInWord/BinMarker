//
//  UserInfo.swift
//  BinMarker
//
//  Created by 彭子上 on 2017/4/28.
//  Copyright © 2017年 彭子上. All rights reserved.
//

import UIKit

class UserInfo: NSObject {
    
    var sex = String.init()
    var nickName = String.init()
    var photoAddress = String.init()
    var userName = String.init()
    var mobile = String.init()
    var editedTime = String.init()
    var createTime = String.init()
    
    override init() {
        super.init()
    }
    
    init(info:Dictionary<String,Any>) {
        super.init()
        setValuesForKeys(info)
    }

    
    override func setValue(_ value: Any?, forKey key: String) {
        super.setValue(value, forKey: key)
    }
    
    override func setValue(_ value: Any?, forUndefinedKey key: String) {
        
    }
    
}
