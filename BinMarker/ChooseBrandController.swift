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
        self .performSegue(withIdentifier: "chooseVersion", sender: indexPath);
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "chooseVersion"
        {
            let target=segue.destination as! ModelVersionController
            let path=Bundle.main.path(forResource: "NSE_Database", ofType: "sqlite")
            let db=FMDatabase.init(path: path);
            if (db?.open())! {
                var deviceTypeStr = String.init();
                switch deviceType.row {
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
                let brandName=deviceBrandList.object(at: (sender as! NSIndexPath).row) as! String
//                select DISTINCT (brand) from RemoteIndex where DeviceType = "SAT" AND Brand ="GBS" order by brand
                let sqlStr="select DISTINCT (Model) from RemoteIndex where DeviceType = " + (deviceTypeStr as String) + " AND Brand ="+"\"" + brandName+"\""+" order by brand"
                print(sqlStr)
                let result=db?.executeQuery(sqlStr, withArgumentsIn: nil)
                let versionList = NSMutableArray.init()
                while (result?.next())! {
                    let subVersionStr=result?.string(forColumn: "Model")
                    versionList .add( subVersionStr!)
                }
                target.deviceType=deviceType
                target.versionList=versionList
                target.brandName=brandName
            }
            
        }
    
    }
    

}
