//
//  ModelVersionController.swift
//  BinMarker
//
//  Created by 彭子上 on 2016/11/18.
//  Copyright © 2016年 彭子上. All rights reserved.
//

import UIKit
class ModelVersionController: UIViewController,UITableViewDelegate,UITableViewDataSource,UISearchControllerDelegate,UISearchResultsUpdating{
    public var versionList : NSArray!
    public var deviceType : NSIndexPath!
    public var brandName : String!
    var searchList : Array<Any>!
    @available(iOS 9.1, *)
    lazy var searchingManger : UISearchController! = {
        let tempSearch=UISearchController.init(searchResultsController: nil)
        tempSearch.delegate=self
        tempSearch.searchResultsUpdater=self
        tempSearch.dimsBackgroundDuringPresentation = true
        tempSearch.obscuresBackgroundDuringPresentation=false
        tempSearch.hidesNavigationBarDuringPresentation=true
        return tempSearch
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
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
        
    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if self.searchingManger.isActive {
            return self.searchList.count
        }
        else
        {
            return versionList.count
        }
        
    }
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "brandCell", for: indexPath as IndexPath) as UITableViewCell
        let  brandTitle=cell .viewWithTag(1001) as! UILabel;
        brandTitle.text=versionList.object(at: indexPath.row) as? String
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        var deviceTypeStr = String.init();
        switch deviceType.row {
        case 0:
            deviceTypeStr="TV"
        case 1:
            deviceTypeStr="DVD"
        case 2:
            deviceTypeStr="COMBI"
        case 3:
            deviceTypeStr="SAT"
        default: break
        }
        var versionName = versionList.object(at: indexPath.row) as! NSString
        if versionName.contains(" (支持)") {
            versionName = versionName.substring(with: NSMakeRange(0, versionName.length-5)) as NSString
        }
        else if versionName.contains(" (不支持)"){
            versionName = versionName.substring(with: NSMakeRange(0, versionName.length-6)) as NSString
        }
        
        let deviceSubInfoDic:Dictionary<String,String>=["deviceType" : deviceTypeStr,
                                                        "brandName" : brandName,
                                                        "versionName" : versionName as String]
        self.performSegue(withIdentifier: "debug", sender: deviceSubInfoDic)
    }
    
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "debug" {
            let target=segue.destination as! TestController;
            let deviceSubInfoDic:Dictionary<String,String>=sender as! Dictionary
            
            let versionName :String = deviceSubInfoDic["versionName"]!
            let brandName:String=deviceSubInfoDic["brandName"]!
            let deviceType:String=deviceSubInfoDic["deviceType"]!

            var sqlStr="select DISTINCT (DeviceNo) from RemoteIndex where DeviceType = " + "\"" + deviceType + "\"" + " AND Brand ="+"\"" + brandName+"\"" + " AND Model = "
            if versionName.contains("\"") {
                sqlStr += "'"+versionName+"'"
            }
            else{
                sqlStr += "\""+versionName+"\""
            }
            sqlStr += " order by DeviceNo"
            print(sqlStr)
            
            var codeList=Array<String>.init()
            let path=Bundle.main.path(forResource: "NSE_Database", ofType: "sqlite")
            let db=FMDatabase.init(path: path);
            if (db?.open())! {
                let result=db?.executeQuery(sqlStr, withArgumentsIn: nil)
                if (result?.next())! {
                    let subVersionStr:String=(result?.string(forColumn: "DeviceNo"))!
                    codeList.append(subVersionStr)
                }
            }
            target.codeList=codeList;
//            target.version=versionName
            target.brandName=brandName
            target.deviceType=deviceType

        }
     // Get the new view controller using segue.destinationViewController.
     // Pass the selected object to the new view controller.
     }
    
    
}
