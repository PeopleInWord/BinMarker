//
//  FMDBFunctions.swift
//  BinMarker
//
//  Created by 彭子上 on 2017/4/21.
//  Copyright © 2017年 彭子上. All rights reserved.
//

//CREATE TABLE IF NOT EXISTS T_UserInfo(
//    userID INTEGER PRIMARY KEY,
//    couponsNum integer KEY,
//    createTime char KEY,
//    editedTime char KEY,
//    loginName char KEY,
//    mobile char KEY,
//    nickName char KEY,
//    passWord char KEY,
//    photoAddress char KEY,
//    userName char NOT NULL UNIQUE,
//    sex char KEY,
//    isLogin integer KEY
//);
//
//CREATE TABLE IF NOT EXISTS T_DeviceInfo(
//    userID INTEGER  KEY,
//    DeviceID INTEGER PRIMARY KEY,
//    devicetype char NOT NULL,
//    brandname char NOT NULL,
//    code char(3) NOT NULL,
//    customname char,
//    isDefault integer,
//    foreign key (userID) references T_UserInfo(userID)
//);
//
//CREATE TABLE IF NOT EXISTS T_DeviceFavorite(
//    DeviceID INTEGER  KEY,
//    channelID INTEGER PRIMARY KEY,
//    channelNum INTEGER NOT NULL,
//    channelName char NOT NULL,
//    isCustom integer,
//    foreign key (DeviceID) references T_DeviceInfo(DeviceID)
//);

import UIKit

class FMDBFunctions: NSObject {
    static let shareInstance = FMDBFunctions.init()
    let targetPath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first! + "/" + "DeviceInfo" + ".db"

    
    override init() {
        super.init()
        
        let quene=FMDatabaseQueue.init(path: targetPath)
        quene?.inDatabase({ (database) in
            
            let creatSQL1 = "CREATE TABLE IF NOT EXISTS T_UserInfo( userID INTEGER PRIMARY KEY, couponsNum integer KEY, createTime char KEY, editedTime char KEY, loginName char KEY, mobile char KEY, nickName char KEY, passWord char KEY, photoAddress char KEY, userName char NOT NULL UNIQUE, sex char KEY ,isLogin integer KEY); "
            if (database?.executeUpdate(creatSQL1, withArgumentsIn: nil))! {
                print("数据库1建立或者打开成功")
                let creatSQL2 = "CREATE TABLE IF NOT EXISTS T_DeviceInfo( userID INTEGER  KEY, DeviceID INTEGER PRIMARY KEY, devicetype char NOT NULL, brandname char NOT NULL, code char(3) NOT NULL, customname char, isDefault integer, foreign key (userID) references T_UserInfo(userID) ); "
                if(database?.executeUpdate(creatSQL2, withArgumentsIn: nil))!{
                    print("数据库2建立或者打开成功")
                    let creatSQL3 = "CREATE TABLE IF NOT EXISTS T_DeviceFavorite( DeviceID INTEGER  KEY, channelID INTEGER PRIMARY KEY, channelNum INTEGER NOT NULL, channelName char NOT NULL, isCustom integer, foreign key (DeviceID) references T_DeviceInfo(DeviceID) );"
                    if(database?.executeUpdate(creatSQL3, withArgumentsIn: nil))!{
                        print("数据库3建立或者打开成功")
                        database?.close()
                    }
                }
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
                    self.insertDeviceData(devicetype: deviceTypeString, brandname: value["brandName"]!, codeString: value["codeString"]! , customname: value["defineName"]!, isDefault: 0, fail: {
                        
                    })
                }
                UserDefaults.standard.removeObject(forKey: "deviceInfo")
                UserDefaults.standard.synchronize()
            }
            
        }
    }
    
