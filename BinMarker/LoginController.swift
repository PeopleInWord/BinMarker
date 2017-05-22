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
    @IBOutlet weak var getCode: UIButton!
    
    var isRegCode = false
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
    }
    @IBAction func login(_ sender: UIButton) {
        guard (userName.text?.characters.count)! == 11 else {
            let alert = UIAlertController.init(title: "账号错误", message: "输入正常的手机号", preferredStyle: .alert)
            alert.addAction(UIAlertAction.init(title: "好的", style: .cancel, handler: { (action) in
                
            }))
            self.present(alert, animated: true, completion: {
                
            })
            return
        }
        sender.isEnabled=false
        registerBtn.isEnabled=false
        activer.startAnimating()
        let manger=UserFunction.init()

        if isRegCode {
            
            manger.codeLoginIn(tel: userName.text!, code: pwd.text!, { (user) in
                self.activer.stopAnimating()
                sender.isEnabled=true
                self.registerBtn.isEnabled=true
                self.success(user: user)
            }, { (errorStr) in
                self.activer.stopAnimating()
                sender.isEnabled=true
                self.registerBtn.isEnabled=true
                
                print(errorStr)
                let alert = UIAlertController.init(title: "登录错误", message: errorStr, preferredStyle: .alert)
                alert.addAction(UIAlertAction.init(title: "好的", style: .cancel, handler: { (action) in
                    
                }))
                self.present(alert, animated: true, completion: {
                    
                })
            })
        }
        else
        {
            
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
                let alert = UIAlertController.init(title: "登录错误", message: errorStr, preferredStyle: .alert)
                alert.addAction(UIAlertAction.init(title: "好的", style: .cancel, handler: { (action) in
                    
                }))
                self.present(alert, animated: true, completion: {
                    
                })
            }
        }
        
        
    }
    
    @IBAction func loginMethoes(_ sender: UISegmentedControl, forEvent event: UIEvent) {
        if sender.selectedSegmentIndex == 0 {
            isRegCode = false
            getCode.isHidden=true
        } else {
            isRegCode = true
            getCode.isHidden=false
            pwd.text=""
        }
    }

    @IBAction func didGetCode(_ sender: UIButton) {
        guard (userName.text?.characters.count)! == 11 else {
            let alert = UIAlertController.init(title: "账号错误", message: "输入正常的手机号", preferredStyle: .alert)
            alert.addAction(UIAlertAction.init(title: "好的", style: .cancel, handler: { (action) in
                
            }))
            self.present(alert, animated: true, completion: {
                
            })
            return
        }
        let manger=UserFunction.init()
        manger.getUserRegisterCode(tel: userName.text!) { (code) in
            CommonFunction.showForShortTime(2, "验证码请求成功", "")
        }
        var i = 60
        sender.isEnabled = false
        DispatchQueue.global().async {
            while i>0
            {
                i-=1
                DispatchQueue.main.async {
                    sender.setTitle(i.description, for: .normal)
                }
                Thread.sleep(forTimeInterval: 1)
            }
            DispatchQueue.main.async {
                sender.isEnabled = true
                sender.setTitle("获取验证码", for: .normal)
            }
        }
    }
    
    




    internal func success(user:UserInfo) -> Void {
        let mobile = FMDBFunctions.shareInstance.getUserData(targetParameters: "mobile", content: user.mobile)
        if mobile.count == 0 {
            FMDBFunctions.shareInstance.insertUserData(user: user, success: {
                
            }, fail: {
                
            })
        }
        else
        {
            FMDBFunctions.shareInstance.delData(table: "T_UserInfo", parameters: "mobile", user.mobile, success: {
                
            }, fail: {
                
            })
            FMDBFunctions.shareInstance.insertUserData(user: user, success: {
                
            }, fail: {
                
            })
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
