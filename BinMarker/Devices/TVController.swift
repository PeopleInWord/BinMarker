//
//  TVController.swift
//  BinMarker
//
//  Created by 彭子上 on 2017/3/10.
//  Copyright © 2017年 彭子上. All rights reserved.
//

import UIKit

class TVController: UIViewController ,UITabBarDelegate ,UITableViewDataSource ,UITableViewDelegate ,UIGestureRecognizerDelegate,UITextFieldDelegate,VoiceDelegate,UIImagePickerControllerDelegate,UINavigationControllerDelegate,FavoriteSubScrollDelegate{
    @IBOutlet weak var funtionView: UIView!
    @IBOutlet weak var numView: UIView!
    @IBOutlet weak var tabBar: UITabBar!
    @IBOutlet weak var scrollViewHeight: NSLayoutConstraint!
    @IBOutlet weak var mainScroll: UIScrollView!
    @IBOutlet weak var favoriteList: UITableView!
    @IBOutlet weak var common: UIButton!
    @IBOutlet weak var costom: UIButton!
    @IBOutlet weak var OK_Voice: UIButton!
    @IBOutlet weak var effectView: UIVisualEffectView!
    @IBOutlet weak var voiceBtn: UIButton!
    @IBOutlet weak var voiceFrame: UIImageView!
    @IBOutlet weak var activeLab: UILabel!
    @IBOutlet weak var resultWord: UILabel!
    @IBOutlet weak var loadingVoice: UIActivityIndicatorView!
    @IBOutlet weak var quitBtn: UIButton!
    @IBOutlet weak var favoriteBg: UIVisualEffectView!
    
    //137 109 114 121
    
    var isCommon = true
    var isOpen = false
    //    var resourseList=UserDefaults.standard.object(forKey: "TVfavorite") as! Array<Dictionary<String, Any>>
    var favoriteDB = Array<FavoriteInfo>.init()
    var actionTemp=UIAlertAction.init()
    var nameField=UITextField.init()
    var numberField=UITextField.init()
    var selectedImageBtn=UIButton.init()
    var selectedChannelTitle=String.init()
    
    var user:UserInfo = UserInfo.init()
    
    public var deviceInfo = DeviceInfo.init()
    
    //MARK:方法
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tabBar.selectedItem=self.tabBar.items?[1]
        DispatchQueue.main.async {
            self.mainScroll.setContentOffset(CGPoint.init(x: self.view.frame.width, y: 0), animated: false)
        }
        
        scrollViewHeight.constant=UIScreen.main.bounds.width*1.4
        self.common.layer.cornerRadius=5.0
        self.costom.layer.cornerRadius=5.0
        
        NotificationCenter.default.addObserver(self, selector:#selector(isLegal(_:)) , name: NSNotification.Name.UITextFieldTextDidChange, object: nil)
        // Do any additional setup after loading the view.
    }
    
    
    func isLegal(_ sender:Notification) -> Void {//输入的频道是否合法
        self.actionTemp.isEnabled=(self.nameField.text?.characters.count)! > 0 && self.numberField.text?.characters.count != 0 && (self.numberField.text?.characters.count)! <= 3
    }
    
    
    @IBAction func longPressOk_Voice(_ sender: UILongPressGestureRecognizer) {
        if sender.state.rawValue == 1 {
            let basic1=CABasicAnimation.init(keyPath: "opacity")
            basic1.fromValue=1.0
            basic1.toValue=0.0
            basic1.duration=1.0
            
            let basic2=CABasicAnimation.init(keyPath: "transform.scale")
            basic2.fromValue=1.0
            basic2.toValue=4.0
            basic2.duration=1.0
            
            let group=CAAnimationGroup.init()
            group.animations=[basic1,basic2]
            group.duration=1.0
            group.isRemovedOnCompletion=true
            group.fillMode=kCAFillModeForwards
            sender.view?.layer.add(group, forKey: "button")
            
            let basic3=CABasicAnimation.init(keyPath: "opacity")
            basic3.fromValue=0.0
            basic3.toValue=0.9
            basic3.duration=1
            basic3.isRemovedOnCompletion=false
            effectView.layer.add(basic3, forKey: "effectView")
            effectView.frame=(self.view.frame)
            self.view.window?.addSubview(effectView)
            effectView.isHidden=true
            effectView.isHidden=false
            
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
            
            self.beginVoiceManger()
            resultWord.text="请说话..."
            quitBtn.isEnabled=false
            quitBtn.isHidden=true
        }
        
    }
    
