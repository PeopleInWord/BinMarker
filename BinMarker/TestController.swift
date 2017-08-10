//
//  TestController.swift
//  BinMarker
//
//  Created by 彭子上 on 2017/2/22.
//  Copyright © 2017年 彭子上. All rights reserved.
//

import UIKit

class TestController: UIViewController,UIApplicationDelegate{
    public var deviceTypeStr : String!
    public var deviceType:NSIndexPath!
    public var brandName : String!
    //    public let codeList:[String]=["Power","Vol-","Vol+","Up","Down","Left","Right","OK"]//这个暂时写死,应该由上级传到这里
    public var codeList:[String]!
    
    @IBOutlet weak var previousBtn: UIButton!
    @IBOutlet weak var nextBtn: UIButton!
    @IBOutlet weak var chooseDeviceBtn: UIButton!
    @IBOutlet weak var currentCode: UILabel!
    
    @IBOutlet weak var moreView: UIView!
    
    @IBOutlet weak var testPad: UIView!
    @IBOutlet weak var testBg: UIView!
    @IBOutlet weak var otherPad: UIScrollView!
    
    @IBOutlet weak var otherViewHeight: NSLayoutConstraint!
    @IBOutlet weak var navTitle: UINavigationItem!
    
    @IBOutlet weak var channelup: UIButton!
    
    @IBOutlet weak var channelDown: UIButton!
    

    
    var currentIndex : Int = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navTitle.title=brandName
        if deviceTypeStr == "DVD" {
            channelup.isEnabled = false
            channelDown.isEnabled = false
        }
//        var frame = self.otherPad.frame
//        frame.size = CGSize.init(width: self.view.frame.size.width * 0.8, height: self.view.frame.size.height * 0.8)
//        self.otherPad.frame = frame
//
//        otherPad.contentSize = CGSize.init(width: 100, height: 300)
        
        self.setCurrentcode(0)
        
