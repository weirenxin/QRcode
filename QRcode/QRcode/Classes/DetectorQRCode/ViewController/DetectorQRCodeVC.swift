//
//  DetectorQRCodeVC.swift
//  QRcode
//
//  Created by weirenxin on 2016/11/3.
//  Copyright © 2016年 广西家饰宝科技有限公司. All rights reserved.
//

import UIKit
import CoreImage

class DetectorQRCodeVC: UIViewController {

    @IBOutlet weak var sourceImageView: UIImageView!
    
    @IBAction func detectorQRCodeAction(_ sender: UIButton) {
        //distinguishQRCode()
        
        setupQRCodeFrame()
    }
    
    // 0.  erweima.png
    private func distinguishQRCode() {
        
        let image = sourceImageView.image
        let imageCI = CIImage(image: image!)
        
        // 1.创建一个二维码探测器
        // CIDetectorTypeQRCode : 识别类型
        // CIDetectorAccuracy : 识别率
        let dector = CIDetector(ofType: CIDetectorTypeQRCode, context: nil, options: [CIDetectorAccuracy: CIDetectorAccuracyHigh])
        
        // 2.直接探测二维码特征
        let features = dector?.features(in: imageCI!)
        
        for feature in features! {
            
            let qrFeature = feature as! CIQRCodeFeature
            print(qrFeature.messageString ?? "NO")
            print(qrFeature.bounds)
        }
    }
}

// MARK: - 二维码边框
extension DetectorQRCodeVC {
    
    fileprivate func setupQRCodeFrame() {
        
        let image = sourceImageView.image
        let imageCI = CIImage(image: image!)

        let dector = CIDetector(ofType: CIDetectorTypeQRCode, context: nil, options: [CIDetectorAccuracy: CIDetectorAccuracyHigh])
        let features = dector?.features(in: imageCI!)
        
        var resultImage = image
        
        var result = [String]()
        
        for feature in features! {
            let qrFeature = feature as! CIQRCodeFeature
            result.append(qrFeature.messageString!)
            resultImage = drawFrame(resultImage!, qrFeature)
            sourceImageView.image = resultImage
        }
    }
    
    private func drawFrame(_ image: UIImage, _ feature: CIQRCodeFeature) -> UIImage {
        
        let size = image.size
        print(size)
        
        UIGraphicsBeginImageContext(size)
        
        //绘制大图
        image.draw(in: CGRect(x: 0, y: 0, width: size.width, height: size.height))
        
        // 转换坐标系 上下颠倒
        let context = UIGraphicsGetCurrentContext()
        context?.scaleBy(x: 1, y: -1)
        context?.translateBy(x: 0, y: -size.height)
        
        // 绘制路径
        let bounds = feature.bounds
        let path = UIBezierPath(rect: bounds)
        UIColor.red.setStroke()
        path.lineWidth = 6
        path.stroke()
        
        let resultImage = UIGraphicsGetImageFromCurrentImageContext()
        
        UIGraphicsEndImageContext()
        
        return resultImage!
    }

}