    @IBAction func quitVoice(_ sender: UIButton) {
        self.removeEffect()
    }
    
    
    @IBAction func startVoice(_ sender: UIButton) {
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
        
        activeLab.text=NSLocalizedString("正在识别...", comment: "正在识别...")
        
        self.beginVoiceManger()
    }
    
    
    //MARK:语音回调
    func beginVoiceManger(){
        voiceBtn.isEnabled=false
        quitBtn.isEnabled=false
        let voiceManger=VoiceManger.shareInstance
        voiceManger.delegate=self
        voiceManger.startHanler()
        
    }
    
    func endOfSpeech() {
        voiceFrame.layer.removeAllAnimations()
        activeLab.text=NSLocalizedString("点击按钮开始识别...", comment: "点击按钮开始识别...")
        voiceBtn.isEnabled=true
        quitBtn.isHidden=false
        quitBtn.isEnabled=true
    }
    
    func voiceChange(_ volumeValue: Int32) {
        
    }
    
    func results(_ results: String, _ resultArr: [String?]){
        quitBtn.isHidden=true
        print(resultArr)
        resultWord.text=results
        loadingVoice.startAnimating()
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
                self.loadingVoice.stopAnimating()
                self.removeEffect()
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
                    
                    let code:String = self.deviceInfo.code
                    let commandNum:Int = Int(value)
                    let command = BinMakeManger.shareInstance.singleCommand(code, commandNum, 0)
                    let deviceID:String="IrRemoteControllerA"
                    
                    CommonFunction.startAnimation(NSLocalizedString("发送中:", comment: "发送中:") + value.intValue.description, nil)
                    BluetoothManager.getInstance()?.sendByteCommand(with: command, deviceID: deviceID, sendType: .remoteTemp, success: { (returnData) in
                        CommonFunction.stopAnimation(NSLocalizedString("发送成功", comment: "发送成功"), NSLocalizedString("长度:", comment: "长度:") + (returnData?.description)!,0.3)
                    }, fail: { (failString) -> UInt in
                        let failDic=["102" : NSLocalizedString("连接设备失败,请重试", comment: "连接设备失败,请重试"),"103" : NSLocalizedString("设备服务发现失败,尝试重启蓝牙", comment: "设备服务发现失败,尝试重启蓝牙"),"104" : NSLocalizedString("写入操作失败,请重试", comment: "写入操作失败,请重试")]
                        CommonFunction.stopAnimation(NSLocalizedString("操作失败", comment: "操作失败"), failDic[failString!],0.3)
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
                        let code:String = self.deviceInfo.code
                        let command=BinMakeManger.shareInstance.channelCommand(code, channelNum, 0)
                        BluetoothManager.getInstance()?.sendByteCommand(with: command, deviceID: "IrRemoteControllerA", sendType: .remoteTemp, success: { (returnData) in
                            CommonFunction.stopAnimation(NSLocalizedString("控制成功..", comment: "控制成功.."), channelNum.description,1)
                        }, fail: { (failString) -> UInt in
                            CommonFunction.stopAnimation(NSLocalizedString("操作失败..", comment: "操作失败.."), failString,1)
                            return 0
                        })
                    }
                }
                
                if !isContain {
                    CommonFunction.stopAnimation(NSLocalizedString("操作失败..", comment: "操作失败.."), NSLocalizedString("没找到对应控制指令", comment: "没找到对应控制指令"),1.5)
                }
                
            }
        }
    }
    
    func removeEffect() -> Void {
        let basic1=CABasicAnimation.init(keyPath: "opacity")
        basic1.fromValue=1.0
        basic1.toValue=0.0
        basic1.duration=0.5
        basic1.isRemovedOnCompletion=true
        effectView.isHidden=true
        effectView.layer.add(basic1, forKey: "effectView")
        effectView.removeFromSuperview()
    }
    
    //MARK:频道快捷
    @IBAction func showFavoriteChannel(_ sender: UIButton) {
        
        isOpen = !isOpen
        if isOpen {
            let alpha=POPBasicAnimation.init(propertyNamed: kPOPViewAlpha)
            alpha?.fromValue=0
            alpha?.toValue=0.8
            favoriteBg.pop_add(alpha, forKey: "alpha")
            
            let favoriteScroll=self.view.viewWithTag(10000) as! FavoriteSubScroll
            favoriteScroll.favoriteDelegate=self
            favoriteScroll.reloadData(with: favoriteDB)
        }
        else
        {
            let alpha=POPBasicAnimation.init(propertyNamed: kPOPViewAlpha)
            alpha?.fromValue=0.8
            alpha?.toValue=0.0
            self.favoriteBg.pop_add(alpha, forKey: "alpha")
            
        }
    }
    
    @IBAction func touchToHideFavoriteBG(_ sender: UIButton) {
        let alpha=POPBasicAnimation.init(propertyNamed: kPOPViewAlpha)
        alpha?.fromValue=0.8
        alpha?.toValue=0.0
        self.favoriteBg.pop_add(alpha, forKey: "alpha")
        isOpen = false
    }
    //MARK:频道快捷代理
    internal func didClickBtn(_ sender: UIButton, _ index: Int) {
        DispatchQueue.global().async {
            let alpha=POPBasicAnimation.init(propertyNamed: kPOPViewAlpha)
            alpha?.fromValue=0.8
            alpha?.toValue=0.0
            self.favoriteBg.pop_add(alpha, forKey: "alpha")
            alpha?.completionBlock=({(anim,isFinish) in
                CommonFunction.startAnimation(NSLocalizedString("操作中...", comment: "操作中..."), nil)
                let channelNum={ () -> [Int] in
                    var temp=Array<Int>.init()
                    for favoriteItem in self.favoriteDB
                    {
                        temp.append(Int(favoriteItem.channelNum)!)
                    }
                    return temp
                }()
                let code:String = self.deviceInfo.code
                let command=BinMakeManger.shareInstance.channelCommand(code, channelNum[index], 0)
                BluetoothManager.getInstance()?.sendByteCommand(with: command, deviceID: "IrRemoteControllerA", sendType: .remoteTemp, success: { (returnData) in
                    CommonFunction.stopAnimation(NSLocalizedString("控制成功..", comment: "控制成功.."), returnData?.description,1)
                }, fail: { (failString) -> UInt in
                    CommonFunction.stopAnimation(NSLocalizedString("操作失败..", comment: "操作失败.."), failString,1)
                    return 0
                })
            })
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
        let code:String = deviceInfo.code
        let command = BinMakeManger.shareInstance.singleCommand(code, sender.tag, 0)
        let deviceID:String="IrRemoteControllerA"
        
        CommonFunction.startAnimation(NSLocalizedString("发送中:", comment: "发送中:") + sender.tag.description, nil)
        BluetoothManager.getInstance()?.sendByteCommand(with: command, deviceID: deviceID, sendType: .remoteTemp, success: { (returnData) in
            CommonFunction.stopAnimation(NSLocalizedString("发送成功", comment: "发送成功"), NSLocalizedString("长度:", comment: "长度:") + (returnData?.description)!,0.3)
        }, fail: { (failString) -> UInt in
            let failDic=["102" : NSLocalizedString("连接设备失败,请重试", comment: "连接设备失败,请重试"),"103" : NSLocalizedString("设备服务发现失败,尝试重启蓝牙", comment: "设备服务发现失败,尝试重启蓝牙"),"104" : NSLocalizedString("写入操作失败,请重试", comment: "写入操作失败,请重试")]
            CommonFunction.stopAnimation(NSLocalizedString("操作失败", comment: "操作失败"), failDic[failString!],0.3)
            return 0
        })
    }
    
    @IBAction func favoriteBtn(_ sender: UIBarButtonItem,_ event:UIEvent) {
        FTPopOverMenuConfiguration.default().menuWidth=100
        FTPopOverMenu.show(from: event, withMenuArray: [NSLocalizedString("添加频道收藏", comment: "添加频道收藏"),NSLocalizedString("定时关机", comment: "定时关机")], doneBlock: { (index) in
            if index==0
            {
                let alert=UIAlertController.init(title: NSLocalizedString("收藏频道号", comment: "收藏频道号"), message: NSLocalizedString("请输入要收藏的频道", comment: "请输入要收藏的频道"), preferredStyle: .alert)
                alert.addTextField(configurationHandler: { (nameF) in
                    self.nameField=nameF
                    nameF.delegate=self
                    nameF.placeholder=NSLocalizedString("输入频道名称", comment: "输入频道名称")
                })
                alert.addTextField(configurationHandler: { (number) in
                    self.numberField=number
                    number.delegate=self
                    number.keyboardType = .numberPad
                    number.placeholder=NSLocalizedString("输入频道号(不超过3位)", comment: "输入频道号(不超过3位)")
                })
                let actionOK=UIAlertAction.init(title: NSLocalizedString("好的", comment: "好的"), style: .default, handler: { (action) in
                    let favoriteTemp=FavoriteInfo.init()
                    let userdb = FMDBFunctions.shareInstance.getUserData(targetParameters: "isLogin", content: NSNumber.init(value: true)).first
                    
                    favoriteTemp.DeviceID=self.deviceInfo.deviceID
                    favoriteTemp.channelName=(alert.textFields?[0].text)!
                    favoriteTemp.channelNum=(alert.textFields?[1].text)!
                    favoriteTemp.channelID = CommonFunction.idMaker().stringValue
                    
                    favoriteTemp.isCustom=false
                    FMDBFunctions.shareInstance.insertChannelData(device: self.deviceInfo, channel: favoriteTemp, success: {
                        
                    }, fail: {
                        
                    })
                    self.favoriteDB.append(favoriteTemp)
                    
                    
                    
                    if userdb != nil
                    {
                        let updata = HTTPFuntion.init()
                        updata.uploadAllData(user: self.user, success: {
                            CommonFunction.showForShortTime(0.5, "更新成功", "")
                        }, fail: {
                            CommonFunction.showForShortTime(1.5, "更新失败", "")
                        })
                    }
                    
                    
                    self.favoriteList.reloadData()
                    
                })
                actionOK.isEnabled=false
                self.actionTemp=actionOK
                alert.addAction(actionOK)
                alert.addAction(UIAlertAction.init(title: NSLocalizedString("取消", comment: "取消"), style: .default, handler: { (action) in
                    return
                }))
                self.present(alert, animated: true, completion: {
                    
                })
            }
            else if index==1
            {
                self.performSegue(withIdentifier: "tv2time", sender: nil)
            }
        })
        {
            
        }
        
    }
    
    func tabBar(_ tabBar: UITabBar, didSelect item: UITabBarItem)
    {
        
        if item==tabBar.items?[0] {
            UIView.animate(withDuration: 0.3, delay: 0, options: .curveEaseIn, animations: {
                self.mainScroll.contentOffset=CGPoint.init(x: 0, y: 0)
            }, completion: { (_) in
                
            })
            
        }
        else if item==tabBar.items?[1]{
            UIView.animate(withDuration: 0.3, delay: 0, options: .curveEaseIn, animations: {
                self.mainScroll.contentOffset=CGPoint.init(x: self.view.frame.width, y: 0)
            }, completion: { (_) in
                
            })
        }
        else if item==tabBar.items?[2]{
            UIView.animate(withDuration: 0.3, delay: 0, options: .curveEaseIn, animations: {
                self.mainScroll.contentOffset=CGPoint.init(x: self.view.frame.width*2, y: 0)
            }, completion: { (_) in
                
            })
        }
    }
    //MARK:儿童模式
    
    
    @IBAction func childrenModeSetting(_ sender: UIButton) {
        
        
        
        let securityPin = UserDefaults.standard.string(forKey: "securityPin") ?? nil
        if securityPin != nil {
            
            let alert = UIAlertController.init(title: "输入4位安全码", message: "输入4位安全码", preferredStyle: .alert)
            alert.addTextField(configurationHandler: { (textField) in
                textField.keyboardType = .numberPad
                
            })
            alert.addAction(UIAlertAction.init(title: "确认", style: .default, handler: { (action) in
                let code = alert.textFields?.first?.text
                UserDefaults.standard.set(code, forKey: "securityPin")
                self.performSegue(withIdentifier: "childrenSet", sender: self.deviceInfo)
            }))
            alert.addAction(UIAlertAction.init(title: "取消", style: .cancel, handler: { (action) in
                
            }))
            self.present(alert, animated: true, completion: {
                
            })
            
        }
        else
        {
            let alert = UIAlertController.init(title: "设置4位安全码", message: "第一次请设置安全码", preferredStyle: .alert)
            alert.addTextField(configurationHandler: { (textField) in
                textField.keyboardType = .numberPad
                
            })
            alert.addAction(UIAlertAction.init(title: "确认", style: .default, handler: { (action) in
                let code = alert.textFields?.first?.text
                UserDefaults.standard.set(code, forKey: "securityPin")
                self.performSegue(withIdentifier: "childrenSet", sender: self.deviceInfo)
            }))
            alert.addAction(UIAlertAction.init(title: "取消", style: .cancel, handler: { (action) in
                
            }))
            self.present(alert, animated: true, completion: {
                
            })
            
        }
    }
    
    @IBAction func activateChildren(_ sender: UIButton) {
        let securityPin = UserDefaults.standard.string(forKey: "securityPin") ?? nil
        if securityPin != nil {
            
            FMDBFunctions.shareInstance.setData(table: "T_DeviceInfo", targetParameters: "isDefault", targetContent: NSNumber.init(value: true), parameters: "DeviceID", content: Int(self.deviceInfo.deviceID)!)
            UserDefaults.standard.set(self.deviceInfo.deviceID, forKey: "DefaultDevice")
            
            self.performSegue(withIdentifier: "tv2children", sender: self.deviceInfo)
        }
        else
        {
            let alert = UIAlertController.init(title: "设置4位安全码", message: "第一次请设置安全码", preferredStyle: .alert)
            alert.addTextField(configurationHandler: { (textField) in
                textField.keyboardType = .numberPad
                
            })
            alert.addAction(UIAlertAction.init(title: "确认", style: .default, handler: { (action) in
                let code = alert.textFields?.first?.text
                UserDefaults.standard.set(code, forKey: "securityPin")
                //                self.dismiss(animated: true, completion: {
                FMDBFunctions.shareInstance.setData(table: "T_DeviceInfo", targetParameters: "isDefault", targetContent: NSNumber.init(value: true), parameters: "DeviceID", content: Int(self.deviceInfo.deviceID)!)
                UserDefaults.standard.set(self.deviceInfo.deviceID, forKey: "DefaultDevice")
                //                let user = FMDBFunctions.shareInstance.getUserData(targetParameters: "isLogin", content: NSNumber.init(value: true)).first
                //                let updater = HTTPFuntion.init()
                //                updater.uploadAllData(user: user!, success: {
                //
                //                }, fail: {
                //
                //                })
                
                
                self.performSegue(withIdentifier: "tv2children", sender: self.deviceInfo)
                //                })
            }))
            alert.addAction(UIAlertAction.init(title: "取消", style: .cancel, handler: { (action) in
                
            }))
            self.present(alert, animated: true, completion: {
                
            })
            
        }
        
    }
    
    
    //MARK:列表的代理
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        if scrollView.contentOffset.x>=self.view.frame.width && scrollView.contentOffset.x<self.view.frame.width*2{
            self.tabBar.selectedItem=self.tabBar.items?[1]
        }
        else if scrollView.contentOffset.x>=self.view.frame.width*2
        {
            self.tabBar.selectedItem=self.tabBar.items?[2]
        }
        else
        {
            self.tabBar.selectedItem=self.tabBar.items?[0]
        }
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView .dequeueReusableCell(withIdentifier: "channel", for: indexPath) as UITableViewCell;
        let channelTitleLab:UILabel=cell.viewWithTag(1001) as! UILabel
        let channelImage:UIImageView=cell.viewWithTag(1000) as! UIImageView
        let editBtn:UIButton=cell.viewWithTag(1002) as! UIButton
        if isCommon {
            editBtn.isHidden=true
            let iconList=[#imageLiteral(resourceName: "channel-8"),#imageLiteral(resourceName: "channel-6"),#imageLiteral(resourceName: "channel-12"),#imageLiteral(resourceName: "channel-15"),#imageLiteral(resourceName: "channel-13"),#imageLiteral(resourceName: "channel-10"),#imageLiteral(resourceName: "channel-11")]
            let channelTitle=["广东卫视","湖南卫视","浙江卫视","深圳卫视","CCTV-1","BTV-北京卫视","江苏卫视"]
            channelTitleLab.text=channelTitle[indexPath.row]
            channelImage.image=iconList[indexPath.row]
        }
        else
        {
            editBtn.isHidden=false
            editBtn.addTarget(self, action: #selector(editIcon(_:)), for: .touchUpInside)
            let channelTitle={ () -> Array<String> in
                var temp=Array<String>.init()
                for favoriteItem in self.favoriteDB
                {
                    temp.append(favoriteItem.channelName)
                }
                
                //                for deviceDicInfo in self.resourseList
                //                {
                //                    temp.append(deviceDicInfo["name"] as! String)
                //                }
                return temp
            }()
            
            //图片设置联网
            
            
            //            let channelImageArr={ () -> Array<Data> in
            //                var temp=Array<Data>.init()
            //                for deviceDicInfo in self.resourseList
            //                {
            //                    temp.append(deviceDicInfo["image"] as! Data)
            //                }
            //                return temp
            //            }()
            channelTitleLab.text=channelTitle[indexPath.row]
            //            editBtn.setBackgroundImage(UIImage.init(data: channelImageArr[indexPath.row]), for: .normal)
            
        }
        
        return cell
    }
    
    func editIcon(_ sender:UIButton) -> Void {
        selectedImageBtn=sender
        selectedChannelTitle=(sender.superview?.superview?.viewWithTag(1001)! as! UILabel).text!
        let chooseAlert=UIAlertController.init(title: "选择图片", message: "选择图片来源", preferredStyle: .actionSheet)
        chooseAlert.addAction(UIAlertAction.init(title: "本机图片", style: .default, handler: { (action) in
            let picker=UIImagePickerController.init()
            picker.allowsEditing=false
            picker.sourceType = .photoLibrary
            picker.delegate = self
            self.present(picker, animated: true, completion: {
                
            })
        }))
        chooseAlert.addAction(UIAlertAction.init(title: "预设图片", style: .default, handler: { (action) in
            print("22")
        }))
        chooseAlert.addAction(UIAlertAction.init(title: "取消", style: .cancel, handler: nil))
        self.present(chooseAlert, animated: true) {
            
        }
    }
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        //固定
        CommonFunction.startAnimation(NSLocalizedString("操作中...", comment: "操作中..."), nil)
        if isCommon{
            let channelNum=[11,12,13,14,15,16,17,18]
            let code:String = deviceInfo.code
            let command=BinMakeManger.shareInstance.channelCommand(code, channelNum[indexPath.row], 0)
            BluetoothManager.getInstance()?.sendByteCommand(with: command, deviceID: "IrRemoteControllerA", sendType: .remoteTemp, success: { (returnData) in
                CommonFunction.stopAnimation(NSLocalizedString("控制成功..", comment: "控制成功.."), returnData?.description,1)
            }, fail: { (failString) -> UInt in
                CommonFunction.stopAnimation(NSLocalizedString("操作失败..", comment: "操作失败.."), failString,1)
                return 0
            })
            
        }
            //用户定制
        else
        {
            let channelNum={ () -> [Int] in
                var temp=Array<Int>.init()
                for favoriteItem in self.favoriteDB
                {
                    temp.append(Int(favoriteItem.channelNum)!)
                }
                return temp
            }()
            let code:String = deviceInfo.code
            let command=BinMakeManger.shareInstance.channelCommand(code, channelNum[indexPath.row], 0)
            BluetoothManager.getInstance()?.sendByteCommand(with: command, deviceID: "IrRemoteControllerA", sendType: .remoteTemp, success: { (returnData) in
                CommonFunction.stopAnimation(NSLocalizedString("控制成功..", comment: "控制成功.."), returnData?.description,1)
            }, fail: { (failString) -> UInt in
                CommonFunction.stopAnimation(NSLocalizedString("操作失败..", comment: "操作失败.."), failString,1)
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
        if self.isCommon==true {
            return 7
        }
        else
        {
            return self.favoriteDB.count
            //            return self.resourseList.count
        }
    }
    
    //MARK:图片选取
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        self.dismiss(animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        
        self.dismiss(animated: true) {
            let tempImage=info["UIImagePickerControllerOriginalImage"] as? UIImage
            self.selectedImageBtn.setBackgroundImage(tempImage, for: .normal)
            let imageData=UIImagePNGRepresentation(tempImage!)
            var selectFavoriteItem=FavoriteInfo.init()
            
            
            for favoriteItem in self.favoriteDB
            {
                let name=favoriteItem.channelName
                if name==self.selectedChannelTitle
                {
                    selectFavoriteItem=favoriteItem
                    break
                }
            }
            //这个地方是同步图片的地方,下次修改
            
            //            for dic in self.resourseList
            //            {
            //                let name=dic["name"] as! String
            //                if name==self.selectedChannelTitle
            //                {
            //                    selectDic=dic
            //                    break
            //                }
            //            }
            //            selectFavoriteItem.imageUrl=
            //            selectDic["image"]=imageData
            //            UserDefaults.standard.set(self.resourseList, forKey: "TVfavorite")
            //            UserDefaults.standard.synchronize()
        }
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    
    // MARK: - Navigation
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "tv2children"
        {
            let target = segue.destination as! ChildrenModeController
            target.device = sender as! DeviceInfo
        }
        else if segue.identifier == "childrenSet"
        {
            let target = segue.destination as! ChildrenSettingController
            target.device = sender as! DeviceInfo
            target.channelList = FMDBFunctions.shareInstance.getChannelData(with: sender as! DeviceInfo)
        }
        
        
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    
    
}