        // Do any additional setup after loading the view.
    }
    
    private func setCurrentcode (_ index:Int)-> Void{
        if self.isContain(codeList[index]) {
            currentCode.text=codeList[index]
        }
        else{
            currentCode.text=codeList[index] + "(不支持)"
        }
    }
    
    private func isContain(_ code:String) ->Bool{
        //        return Bundle.main.path(forResource: code, ofType: "bin") != nil
        return true
    }
    
    
    @IBAction func moreBtn(_ sender: Any) {
        self.testBg.isHidden=false

        self .initOtherView()
        
        
        let fade=POPBasicAnimation.init(propertyNamed: kPOPViewAlpha)
        fade?.fromValue=0
        fade?.toValue=0.6
        self.moreView.pop_add(fade, forKey: "fade")

        let scale=POPSpringAnimation.init(propertyNamed: kPOPLayerScaleXY)
        scale?.fromValue=NSValue.init(cgSize: CGSize.init(width: 1.0, height: 1.0))
        scale?.toValue=NSValue.init(cgSize: CGSize.init(width: 1.0, height: 1.0))
        scale?.dynamicsFriction=15
        self.testPad.layer.pop_add(scale, forKey: "scale")

        let point=POPBasicAnimation.init(propertyNamed: kPOPLayerPosition)
        point?.toValue=NSValue.init(cgPoint: (self.view.window?.center)!)
        self.testPad.layer.pop_add(point, forKey: "point")
        
    }
    
    
    func initOtherView() -> () {
        
        var funtions = ToolsFuntion.getOriginOrder(RemoteDevice(rawValue: UInt(deviceType.row))!)
        funtions?.removeSubrange(Range.init(NSMakeRange(0, 4))!)
        let funTags = ToolsFuntion.getfuntionOrder(RemoteDevice(rawValue: UInt(deviceType.row))!)
        var lineCount : CGFloat = CGFloat((funtions?.count)! / 3)
        if (funtions?.count)! % 3 == 0 {
            lineCount -= 1
        }
        let verticalSpacing :CGFloat = 20 //纵向间隔
        let btnHigh = (self.testPad.frame.size.height - verticalSpacing * 7) / 6
        let btnWidth : CGFloat = btnHigh * 23 / 15
        let horizontalSpacing :CGFloat = (self.testPad.frame.size.width - 3 * btnWidth)/4 //横向间隔
        
        otherViewHeight.constant = lineCount * (verticalSpacing + btnHigh) + verticalSpacing + btnHigh
        funtions?.forEach({ (obj) in
            let verticalOffset : CGFloat = CGFloat((funtions?.index(of: obj))! / 3) //纵向偏移
            let horizontalOffset : CGFloat = CGFloat((funtions?.index(of: obj))! % 3) //横向偏移
            let btn = UIButton.init(type: .system)
            btn.frame = CGRect.init(origin: CGPoint.init(x: horizontalSpacing + (horizontalSpacing + btnWidth) * horizontalOffset, y: verticalSpacing + (verticalSpacing + btnHigh) * verticalOffset), size: CGSize.init(width: btnWidth, height: btnHigh))
            btn.setTitleColor(UIColor.black, for: .normal)
            btn.setBackgroundImage(#imageLiteral(resourceName: "sat_btn_shuzjian_bg"), for: .normal)
            btn.setTitle(obj, for: .normal)
            btn.titleLabel?.font = UIFont.systemFont(ofSize: 13)
            btn.tag = Int(funTags![(funtions?.index(of: obj))!])! + 100
            btn.addTarget(self, action: #selector(powerTest(_:)), for: .touchUpInside)
            otherPad.addSubview(btn)
        })
        
        //按钮在这里添加
    }
    
    @IBAction func closeMore(_ sender: UIButton) {
        self.testBg.isHidden = true
        let fade=POPBasicAnimation.init(propertyNamed: kPOPViewAlpha)
        fade?.fromValue=0.6
        fade?.toValue=0
        self.moreView.pop_add(fade, forKey: "fade1")
    }
    
    @IBAction func powerTest(_ sender: UIButton) {
        //调试代码
        CommonFunction.startAnimation(NSLocalizedString("发送中:", comment: "发送中:"), sender.tag.description)
        let deviceID:String="IrRemoteControllerA"
        let codeIndex = codeList[currentIndex]
        let code = ToolsFuntion.getFastCodeDeviceIndex(codeIndex, deviceType: RemoteDevice(rawValue: UInt(deviceType.row))!, keynum: UInt(sender.tag - 100))
        BluetoothManager.getInstance()?.sendByteCommand(with: code!, deviceID: deviceID, sendType: .remoteNew, success: { (returnData) in
            CommonFunction.stopAnimation(NSLocalizedString("操作成功", comment: "操作成功"), returnData?.description, 0.5)
        }, fail: { (failString) -> UInt in
            CommonFunction.stopAnimation(NSLocalizedString("操作失败", comment: "操作失败"), failString, 1.5)
            return 0
        })
    }
    
    @IBAction func nextCode(_ sender: UIButton) {
        currentIndex += 1
        if currentIndex == codeList.count {
            currentIndex -= 1
        }
        self.setCurrentcode(currentIndex)
        print("next")
    }
    
    @IBAction func previousCode(_ sender: UIButton) {
        if currentIndex>0 {
            currentIndex -= 1
        }
        if currentIndex == codeList.count {
            currentIndex -= 1
        }
        self.setCurrentcode(currentIndex)
        print("previous")
    }
    
    @IBAction func confirm(_ sender: UIButton) {
        
        let alert=UIAlertController.init(title: NSLocalizedString("设备名", comment: "设备名"), message: NSLocalizedString("请输入名称", comment: "请输入名称"), preferredStyle: .alert)
        alert.addTextField(configurationHandler: { (nameField) in
            nameField.placeholder=self.brandName! + " " + self.codeList[self.currentIndex]
        })
        alert.addAction(UIAlertAction.init(title: NSLocalizedString("好的", comment: "好的"), style: .default, handler: { (action) in
            DispatchQueue.main.asyncAfter(deadline: .init(uptimeNanoseconds: 50), execute: {
                CommonFunction.startAnimation(NSLocalizedString("下载第1个命令:", comment: "发送中:"), "下载命令中")
                let codeIndex = self.codeList[self.currentIndex]
                let deviceID:String="IrRemoteControllerA"
                let commands = ToolsFuntion.getDownloadCode(withDeviceIndex: codeIndex, deviceType: RemoteDevice(rawValue: UInt(self.deviceType.row))!)
                BluetoothManager.getInstance()?.setInterval(1)
                var failCodeTemp  = ""
                BluetoothManager.getInstance()?.sendMutiCommand(withSingleDeviceID: deviceID, sendType: .remoteNew, commands: commands, success: { (deviceIndex, data) in
                    CommonFunction.changeAnimationTitle(to: "正在下载第" + (deviceIndex + UInt(2) ).description + "个", "请等待")
                }, fail: { (failCode) -> UInt in
                    failCodeTemp = failCode!
                    return 0
                }, finish: { (finish) in
                    if finish {
                        CommonFunction.stopAnimation(NSLocalizedString("操作完成", comment: "操作完成"), "请检查是否可用", 0.5)
                        let device = DeviceInfo.init()
                        device.devicetype = self.deviceTypeStr
                        device.brandname = self.brandName!
                        device.code = self.codeList[self.currentIndex]
                        device.customname = alert.textFields!.first!.text!
                        device.deviceID = CommonFunction.idMaker().stringValue
                        
                        if device.customname.characters.count == 0
                        {
                            device.customname = device.brandname
                        }
                        
                        let user = FMDBFunctions.shareInstance.getUserData(targetParameters: "isLogin", content: NSNumber.init(value: true)).first
                        if user != nil {
                            FMDBFunctions.shareInstance.insertDeviceData(in: user!, with: device, success: {
                                
                            }, fail: {
                                
                            })
                            let updater=HTTPFuntion.init()
                            updater.uploadAllData(user: user!, success: {
                                
                            }, fail: {
                                
                            })
                        }
                        else
                        {
                            FMDBFunctions.shareInstance.insertDeviceData(devicetype: device.devicetype, brandname: device.brandname, codeString: device.code, customname: device.customname, isDefault: 0, success: {
                                
                            }, fail: {
                                
                            })
                            
                        }
                        
                        let _ = self.navigationController?.popToRootViewController(animated: true)
                    }
                    else {
                        CommonFunction.stopAnimation(NSLocalizedString("操作失败", comment: "操作失败"), "错误代码:" + failCodeTemp.description, 1.5)
                    }
                    
                })
            })
            
            

            
        }))
        alert.addAction(UIAlertAction.init(title: NSLocalizedString("取消", comment: "取消"), style: .destructive, handler: { (action) in
            return
        }))
        self.present(alert, animated: true, completion: {
            
        })
        
        
    }
    
    @IBAction func noAndNext(_ sender: UIButton) {
        currentIndex += 1
        if currentIndex == codeList.count {
            currentIndex = 0
        }
        self.setCurrentcode(currentIndex)
        
    }
    
    
    
    @IBAction func cancle(_ sender: UIButton) {
        let _ = self.navigationController?.popToRootViewController(animated: true)
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
