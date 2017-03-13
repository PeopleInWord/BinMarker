//
//  AMPController.swift
//  BinMarker
//
//  Created by 彭子上 on 2017/3/13.
//  Copyright © 2017年 彭子上. All rights reserved.
//

import UIKit

class AMPController: UIViewController,UITabBarDelegate {

    @IBOutlet weak var scrollViewHeight: NSLayoutConstraint!
    @IBOutlet weak var tabBar: UITabBar!
    @IBOutlet weak var controlView: UIView!
    @IBOutlet weak var functionView: UIView!
    @IBOutlet weak var numView: UIView!
    
    public var deviceInfo=Dictionary<String, Any>.init()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tabBar.selectedItem=self.tabBar.items?[1]
        scrollViewHeight.constant=UIScreen.main.bounds.height*0.41
        // Do any additional setup after loading the view.
    }

    func tabBar(_ tabBar: UITabBar, didSelect item: UITabBarItem)
    {
        if item.title=="数字" {
            UIView.animate(withDuration: 1, delay: 2, options: .curveEaseIn, animations: {
                self.controlView.isHidden=true
                self.functionView.isHidden=true
                self.numView.isHidden=false
                self.scrollViewHeight.constant=UIScreen.main.bounds.height*0.37
            }, completion: { (_) in
                
            })
            
        }
        else if item.title=="功能"{
            UIView.animate(withDuration: 1, delay: 2, options: .curveEaseIn, animations: {
                self.controlView.isHidden=false
                self.functionView.isHidden=true
                self.numView.isHidden=true
                self.scrollViewHeight.constant=UIScreen.main.bounds.height*0.41
            }, completion: { (_) in
                
            })
            
        }
        else if item.title=="扩展"{
            UIView.animate(withDuration: 1, delay: 2, options: .curveEaseIn, animations: {
                
            }, completion: { (_) in
                self.controlView.isHidden=true
                self.functionView.isHidden=false
                self.numView.isHidden=true
                self.scrollViewHeight.constant=UIScreen.main.bounds.height*0.34
            })
            
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
