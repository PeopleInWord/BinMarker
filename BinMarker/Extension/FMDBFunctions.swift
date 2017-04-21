//
//  FMDBFunctions.swift
//  BinMarker
//
//  Created by 彭子上 on 2017/4/21.
//  Copyright © 2017年 彭子上. All rights reserved.
//

import UIKit

class FMDBFunctions: NSObject {
    let shareInstance = FMDBFunctions.init()
    override init() {
        let path=NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first
        let targetPath = path! + "/" + "DeviceInfo" + ".sqlite"
        let manger=FileManager.default
        if manger.fileExists(atPath: targetPath) {
            
        }
        else
        {
            
        }
        
    }
    
    

}
