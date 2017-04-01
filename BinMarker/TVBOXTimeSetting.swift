//
//  TVBOXTimeSetting.swift
//  BinMarker
//
//  Created by 彭子上 on 2017/3/31.
//  Copyright © 2017年 彭子上. All rights reserved.
//

import UIKit

class TVBOXTimeSetting: UIViewController ,UIPickerViewDelegate,UIPickerViewDataSource{

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
            return (row+1).description+"小时"
        }
        else if component == 2 {
            return (row*5).description+"分钟"
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
