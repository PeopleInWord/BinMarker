//
//  TestController.swift
//  BinMarker
//
//  Created by 彭子上 on 2017/2/22.
//  Copyright © 2017年 彭子上. All rights reserved.
//

import UIKit

class TestController: UIViewController{

//    public var version : String!
    public var deviceTypeStr : String!
    public var deviceType:NSIndexPath!
    public var brandName : String!
//    public let codeList:[String]=["Power","Vol-","Vol+","Up","Down","Left","Right","OK"]//这个暂时写死,应该由上级传到这里
    public var codeList:[String]!
    
    @IBOutlet weak var previousBtn: UIButton!
    @IBOutlet weak var nextBtn: UIButton!
    @IBOutlet weak var chooseDeviceBtn: UIButton!
    @IBOutlet weak var currentInfoLab: UILabel!
    @IBOutlet weak var currentCode: UILabel!
    
    
    @IBOutlet weak var moreView: UIView!
    
    @IBOutlet weak var testPad: UIView!
    
    @IBOutlet weak var testBg: UIView!
    
    var currentIndex : Int = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        currentInfoLab.text = brandName
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
    @IBAction func moreBtn(_ sender: UIBarButtonItem) {
        self.testBg.isHidden=false
        let fade=POPBasicAnimation.init(propertyNamed: kPOPViewAlpha)
        fade?.fromValue=0
        fade?.toValue=0.6
        self.moreView.pop_add(fade, forKey: "fade")
        
        let scale=POPSpringAnimation.init(propertyNamed: kPOPLayerScaleXY)
        scale?.fromValue=NSValue.init(cgSize: CGSize.init(width: 0.4, height: 0.4))
        scale?.toValue=NSValue.init(cgSize: CGSize.init(width: 1.0, height: 1.0))
        scale?.dynamicsFriction=15
        self.testPad.layer.pop_add(scale, forKey: "scale")
        
        let point=POPBasicAnimation.init(propertyNamed: kPOPLayerPosition)
        point?.toValue=NSValue.init(cgPoint: (self.view.window?.center)!)
        self.testPad.layer.pop_add(point, forKey: "point")
        
        
    }
    @IBAction func closeMore(_ sender: UIButton) {
        self.testBg.isHidden = true
        let fade=POPBasicAnimation.init(propertyNamed: kPOPViewAlpha)
        fade?.fromValue=0.6
        fade?.toValue=0
        self.moreView.pop_add(fade, forKey: "fade")
    }

    @IBAction func powerTest(_ sender: UIButton) {
        //调试代码
        CommonFunction.startAnimation(NSLocalizedString("发送中:", comment: "发送中:"), sender.tag.description)
            let deviceID:String="IrRemoteControllerA"
            let code:String=BinMakeManger.shareInstance.singleCommand(codeList[currentIndex], sender.tag, self.deviceType.row)
            BluetoothManager.getInstance()?.sendByteCommand(with: code, deviceID: deviceID, sendType: .remoteTemp, success: { (returnData) in
                CommonFunction.stopAnimation(NSLocalizedString("操作成功", comment: "操作成功"), returnData?.description, 0.5)
            }, fail: { (failString) -> UInt in
                CommonFunction.stopAnimation(NSLocalizedString("操作失败", comment: "操作失败"), failString, 0.5)
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
            let deviceSubInfoDic:Dictionary<String,String>=[
                "deviceType" : self.deviceTypeStr,
                "brandName" : self.brandName!,
                "codeString" : self.codeList[self.currentIndex],
                "defineName" : alert.textFields!.first!.text!]
            
            let user = UserDefaults.init()
            if (user.array(forKey: "deviceInfo") != nil)
            {
                let deviceInfoArr = NSMutableArray.init(array: user.array(forKey: "deviceInfo")!)
                deviceInfoArr .add(deviceSubInfoDic)
                user.set(deviceInfoArr, forKey: "deviceInfo")
            }
            else
            {
                let deviceInfoArr = NSMutableArray.init()
                deviceInfoArr .add(deviceSubInfoDic)
                user.set(deviceInfoArr, forKey: "deviceInfo")
            }
            
            user.synchronize()

            let _ = self.navigationController?.popToRootViewController(animated: true)
        }))
        alert.addAction(UIAlertAction.init(title: NSLocalizedString("取消", comment: "取消"), style: .destructive, handler: { (action) in
            return
        }))
        self.present(alert, animated: true, completion: {
            print("ddd")
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
