//
//  TVController.swift
//  BinMarker
//
//  Created by 彭子上 on 2017/3/10.
//  Copyright © 2017年 彭子上. All rights reserved.
//

import UIKit

class TVController: UIViewController ,UITabBarDelegate ,UITableViewDataSource ,UITableViewDelegate ,UIGestureRecognizerDelegate,UITextFieldDelegate{
    @IBOutlet weak var controlView: UIView!
    @IBOutlet weak var funtionView: UIView!
    @IBOutlet weak var numView: UIView!
    @IBOutlet weak var tabBar: UITabBar!
    @IBOutlet weak var scrollViewHeight: NSLayoutConstraint!
    @IBOutlet weak var mainScroll: UIScrollView!
    @IBOutlet weak var favoriteList: UITableView!
    @IBOutlet weak var common: UIButton!
    @IBOutlet weak var costom: UIButton!
    var isCommon = true
    var lastTabberItemIndex = 1
    var resourseList=UserDefaults.standard.object(forKey: "TVfavorite") as! Array<Dictionary<String, Any>>
    
    var actionTemp=UIAlertAction.init()
    var nameField=UITextField.init()
    var numberField=UITextField.init()
    public var deviceInfo:Dictionary<String, Any> = [:]

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
        let mbp=MBProgressHUD.showAdded(to: self.view, animated: true)
        mbp.removeFromSuperViewOnHide=true
        mbp.show(animated: true)
        mbp.label.text="发送中:" + sender.tag.description
        BluetoothManager.getInstance()?.sendByteCommand(with: command, deviceID: deviceID, sendType: .remoteTemp, success: { (returnData) in
            mbp.detailsLabel.text=returnData?.description
            mbp.hide(animated: true, afterDelay: 0.5)
        }, fail: { (failString) -> UInt in
            mbp.label.text="操作失败"
            mbp.detailsLabel.text=failString
            mbp.hide(animated: true, afterDelay: 1.5)
            return 0
        })
    }
    
    @IBAction func favoriteBtn(_ sender: UIBarButtonItem,_ event:UIEvent) {
        FTPopOverMenuConfiguration.default().menuWidth=100
        if UserDefaults.standard.object(forKey: "TVfavorite") == nil{
            UserDefaults.standard.set([], forKey: "TVfavorite")
        }
        FTPopOverMenu.show(from: event, withMenuArray: ["添加频道收藏"], doneBlock: { (index) in
            if index==0
            {
                let alert=UIAlertController.init(title: "收藏频道号", message: "请输入要收藏的频道", preferredStyle: .alert)
                alert.addTextField(configurationHandler: { (nameF) in
                    self.nameField=nameF
                    nameF.delegate=self
                    nameF.placeholder="输入频道名称"
                })
                alert.addTextField(configurationHandler: { (number) in
                    self.numberField=number
                    number.delegate=self
                    number.keyboardType = .numberPad
                    number.placeholder="输入频道号(不超过3位)"
                })
                let actionOK=UIAlertAction.init(title: "好的", style: .default, handler: { (action) in
                    //加限制
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
                alert.addAction(UIAlertAction.init(title: "取消", style: .destructive, handler: { (action) in
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
        if item.title=="数字" {
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
        else if item.title=="功能"{
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
        else if item.title=="扩展"{
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
        else if item.title=="频道"{
            
            UIView.animate(withDuration: 0.3, delay: 0, options: .curveEaseIn, animations: {
                self.mainScroll.contentOffset=CGPoint.init(x: self.view.frame.width, y: 0)
            }, completion: { (_) in
                
            })
        }
    }
    
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        if scrollView.contentOffset.x>=self.view.frame.width {
            self.tabBar.selectedItem=self.tabBar.items?[3]
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
        let mbp=MBProgressHUD.showAdded(to: self.view, animated: true)
        mbp.removeFromSuperViewOnHide=true
        mbp.show(animated: true)
        mbp.label.text="发送中"
        if isCommon{
            let channelNum=[11,12,13,14,15,16,17,18]
            let code:String = self.deviceInfo["codeString"] as! String
            let command=BinMakeManger.shareInstance.channelCommand(code, channelNum[indexPath.row], 0)
            BluetoothManager.getInstance()?.sendByteCommand(with: command, deviceID: "IrRemoteControllerA", sendType: .remoteTemp, success: { (returnData) in
                mbp.detailsLabel.text=returnData?.description
                mbp.hide(animated: true, afterDelay: 0.5)
            }, fail: { (failString) -> UInt in
                mbp.label.text="操作失败"
                mbp.detailsLabel.text=failString
                mbp.hide(animated: true, afterDelay: 1.5)
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
                mbp.detailsLabel.text=returnData?.description
                mbp.hide(animated: true, afterDelay: 0.5)
            }, fail: { (failString) -> UInt in
                mbp.label.text="操作失败"
                mbp.detailsLabel.text=failString
                mbp.hide(animated: true, afterDelay: 1.5)
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
        let delete = UITableViewRowAction.init(style: .destructive, title: "删除") { (deleteAction, deleteIndex) in
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
