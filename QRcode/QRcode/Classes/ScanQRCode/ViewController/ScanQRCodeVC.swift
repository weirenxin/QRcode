//
//  ScanQRCodeVC.swift
//  QRcode
//
//  Created by weirenxin on 2016/11/3.
//  Copyright © 2016年 广西家饰宝科技有限公司. All rights reserved.
//

import UIKit

class ScanQRCodeVC: UIViewController {

    @IBOutlet weak var scanBackView: UIImageView!
    @IBOutlet weak var scanView: UIImageView!
    @IBOutlet weak var scanViewBottomConstraint: NSLayoutConstraint!
    
    @IBAction func startAction(_ sender: UIButton) {
        startAnimation()
        
    }
    @IBAction func stopAction(_ sender: UIButton) {
        removeAnimation()
        
    }
}

extension ScanQRCodeVC {
    fileprivate func startAnimation() {
        scanViewBottomConstraint.constant = scanBackView.frame.size.height
        view.layoutIfNeeded()
        
        scanViewBottomConstraint.constant = -scanBackView.frame.size.height
        UIView.animate(withDuration: 1, animations:{
            UIView.setAnimationRepeatCount(MAXFLOAT)
            self.view.layoutIfNeeded()
        });
    }
    
    fileprivate func removeAnimation() {
        scanView.layer.removeAllAnimations()
    }
}
