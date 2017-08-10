//
//  BOXController.swift
//  BinMarker
//
//  Created by 彭子上 on 2017/3/11.
//  Copyright © 2017年 彭子上. All rights reserved.
//

import UIKit

class BOXController: UIViewController ,UITabBarDelegate,UITableViewDataSource ,UITableViewDelegate ,UIGestureRecognizerDelegate,UITextFieldDelegate{
    @IBOutlet weak var numView: UIView!
    @IBOutlet weak var functionView: UIView!
    @IBOutlet weak var tabBar: UITabBar!
    @IBOutlet weak var scrollViewHeight: NSLayoutConstraint!
    @IBOutlet weak var mainScroll: UIScrollView!
    @IBOutlet weak var common: UIButton!
    @IBOutlet weak var costom: UIButton!
    @IBOutlet weak var favoriteList: UITableView!
    var isCommon = true
//    var resourseList=UserDefaults.standard.object(forKey: "BOXfavorite") as! Array<Dictionary<String, Any>>
//    public var deviceInfo=Dictionary<String, Any>.init()
    public var deviceInfo = DeviceInfo.init()
    var actionTemp=UIAlertAction.init()
    var nameField=UITextField.init()
    var numberField=UITextField.init()
    var favoriteDB = Array<FavoriteInfo>.init()
    
    var user:UserInfo = UserInfo.init()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.title=self.deviceInfo.brandname
        self.tabBar.selectedItem=self.tabBar.items?[0]
        self.common.layer.cornerRadius=5.0
        self.costom.layer.cornerRadius=5.0
        
        NotificationCenter.default.addObserver(self, selector:#selector(isLegal(_:)) , name: NSNotification.Name.UITextFieldTextDidChange, object: nil)
        // Do any additional setup after loading the view.
    }
    
    //109    137
    func isLegal(_ sender:Notification) -> Void {
        if (self.nameField.text?.characters.count)! > 0 && self.numberField.text?.characters.count != 0 && (self.numberField.text?.characters.count)! <= 3{
            self.actionTemp.isEnabled=true
        }
        else
        {
            self.actionTemp.isEnabled=false
        }
    }
    
    @IBAction func selectCommon(_ sender: UIButton) {
        self.common.backgroundColor=UIColor.black
        self.costom.backgroundColor=UIColor.white
        self.common.setTitleColor(UIColor.white, for: .normal)
        self.costom.setTitleColor(UIColor.black, for: .normal)
        isCommon=true
        self.favoriteList.reloadData()
        
    }
    
    
    @IBAction func selectCostom(_ sender: UIButton) {
        //        self.costom.backgroundColor=UIColor.init(red: 3, green: 139, blue: 244, alpha: 1)
        self.costom.backgroundColor=UIColor.black
        self.common.backgroundColor=UIColor.white
        
        self.costom.setTitleColor(UIColor.white, for: .normal)
        self.common.setTitleColor(UIColor.black, for: .normal)
        isCommon=false
        self.favoriteList.reloadData()
        
    }
    
    
    @IBAction func pressBtn(_ sender: UIButton) {
        print(sender.tag)
//        let code:String = deviceInfo.code
//        let command = BinMakeManger.shareInstance.singleCommand(code, sender.tag, 3)
//        let deviceID:String="IrRemoteControllerA"
        CommonFunction.startAnimation(NSLocalizedString("发送中:", comment: "发送中:") + sender.tag.description, nil)
//        BluetoothManager.getInstance()?.sendByteCommand(with: command, deviceID: deviceID, sendType: .remoteTemp, success: { (returnData) in
//            CommonFunction.stopAnimation(NSLocalizedString("发送成功", comment: "发送成功"), NSLocalizedString("长度:", comment: "长度:") + (returnData?.description)!,0.3)
//        }, fail: { (failString) -> UInt in
//            let failDic=["102" : NSLocalizedString("连接设备失败,请重试", comment: "连接设备失败,请重试"),"103" : NSLocalizedString("设备服务发现失败,尝试重启蓝牙", comment: "设备服务发现失败,尝试重启蓝牙"),"104" : NSLocalizedString("写入操作失败,请重试", comment: "写入操作失败,请重试")]
//            CommonFunction.stopAnimation(NSLocalizedString("操作失败", comment: "操作失败"), failDic[failString!],0.3)
//            return 0
//        })
        
        let code = ToolsFuntion.getFastCodeDeviceIndex(self.deviceInfo.code, deviceType: .SAT, keynum: UInt(sender.tag - 100))
        BluetoothManager.getInstance()?.sendByteCommand(with: code!, deviceID: "IrRemoteControllerA", sendType: .remoteNew, success: { (returnData) in
            CommonFunction.stopAnimation(NSLocalizedString("发送成功", comment: "发送成功"), NSLocalizedString("长度:", comment: "长度:") + (returnData?.description)!,0.3)
        }, fail: { (failString) -> UInt in
            let failDic=["102" : NSLocalizedString("连接设备失败,请重试", comment: "连接设备失败,请重试"),"103" : NSLocalizedString("设备服务发现失败,尝试重启蓝牙", comment: "设备服务发现失败,尝试重启蓝牙"),"104" : NSLocalizedString("写入操作失败,请重试", comment: "写入操作失败,请重试")]
            CommonFunction.stopAnimation(NSLocalizedString("操作失败", comment: "操作失败"), failDic[failString!],0.3)
            return 0
        })
        
    }
    
