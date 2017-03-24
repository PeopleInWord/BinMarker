//
//  FavoriteScrollView.swift
//  BinMarker
//
//  Created by 彭子上 on 2017/3/21.
//  Copyright © 2017年 彭子上. All rights reserved.
//

import UIKit

class FavoriteScrollView: UIScrollView ,UIGestureRecognizerDelegate,UIScrollViewDelegate{

    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        if gestureRecognizer.state.rawValue != 0 {
            return true
        }
        else{
            return false
        }
//        return otherGestureRecognizer.view?.superview is UITableView
    }
    
    func scrollViewWillBeginDecelerating(_ scrollView: UIScrollView) {
        print(scrollView.contentOffset)
    }
    
    func scrollViewDidEndScrollingAnimation(_ scrollView: UIScrollView) {
        print(scrollView.contentOffset)
    }
    
    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */

}
