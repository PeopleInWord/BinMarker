//
//  CommonFunction.swift
//  BinMarker
//
//  Created by 彭子上 on 2017/3/30.
//  Copyright © 2017年 彭子上. All rights reserved.
//

import UIKit

class CommonFunction: NSObject {
    //MARK:动画
    class func startAnimation(_ mainTitle:String? ,_ subTitle:String?) {
        self.startAnimation(mainTitle, subTitle, nil)
    }
    
    class func startAnimation(_ mainTitle:String? ,_ subTitle:String? ,_ finish:(()->())?){
        let frontView=self.getCurrentView()
        DispatchQueue.main.async {
            var hub = frontView?.viewWithTag(10001) as? MBProgressHUD
            if hub == nil {
                hub = MBProgressHUD.showAdded(to: frontView!, animated: true)
                hub?.tag=10001
                hub?.removeFromSuperViewOnHide=true
                hub?.completionBlock = {()->() in
                    if (finish != nil){
                        finish!()
                    }
                }
            }
            hub?.label.text = mainTitle;
            hub?.detailsLabel.text = subTitle;
        }
    }
    
    class func changeAnimationTitle(to mainTitle:String? ,_ subTitle:String?){
        let frontView=self.getCurrentView()
        DispatchQueue.main.async {
            var hub = frontView?.viewWithTag(10001) as? MBProgressHUD
            if hub != nil {
                hub?.label.text = mainTitle;
                hub?.detailsLabel.text = subTitle;
            }
        }
    }
    
    
    class func stopAnimation(_ mainTitle:String? ,_ subTitle:String?,_ hideTime:TimeInterval) {
        self.stopAnimation(mainTitle, subTitle, hideTime, nil)
    }
    
    class func stopAnimation(_ mainTitle:String? ,_ subTitle:String?,_ hideTime:TimeInterval,_ finish:(()->())?){
        let frontView=self.getCurrentView()
        DispatchQueue.main.async {
            let hub = frontView?.viewWithTag(10001) as? MBProgressHUD
            hub?.label.text = mainTitle;
            hub?.detailsLabel.text = subTitle;
            hub?.hide(animated: true, afterDelay: hideTime)
            hub?.completionBlock = {()->() in
                if (finish != nil){
                    finish!()
                }
            }
        }
    }
    
    
    class func showForShortTime(_ time:TimeInterval ,_ mainTitle:String? ,_ subTitle:String?) {
        self.showForShortTime(time, mainTitle, subTitle, nil)
    }
    
    class func showForShortTime(_ time:TimeInterval ,_ mainTitle:String? ,_ subTitle:String? ,_ finish:(()->())? ){
        let frontView=self.getCurrentView()
        DispatchQueue.main.async {
            var hub = frontView?.viewWithTag(10001) as? MBProgressHUD
            if hub == nil {
                hub = MBProgressHUD.showAdded(to: frontView!, animated: true)
                hub?.removeFromSuperViewOnHide=true
                hub?.tag=10001
            }
            hub?.label.text = mainTitle
            hub?.detailsLabel.text = subTitle
            hub?.hide(animated: true, afterDelay: time)
            hub?.completionBlock = {()->() in
                if (finish != nil){
                    finish!()
                }
            }
        }
    }
    
    class func getCurrentView() -> UIView?
    {
        var window=UIApplication.shared.keyWindow
        if window?.windowLevel != UIWindowLevelNormal {
            let windows=UIApplication.shared.windows
            for tempWindow in windows {
                if tempWindow.windowLevel == UIWindowLevelNormal {
                    window = tempWindow
                    break
                }
            }
        }
        return window?.subviews.first
    }
    
    class func md5(with str:String) -> String? {
        let cStr = str.cString(using: String.Encoding.utf8);
        let buffer = UnsafeMutablePointer<UInt8>.allocate(capacity: 32)
        
        CC_MD5(cStr!,(CC_LONG)(strlen(cStr!)), buffer)
        let md5String = NSMutableString();
        for i in 0 ..< 16{
            md5String.appendFormat("%02x", buffer[i])
        }
        free(buffer)
//        return CommonFunction.replaceMd5(md5Str: md5String as String)
        return md5String as String
    }
    
    class func replaceMd5(md5Str:String) -> String {
        var returnStr = ""
        for single in md5Str.characters
        {
            var temp = String.init()
            switch single {
            case "a":
                temp = "10"
                break;
            case "b":
                temp = "11"
                break;
            case "c":
                temp = "12"
                break;
            case "d":
                temp = "13"
                break;
            case "e":
                temp = "14"
                break;
            case "f":
                temp = "15"
                break;
                
            default:
                temp = "0" + single.description
                break
            }
            returnStr += temp
        }
        return returnStr
    }
    
    class func idMaker() -> NSNumber {
        return NSNumber.init(value: Int(NSDate().timeIntervalSince1970))
    }
    
}
