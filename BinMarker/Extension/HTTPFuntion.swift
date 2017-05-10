//
//  HTTPFuntion.swift
//  BinMarker
//
//  Created by 彭子上 on 2017/5/5.
//  Copyright © 2017年 彭子上. All rights reserved.
//

import UIKit

protocol HTTPFuntionDelegate : NSObjectProtocol {
    func didFinishSingle(index:Int) -> Void
    func didFailSingle(index:Int) -> Void
}

class HTTPFuntion: NSObject ,HTTPFuntionDelegate{
    func didFailSingle(index: Int) {
        
    }

    func didFinishSingle(index: Int) {
        
    }

    

    
    weak var delegate:HTTPFuntionDelegate?
    
    override init() {
        super.init()
        self.delegate=self
    }
    
    func uploadMutiDevice(devices:[DeviceInfo],user:UserInfo,success:()->Void) -> Void {
//        let body:Dictionary = ["userId":user]
//        let firstDevice =  devices.first!
//        let urlStr="http://120.76.74.87/PMSWebService/AjaxService.jsp?"
//        let bodyDic=["userId":user.mobile,
//                     "deviceType":firstDevice.devicetype,
//                     "brand":firstDevice.brandname,
//                     "codeId":firstDevice.code,
//                     "channelId":firstDevice.]
    }
    
    func uploadSingleDevice(with device:DeviceInfo,user:UserInfo,success:()->Void,fail:()->Void) -> Void {
        
    }
    
    func uploadAllData(user:UserInfo) -> Void {
        var uploadDic = Dictionary<String, Any>.init()
//        var deviceDataArray=Array<Any>.init()
        var devicesDataArray=Array<Dictionary<String, Any>>.init()
        
        
//        var collectData = Dictionary<String, Array<Dictionary<String,String>>>.init()
        
//        uploadDic["mobile"]=user.mobile
//        uploadDic["userName"]=user.userName
        

        FMDBFunctions.shareInstance.getDeviceData(with: user).forEach { (device) in
            var deviceDic=Dictionary<String, Any>.init()
            var deviceInfo=Dictionary<String, Any>.init()
            var collectData=Array<Dictionary<String,Any>>.init()
            
            deviceInfo["collectData"]=device.customname
            deviceInfo["code"]=device.code
            deviceInfo["deviceType"]=device.devicetype
            deviceInfo["deviceId"]=device.deviceID
            deviceInfo["brandName"]=device.brandname
            deviceInfo["mobile"]=device.mobile
            
            deviceDic["userControl"]=deviceInfo
            
            
//            deviceDic["mobile"]=device.mobile
//            deviceDic["brandname"]=device.brandname
//            deviceDic["code"]=device.code
//            deviceDic["customname"]=device.customname
//            deviceDic["deviceID"]=device.deviceID
//            deviceDic["devicetype"]=device.devicetype
//            deviceDic["isDefault"]=device.isDefault
//            deviceDic["mobile"]=device.mobile
            
//            var favorites=Array<Dictionary<String, Any>>.init()
            FMDBFunctions.shareInstance.getChannelData(with: device).forEach({ (favorite) in
                var favoriteDic=Dictionary<String, Any>.init()
                
                favoriteDic["channelID"]=favorite.channelID
                favoriteDic["isCustom"]=favorite.isCustom
                favoriteDic["DeviceID"]=favorite.DeviceID
                
                favoriteDic["uid"]=user.mobile
                favoriteDic["name"]=favorite.channelName
                favoriteDic["remoteId"]=favorite.channelNum
                collectData.append(favoriteDic)
            })
            deviceDic["collectData"]=collectData
            devicesDataArray.append(deviceDic)
//            devices.append(deviceDic)
        }
        uploadDic["testaa"]=devicesDataArray
        
        print(uploadDic)
    }
    
    
    func delDevice(with devices:[DeviceInfo],and user:UserInfo,success:()->Void) -> Void {
        
    }
    
    func getAllChange(with userid:String,_ success:()->Void) -> Void {
        var urlStr="http://120.76.74.87/PMSWebService/AjaxService.jsp?"
        let bodyDic=["action":"downloadChannel",
                     "appId":"100070001",
                     "timestamp":"1476087104",
                     "Sign":"0fd30f5721e105521a2d3e1d8d366446",
                     "userId":userid,
                     "deviceType":"",
                     "brand":""]
        
        let bodylist  = NSMutableArray()
        for subDic in bodyDic {
            let tmpStr = subDic.key + "=" + subDic.value
            bodylist.add(tmpStr)
        }
        
        let paraStr=bodylist.componentsJoined(by: "&")
        urlStr=urlStr+paraStr
        urlStr=urlStr.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed)!
        
        var request=URLRequest.init(url: URL(string: urlStr)!)
        request.httpMethod = "GET"
        
        let config=URLSessionConfiguration.default
        let datasession=URLSession(configuration: config)
        let dataTask=datasession.dataTask(with: request) { (data, response, error) in
            let data1 = try!JSONSerialization.jsonObject(with: data!, options: .mutableContainers)
            //Data转换成String打印输出
            print(data1)
        }
        
        dataTask.resume()
        

    }
    
    
    
    
}
