//
//  FMDBFunctions.swift
//  BinMarker
//
//  Created by 彭子上 on 2017/4/21.
//  Copyright © 2017年 彭子上. All rights reserved.
//

import UIKit

class FMDBFunctions: NSObject {
    static let shareInstance = FMDBFunctions.init()
    let targetPath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first! + "/" + "DeviceInfo" + ".db"

    
    override init() {
        super.init()
        
        let quene=FMDatabaseQueue.init(path: targetPath)
        quene?.inDatabase({ (database) in
            
            let creatSQL="CREATE TABLE IF NOT EXISTS T_DeviceInfo" +
            "(DeviceID INTEGER PRIMARY KEY, " +
            "devicetype char NOT NULL, " +
            "brandname char NOT NULL, " +
            "code char(3) NOT NULL, " +
            "customname char, " +
            "isDefault integer)"
            
            
            if (database?.executeUpdate(creatSQL, withArgumentsIn: nil))! {
                print("数据库建立或者打开成功")
                database?.close()
            }
            else
            {
                print("执行失败")
            }
        })
    }
    
    func translateData() -> Void {
        let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as! NSString
        if  version.floatValue > 1.90 {
            if UserDefaults.standard.object(forKey: "deviceInfo") != nil {
                let tempArray=UserDefaults.standard.object(forKey: "deviceInfo") as! Array<Dictionary<String,String>>
                
                for value in tempArray {
                    var deviceTypeString=value["deviceType"]!
                    deviceTypeString=deviceTypeString.replacingOccurrences(of: "\"", with: "")
                    self.insertData(devicetype: deviceTypeString, brandname: value["brandName"]!, codeString: value["codeString"]! , customname: value["defineName"]!, isDefault: 0, fail: {
                        
                    })
                }
                UserDefaults.standard.removeObject(forKey: "deviceInfo")
                UserDefaults.standard.synchronize()
            }
            
        }
    }
    
    func insertData(devicetype:String,brandname:String,codeString:String,customname:String,isDefault:Int,fail:@escaping ()->Void) -> Void {
        let quene=FMDatabaseQueue.init(path: targetPath)
        quene?.inDatabase({ (database) in
            if (database?.open())!
            {
                let sqlString = "INSERT INTO T_DeviceInfo (devicetype,brandname,code,customname,isDefault) VALUES (?,?,?,?,?)"
                do {
                    try database?.executeUpdate(sqlString, values: [devicetype,brandname,codeString,customname,NSNumber.init(value: isDefault)])
                } catch  {
                    print("插入数据失败")
                    fail()
                    database?.close()
                }

            }
            else
            {
                print("打开失败")
            }
        })

    }
    
    
//    
//    
    func getAllData() -> [DeviceInfo] {
        var resultArray = Array<DeviceInfo>.init()
        let quene=FMDatabaseQueue.init(path: targetPath)
        let sqlString="select * from T_DeviceInfo"
        quene?.inDatabase({ (database) in
            if (database?.open())!
            {
                
                let result=database?.executeQuery(sqlString, withArgumentsIn: nil)
                while (result?.next())!
                {
                    let device=DeviceInfo.init()
                    device.deviceID=(result?.string(forColumn: "deviceID")!)!
                    device.devicetype=(result?.string(forColumn: "devicetype")!)!
                    device.code=(result?.string(forColumn: "code")!)!
                    device.brandname=(result?.string(forColumn: "brandname")!)!
                    device.isDefault=(result?.bool(forColumn: "isDefault"))!
                    device.customname=(result?.string(forColumn: "customname")!)!
                    resultArray.append(device)
                }
            }
            else
            {
                print("打开失败")
            }
            
        })
        return resultArray
    }
    
    func getSelectData(targetParameters : String,content:String) -> [DeviceInfo] {
        var resultArray = Array<DeviceInfo>.init()
        let quene=FMDatabaseQueue.init(path: targetPath)
        let sqlString="select * from T_DeviceInfo where " + targetParameters + " like " + "\"" + content + "\""
        quene?.inDatabase({ (database) in
            if (database?.open())!
            {
                let result=database?.executeQuery(sqlString, withArgumentsIn: nil)
                while (result?.next())!
                {
                    let device=DeviceInfo.init()
                    device.deviceID=(result?.string(forColumn: "deviceID")!)!
                    device.devicetype=(result?.string(forColumn: "devicetype")!)!
                    device.code=(result?.string(forColumn: "code")!)!
                    device.brandname=(result?.string(forColumn: "brandname")!)!
                    device.isDefault=(result?.bool(forColumn: "isDefault"))!
                    device.customname=(result?.string(forColumn: "customname")!)!
                    resultArray.append(device)
                }
            }
            else
            {
                print("打开失败")
            }
            
        })
        return resultArray
    }
    
    /// 返回某一列下内容的个数
    ///
    /// - Parameters:
    ///   - parameters: <#parameters description#>
    ///   - content: <#content description#>
    /// - Returns: <#return value description#>
    func returnSectionCount(parameters:String) -> Int32 {
        let quene=FMDatabaseQueue.init(path: targetPath)
        let sqlString = "select count(DISTINCT " + parameters + ") from T_DeviceInfo "
        var returnCount:Int32 = 0
        quene?.inDatabase({ (database) in
            let result = database?.executeQuery(sqlString, withArgumentsIn: nil)
            
            while (result?.next())!
            {
                returnCount=(result?.int(forColumn: "count(DISTINCT devicetype)"))!
            }
        })
        return returnCount
    }
    
    func returnSectionRowCount(parameters:String,content:String) -> Int32 {
        let quene=FMDatabaseQueue.init(path: targetPath)
        var sqlString = "select count(" + parameters + ") from T_DeviceInfo "
            sqlString += " where " + parameters + " like \"%" + content + "%\""
        var returnCount:Int32 = 0
        quene?.inDatabase({ (database) in
            let result = database?.executeQuery(sqlString, withArgumentsIn: nil)
            
            while (result?.next())!
            {
                returnCount=(result?.int(forColumn: "COUNT(devicetype)"))!
            }
        })
//        print(content + " " + returnCount.description)
        return returnCount
    }

    
    func delData(parameters:String ,_ content:String) -> Void {
        let sqlString="DELETE FROM T_DeviceInfo where " + parameters + " LIKE \"" + content + "\""
        let quene=FMDatabaseQueue.init(path: targetPath)
        quene?.inDatabase({ (database) in
            if (database?.open())!
            {
                if (database?.executeUpdate(sqlString, withArgumentsIn: nil))!
                {
                    print("删除成功")
                }
                else
                {
                    print("删除失败")
                }
            }
            else
            {
                print("打开失败")
            }
            
        })
    }
    
    func setData(targetParameters:String,targetContent:Any,parameters:String ,content:Any) -> Void {
        var sqlString = "UPDATE T_DeviceInfo set "
            + targetParameters
        
        if targetContent is String {
            sqlString += " = \"" + (targetContent as! String) + "\" WHERE " + parameters
        }
        else
        {
            sqlString += " = " + (targetContent as! String) + " WHERE " + parameters
        }
        
        if content is String {
            sqlString += " IS \"" + (content as! String) + "\""
        }
        else
        {
            sqlString += " IS " + (content as! String)
        }
        
        let quene=FMDatabaseQueue.init(path: targetPath)
        quene?.inDatabase({ (database) in
            if (database?.open())!
            {
                if (database?.executeUpdate(sqlString, withArgumentsIn: nil))!
                {
                    print("成功")
                }
                else
                {
                    print("失败")
                }
            }
            else
            {
                print("打开失败")
            }
        })
    }
}
