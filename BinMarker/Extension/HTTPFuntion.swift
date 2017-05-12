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
        //                      "channelId":firstDevice.]
    }
    
    func uploadSingleDevice(with device:DeviceInfo,user:UserInfo,success:()->Void,fail:()->Void) -> Void {
        
    }
    
    func uploadAllData(user:UserInfo,success:@escaping ()->Void,fail:@escaping ()->Void) -> Void {
        var uploadDic = Dictionary<String, Any>.init()
        var devicesDataArray=Array<Dictionary<String, Any>>.init()
        
        FMDBFunctions.shareInstance.getDeviceData(with: user).forEach { (device) in
            var deviceDic=Dictionary<String, Any>.init()
            var deviceInfo=Dictionary<String, Any>.init()
            var collectData=Array<Dictionary<String,Any>>.init()
            //
            deviceInfo["customName"]=device.customname
            deviceInfo["code"]=device.code
            deviceInfo["deviceType"]=device.devicetype
            deviceInfo["deviceId"]=device.deviceID
            deviceInfo["brandName"]=device.brandname
            deviceInfo["mobile"]=device.mobile
            
            deviceDic["device"]=deviceInfo
            //
            FMDBFunctions.shareInstance.getChannelData(with: device).forEach({ (favorite) in
                var favoriteDic=Dictionary<String, Any>.init()
                
                favoriteDic["channelId"]=favorite.channelID
                favoriteDic["isCustom"]=favorite.isCustom
                favoriteDic["deviceId"]=favorite.DeviceID
                
                favoriteDic["channelCustomName"]=favorite.channelName
                favoriteDic["channelNum"]=favorite.channelNum
                collectData.append(favoriteDic)
            })
            deviceDic["channel"]=collectData
            devicesDataArray.append(deviceDic)
        }
        uploadDic["data"]=devicesDataArray
        guard JSONSerialization.isValidJSONObject(uploadDic) else {
            fail()
            print("不能转换")
            return
        }
        let jsondata = try?JSONSerialization.data(withJSONObject: uploadDic, options: JSONSerialization.WritingOptions(rawValue: 0))
        guard jsondata != nil else {
            return
        }
        let str = String.init(data: jsondata!, encoding: .utf8)
        print(str!)
        
        let urlStr="http://120.76.74.87/PMSWebService/AjaxService.jsp?action=collectionChannel"
        var request=URLRequest.init(url: URL(string: urlStr)!)
        request.httpMethod = "POST"
        request.httpBody = jsondata
        request.timeoutInterval = 10
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let config=URLSessionConfiguration.default
        let datasession=URLSession(configuration: config)
        let dataTask=datasession.dataTask(with: request) { (data, response, error) in
            guard (try?JSONSerialization.jsonObject(with: data!, options: .mutableContainers)) != nil else
            {
                fail()
                print("没有数据")
                return
            }
            let data1 = try?JSONSerialization.jsonObject(with: data!, options: .mutableContainers) as! Dictionary<String, Any>
            //Data转换成String打印输出
            success()
            print(data1?["rspMsg"]! as! String)
        }
        
        dataTask.resume()
    }
    
    
    
    func delDevice(with devices:[DeviceInfo],and user:UserInfo,success:()->Void) -> Void {
        
    }
    
    func getAllChange(with user:UserInfo,_ success:@escaping ()->Void) -> Void {
        var urlStr="http://120.76.74.87/PMSWebService/AjaxService.jsp?"
        let bodyDic=["action":"downloadChannel",
                     "appId":"100070001",
                     "timestamp":"1476087104",
                     "Sign":"47b3435414dff3ab4d7a082563095294",
                     "mobile":user.mobile]
        
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
            //            let data1 = try?JSONSerialization.jsonObject(with: data!, options: .mutableContainers) as! Dictionary<String, Any>
            //Data转换成String打印输出
            guard ((try?JSONSerialization.jsonObject(with: data!, options: .mutableContainers)) != nil) else {
                return
            }
            let data1 = try!JSONSerialization.jsonObject(with: data!, options: .mutableContainers) as! Dictionary<String, Any>
            guard data1["data"] != nil else {
                return
            }
            FMDBFunctions.shareInstance.delAll(success: {
                
            }, fail: {
                
            })
            let arr1=data1["data"] as! Array<Dictionary<String,Any>>
            print(arr1)
            for value in arr1
            {
                let deviceDic=value["device"] as! Dictionary<String,Any>
                let channel = value["channel"] as! Array<Dictionary<String,Any>>
                let device = DeviceInfo.init()
                device.brandname = deviceDic["brandName"]! as! String
                device.code = deviceDic["code"]! as! String
                device.deviceID = deviceDic["deviceId"]! as! String
                device.devicetype = deviceDic["deviceType"]! as! String
                device.customname = deviceDic["customName"]! as! String
                FMDBFunctions.shareInstance.insertDeviceData(in: user, with: device, success: {
                    
                }, fail: {
                    
                })
                
                channel.forEach({ (channelDic) in
//                    print( channelDic)
                    let singleChannel = FavoriteInfo.init()
                    singleChannel.channelName =  channelDic["channelCustomName"]! as! String
                    singleChannel.channelID = channelDic["channelId"]! as! String
                    singleChannel.channelNum = channelDic["channelNum"]! as! String
                    singleChannel.DeviceID = device.deviceID
                    if channelDic["photoAddress"] == nil || channelDic["photoAddress"] is NSNull
                    {
                    }
                    else
                    {
                        singleChannel.imageUrl = channelDic["photoAddress"] as! String
                    }
                    
                    FMDBFunctions.shareInstance.insertChannelData(device: device, channel: singleChannel, success: {
                        
                    }, fail: {
                        
                    })
                })
            }
            
            success()
        }
        

        
        dataTask.resume()
        
        
    }
}
