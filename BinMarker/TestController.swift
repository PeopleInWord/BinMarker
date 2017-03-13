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
    public var deviceType : String!
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
    @IBAction func chooseDevice(_ sender: UIButton) {
        FTPopOverMenuConfiguration.default().menuWidth=180
        let main=self.navigationController?.viewControllers[0] as! MainController
        print(main.nearRemote)
        var titleArr:[String]=Array.init()
        for deviceName in main.nearRemote {
            titleArr.append(deviceName as! String)
        }
        
        FTPopOverMenu.show(forSender: sender, withMenuArray: titleArr, doneBlock: { (selectIndex) in
            self.chooseDeviceBtn.setTitle(titleArr[selectIndex], for: .normal)
            UserDefaults.standard.set(titleArr[selectIndex], forKey: "CurrentDevice")
        }) { 
            
        }
    }

    @IBAction func powerTest(_ sender: UIButton) {
        //调试代码
        let mbp=MBProgressHUD.showAdded(to: self.view, animated: true)
        mbp.removeFromSuperViewOnHide=true
        mbp.show(animated: true)
        mbp.label.text="发送中"
        if (UserDefaults.standard.string(forKey: "CurrentDevice") == nil) {
            let alert=UIAlertController.init(title: "警告", message: "先点击标题添加设备", preferredStyle: .alert)
            let ok=UIAlertAction.init(title: "好的", style: .default, handler: { (action) in
                return
            })
            alert.addAction(ok)
            self.present(alert, animated: true, completion: { 
                
            })
            return
        }
        else
        {
            let deviceID:String=UserDefaults.standard.string(forKey: "CurrentDevice")!
            let code:[String] =
                ["250132170085021021063008008008008000000000255087168000000",
                 "250132170085021021063008008008008000000000255088167000000",
                 "250132170085021021063008008008008000000000255027228000000",
                 "250132170085021021063008008008008000000000255067188000000",
                 "250132170085021021063008008008008000000000255010245000000",
                 "250132170085021021063008008008008000000000255006249000000",
                 "250132170085021021063008008008008000000000255014241000000",
                 "250132170085021021063008008008008000000000255002253000000"]
            
            BluetoothManager.getInstance()?.sendByteCommand(with: code[currentIndex], deviceID: deviceID, sendType: .remote, success: { (returnData) in
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
        let deviceSubInfoDic:Dictionary<String,String>=[
            "deviceType" : deviceType,
            "brandName" : brandName!,
            "codeString" : codeList[currentIndex]]
        
        let user = UserDefaults.init()
        if (user.array(forKey: "deviceInfo") != nil)
        {
            let deviceInfoArr = NSMutableArray.init(array: user.array(forKey: "deviceInfo")!)
//            if deviceInfoArr.count<4 {
                deviceInfoArr .add(deviceSubInfoDic)
                user.set(deviceInfoArr, forKey: "deviceInfo")
//            }
        }
        else
        {
            let deviceInfoArr = NSMutableArray.init()
            deviceInfoArr .add(deviceSubInfoDic)
            user.set(deviceInfoArr, forKey: "deviceInfo")
        }
        
        user.synchronize()
        let _ = self.navigationController?.popToRootViewController(animated: true)
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