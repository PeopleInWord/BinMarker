//
//  BOXController.swift
//  BinMarker
//
//  Created by 彭子上 on 2017/3/11.
//  Copyright © 2017年 彭子上. All rights reserved.
//

import UIKit

class BOXController: UIViewController ,UITabBarDelegate{
    @IBOutlet weak var numView: UIView!
    @IBOutlet weak var controlView: UIView!
    @IBOutlet weak var functionView: UIView!
    @IBOutlet weak var tabBar: UITabBar!
    @IBOutlet weak var scrollViewHeight: NSLayoutConstraint!
    
    public var deviceInfo=Dictionary<String, Any>.init()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        super.viewDidLoad()
        self.tabBar.selectedItem=self.tabBar.items?[1]
        scrollViewHeight.constant=UIScreen.main.bounds.height*0.37
        // Do any additional setup after loading the view.
    }
    
    @IBAction func pressBtn(_ sender: UIButton) {
        print(sender.tag)
        
        
    }
    
    
    func tabBar(_ tabBar: UITabBar, didSelect item: UITabBarItem)
    {
        if item.title=="数字" {
            UIView.animate(withDuration: 1, delay: 2, options: .curveEaseIn, animations: {
                self.controlView.isHidden=true
                self.functionView.isHidden=true
                self.numView.isHidden=false
            }, completion: { (_) in
                
            })
            
        }
        else if item.title=="功能"{
            UIView.animate(withDuration: 1, delay: 2, options: .curveEaseIn, animations: {
                self.controlView.isHidden=false
                self.functionView.isHidden=true
                self.numView.isHidden=true
            }, completion: { (_) in
                
            })
            
        }
        else if item.title=="扩展"{
            UIView.animate(withDuration: 1, delay: 2, options: .curveEaseIn, animations: {
                
            }, completion: { (_) in
                self.controlView.isHidden=true
                self.functionView.isHidden=false
                self.numView.isHidden=true
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
