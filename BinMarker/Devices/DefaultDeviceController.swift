//
//  DefaultDeviceController.swift
//  BinMarker
//
//  Created by 彭子上 on 2017/5/24.
//  Copyright © 2017年 彭子上. All rights reserved.
//

import UIKit

class DefaultDeviceController: UIViewController , UITableViewDataSource , UITableViewDelegate{

    var deviceList = Array<DeviceInfo>.init()
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        
        
        // Do any additional setup after loading the view.
    }
    
    
    @IBAction func complete(_ sender: UIBarButtonItem) {
        self.dismiss(animated: true) { 
            
        }
    }
    
    
    

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let device = self.deviceList[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        let titleLab = cell.viewWithTag(1001) as! UILabel
        let codeNumLab = cell.viewWithTag(1002) as! UILabel
        let selectImage = cell.viewWithTag(1003) as! UIImageView
        
        titleLab.text = device.brandname
        codeNumLab.text = device.code
        selectImage.image = UIImage.init(named: "default_unselect_btn")
        
        if device.deviceID == UserDefaults.standard.string(forKey: "defaultDevice") {
            selectImage.image = UIImage.init(named: "pressed_select_btn")
        }
        
        
        return cell
        
        
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let device = self.deviceList[indexPath.row]
        UserDefaults.standard.set(device.deviceID, forKey: "defaultDevice")
        tableView.reloadData()
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.deviceList.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 80
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
