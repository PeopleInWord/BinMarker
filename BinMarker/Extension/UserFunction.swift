//
//  UserFunction.swift
//  BinMarker
//
//  Created by 彭子上 on 2017/4/28.
//  Copyright © 2017年 彭子上. All rights reserved.
//

import UIKit

class UserFunction: NSObject {
    private let httpManger=NetWorkingManager.init()
//    let testAddress="http://120.76.74.87/PMSWebService/services/"
    override init() {
        super.init()
    }
    
    /// 登录
    ///
    /// - Parameters:
    ///   - tel: <#tel description#>
    ///   - password: <#password description#>
    ///   - success: <#success description#>
    ///   - fail: <#fail description#>
    func loginIn(tel:String,password:String,_ success:@escaping (UserInfo)->Void,_ fail:@escaping (String)->Void ) -> Void {
        let interface="userAccountLogin"
        let requestBody:Dictionary<String,String>=["mobile":tel,"passWord":password]
        
        httpManger.sendDataToServer(withInterface: interface, requestBody: requestBody, success: { (requestDic) in
            if requestDic["resultType"] as! String == "1"
            {
                let userInfo:Array<Dictionary<String,Any>>=requestDic["userAccountLogin"]! as! Array<Dictionary<String, Any>>
                let user = UserInfo.init(info: userInfo.first!)
                success(user)
            }
            else
            {
                var failString=String.init()
                if requestDic["isMember"] as! String == "NO"
                {
                    failString = "不是内测会员"
                }
                else
                {
                    failString = "账号或者密码错误"
                }
                
                fail(failString)
            }
        }) { (error) in
            fail("服务器错误")
            print(error!)
        }
    }
    
    func codeLoginIn(tel:String,code:String,_ success:@escaping (UserInfo)->Void,_ fail:@escaping (String)->Void ) -> Void{
        let interface="userRegLogin"
        let requestBody:Dictionary<String,String>=["mobile":tel,"regCode":code]
        
        httpManger.sendDataToServer(withInterface: interface, requestBody: requestBody, success: { (requestDic) in
            if requestDic["resultType"] as! String == "1"
            {
                let userInfo:Array<Dictionary<String,Any>>=requestDic["userAccountLogin"]! as! Array<Dictionary<String, Any>>
                let user = UserInfo.init(info: userInfo.first!)
                success(user)
            }
            else
            {
                var failString=String.init()
                if requestDic["isMember"] as! String == "NO"
                {
                    failString = "不是内测会员"
                }
                else
                {
                    failString = "账号或者密码错误"
                }
                
                fail(failString)
            }
        }) { (error) in
            fail("服务器错误")
            print(error!)
        }
    }
    
    /// 导入
    ///
    /// - Parameter user: user
    func leadIn(user:UserInfo) -> Void {
        let deviceArray=FMDBFunctions.shareInstance.getAllData()
        deviceArray.forEach { (device) in
            FMDBFunctions.shareInstance.setData(table: "T_DeviceInfo", targetParameters: "DeviceID", targetContent: device.deviceID, parameters: "mobile", content: user.mobile)
        }
        FMDBFunctions.shareInstance.setData(table: "T_UserInfo", targetParameters: "mobile", targetContent: user.mobile, parameters: "isLogin", content: 1)
    }
    
    
    func getUserRegisterCode(tel:String,_ success:@escaping (String)->Void) -> Void {
        let interface="getUserRegisterCode"
        let requestBody:Dictionary<String,String>=["mobile":tel]
        httpManger.sendDataToServer(withInterface: interface, requestBody: requestBody, success: { (requestDic) in
            print(requestDic)
            success("success")
        }) { (error) in
            print(error!)
        }
    }
}





















