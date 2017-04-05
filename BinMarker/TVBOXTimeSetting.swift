//
//  TVBOXTimeSetting.swift
//  BinMarker
//
//  Created by 彭子上 on 2017/3/31.
//  Copyright © 2017年 彭子上. All rights reserved.
//

import UIKit

class TVBOXTimeSetting: UIViewController ,UIPickerViewDelegate,UIPickerViewDataSource,UITableViewDataSource,UITableViewDelegate{

    @IBOutlet weak var timePicker: UIPickerView!
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String?
    {
        if component == 0 {
            return ["上午","下午"][row]
        }
        else if component == 1 {
            return (row+1).description+NSLocalizedString("小时", comment: "小时")
        }
        else if component == 2 {
            return (row*5).description+NSLocalizedString("分钟", comment: "分钟")
        }
        return nil
    }
    
    
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int
    {
        return 3
    }
    

    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int
    {
        if component == 0 {
            return 2
        }
        else if component == 1{
            return 12
        }
        else if component == 2{
            return 12
        }
        return 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let reuseID=["time1","time2"][indexPath.row]
        let cell = tableView .dequeueReusableCell(withIdentifier: reuseID, for: indexPath) as UITableViewCell;
        if indexPath.row == 0 {
            let timeLab=cell.viewWithTag(1001) as! UILabel
            timeLab.text=NSLocalizedString("1小时", comment: "1小时")
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        
    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 2
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
