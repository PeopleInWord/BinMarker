//
//  DVDController.swift
//  BinMarker
//
//  Created by 彭子上 on 2017/3/11.
//  Copyright © 2017年 彭子上. All rights reserved.
//

import UIKit

class DVDController: UIViewController ,UITabBarDelegate{

    @IBOutlet weak var scrollViewHeight: NSLayoutConstraint!
    @IBOutlet weak var tabBar: UITabBar!
    @IBOutlet weak var controlView: UIView!
    @IBOutlet weak var functionView: UIView!
    @IBOutlet weak var numView: UIView!
    
    public var deviceInfo=Dictionary<String, Any>.init()
    //131  141 152 121 156 156
    override func viewDidLoad() {
        super.viewDidLoad()
    }

    @IBAction func pressBtn(_ sender: UIButton) {
        print(sender.tag)
        let code:String = deviceInfo["codeString"] as! String
        let command = BinMakeManger.shareInstance.singleCommand(code, sender.tag, 1)
        let deviceID:String="IrRemoteControllerA"
        CommonFunction.startAnimation(NSLocalizedString("发送中:", comment: "发送中:") + sender.tag.description, nil)
        BluetoothManager.getInstance()?.sendByteCommand(with: command, deviceID: deviceID, sendType: .remoteTemp, success: { (returnData) in
            CommonFunction.stopAnimation(NSLocalizedString("发送成功", comment: "发送成功"), NSLocalizedString("长度:", comment: "长度:") + (returnData?.description)!,0.3)
        }, fail: { (failString) -> UInt in
            let failDic=["102" : NSLocalizedString("连接设备失败,请重试", comment: "连接设备失败,请重试"),"103" : NSLocalizedString("设备服务发现失败,尝试重启蓝牙", comment: "设备服务发现失败,尝试重启蓝牙"),"104" : NSLocalizedString("写入操作失败,请重试", comment: "写入操作失败,请重试")]
            CommonFunction.stopAnimation(NSLocalizedString("操作失败", comment: "操作失败"), failDic[failString!],0.3);           return 0
        })
        
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
