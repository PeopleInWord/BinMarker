//
//  ChildrenSettingController.swift
//  BinMarker
//
//  Created by 彭子上 on 2017/5/17.
//  Copyright © 2017年 彭子上. All rights reserved.
//

import UIKit

class ChildrenSettingController: UIViewController , UITableViewDataSource , UITableViewDelegate{

    var device = DeviceInfo.init()
    var channelList =  Array<FavoriteInfo>.init()
    
    @IBOutlet weak var mainTable: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        
        // Do any additional setup after loading the view.
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let favorite =  self.channelList[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        let titleLab = cell.viewWithTag(1001) as! UILabel
        let channelNumLab = cell.viewWithTag(1002) as! UILabel
        let existBtn = cell.viewWithTag(1003) as! UIButton
        let existLab = cell.viewWithTag(1004) as! UILabel
        
        
        titleLab.text = favorite.channelName
        channelNumLab.text =  favorite.channelNum
        existBtn.isHidden = favorite.isCustom
        existLab.isHidden = !favorite.isCustom
        
        cell.tag = indexPath.row + 10000
        return cell
        
        
    }
    @IBAction func addChannel(_ sender: UIButton) {
        let cell = sender.superview?.superview
        let index = (cell?.tag)! - 10000
        print(index)
        FMDBFunctions.shareInstance.setData(table: "T_DeviceFavorite", targetParameters: "isCustom", targetContent: NSNumber.init(value: true), parameters: "channelID", content: self.channelList[index].channelID)
                        let user = FMDBFunctions.shareInstance.getUserData(targetParameters: "isLogin", content: NSNumber.init(value: true)).first
                        let updater = HTTPFuntion.init()
                        updater.uploadAllData(user: user!, success: {
        
                        }, fail: {
        
                        })
        
        let existBtn = cell?.viewWithTag(1003) as! UIButton
        let existLab = cell?.viewWithTag(1004) as! UILabel

        existBtn.isHidden = true
        existLab.isHidden = false
        
        
    }
//    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
//        let channelNum={ () -> [Int] in
//            var temp=Array<Int>.init()
//            for favoriteItem in self.channelList
//            {
//                temp.append(Int(favoriteItem.channelNum)!)
//            }
//            return temp
//        }()
//        let code:String = self.device.code
//        let command=BinMakeManger.shareInstance.channelCommand(code, channelNum[indexPath.row], 0)
//        BluetoothManager.getInstance()?.sendByteCommand(with: command, deviceID: "IrRemoteControllerA", sendType: .remoteTemp, success: { (returnData) in
//            CommonFunction.stopAnimation(NSLocalizedString("控制成功..", comment: "控制成功.."), returnData?.description,1)
//        }, fail: { (failString) -> UInt in
//            CommonFunction.stopAnimation(NSLocalizedString("操作失败..", comment: "操作失败.."), failString,1)
//            return 0
//        })
//        
//        
//        tableView.deselectRow(at: indexPath, animated: true)
//    }
    
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
