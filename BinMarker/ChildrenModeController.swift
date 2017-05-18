//
//  ChildrenModeController.swift
//  BinMarker
//
//  Created by 彭子上 on 2017/5/17.
//  Copyright © 2017年 彭子上. All rights reserved.
//

import UIKit

class ChildrenModeController: UIViewController , UITableViewDataSource , UITableViewDelegate{
    @IBOutlet weak var channelTable: UITableView!

    var channelList = Array<FavoriteInfo>.init()
    var device = DeviceInfo.init()
    override func viewDidLoad() {
        super.viewDidLoad()
        UserDefaults.standard.set(true, forKey: "isChildrenMode")
        let tempArray = FMDBFunctions.shareInstance.getChannelData(with: device)
        tempArray.forEach { (item) in
            if item.isCustom == true
            {
                channelList.append(item)
            }
        }
        self.channelTable.reloadData()
        
        // Do any additional setup after loading the view.
    }

    
    
    @IBAction func exit(_ sender: UIBarButtonItem) {
        let alert = UIAlertController.init(title: "安全码", message: "输入4位安全码", preferredStyle: .alert)
        alert.addTextField(configurationHandler: { (textField) in
            textField.keyboardType = .numberPad
            
        })
        alert.addAction(UIAlertAction.init(title: "确认", style: .default, handler: { (action) in
            let code = alert.textFields?.first?.text
            guard code == UserDefaults.standard.string(forKey: "securityPin") else {
                return
            }
            FMDBFunctions.shareInstance.setData(table: "T_DeviceInfo", targetParameters: "isDefault", targetContent: NSNumber.init(value: false), parameters: "DeviceID", content: Int(self.device.deviceID)!)
            UserDefaults.standard.removeObject(forKey: "DefaultDevice")
            UserDefaults.standard.set(false, forKey: "isChildrenMode")
            self.dismiss(animated: true, completion: {
                self.dismiss(animated: true, completion: {   
                })
            })
            
        }))
        alert.addAction(UIAlertAction.init(title: "取消", style: .cancel, handler: { (action) in
            return
        }))
        self.present(alert, animated: true, completion: {
            
        })
        
        
    }
    
    @IBAction func didClickFun(_ sender: UIButton) {
        print(sender.tag)
        let code:String = self.device.code
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
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let favorite =  self.channelList[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: "childrenChannel", for: indexPath)
        let titleLab = cell.viewWithTag(1001) as! UILabel
        let channelNumLab = cell.viewWithTag(1003) as! UILabel
//        let iconImageView =  cell.viewWithTag(1002) as! UIImageView
        
        titleLab.text = favorite.channelName
        channelNumLab.text =  favorite.channelNum
        
        return cell
        
        
        }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let channelNum={ () -> [Int] in
            var temp=Array<Int>.init()
            for favoriteItem in self.channelList
            {
                temp.append(Int(favoriteItem.channelNum)!)
            }
            return temp
        }()
        let code:String = self.device.code
        let command=BinMakeManger.shareInstance.channelCommand(code, channelNum[indexPath.row], 0)
        BluetoothManager.getInstance()?.sendByteCommand(with: command, deviceID: "IrRemoteControllerA", sendType: .remoteTemp, success: { (returnData) in
            CommonFunction.stopAnimation(NSLocalizedString("控制成功..", comment: "控制成功.."), returnData?.description,1)
        }, fail: { (failString) -> UInt in
            CommonFunction.stopAnimation(NSLocalizedString("操作失败..", comment: "操作失败.."), failString,1)
            return 0
        })
        
        
        tableView.deselectRow(at: indexPath, animated: true)
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.channelList.count
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
