//
//  FavoriteSubScroll.swift
//  BinMarker
//
//  Created by 彭子上 on 2017/4/19.
//  Copyright © 2017年 彭子上. All rights reserved.
//

import UIKit

protocol FavoriteSubScrollDelegate :NSObjectProtocol {
    func didClickBtn(_ sender:UIButton,_ index:Int) -> Void
}

class FavoriteSubScroll: UIScrollView {
    
    var channelInfoList = Array<Dictionary<String,Any>>.init()
    weak var favoriteDelegate:FavoriteSubScrollDelegate?
    
    func reloadData(with channelArray:Array<Dictionary<String,Any>>) -> Void {
        let containView=self.subviews.first!
        for subView in containView.subviews {
            subView.removeFromSuperview()
        }
        self.contentSize=CGSize.init(width: CGFloat(channelArray.count*Int(self.bounds.width)/4), height: self.bounds.height)
        for (index,value) in channelArray.enumerated() {
            
            let width=self.bounds.width/4
            let high=width/0.9
            let bgView=UIView.init(frame: CGRect.init(origin: CGPoint.init(x: Int(width) * index, y: 0), size: CGSize.init(width: width, height: high)))
            containView.addSubview(bgView)
            
            let channelImageBtnWidth=bgView.bounds.width*0.75
            let channelImageBtn=UIButton.init(
                frame: CGRect.init(origin: CGPoint.init(x: bgView.bounds.width*0.25/2,
                                                        y: bgView.bounds.height*0.15/2),
                                   size: CGSize.init(width: channelImageBtnWidth,
                                                     height: channelImageBtnWidth)))
            
            bgView.addSubview(channelImageBtn)
            channelImageBtn.addTarget(self, action: #selector(didClickBtn(_:)), for:.touchUpInside)
            channelImageBtn.tag=2000+index
            channelImageBtn.setBackgroundImage(#imageLiteral(resourceName: "channel-6"), for: .normal)
            
            
            let channelLab = UILabel.init(frame: CGRect.init(origin: CGPoint.init(x: channelImageBtn.center.x-40,y: channelImageBtn.frame.maxY), size: CGSize.init(width: 80, height: 20)))

            channelLab.text=value["name"] as? String
            channelLab.textAlignment = .center
            bgView.addSubview(channelLab)
            //图片未解决
            //加入点击事件
        }
    }
    
    func didClickBtn(_ sender:UIButton) -> Void {
        favoriteDelegate?.didClickBtn(sender, sender.tag-2000)
    }
    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */

}
