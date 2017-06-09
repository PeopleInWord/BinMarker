//
//  VoiceController.swift
//  BinMarker
//
//  Created by 彭子上 on 2017/5/24.
//  Copyright © 2017年 彭子上. All rights reserved.
//

import UIKit

class VoiceController: UIViewController , VoiceDelegate{

    let voiceManger = VoiceManger.init()
    var device = DeviceInfo.init()
    
    @IBOutlet weak var recognitionLab: UILabel!
    @IBOutlet weak var resultLab: UILabel!
    @IBOutlet weak var loadingAction: UIActivityIndicatorView!
    
    @IBOutlet weak var voiceFrame: UIImageView!
    
    @IBOutlet weak var quitBtn: UIButton!
    
    @IBOutlet weak var voiceBtn: UIButton!
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.beginVoiceManger()
        // Do any additional setup after loading the view.
    }
    
    
    @IBAction func quitVoice(_ sender: UIButton) {
        self.dismiss(animated: true) { 
            
        }
        
    }
    
    @IBAction func clickVoiceBtn(_ sender: UIButton) {

        self.beginVoiceManger()
        
    }
    
    func beginVoiceManger(){
        let basic4=CABasicAnimation.init(keyPath: "transform.scale")
        basic4.fromValue=1.0
        basic4.toValue=10
        basic4.duration=1
        
        let basic5=CABasicAnimation.init(keyPath: "opacity")
        basic5.fromValue=1.0
        basic5.toValue=0.0
        basic5.duration=1.0
        
        let group2=CAAnimationGroup.init()
        group2.animations=[basic4,basic5]
        
        group2.duration=1.5
        group2.repeatCount=1000
        group2.timingFunction=CAMediaTimingFunction.init(name: kCAMediaTimingFunctionEaseInEaseOut)
        voiceFrame.layer.add(group2, forKey: "voiceFrame")
        
        recognitionLab.text=NSLocalizedString("正在识别...", comment: "正在识别...")
        voiceBtn.isEnabled=false
        quitBtn.isEnabled=false
        let voiceManger=VoiceManger.shareInstance
        voiceManger.delegate=self
        voiceManger.startHanler()
        
    }
    
    //代理

    func voiceChange(_ volumeValue: Int32) {
        
    }
    
    func endOfSpeech() {
        voiceFrame.layer.removeAllAnimations()
        recognitionLab.text=NSLocalizedString("点击按钮开始识别...", comment: "点击按钮开始识别...")
        voiceBtn.isEnabled=true
        quitBtn.isHidden=false
        quitBtn.isEnabled=true
    }
    
    func results(_ results: String, _ resultArr: [String?]) {
        quitBtn.isHidden=true
        print(resultArr)
        resultLab.text=results
        loadingAction.startAnimating()
        var resultWords = ""
        if (resultArr.count)==0 {
            return
        }
        else
        {
            resultArr.forEach({ (str) in
                resultWords += str!
            })
        }
        DispatchQueue.global().async {
            Thread.sleep(forTimeInterval: 1.5)
            DispatchQueue.main.async {
                self.loadingAction.stopAnimating()
//                self.removeEffect()
                CommonFunction.startAnimation(NSLocalizedString("匹配中...", comment: "匹配中..."), nil)
                //进行语言操作
                print(results)
                
                let path = Bundle.main.path(forResource: "VoiceCommand", ofType: "plist")
                
                let voiceDictemp = NSDictionary.init(contentsOfFile: path!)
                let voiceDic = voiceDictemp as! Dictionary<String, Any>
                let commandDic = voiceDic["Control"] as? Dictionary<String, NSNumber>
                let channelDic = voiceDic["Channel"]  as? Dictionary<String, NSNumber>
                
                var isContain=false
                
                for (key,value) in commandDic!
                {
                    guard key == resultWords else
                    {
                        continue
                    }
                    isContain = true
                    
                    let code:String = self.device.code
                    let commandNum:Int = Int(value)
                    let command = BinMakeManger.shareInstance.singleCommand(code, commandNum, 0)
                    let deviceID:String="IrRemoteControllerA"
                    
                    CommonFunction.startAnimation(NSLocalizedString("发送中:", comment: "发送中:") + value.intValue.description, nil)
                    BluetoothManager.getInstance()?.sendByteCommand(with: command, deviceID: deviceID, sendType: .remoteTemp, success: { (returnData) in
                        CommonFunction.stopAnimation(NSLocalizedString("发送成功", comment: "发送成功"), NSLocalizedString("长度:", comment: "长度:") + (returnData?.description)!,0.3)
                        self.quitBtn.isHidden=false
                        self.quitBtn.isEnabled=true
                    }, fail: { (failString) -> UInt in
                        let failDic=["102" : NSLocalizedString("连接设备失败,请重试", comment: "连接设备失败,请重试"),"103" : NSLocalizedString("设备服务发现失败,尝试重启蓝牙", comment: "设备服务发现失败,尝试重启蓝牙"),"104" : NSLocalizedString("写入操作失败,请重试", comment: "写入操作失败,请重试")]
                        CommonFunction.stopAnimation(NSLocalizedString("操作失败", comment: "操作失败"), failDic[failString!],0.3)
                        self.quitBtn.isHidden=false
                        self.quitBtn.isEnabled=true
                        return 0
                    })
                }
                
                if !isContain
                {
                    for (key,value)  in channelDic!
                    {
                        guard key == resultWords else
                        {
                            continue
                        }
                        isContain = true
                        let channelNum:Int = Int(value)
                        let code:String = self.device.code
                        let command=BinMakeManger.shareInstance.channelCommand(code, channelNum, 0)
                        BluetoothManager.getInstance()?.sendByteCommand(with: command, deviceID: "IrRemoteControllerA", sendType: .remoteTemp, success: { (returnData) in
                            CommonFunction.stopAnimation(NSLocalizedString("控制成功..", comment: "控制成功.."), channelNum.description,1)
                            self.quitBtn.isHidden=false
                            self.quitBtn.isEnabled=true
                        }, fail: { (failString) -> UInt in
                            CommonFunction.stopAnimation(NSLocalizedString("操作失败..", comment: "操作失败.."), failString,1)
                            self.quitBtn.isHidden=false
                            self.quitBtn.isEnabled=true
                            return 0
                        })
                    }
                }
                
                if !isContain {
                    CommonFunction.stopAnimation(NSLocalizedString("操作失败..", comment: "操作失败.."), NSLocalizedString("没找到对应控制指令", comment: "没找到对应控制指令"),1.5)
                    self.quitBtn.isHidden=false
                    self.quitBtn.isEnabled=true
                }
                
            }
        }


    }
    
//    func removeEffect() -> Void {
//        let basic1=CABasicAnimation.init(keyPath: "opacity")
//        basic1.fromValue=1.0
//        basic1.toValue=0.0
//        basic1.duration=0.5
//        basic1.isRemovedOnCompletion=true
//        effectView.isHidden=true
//        effectView.layer.add(basic1, forKey: "effectView")
//        effectView.removeFromSuperview()
//    }
    
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
