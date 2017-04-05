//
//  UserInfoController.swift
//  BinMarker
//
//  Created by 彭子上 on 2017/3/30.
//  Copyright © 2017年 彭子上. All rights reserved.
//

import UIKit

class UserInfoController: UIViewController ,UITableViewDelegate,UITableViewDataSource{

    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.navigationBar.subviews.first?.alpha=0.0
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.navigationController?.navigationBar.subviews.first?.alpha=1.0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section==0 {
            let cell = tableView .dequeueReusableCell(withIdentifier: "option", for: indexPath) as UITableViewCell;
            let imageArr=[#imageLiteral(resourceName: "login_option5"),#imageLiteral(resourceName: "login_option4")]
            let optionTitle=[NSLocalizedString("修改密码", comment: "修改密码"),NSLocalizedString("设置安全码", comment: "设置安全码")]
            let imageView=cell.viewWithTag(1001) as! UIImageView
            let optionBtn=cell.viewWithTag(1002) as! UIButton
            imageView.image=imageArr[indexPath.row]
            optionBtn.setTitle(optionTitle[indexPath.row], for: .normal)
            return cell
        }
        else
        {
            let cell = tableView .dequeueReusableCell(withIdentifier: "quit", for: indexPath) as UITableViewCell
            return cell
        }

    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        
    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section==0 {
            return 2
        }
        else if section==1
        {
            return 1
        }
        return 0
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }

    //sectionTitle
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return ""
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