    func insertDeviceData(devicetype:String,brandname:String,codeString:String,customname:String,isDefault:Int,fail:@escaping ()->Void) -> Void {
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
    
    func insertUserData(user:UserInfo) -> Void {
        let quene=FMDatabaseQueue.init(path: targetPath)
        quene?.inDatabase({ (database) in
            if (database?.open())!
            {
                let sqlString = "INSERT INTO T_UserInfo (sex,nickName,photoAddress,userName,isLogin,mobile,editedTime,createTime) VALUES (?,?,?,?,?,?,?,?)"
                do {
                    try database?.executeUpdate(sqlString, values: [user.sex,user.nickName,user.photoAddress,user.userName,NSNumber.init(value: 0),user.mobile,user.editedTime,user.createTime])
                } catch  {
                    print("插入数据失败")
                    database?.close()
                }
            }
            else
            {
                print("打开失败")
            }
        })
    }
    
 
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
                    device.deviceID=(result?.string(forColumn: "DeviceID")!)!
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
    
    /// 得到设备列表
    ///
    /// - Parameters:
    ///   - table: <#table description#>
    ///   - targetParameters: <#targetParameters description#>
    ///   - content: <#content description#>
    /// - Returns: <#return value description#>
    func getSelectData(table:String,targetParameters : String,content:String) -> [DeviceInfo] {
        var resultArray = Array<DeviceInfo>.init()
        let quene=FMDatabaseQueue.init(path: targetPath)
        let sqlString="select * from " + table + " where " + targetParameters + " like " + "\"" + content + "\""
        quene?.inDatabase({ (database) in
            if (database?.open())!
            {
                let result=database?.executeQuery(sqlString, withArgumentsIn: nil)
                while (result?.next())!
                {
                    let device=DeviceInfo.init()
                    device.deviceID=(result?.string(forColumn: "DeviceID")!)!
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
    
    func getUserData(targetParameters : String,content:Any) -> [UserInfo] {
        var resultArray = Array<UserInfo>.init()
        let quene=FMDatabaseQueue.init(path: targetPath)
        var sqlString="select * from " + "T_UserInfo" + " where " + targetParameters + " like "
        
        
        if content is String {
            sqlString += "\"" + (content as! String) + "\""
        }
        else if content is NSNumber
        {
            let num=content as! NSNumber
            sqlString += num.stringValue
        }
        else
        {
            
        }
        
        quene?.inDatabase({ (database) in
            if (database?.open())!
            {
                let result=database?.executeQuery(sqlString, withArgumentsIn: nil)
                while (result?.next())!
                {
                    let user:UserInfo=UserInfo.init()
                    user.mobile=(result?.string(forColumn: "mobile")!)!
                    user.createTime=(result?.string(forColumn: "createTime")!)!
                    user.editedTime=(result?.string(forColumn: "editedTime")!)!
                    user.nickName=(result?.string(forColumn: "nickName")!)!
                    user.photoAddress=(result?.string(forColumn: "photoAddress")!)!
                    user.sex=(result?.string(forColumn: "sex")!)!
                    user.userName=(result?.string(forColumn: "userName")!)!
                    resultArray.append(user)
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
        return returnCount
    }

    
    func delData(table:String,parameters:String ,_ content:String) -> Void {
        let sqlString="DELETE FROM " + table + " where " + parameters + " LIKE \"" + content + "\""
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
    
    func setData(table:String,targetParameters:String,targetContent:Any,parameters:String ,content:Any) -> Void {
        var sqlString = "UPDATE " + table + " set "
            + targetParameters
        
        if targetContent is String {
            sqlString += " = \"" + (targetContent as! String) + "\" WHERE " + parameters
        }
        else
        {
            if targetContent is NSNumber{
                let num=targetContent as! NSNumber
                sqlString += " = " + num.stringValue + " WHERE " + parameters
                
            } else {
                sqlString += " = " + (targetContent as! String) + " WHERE " + parameters
            }
            
        }
        
        
        
        
        if content is String{
            sqlString += " IS \"" + (content as! String) + "\""
        }
        else
        {
            if content is NSNumber {
                let num=content as! NSNumber
                sqlString += " IS " + num.stringValue
            }
            else
            {
                sqlString += " IS " + (content as! String)
            }
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
