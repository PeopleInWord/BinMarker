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
    private var tableTitle:Array<Dictionary<String,Int>> = []
    
    @IBOutlet weak var tableView: UITableView!

    override func viewDidLoad() {
        super.viewDidLoad()
        self.prefetchTitle()
        // Do any additional setup after loading the view.
    }
    
    private func prefetchTitle() ->Void
    {
        var titleIndex:Int = 0
        if self.tableTitle.count==0 {//预加载设备表序列
            for item in self.deviceBrandList
            {
                var isContain=false
                let headTitle = (item as! NSString).substring(to: 1)
                var i:Int=0
                for dic in self.tableTitle {
                    if dic.keys.contains(headTitle) {
                        isContain=true
                        break
                    }
                    i+=1
                }
                if isContain {
                    self.tableTitle.remove(at: i)
                }
                self.tableTitle.append([headTitle:titleIndex])
                
                titleIndex += 1
            }
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
            
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView .dequeueReusableCell(withIdentifier: "brandCell", for: indexPath) as UITableViewCell;
        var charIndex:Int = 0
        if indexPath.section == 0 {//第一个元素
            charIndex = 0
        }
        else
        {
            charIndex = self.tableTitle[indexPath.section-1].values.first!+1
        }
        let version_lab=cell .viewWithTag(1001) as! UILabel
        version_lab.text=(self.deviceBrandList.object(at: charIndex+indexPath.row) as! String)
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
                let deviceTypeStr = self.deviceTypeStr(self.deviceType);
                let brandName = self.brandNameStr(indexPath)
                let sqlStr=self.SQLString(deviceTypeStr!,brandName!)
                
                let result=db?.executeQuery(sqlStr, withArgumentsIn: nil)
                var index=0
                mbp.detailsLabel.text=index.description //修改总数
                let deviceNoList = NSMutableArray.init()
                while (result?.next())! {
                    index+=1
                    let subDeviceNo:String=(result?.string(forColumn: "DeviceNo"))!
                    deviceNoList.add(subDeviceNo)
                }
                db?.close()
                db?.clearCachedStatements()
                deviceInfo=["deviceType" : deviceTypeStr!,"deviceNoList":NSArray.init(array: deviceNoList),"brandName":brandName!]
                
            }
            DispatchQueue.main.async {
                mbp.hide(animated: true)
                self.performSegue(withIdentifier: "showCode", sender: deviceInfo);
            }
        }
    }
    
    private func deviceTypeStr(_ deviceType:NSIndexPath) ->String?
    {
        switch deviceType.row {
        case 0:
            return "\"TV\""
        case 1:
            return "\"DVD\""
        case 2:
            return "\"COMBI\""
        case 3:
            return "\"SAT\""
        default:
            return nil
        }
    }
    
    private func brandNameStr(_ indexPath:IndexPath) ->String!
    {
        var charIndex:Int = 0
        if indexPath.section == 0 {//第一个元素
            charIndex = 0
        }
        else
        {
            charIndex = self.tableTitle[indexPath.section-1].values.first!+1
        }
        return self.deviceBrandList.object(at: charIndex + indexPath.row) as! String
    }
    
    private func SQLString(_ deviceType:String ,_ brandName:String) ->String!
    {
        var sqlStr="select DISTINCT (DeviceNo) from RemoteIndex where DeviceType = "
        sqlStr = sqlStr + deviceType + " AND Brand =" + "\""
        sqlStr = sqlStr + brandName + "\"" + " order by DeviceNo"
        print(sqlStr)
        return sqlStr
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let dic=self.tableTitle[section]
        if section == 0 {
            return dic.values.first!+1
        }
        else
        {
            let indexEnd = dic.values.first!
            let dictemp = self.tableTitle[section-1]
            let indexHead = dictemp.values.first!
            return indexEnd-indexHead
        }
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return self.tableTitle.count
    }
    //右边列表
    func sectionIndexTitles(for tableView: UITableView) -> [String]? {
        var strings=Array<String>.init()
        for item in self.tableTitle {
            strings.append(item.keys.first!)
        }
        return strings
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        let dic=self.tableTitle[section]
        return dic.keys.first
    }
    
    //点击右边的反应
    func tableView(_ tableView: UITableView, sectionForSectionIndexTitle title: String, at index: Int) -> Int {
        return index
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    private func isContain(_ code:String) ->Bool{//是否包含相应码组
        var isContain:Bool=false
        if (Bundle.main.path(forResource: code, ofType: "bin") != nil) {
            isContain=true
        }
        
        return isContain;
    }
    
    /// 操作型号名的字符
    ///
    /// - Parameters:
    ///   - versionString: <#versionString description#>
    ///   - deviceTypeStr: <#deviceTypeStr description#>
    ///   - brandName: <#brandName description#>
    /// - Returns: <#return value description#>
    private func operating(_ versionString:String , _ deviceTypeStr:String , _ brandName:String) -> String! {
        let path=Bundle.main.path(forResource: "NSE_Database", ofType: "sqlite")
        let db=FMDatabase.init(path: path)
        var returnString:String=versionString
        if (db?.open())! {
            var queryCode="select DISTINCT (DeviceNo) from RemoteIndex where DeviceType = "
                + (deviceTypeStr as String)
            queryCode += " AND Brand = "+"\""
                + brandName + "\"" + " AND Model = "
            if returnString.contains("\"") {
                queryCode += "'"+returnString+"'"
            }
            else{
                queryCode += "\""+returnString+"\""
            }
            queryCode += " order by DeviceNo"
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
        if segue.identifier == "showCode"
        {
            let target=segue.destination as! TestController
            let deviceInfo=sender as! Dictionary<String,Any>
            target.deviceType=deviceInfo["deviceType"] as! String!
            target.codeList=deviceInfo["deviceNoList"] as! [String]!
            target.brandName=deviceInfo["brandName"] as! String!
        }
    
    }
    

}
