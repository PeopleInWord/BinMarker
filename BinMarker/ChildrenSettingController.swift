//
//  ChildrenSettingController.swift
//  BinMarker
//
//  Created by 彭子上 on 2017/5/17.
//  Copyright © 2017年 彭子上. All rights reserved.
//

import UIKit

class ChildrenSettingController: UIViewController , UITableViewDataSource , UITableViewDelegate ,UITextFieldDelegate{

    var device = DeviceInfo.init()
    var channelList =  Array<FavoriteInfo>.init()
    var actionTemp=UIAlertAction.init()
    var nameField=UITextField.init()
    var numberField=UITextField.init()
    
    
    
    @IBOutlet weak var mainTable: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        NotificationCenter.default.addObserver(self, selector:#selector(isLegal(_:)) , name: NSNotification.Name.UITextFieldTextDidChange, object: nil)
        
        // Do any additional setup after loading the view.
    }

    func isLegal(_ sender:Notification) -> Void {//输入的频道是否合法
        self.actionTemp.isEnabled=(self.nameField.text?.characters.count)! > 0 && self.numberField.text?.characters.count != 0 && (self.numberField.text?.characters.count)! <= 3
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

    @IBAction func addFavorite(_ sender: UIBarButtonItem) {
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
                
                favoriteTemp.DeviceID=self.device.deviceID
                favoriteTemp.channelName=(alert.textFields?[0].text)!
                favoriteTemp.channelNum=(alert.textFields?[1].text)!
                favoriteTemp.channelID = CommonFunction.idMaker().stringValue
                
                favoriteTemp.isCustom=false
                FMDBFunctions.shareInstance.insertChannelData(device: self.device, channel: favoriteTemp, success: {
                    
                }, fail: {
                    
                })
                self.channelList.append(favoriteTemp)
                
                
                
                if userdb != nil
                {
                    let updata = HTTPFuntion.init()
                    updata.uploadAllData(user: userdb!, success: {
                        CommonFunction.showForShortTime(0.5, "更新成功", "")
                    }, fail: {
                        CommonFunction.showForShortTime(1.5, "更新失败", "")
                    })
                }
                
                
                self.mainTable.reloadData()
                
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