    @IBAction func favoriteBtn(_ sender: UIBarButtonItem,_ event:UIEvent) {
        FTPopOverMenuConfiguration.default().menuWidth=100
        if UserDefaults.standard.object(forKey: "BOXfavorite") == nil{
            UserDefaults.standard.set([], forKey: "BOXfavorite")
        }
        FTPopOverMenu.show(from: event, withMenuArray: [NSLocalizedString("添加频道收藏", comment: "添加频道收藏")], doneBlock: { (index) in
            if index==0
            {
                let alert=UIAlertController.init(title: NSLocalizedString("收藏频道号", comment: "收藏频道号"), message: NSLocalizedString("请输入要收藏的频道", comment: "请输入要收藏的频道"), preferredStyle: .alert)
                alert.addTextField(configurationHandler: { (nameF) in
                    self.nameField=nameF
                    nameF.delegate=self
                    nameF.placeholder=NSLocalizedString(NSLocalizedString("输入频道名称", comment: "输入频道名称"), comment: "输入频道名称")
                })
                alert.addTextField(configurationHandler: { (number) in
                    self.numberField=number
                    number.tag=201
                    number.delegate=self
                    number.keyboardType = .numberPad
                    number.placeholder=NSLocalizedString("输入频道号(不超过3位)", comment: "输入频道号(不超过3位)")
                })
                let actionOK=UIAlertAction.init(title: NSLocalizedString("好的", comment: "好的"), style: .default, handler: { (action) in
                    //加限制
                    let favoriteTemp=FavoriteInfo.init()
                    favoriteTemp.DeviceID=self.deviceInfo.deviceID
                    favoriteTemp.channelName=(alert.textFields?[0].text)!
                    favoriteTemp.channelNum=(alert.textFields?[1].text)!
                    
                    favoriteTemp.channelID = CommonFunction.idMaker().stringValue
                    
                    favoriteTemp.isCustom=true
                    FMDBFunctions.shareInstance.insertChannelData(device: self.deviceInfo, channel: favoriteTemp, success: {
                        
                    }, fail: {
                        
                    })
                    
                    let userdb = FMDBFunctions.shareInstance.getUserData(targetParameters: "isLogin", content: NSNumber.init(value: true)).first
                    
                    if userdb != nil
                    {
                        let updata = HTTPFuntion.init()
                        updata.uploadAllData(user: self.user, success: {
                            CommonFunction.showForShortTime(0.5, "更新成功", "")
                        }, fail: {
                            CommonFunction.showForShortTime(1.5, "更新失败", "")
                        })
                    }
                    
                    self.favoriteDB.append(favoriteTemp)
                    self.favoriteList.reloadData()
                    
                })
                
                actionOK.isEnabled=false
                self.actionTemp=actionOK
                alert.addAction(actionOK)
                alert.addAction(UIAlertAction.init(title: NSLocalizedString("取消", comment: "取消"), style: .destructive, handler: { (action) in
                    return
                }))
                self.present(alert, animated: true, completion: {
                    
                })
            }
        })
        {
            
        }
        
    }
    
    
    func tabBar(_ tabBar: UITabBar, didSelect item: UITabBarItem)
    {
        if item==tabBar.items?[0] {
            UIView.animate(withDuration: 0.3, delay: 0, options: .curveEaseIn, animations: {
                self.mainScroll.contentOffset=CGPoint.init(x:0, y: 0)
            }, completion: { (_) in
            })
            
        }
        else if item==tabBar.items?[1]{
            UIView.animate(withDuration: 0.3, delay: 0, options: .curveEaseIn, animations: {
                self.mainScroll.contentOffset=CGPoint.init(x:self.view.frame.width, y: 0)
            }, completion: { (_) in
            })
            
        }
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        if scrollView.contentOffset.x>=self.view.frame.width {
            self.tabBar.selectedItem=self.tabBar.items?[1]
        }
        else
        {
            self.tabBar.selectedItem=self.tabBar.items?[0]
        }
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView .dequeueReusableCell(withIdentifier: "BOXchannel", for: indexPath) as UITableViewCell;
        let channelTitleLab:UILabel=cell.viewWithTag(1001) as! UILabel
        let channelImage:UIImageView=cell.viewWithTag(1000) as! UIImageView
        if isCommon {
            let iconList=[#imageLiteral(resourceName: "channel-8"),#imageLiteral(resourceName: "channel-6"),#imageLiteral(resourceName: "channel-12"),#imageLiteral(resourceName: "channel-15"),#imageLiteral(resourceName: "channel-13"),#imageLiteral(resourceName: "channel-10"),#imageLiteral(resourceName: "channel-11")]
            let channelTitle=["广东卫视","湖南卫视","浙江卫视","深圳卫视","CCTV-1","BTV-北京卫视","江苏卫视"]
            channelTitleLab.text=channelTitle[indexPath.row]
            channelImage.image=iconList[indexPath.row]
        }
        else
        {
            let channelTitle={ () -> Array<String> in
                var temp=Array<String>.init()
                for favoriteItem in self.favoriteDB
                {
                    temp.append(favoriteItem.channelName)
                }
                return temp
            }()
            channelTitleLab.text=channelTitle[indexPath.row]
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        CommonFunction.startAnimation(NSLocalizedString("发送中:", comment: "发送中:") + indexPath.row.description, nil)
        if isCommon{
            let channelNum=[11,12,13,14,15,16,17,18]
            let code:String = self.deviceInfo.code
            let command=BinMakeManger.shareInstance.channelCommand(code, channelNum[indexPath.row], 0)
            BluetoothManager.getInstance()?.sendByteCommand(with: command, deviceID: "IrRemoteControllerA", sendType: .remoteTemp, success: { (returnData) in
                CommonFunction.stopAnimation(NSLocalizedString("发送成功", comment: "发送成功"), NSLocalizedString("长度:", comment: "长度:") + (returnData?.description)!,0.3)
            }, fail: { (failString) -> UInt in
                let failDic=["102" : NSLocalizedString("连接设备失败,请重试", comment: "连接设备失败,请重试"),"103" : NSLocalizedString("设备服务发现失败,尝试重启蓝牙", comment: "设备服务发现失败,尝试重启蓝牙"),"104" : NSLocalizedString("写入操作失败,请重试", comment: "写入操作失败,请重试")]
                CommonFunction.stopAnimation(NSLocalizedString("操作失败", comment: "操作失败"), failDic[failString!],0.3)
                return 0
            })
            
            
            
            
        }
        else
        {
            let channelNum={ () -> [Int] in
                var temp=Array<Int>.init()
                for favoriteItem in self.favoriteDB
                {
                    temp.append(Int(favoriteItem.channelNum)!)
                }
//                for deviceDicInfo in self.resourseList
//                {
//                    temp.append(Int(deviceDicInfo.values.first! as! String)!)
//                }
                return temp
            }()
            let code:String = self.deviceInfo.code
            let command=BinMakeManger.shareInstance.channelCommand(code, channelNum[indexPath.row], 0)
            BluetoothManager.getInstance()?.sendByteCommand(with: command, deviceID: "IrRemoteControllerA", sendType: .remoteTemp, success: { (returnData) in
                CommonFunction.stopAnimation(NSLocalizedString("发送成功", comment: "发送成功"), NSLocalizedString("长度:", comment: "长度:") + (returnData?.description)!,0.3)
            }, fail: { (failString) -> UInt in
                let failDic=["102" : NSLocalizedString("连接设备失败,请重试", comment: "连接设备失败,请重试"),"103" : NSLocalizedString("设备服务发现失败,尝试重启蓝牙", comment: "设备服务发现失败,尝试重启蓝牙"),"104" : NSLocalizedString("写入操作失败,请重试", comment: "写入操作失败,请重试")]
                CommonFunction.stopAnimation(NSLocalizedString("操作失败", comment: "操作失败"), failDic[failString!],0.3)
                return 0
            })
        }
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return !isCommon
    }
    
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        let delete = UITableViewRowAction.init(style: .destructive, title: NSLocalizedString("删除", comment: "删除")) { (deleteAction, deleteIndex) in
            
            let favoriteTemp=self.favoriteDB[indexPath.row]
            FMDBFunctions.shareInstance.delData(table: "T_DeviceFavorite", parameters: "channelID", favoriteTemp.channelID, success: {
                
            }, fail: {
                
            })
            self.favoriteDB.remove(at: indexPath.row)
            
            let userdb = FMDBFunctions.shareInstance.getUserData(targetParameters: "isLogin", content: NSNumber.init(value: true)).first
            if userdb != nil
            {
                let updata = HTTPFuntion.init()
                updata.uploadAllData(user: self.user, success: {
                    CommonFunction.showForShortTime(0.5, "更新成功", "")
                }, fail: {
                    CommonFunction.showForShortTime(1.5, "更新失败", "")
                })
            }
            
            tableView.reloadData()
        }
        return [delete]
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return isCommon ?7:self.favoriteDB.count
    }
    
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    deinit {
        NotificationCenter.default.removeObserver(self)
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
