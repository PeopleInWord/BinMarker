//
//  TVController.swift
//  BinMarker
//
//  Created by 彭子上 on 2017/3/10.
//  Copyright © 2017年 彭子上. All rights reserved.
//

import UIKit

class TVController: UIViewController ,UITabBarDelegate ,UITableViewDataSource ,UITableViewDelegate ,UIGestureRecognizerDelegate,UITextFieldDelegate,VoiceDelegate{
    @IBOutlet weak var controlView: UIView!
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
    var isCommon = true
    var lastTabberItemIndex = 1
    var resourseList=UserDefaults.standard.object(forKey: "TVfavorite") as! Array<Dictionary<String, Any>>
    var actionTemp=UIAlertAction.init()
    var nameField=UITextField.init()
    var numberField=UITextField.init()
    public var deviceInfo:Dictionary<String, Any> = [:]
    //MARK:方法
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tabBar.selectedItem=self.tabBar.items?[lastTabberItemIndex]
        scrollViewHeight.constant=UIScreen.main.bounds.height*0.37
        self.common.layer.cornerRadius=5.0
        self.costom.layer.cornerRadius=5.0

        NotificationCenter.default.addObserver(self, selector:#selector(isLegal(_:)) , name: NSNotification.Name.UITextFieldTextDidChange, object: nil)
            // Do any additional setup after loading the view.
    }
    
