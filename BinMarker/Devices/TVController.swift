//
//  TVController.swift
//  BinMarker
//
//  Created by 彭子上 on 2017/3/10.
//  Copyright © 2017年 彭子上. All rights reserved.
//

import UIKit

class TVController: UIViewController ,UITabBarDelegate{
    @IBOutlet weak var controlView: UIView!
    @IBOutlet weak var funtionView: UIView!
    @IBOutlet weak var numView: UIView!
    @IBOutlet weak var tabBar: UITabBar!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var scrollViewHeight: NSLayoutConstraint!

    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tabBar.selectedItem=self.tabBar.items?[1]
        scrollViewHeight.constant=UIScreen.main.bounds.height*0.38
        // Do any additional setup after loading the view.
    }

    func tabBar(_ tabBar: UITabBar, didSelect item: UITabBarItem)
    {
        if item.title=="数字" {
            self.controlView.isHidden=true
            self.funtionView.isHidden=true
            self.numView.isHidden=false
            scrollViewHeight.constant=UIScreen.main.bounds.height*0.35
        }
        else if item.title=="功能"{
            self.controlView.isHidden=false
            self.funtionView.isHidden=true
            self.numView.isHidden=true
            scrollViewHeight.constant=UIScreen.main.bounds.height*0.37
        }
        else if item.title=="扩展"{
            self.controlView.isHidden=true
            self.funtionView.isHidden=false
            self.numView.isHidden=true
            scrollViewHeight.constant=UIScreen.main.bounds.height*0.37
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
