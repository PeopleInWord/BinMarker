//
//  LoginController.swift
//  BinMarker
//
//  Created by 彭子上 on 2017/3/30.
//  Copyright © 2017年 彭子上. All rights reserved.
//

import UIKit
@objc(LoginDelegate)
protocol LoginDelegate : NSObjectProtocol{
    func didLogin(user:UserInfo) -> Void
}

class LoginController: UIViewController {

    weak var delegate:LoginDelegate!
    
    @IBOutlet weak var userName: UITextField!
    @IBOutlet weak var pwd: UITextField!
    @IBOutlet weak var activer: UIActivityIndicatorView!
    
    @IBOutlet weak var registerBtn: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    @IBAction func login(_ sender: UIButton) {
        sender.isEnabled=false
        registerBtn.isEnabled=false
        activer.startAnimating()
        let manger=UserFunction.init()
        manger.loginIn(tel: userName.text!, password: pwd.text!, { (user) in
            self.activer.stopAnimating()
            sender.isEnabled=true
            self.registerBtn.isEnabled=true
            self.success(user: user)
        }) { (errorStr) in
            self.activer.stopAnimating()
            sender.isEnabled=true
            self.registerBtn.isEnabled=true
            print(errorStr)
        }
    }

    func success(user:UserInfo) -> Void {
        let mobile = FMDBFunctions.shareInstance.getUserData(targetParameters: "mobile", content: user.mobile)
        if mobile.count == 0 {
            FMDBFunctions.shareInstance.insertUserData(user: user)
        }
        else
        {
            FMDBFunctions.shareInstance.delData(table: "T_UserInfo", parameters: "mobile", user.mobile)
            FMDBFunctions.shareInstance.insertUserData(user: user)
        }
        
        self.dismiss(animated: true) {
            self.delegate?.didLogin(user: user)
            //在主布局中,写是否导入
        }
    }
    
    func fail() -> Void {
        
    }
    
    
    @IBAction func back2Main(_ sender: UIBarButtonItem) {
        self.dismiss(animated: true) {
        }
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
