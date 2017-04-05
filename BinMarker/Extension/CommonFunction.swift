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
        let frontView=self.getCurrentView()
        var hub = frontView?.viewWithTag(10001) as? MBProgressHUD
        if hub == nil {
            hub = MBProgressHUD.showAdded(to: frontView!, animated: true)
            hub?.tag=10001
            hub?.removeFromSuperViewOnHide=true
        }
        hub?.label.text = mainTitle;
        hub?.detailsLabel.text = subTitle;
    }
    
    
    class func stopAnimation(_ mainTitle:String? ,_ subTitle:String?,_ hideTime:TimeInterval) {
        let frontView=self.getCurrentView()
        let hub = frontView?.viewWithTag(10001) as? MBProgressHUD
        hub?.label.text = mainTitle;
        hub?.detailsLabel.text = subTitle;
        hub?.hide(animated: true, afterDelay: hideTime)
    }
    
    
    class func showForShortTime(_ time:TimeInterval ,_ mainTitle:String? ,_ subTitle:String?) {
        let frontView=self.getCurrentView()
        var hub = frontView?.viewWithTag(10001) as? MBProgressHUD
        if hub == nil {
            hub = MBProgressHUD.showAdded(to: frontView!, animated: true)
            hub?.removeFromSuperViewOnHide=true
            hub?.tag=10001
        }
        hub?.label.text = mainTitle
        hub?.detailsLabel.text = subTitle
        hub?.hide(animated: true, afterDelay: time)
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
}
