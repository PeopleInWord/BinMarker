//
//  ChooseBrandController.swift
//  BinMarker
//
//  Created by 彭子上 on 2016/11/18.
//  Copyright © 2016年 彭子上. All rights reserved.
//

import UIKit

class ChooseBrandController: UIViewController ,UITableViewDataSource,UITableViewDelegate,UISearchControllerDelegate,UISearchResultsUpdating{
    public var deviceBrandList: NSArray!
    public var deviceTypeIndex:NSIndexPath!
    var searchList : Array<Any>!
    lazy var tableTitle:Array<Dictionary<String,Int>> = {
        var temp:Array<Dictionary<String,Int>>=[]
        var titleIndex:Int = 0//预加载设备表序列
        for item in self.deviceBrandList
        {
            var isContain=false
            let headTitle = (item as! NSString).substring(to: 1)
            var i:Int=0
            for dic in temp {
                if dic.keys.contains(headTitle) {
                    isContain=true
                    break
                }
                i+=1
            }
            if isContain {
                temp.remove(at: i)
            }
            temp.append([headTitle:titleIndex])
            titleIndex += 1
        }
        return temp
    }()

    lazy var searchingManger : UISearchController! = {
        let tempSearch=UISearchController.init(searchResultsController: nil)
        tempSearch.delegate=self
        tempSearch.searchResultsUpdater=self
        tempSearch.dimsBackgroundDuringPresentation = true
        tempSearch.obscuresBackgroundDuringPresentation=false
        tempSearch.hidesNavigationBarDuringPresentation=true
        tempSearch.searchBar.placeholder=NSLocalizedString("输入品牌名", comment: "输入品牌名")
        tempSearch.searchBar.sizeToFit()
        tempSearch.searchBar.searchBarStyle=UISearchBarStyle.prominent
        tempSearch.searchBar.isTranslucent=true
        tempSearch.searchBar.backgroundColor=UIColor.blue
        return tempSearch
    }()
    
    @IBOutlet weak var tableView: UITableView!

    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.tableHeaderView=self.searchingManger.searchBar
        self.tableView.contentOffset=CGPoint.init(x: 0, y: 44)
        // Do any additional setup after loading the view.
    }
    
    func willPresentSearchController(_ searchController: UISearchController)
    {
        
    }
    func didPresentSearchController(_ searchController: UISearchController)
    {
        
    }
    func willDismissSearchController(_ searchController: UISearchController)
    {
        
    }
    func didDismissSearchController(_ searchController: UISearchController)
    {
        
    }
    func presentSearchController(_ searchController: UISearchController)
    {
        
    }
    
    func updateSearchResults(for searchController: UISearchController) {

        let searchString:String = searchingManger.searchBar.text!;
        let preicate :NSPredicate = NSPredicate.init(format: "SELF CONTAINS[c] %@", searchString)
        if (self.searchList != nil) {
            self.searchList.removeAll()
        }
        self.searchList=self.deviceBrandList.filtered(using: preicate)
        self.tableView.reloadData()
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView .dequeueReusableCell(withIdentifier: "brandCell", for: indexPath) as UITableViewCell
        var charIndex:Int = 0
        if indexPath.section == 0 {//第一个元素
            charIndex = 0
        }
        else
        {
            charIndex = self.tableTitle[indexPath.section-1].values.first!+1
        }
        let version_lab=cell .viewWithTag(1001) as! UILabel
        if (self.searchingManger.isActive) {
            version_lab.text = self.searchList[indexPath.row] as? String;
        } else {
            version_lab.text=(self.deviceBrandList.object(at: charIndex+indexPath.row) as! String)
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let path=Bundle.main.path(forResource: "Infrared_Datebase", ofType: "sqlite")
        let db=FMDatabase.init(path: path)
        
        let mbp=MBProgressHUD.showAdded(to: self.view, animated: true)
        mbp.label.text=NSLocalizedString("加载中...", comment: "加载中...")
        mbp.removeFromSuperViewOnHide=true
        DispatchQueue.global().async {
            var deviceInfo=Dictionary<String, Any>.init()
            if (db?.open())! {
                let deviceTypeStr = self.deviceTypeStrReturn(self.deviceTypeIndex);
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
    
    fileprivate func deviceTypeStrReturn(_ deviceType:NSIndexPath) ->String?
    {
        switch deviceType.row {
        case 0:
            return "TV"
        case 1:
            return "DVD"
        case 2:
            return "AUX"
        case 3:
            return "SAT"
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
        sqlStr = sqlStr + "\"" + deviceType + "\"" + " AND Brand =" + "\""
        sqlStr = sqlStr + brandName + "\"" + " order by DeviceNo"
        print(sqlStr)
        return sqlStr
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if self.searchingManger.isActive {
            return self.searchList.count
        }
        else
        {
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
        
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        if self.searchingManger.isActive
        {
            return 1
        }
        else
        {
            return self.tableTitle.count
        }

    }
    //右边列表
    func sectionIndexTitles(for tableView: UITableView) -> [String]? {
        if self.searchingManger.isActive
        {
            return nil
        }
        else
        {
            var strings=Array<String>.init()
            for item in self.tableTitle {
                strings.append(item.keys.first!)
            }
            return strings
        }
        
    }
    //sectionTitle
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if self.searchingManger.isActive
        {
            return NSLocalizedString("搜索结果", comment: "搜索结果")
        }
        else
        {
            let dic=self.tableTitle[section]
            return dic.keys.first
        }
        
    }
    
    //点击右边的反应
    func tableView(_ tableView: UITableView, sectionForSectionIndexTitle title: String, at index: Int) -> Int {
        if self.searchingManger.isActive
        {
            return 0
        }
        else
        {
            return index
        }
        
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
        let path=Bundle.main.path(forResource: "Infrared_Datebase", ofType: "sqlite")
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
        return returnString
    }
    
    
    deinit {
        self.searchingManger.view.superview?.removeFromSuperview()
    }
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showCode"
        {
            let target=segue.destination as! TestController
            let deviceInfo=sender as! Dictionary<String,Any>
            target.deviceTypeStr=deviceInfo["deviceType"] as! String!
            target.deviceType=self.deviceTypeIndex
            target.codeList=deviceInfo["deviceNoList"] as! [String]!
            target.brandName=deviceInfo["brandName"] as! String!
        }
    
    }
}
