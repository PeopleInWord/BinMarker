//
//  HTTPForSoapFunction.swift
//  BinMarker
//
//  Created by 彭子上 on 2017/4/27.
//  Copyright © 2017年 彭子上. All rights reserved.
//

import UIKit

class HTTPForSoapFunction: NSObject {
    override init() {
        super.init()
    }
    
    func sendData(with url:String,_ interface:String,_ requestBody:Dictionary<String,String>,
                  success:(Dictionary<String, Any>)->Void,
                  fail:(Error)->Void) -> Void
    {
        
    }
    
    private func makeRequestStr(with body:Dictionary<String, String>,_ interface:String) -> String! {
        let headStr="<?xml version=\"1.0\" encoding=\"utf-8\"?><soap:Envelope xmlns:xsi=\"http://www.w3.org/2001/XMLSchema-instance\" xmlns:xsd=\"http://www.w3.org/2001/XMLSchema\" xmlns:soap=\"http://schemas.xmlsoap.org/soap/envelope/\"><soap:Body><%@ xmlns=\"http://wwdog.org/\">"
        var resUrl = headStr + interface
        for (key, value) in body {
            let subStr = "<" + key + ">" + value + "</" + key + ">"
            resUrl += subStr
        }
        resUrl = resUrl + "</" + interface + "></soap:Body></soap:Envelope>"
        return resUrl
    }
    
//    private func translate(from responseObject:Data) -> Dictionary<String,Any> {
//        let resp = NSString.init(data: responseObject, encoding: 4)
////        let resp = String.init(data: responseObject, encoding: .utf8)
//        var returnDic=Dictionary<String, Any>.init()
//        var resultArray=Array<NSTextCheckingResult>.init()
//        var result=NSRegularExpression.init()
//        do {
//            result = try NSRegularExpression.init(pattern: "(?<=return\\>).*(?=</return)", options: .caseInsensitive)
//            resultArray=result.matches(in: resp! as String, options: .reportProgress, range: NSRange.init(location: 0, length: (resp?.length)!))
//        } catch let error  {
//            print(error)
//        }
//        
////        resultArray.forEach({ (checkingResult) in
////            let subresp = resp?.substring(with: checkingResult.range)
////            returnDic = try! JSONSerialization.data(withJSONObject: subresp!, options: JSONSerialization.WritingOptions(rawValue: 0)).en
////            
////            
////        })
////        
//        
//        
//        
//        
//    }
}
