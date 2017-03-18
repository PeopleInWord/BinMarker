//
//  TVController.swift
//  BinMarker
//
//  Created by 彭子上 on 2017/3/10.
//  Copyright © 2017年 彭子上. All rights reserved.
//

import UIKit

class TVController: UIViewController ,UITabBarDelegate{
    @IBOutlet weak var controlView: UIView!
    @IBOutlet weak var funtionView: UIView!
    @IBOutlet weak var numView: UIView!
    @IBOutlet weak var tabBar: UITabBar!
    @IBOutlet weak var scrollViewHeight: NSLayoutConstraint!

    public var deviceInfo:Dictionary<String, Any> = [:]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tabBar.selectedItem=self.tabBar.items?[1]
        scrollViewHeight.constant=UIScreen.main.bounds.height*0.37
        // Do any additional setup after loading the view.
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
        if UserDefaults.standard.object(forKey: "favorite") == nil{
            UserDefaults.standard.set([], forKey: "favorite")
        }
        let favoriteList=UserDefaults.standard.object(forKey: "favorite") as? Array<Dictionary<String, String>>
        var channelList:Array<String> = ["添加频道收藏"]
        if favoriteList != nil {
            for channelInfo in favoriteList! {
                channelList.append(channelInfo.keys.first! + ":" + channelInfo.values.first!)
            }
        }
        
        
        
        FTPopOverMenu.show(from: event, withMenuArray: channelList, doneBlock: { (index) in
            if index==0
            {
                let alert=UIAlertController.init(title: "收藏频道号", message: "请输入要收藏的频道", preferredStyle: .alert)
                alert.addTextField(configurationHandler: { (nameField) in
                    nameField.placeholder="输入频道名称"
                })
                alert.addTextField(configurationHandler: { (number) in
                    number.keyboardType = .numberPad
                    number.placeholder="输入频道号(不超过3位)"
                })
                alert.addAction(UIAlertAction.init(title: "好的", style: .default, handler: { (action) in
                    //加限制
                    var channelList=UserDefaults.standard.object(forKey: "favorite") as? Array<Dictionary<String, String>>
                    let channelInfo:Dictionary<String,String>=[(alert.textFields?[0].text)!:(alert.textFields?[1].text)!]
                    channelList?.append(channelInfo)
                    UserDefaults.standard.set(channelList, forKey: "favorite")
                    UserDefaults.standard.synchronize()
                    
                }))
                alert.addAction(UIAlertAction.init(title: "取消", style: .destructive, handler: { (action) in
                    return
                }))
                self.present(alert, animated: true, completion: {
                    
                })
            }
            else
            {
                let mbp=MBProgressHUD.showAdded(to: self.view, animated: true)
                mbp.removeFromSuperViewOnHide=true
                mbp.show(animated: true)
                mbp.label.text="发送中:"
                let channelInfo = favoriteList?[index-1]
                let channelNum:Int = Int((channelInfo?.values.first)!)!
                let code:String = self.deviceInfo["codeString"] as! String
                let command=BinMakeManger.shareInstance.channelCommand(code, channelNum, 0)
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
        }) { 
            
        }
        
    }
    
    
    
    func tabBar(_ tabBar: UITabBar, didSelect item: UITabBarItem)
    {
        if item.title=="数字" {
            UIView.animate(withDuration: 1, delay: 2, options: .curveEaseIn, animations: {
                self.controlView.isHidden=true
                self.funtionView.isHidden=true
                self.numView.isHidden=false
                self.scrollViewHeight.constant=UIScreen.main.bounds.height*0.37
            }, completion: { (_) in
                
            })
            
        }
        else if item.title=="功能"{
            UIView.animate(withDuration: 1, delay: 2, options: .curveEaseIn, animations: {
                self.controlView.isHidden=false
                self.funtionView.isHidden=true
                self.numView.isHidden=true
                self.scrollViewHeight.constant=UIScreen.main.bounds.height*0.37
            }, completion: { (_) in
                
            })
            
        }
        else if item.title=="扩展"{
            UIView.animate(withDuration: 1, delay: 2, options: .curveEaseIn, animations: { 
                
            }, completion: { (_) in
                self.controlView.isHidden=true
                self.funtionView.isHidden=false
                self.numView.isHidden=true
                self.scrollViewHeight.constant=UIScreen.main.bounds.height*0.48
            })
            
        }
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
