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
        return Bundle.main.path(forResource: code, ofType: "bin") != nil
    }
//    @IBAction func chooseDevice(_ sender: UIButton) {
//        FTPopOverMenuConfiguration.default().menuWidth=180
//        let main=self.navigationController?.viewControllers[0] as! MainController
//        print(main.nearRemote)
//        var titleArr:[String]=Array.init()
//        for deviceName in main.nearRemote {
//            titleArr.append(deviceName as! String)
//        }
//        
//        FTPopOverMenu.show(forSender: sender, withMenuArray: titleArr, doneBlock: { (selectIndex) in
//            self.chooseDeviceBtn.setTitle(titleArr[selectIndex], for: .normal)
//            UserDefaults.standard.set(titleArr[selectIndex], forKey: "CurrentDevice")
//        }) { 
//            
//        }
//    }

    @IBAction func powerTest(_ sender: UIButton) {
        //调试代码
        let mbp=MBProgressHUD.showAdded(to: self.view, animated: true)
        mbp.removeFromSuperViewOnHide=true
        mbp.show(animated: true)
        mbp.label.text="发送中:" + sender.tag.description
        if (UserDefaults.standard.string(forKey: "CurrentDevice") == nil) {
            let alert=UIAlertController.init(title: "警告", message: "先点击标题添加设备", preferredStyle: .alert)
            let ok=UIAlertAction.init(title: "好的", style: .default, handler: { (action) in
                mbp.hide(animated: true, afterDelay: 0.5)
                return
            })
            alert.addAction(ok)
            self.present(alert, animated: true, completion: { 
                
            })
            return
        }
        else
        {
            let deviceID:String="IrRemoteControllerA"
            let code:String=BinMakeManger.shareInstance.singleCommand(codeList[currentIndex], sender.tag, self.deviceType.row)
            BluetoothManager.getInstance()?.sendByteCommand(with: code, deviceID: deviceID, sendType: .remoteTemp, success: { (returnData) in
                mbp.detailsLabel.text=returnData?.description
                mbp.hide(animated: true, afterDelay: 0.5)
            }, fail: { (failString) -> UInt in
                mbp.label.text="操作失败"
                mbp.detailsLabel.text=failString
                mbp.hide(animated: true, afterDelay: 1.5)
                return 0
            })
        }
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
        
        let alert=UIAlertController.init(title: "收藏频道号", message: "请输入要收藏的频道", preferredStyle: .alert)
        alert.addTextField(configurationHandler: { (nameField) in
            nameField.placeholder=self.brandName! + " " + self.codeList[self.currentIndex]
        })
        alert.addAction(UIAlertAction.init(title: "好的", style: .default, handler: { (action) in
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
        alert.addAction(UIAlertAction.init(title: "取消", style: .destructive, handler: { (action) in
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
