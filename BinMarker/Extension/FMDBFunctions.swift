//
//  FMDBFunctions.swift
//  BinMarker
//
//  Created by 彭子上 on 2017/4/21.
//  Copyright © 2017年 彭子上. All rights reserved.
//

//CREATE TABLE IF NOT EXISTS T_UserInfo(
//    couponsNum integer KEY,
//    createTime char KEY,
//    editedTime char KEY,
//    loginName char KEY,
//    mobile char PRIMARY KEY,
//    nickName char KEY,
//    passWord char KEY,
//    photoAddress char KEY,
//    userName char NOT NULL UNIQUE,
//    sex char KEY,
//    isLogin integer KEY
//);
//
//CREATE TABLE IF NOT EXISTS T_DeviceInfo(
//    mobile char KEY,
//    DeviceID INTEGER PRIMARY KEY,
//    devicetype char NOT NULL,
//    brandname char NOT NULL,
//    code char(3) NOT NULL,
//    customname char,
//    isDefault integer,
//    foreign key (mobile) references T_UserInfo(mobile)
//);
//
//CREATE TABLE IF NOT EXISTS T_DeviceFavorite(
//    DeviceID INTEGER  KEY,
//    channelID INTEGER PRIMARY KEY,
//    channelNum INTEGER NOT NULL,
//    channelName char NOT NULL,
//    imageUrl char NULL,
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
            let creatSQL1 = "CREATE TABLE IF NOT EXISTS T_UserInfo(mobile char PRIMARY KEY,couponsNum integer KEY,createTime char KEY,editedTime char KEY,loginName char KEY,nickName char KEY,passWord char KEY,photoAddress char KEY,userName char NOT NULL UNIQUE,sex char KEY,isLogin integer KEY); "
            if (database?.executeUpdate(creatSQL1, withArgumentsIn: nil))! {
                print("用户库建立或者打开成功")
                let creatSQL2 = "CREATE TABLE IF NOT EXISTS T_DeviceInfo( mobile char KEY,DeviceID INTEGER PRIMARY KEY,devicetype char NOT NULL,brandname char NOT NULL,code char(3) NOT NULL,customname char,isDefault integer,foreign key (mobile) references T_UserInfo(mobile)); "
                if(database?.executeUpdate(creatSQL2, withArgumentsIn: nil))!{
                    print("设备库建立或者打开成功")
                    let creatSQL3 = "CREATE TABLE IF NOT EXISTS T_DeviceFavorite( DeviceID INTEGER  KEY, channelID INTEGER PRIMARY KEY, channelNum INTEGER NOT NULL, channelName char NOT NULL,imageUrl char NULL, isCustom integer, foreign key (DeviceID) references T_DeviceInfo(DeviceID) );"
                    if(database?.executeUpdate(creatSQL3, withArgumentsIn: nil))!{
                        print("频道库建立或者打开成功")
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
                    
                    self.insertDeviceData(devicetype: deviceTypeString, brandname: value["brandName"]!, codeString: value["codeString"]! , customname: value["defineName"]!, isDefault: 0, success: { 
                        
                    }, fail: { 
                        
                    })                }
                UserDefaults.standard.removeObject(forKey: "deviceInfo")
                UserDefaults.standard.synchronize()
            }
            
        }
    }
    
    func insertDeviceData(devicetype:String,brandname:String,codeString:String,customname:String,isDefault:Int,success:@escaping ()->Void,fail:@escaping ()->Void) -> Void {
        let quene=FMDatabaseQueue.init(path: targetPath)
        quene?.inDatabase({ (database) in
            guard (database?.open())! else {
                fail()
                print("打开失败")
                return
            }
            let sqlString = "INSERT INTO T_DeviceInfo (deviceID,mobile,devicetype,brandname,code,customname,isDefault) VALUES (?,?,?,?,?,?,?)"
            do {
                let custring=customname.characters.count == 0 ?brandname:customname
                try database?.executeUpdate(sqlString, values: [CommonFunction.idMaker(),"00000000000",devicetype,brandname,codeString,custring,NSNumber.init(value: isDefault)])
                success()
            } catch  {
                print("插入设备数据失败")
                fail()
                database?.close()
            }
            
        })
        
    }
    
    func insertDeviceData(in user:UserInfo,with device:DeviceInfo,success:@escaping ()->Void,fail:@escaping ()->Void) -> Void {
        let quene=FMDatabaseQueue.init(path: targetPath)
        quene?.inDatabase({ (database) in
            if (database?.open())!
            {
                let sqlString = "INSERT INTO T_DeviceInfo (DeviceID,mobile,devicetype,brandname,code,customname,isDefault) VALUES (?,?,?,?,?,?,?)"
                do {
                    
                    let custring=device.customname.characters.count == 0 ?device.brandname:device.customname
                    let deviceid = NSNumber.init(value: Int(device.deviceID)!)
                    print("设备ID" + deviceid.description)
                    try database?.executeUpdate(sqlString, values:[deviceid ,user.mobile,device.devicetype,device.brandname,device.code,custring,NSNumber.init(value: device.isDefault)])
                    success()
                    
                } catch  {
                    print("插入数据失败")
                    fail()
                    database?.close()
                }
                
                
            }
            else
            {
                print("打开失败")
                fail()
            }
        })
        
    }
    
    
    func insertUserData(user:UserInfo,success:@escaping ()->Void,fail:@escaping ()->Void) -> Void {
        let quene=FMDatabaseQueue.init(path: targetPath)
        quene?.inDatabase({ (database) in
            if (database?.open())!
            {
                let sqlString = "INSERT INTO T_UserInfo (sex,nickName,photoAddress,userName,isLogin,mobile,editedTime,createTime) VALUES (?,?,?,?,?,?,?,?)"
                do {
                    try database?.executeUpdate(sqlString, values: [user.sex,user.nickName,user.photoAddress,user.userName,NSNumber.init(value: 0),user.mobile,user.editedTime,user.createTime])
                    success()
                } catch  {
                    print("插入用户数据失败")
                    fail()
                    database?.close()
                }
            }
            else
            {
                print("打开失败")
                fail()
            }
        })
    }
    
    //    DeviceID INTEGER  KEY,
    //    channelID INTEGER PRIMARY KEY,
    //    channelNum INTEGER NOT NULL,
    //    channelName char NOT NULL,
    //    imageUrl char NULL,
    //    isCustom integer,
    //    foreign key (DeviceID) references T_DeviceInfo(DeviceID)
    
    func insertChannelData(device:DeviceInfo,channel:FavoriteInfo,success:@escaping ()->Void,fail:@escaping ()->Void) -> Void {
        let quene=FMDatabaseQueue.init(path: targetPath)
        quene?.inDatabase({ (database) in
            if (database?.open())!
            {
                let sqlString = "INSERT INTO T_DeviceFavorite (channelID,DeviceID,channelNum,channelName,isCustom,imageUrl) VALUES (?,?,?,?,?,?)"
                do {
                    //如果有user的时候,是不需要重新算ID
//                    let md5 = CommonFunction.md5eight(with: (device.deviceID) + device.devicetype + device.brandname + device.code + device.customname)
//                    channel.channelID = md5!
                    print("频道 :" + channel.channelID)
                    
                    try database?.executeUpdate(sqlString, values: [NSNumber.init(value: Int(channel.channelID)!),NSNumber.init(value:Int(device.deviceID)!) ,channel.channelNum,channel.channelName,NSNumber.init(value: channel.isCustom),channel.imageUrl])
                    success()
                } catch  {
                    print("插入数据失败")
                    database?.close()
                    fail()
                }
            }
            else
            {
                print("打开失败")
                fail()
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
    

    func getDeviceData(with user:UserInfo) -> [DeviceInfo]{
        let sqlString="select * from T_DeviceInfo where mobile is " + user.mobile
        var resultArray = Array<DeviceInfo>.init()
        let quene=FMDatabaseQueue.init(path: targetPath)
        quene?.inDatabase({ (database) in
            
            if (database?.open())!
            {
                let result=database?.executeQuery(sqlString, withArgumentsIn: nil)
                while (result?.next())!
                {
                    let device=DeviceInfo.init()
                    device.mobile=user.mobile
                    device.brandname=(result?.string(forColumn: "brandname"))!
                    device.code=(result?.string(forColumn: "code"))!
                    device.customname=(result?.string(forColumn: "customname"))!
                    device.isDefault=(result?.bool(forColumn: "isDefault"))!
                    device.devicetype=(result?.string(forColumn: "devicetype"))!
                    device.deviceID=(result?.string(forColumn: "deviceID"))!
                    resultArray.append(device)
                }
            }
        })
        return resultArray
    }
    
    
    func getChannelData(with device:DeviceInfo) -> [FavoriteInfo] {
        let sqlString="select * from T_DeviceFavorite where DeviceID is " + device.deviceID
        var resultArray = Array<FavoriteInfo>.init()
        let quene=FMDatabaseQueue.init(path: targetPath)
        quene?.inDatabase({ (database) in
            if (database?.open())!
            {
                let result=database?.executeQuery(sqlString, withArgumentsIn: nil)
                while (result?.next())!
                {
                    let favorite=FavoriteInfo.init()
                    favorite.DeviceID=device.deviceID
                    favorite.channelID=(result?.string(forColumn: "channelID"))!
                    favorite.channelNum=(result?.string(forColumn: "channelNum"))!
                    favorite.channelName=(result?.string(forColumn: "channelName"))!
                    favorite.isCustom=(result?.bool(forColumn: "isCustom"))!
                    if result?.bool(forColumn: "isCustom") != nil
                    {
                        favorite.imageUrl=(result?.string(forColumn: "imageUrl"))!
                    }
                    else
                    {
                        favorite.imageUrl=""
                    }
                    resultArray.append(favorite)
                }
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

    
    /// 删除某一条数据
    ///
    /// - Parameters:
    ///   - table: <#table description#>
    ///   - parameters: <#parameters description#>
    ///   - content: <#content description#>
    func delData(table:String,parameters:String ,_ content:String,success:@escaping ()->Void,fail:@escaping ()->Void) -> Void {
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
    
    
    /// 修改某一条数据
    ///
    /// - Parameters:
    ///   - table: <#table description#>
    ///   - targetParameters: <#targetParameters description#>
    ///   - targetContent: <#targetContent description#>
    ///   - parameters: <#parameters description#>
    ///   - content: <#content description#>
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
                    print("修改成功")
                }
                else
                {
                    print("修改失败")
                }
            }
            else
            {
                print("打开失败")
            }
        })
    }
    
    func syncData(with user:UserInfo,successSync:@escaping ()->Void,failSync:@escaping ()->Void) -> Void {
        let devices = self.getAllData()
        let sqlString = "DELETE FROM T_DeviceInfo WHERE mobile is 00000000000"
        let quene=FMDatabaseQueue.init(path: targetPath)
        quene?.inDatabase({ (database) in
            guard (database?.open())! else {
                failSync()
                print("打开失败")
                return
            }
            guard (database?.executeUpdate(sqlString, withArgumentsIn: nil))! else {
                failSync()
                print("删除设备失败")
                return
            }
            print("删除设备成功")
            devices.forEach { (device) in
                let channels = self.getChannelData(with: device)
                let sqlString1 = "DELETE FROM T_DeviceFavorite WHERE DeviceID is " + device.deviceID//
                guard (database?.executeUpdate(sqlString1, withArgumentsIn: nil))! else {
                    failSync()
                    print("删除频道失败")
                    return
                }
                
                print("删除频道成功")
                channels.forEach({ (channel) in
                    channel.DeviceID = device.deviceID
                    self.insertChannelData(device: device, channel: channel, success: {
                        
                    }, fail: {
                        failSync()
                        print("添加频道失败")
                    })
                    
                })
                
                
                device.mobile = user.mobile
//                device.deviceID = CommonFunction.idMaker().stringValue
                self.insertDeviceData(in: user, with: device, success: {
                }, fail: {
                    print("添加设备失败")
                    failSync()
                })
                
                
            }
            successSync()
        })
        
        
    }
    
    
    func delAll(success:@escaping ()->Void,fail:@escaping ()->Void) -> Void {
        let sqlString = "DELETE FROM T_DeviceInfo"
        let quene=FMDatabaseQueue.init(path: targetPath)
        quene?.inDatabase({ (database) in
            guard (database?.open())! else {
                print("打开失败")
                return
            }
            guard (database?.executeUpdate(sqlString, withArgumentsIn: nil))! else {
                fail()
                print("删除失败")
                return
            }
            let sql2 = "DELETE FROM T_DeviceFavorite"
            if (database?.executeUpdate(sql2, withArgumentsIn: nil))!
            {
                success()
                print("删除所有成功")
            }
            
            
        })
    }
}
