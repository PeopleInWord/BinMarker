//
//  ChooseBrandController.swift
//  BinMarker
//
//  Created by 彭子上 on 2016/11/18.
//  Copyright © 2016年 彭子上. All rights reserved.
//

import UIKit

class ChooseBrandController: UIViewController ,UITableViewDataSource,UITableViewDelegate{
    public var deviceBrandList: NSArray!
    public var deviceType:NSIndexPath!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return deviceBrandList.count;
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView .dequeueReusableCell(withIdentifier: "brandCell", for: indexPath) as UITableViewCell;
        cell.selectionStyle=UITableViewCellSelectionStyle.none;
        let version_lab=cell .viewWithTag(1001) as! UILabel;
        version_lab.text=deviceBrandList.object(at: indexPath.row) as? String;
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let path=Bundle.main.path(forResource: "NSE_Database", ofType: "sqlite")
        let db=FMDatabase.init(path: path)
        let mbp=MBProgressHUD.showAdded(to: self.view, animated: true)
        mbp.label.text="加载中..."
        mbp.removeFromSuperViewOnHide=true
        DispatchQueue.global().async {
            var deviceInfo=Dictionary<String, Any>.init()
            if (db?.open())! {
                var deviceTypeStr = String.init();
                switch self.deviceType.row {
                case 0:
                    deviceTypeStr="\"TV\""
                case 1:
                    deviceTypeStr="\"DVD\""
                case 2:
                    deviceTypeStr="\"COMBI\""
                case 3:
                    deviceTypeStr="\"SAT\""
                default: break
                    
                }
                let brandName=self.deviceBrandList.object(at: indexPath.row) as! String
                let sqlStr="select DISTINCT (Model) from RemoteIndex where DeviceType = " + (deviceTypeStr as String) + " AND Brand ="+"\"" + brandName+"\""+" order by brand"
                print(sqlStr)
                let result=db?.executeQuery(sqlStr, withArgumentsIn: nil)
                var index=0
                mbp.detailsLabel.text=index.description //修改总数
                let versionList = NSMutableArray.init()
                while (result?.next())! {
                    index+=1
                    var subVersionStr:String=(result?.string(forColumn: "Model"))!
                    subVersionStr = self.operating(subVersionStr, deviceTypeStr, brandName)//字符串后面加是否适配
                    versionList .add( subVersionStr)
                    DispatchQueue.main.async {
                        mbp.detailsLabel.text = index.description + "/" + (result?.columnCount().description)!
                    }
                }
                db?.close()
                db?.clearCachedStatements()
                deviceInfo=["deviceType" : self.deviceType,"versionList":NSArray.init(array: versionList),"brandName":brandName] as [String : Any]
                
            }
            DispatchQueue.main.async {
                mbp.hide(animated: true)
                self.performSegue(withIdentifier: "chooseVersion", sender: deviceInfo);
            }
        }
        
        
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    private func isContain(_ code:String) ->Bool{
        var isContain:Bool=false
        if (Bundle.main.path(forResource: code, ofType: "bin") != nil) {
            isContain=true
        }
        
        return isContain;
    }
    
    private func operating(_ versionString:String , _ deviceTypeStr:String , _ brandName:String) -> String! {
        let path=Bundle.main.path(forResource: "NSE_Database", ofType: "sqlite")
        let db=FMDatabase.init(path: path)
        var returnString:String=versionString
        
        let translateString = returnString.replacingOccurrences(of: "\"", with: "'")// 数据库的转义字符
        
        if (db?.open())! {
            var queryCode="select DISTINCT (DeviceNo) from RemoteIndex where DeviceType = "
                + (deviceTypeStr as String)
            queryCode += " AND Brand = "+"\""
                + brandName + "\""
            queryCode += " AND Model = " + "\""
                + translateString + "\"" + " order by DeviceNo"
            print(queryCode)
            let codeResult=db?.executeQuery(queryCode, withArgumentsIn: nil)
            
            while (codeResult?.next())!{
                let single:String = (codeResult?.string(forColumn: "DeviceNo"))!
                if self.isContain(single) {
                    returnString+=" (支持)"
                }
                else
                {
                    returnString+=" (不支持)"
                }
                break
            }
        }
        db?.close()
        return returnString;
    }
    
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "chooseVersion"
        {
            let target=segue.destination as! ModelVersionController
            let deviceInfo=sender as! Dictionary<String,Any>
            target.deviceType=deviceInfo["deviceType"] as! NSIndexPath!
            target.versionList=deviceInfo["versionList"] as! NSArray!
            target.brandName=deviceInfo["brandName"] as! String!
        }
    
    }
    

}