    func isLegal(_ sender:Notification) -> Void {
        if (self.nameField.text?.characters.count)! > 0 && self.numberField.text?.characters.count != 0 && (self.numberField.text?.characters.count)! <= 3{
            self.actionTemp.isEnabled=true
        }
        else
        {
            self.actionTemp.isEnabled=false
        }
    }
    
    
    @IBAction func longPressOk_Voice(_ sender: UILongPressGestureRecognizer) {
        print(sender.state.rawValue)
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
            
        }
        
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
        let voiceManger=VoiceManger.shareInstance
        voiceManger.delegate=self
        voiceManger.startHanler()

    }
    
    func endOfSpeech() {
        voiceFrame.layer.removeAllAnimations()
        activeLab.text=NSLocalizedString("点击按钮开始识别...", comment: "点击按钮开始识别...")
        voiceBtn.isEnabled=true
    }
    
    func voiceChange(_ volumeValue: Int32) {
        
    }
    
    func onResults(_ results: String, _ resultArr: Array<String>){
        print(resultArr)
        resultWord.text=results
    }
    
    @IBAction func removeEffect(_ sender: UIButton) {
        let basic1=CABasicAnimation.init(keyPath: "opacity")
        basic1.fromValue=1.0
        basic1.toValue=0.0
        basic1.duration=0.5
        basic1.isRemovedOnCompletion=true
        effectView.isHidden=true
        effectView.layer.add(basic1, forKey: "effectView")
        effectView.removeFromSuperview()
        
        let voiceManger=VoiceManger.shareInstance
        let returnWords=voiceManger.stopAndConfirm()
        if (returnWords.count)>0 {
            CommonFunction.startAnimation(NSLocalizedString("匹配中...", comment: "匹配中..."), nil)
            //进行语言操作
            print(returnWords)

            let channelTitle=["广东":0,"湖南":1,"浙江":13,"深圳":14,"中央":15,"北京":16,"江苏":17]
            var isContain=false
            for channel in channelTitle.keys {
                for word in returnWords {
                    if channel == word {
                        let channelNum:Int = channelTitle[channel]!
                        let code:String = self.deviceInfo["codeString"] as! String
                        let command=BinMakeManger.shareInstance.channelCommand(code, channelNum, 0)
                        BluetoothManager.getInstance()?.sendByteCommand(with: command, deviceID: "IrRemoteControllerA", sendType: .remoteTemp, success: { (returnData) in
                            CommonFunction.stopAnimation(NSLocalizedString("控制成功..", comment: "控制成功.."), channel,1)
                        }, fail: { (failString) -> UInt in
                            CommonFunction.stopAnimation(NSLocalizedString("操作失败..", comment: "操作失败.."), failString,1)
                            return 0
                        })
                        isContain=true
                        break

                    }
                }
            }
            if isContain == false {
                CommonFunction.stopAnimation(NSLocalizedString("操作失败..", comment: "操作失败.."), NSLocalizedString("没找到对应控制指令", comment: "没找到对应控制指令"),1.5)
            }
            
        }
        
    }
    
    
    
    //MARK:Tabber
    
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
        let code:String = deviceInfo["codeString"] as! String
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
        if UserDefaults.standard.object(forKey: "TVfavorite") == nil{
            UserDefaults.standard.set([], forKey: "TVfavorite")
        }
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
                    var channelList=UserDefaults.standard.object(forKey: "TVfavorite") as? Array<Dictionary<String, String>>
                    let channelInfo:Dictionary<String,String>=[(alert.textFields?[0].text)!:(alert.textFields?[1].text)!]
                    channelList?.append(channelInfo)
                    self.resourseList=channelList!
                    UserDefaults.standard.set(channelList, forKey: "TVfavorite")
                    UserDefaults.standard.synchronize()
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
                self.controlView.isHidden=true
                self.funtionView.isHidden=true
                self.numView.isHidden=false
                self.scrollViewHeight.constant=UIScreen.main.bounds.height*0.37
            }, completion: { (_) in
                self.lastTabberItemIndex=0
            })
            
        }
        else if item==tabBar.items?[1]{
            UIView.animate(withDuration: 0.3, delay: 0, options: .curveEaseIn, animations: {
                self.mainScroll.contentOffset=CGPoint.init(x:0, y: 0)
                self.controlView.isHidden=false
                self.funtionView.isHidden=true
                self.numView.isHidden=true
                self.scrollViewHeight.constant=UIScreen.main.bounds.height*0.37
            }, completion: { (_) in
                self.lastTabberItemIndex=1
                
            })
            
        }
        else if item==tabBar.items?[2]{
            UIView.animate(withDuration: 0.3, delay: 0, options: .curveEaseIn, animations: {
                self.mainScroll.contentOffset=CGPoint.init(x:0, y: 0)
                self.controlView.isHidden=true
                self.funtionView.isHidden=false
                self.numView.isHidden=true
                self.scrollViewHeight.constant=UIScreen.main.bounds.height*0.48
            }, completion: { (_) in
                self.lastTabberItemIndex=2
            })
            
        }
        else if item==tabBar.items?[3]{
            
            UIView.animate(withDuration: 0.3, delay: 0, options: .curveEaseIn, animations: {
                self.mainScroll.contentOffset=CGPoint.init(x: self.view.frame.width, y: 0)
            }, completion: { (_) in
                
            })
        }
        else if item==tabBar.items?[4]{
            
            UIView.animate(withDuration: 0.3, delay: 0, options: .curveEaseIn, animations: {
                self.mainScroll.contentOffset=CGPoint.init(x: self.view.frame.width*2, y: 0)
            }, completion: { (_) in
                
            })
        }
    }
    
    //MARK:列表的代理
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        if scrollView.contentOffset.x>=self.view.frame.width && scrollView.contentOffset.x<self.view.frame.width*2{
            self.tabBar.selectedItem=self.tabBar.items?[3]
        }
        else if scrollView.contentOffset.x>=self.view.frame.width*2
        {
            self.tabBar.selectedItem=self.tabBar.items?[4]
        }
        else
        {
            self.tabBar.selectedItem=self.tabBar.items?[lastTabberItemIndex]
        }
    }

    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView .dequeueReusableCell(withIdentifier: "channel", for: indexPath) as UITableViewCell;
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
                for deviceDicInfo in self.resourseList
                {
                    temp.append(deviceDicInfo.keys.first!)
                }
                return temp
            }()
            channelTitleLab.text=channelTitle[indexPath.row]
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        CommonFunction.startAnimation(NSLocalizedString("操作中...", comment: "操作中..."), nil)
        if isCommon{
            let channelNum=[11,12,13,14,15,16,17,18]
            let code:String = self.deviceInfo["codeString"] as! String
            let command=BinMakeManger.shareInstance.channelCommand(code, channelNum[indexPath.row], 0)
            BluetoothManager.getInstance()?.sendByteCommand(with: command, deviceID: "IrRemoteControllerA", sendType: .remoteTemp, success: { (returnData) in
                CommonFunction.stopAnimation(NSLocalizedString("控制成功..", comment: "控制成功.."), returnData?.description,1)
            }, fail: { (failString) -> UInt in
                CommonFunction.stopAnimation(NSLocalizedString("操作失败..", comment: "操作失败.."), failString,1)
                return 0
            })

        }
        else
        {
            let channelNum={ () -> [Int] in
                var temp=Array<Int>.init()
                for deviceDicInfo in self.resourseList
                {
                    temp.append(Int(deviceDicInfo.values.first! as! String)!)
                }
                return temp
            }()
            let code:String = self.deviceInfo["codeString"] as! String
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
        if isCommon {
            return false
        }
        return true
    }
    
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        let delete = UITableViewRowAction.init(style: .destructive, title: NSLocalizedString("删除", comment: "删除")) { (deleteAction, deleteIndex) in
            var channelList=UserDefaults.standard.object(forKey: "TVfavorite") as? Array<Dictionary<String, String>>
            channelList?.remove(at: indexPath.row)
            self.resourseList=channelList!
            UserDefaults.standard.set(channelList, forKey: "TVfavorite")
            UserDefaults.standard.synchronize()
            tableView.reloadData()
        }
        return [delete]
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if self.isCommon {
            return 7
        }
        else
        {
            return self.resourseList.count
        }
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
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
