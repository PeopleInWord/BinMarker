//
//  CustomStatusBar.swift
//  BinMarker
//
//  Created by 彭子上 on 2017/6/1.
//  Copyright © 2017年 彭子上. All rights reserved.
//

import UIKit

class CustomStatusBar: UIWindow {
    
    let messageLab = UILabel.init()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.frame = UIApplication.shared.statusBarFrame
        self.backgroundColor = UIColor.red
        messageLab.textColor = UIColor.white
        messageLab.center = self.center
        self.windowLevel = UIWindowLevelStatusBar + 10000.0
        self.alpha = 0.2
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    func show(with message:String) -> Void {
        self.isHidden = false
        self.alpha = 0.8
        self.addSubview(messageLab)
        self.messageLab.text = message
    }
    
    func hide() -> Void {
        self.isHidden = true
    }
    
    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */

}
