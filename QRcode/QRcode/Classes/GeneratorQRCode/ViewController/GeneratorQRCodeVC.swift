//
//  GeneratorQRCodeVC.swift
//  QRcode
//
//  Created by weirenxin on 2016/11/3.
//  Copyright © 2016年 广西家饰宝科技有限公司. All rights reserved.
//

import UIKit
import CoreImage

class GeneratorQRCodeVC: UIViewController {

    @IBOutlet weak var qrCodeImageView: UIImageView!
    @IBOutlet weak var inputTV: UITextView!
    
    @IBAction func generateAction(_ sender: UIButton) {
        //setupQRCode()
        
        setupCustomQRCode()
    }
    
    // 0.
    fileprivate func setupQRCode() {
        // 1.创建二维码滤镜/恢复默认设置
        let filter = CIFilter(name: "CIQRCodeGenerator")
        filter?.setDefaults()
        
        // 2.设置滤镜数据
        let data = "456".data(using: .utf8)
        filter?.setValue(data, forKey: "inputMessage")
        
        // 3.获取结果图片
        var image = filter?.outputImage
        
        let transform = CGAffineTransform(scaleX: 20, y: 20)
        image = image?.applying(transform)
        
        // 4.显示图片
        let resultImage = UIImage(ciImage: image!)
        print(resultImage.size)
        qrCodeImageView.image = resultImage;
    }
}

// MARK: - 自定义二维码
extension GeneratorQRCodeVC {
    fileprivate func setupCustomQRCode() {
        
        let inputStr = inputTV.text ?? ""
        
        let filter = CIFilter(name: "CIQRCodeGenerator")
        filter?.setDefaults()
        
        let data = inputStr.data(using: .utf8)
        filter?.setValue(data, forKey: "inputMessage")
        
        // 设置二维码纠错率
        filter?.setValue("M", forKey: "inputCorrectionLevel")
        
        var image = filter?.outputImage
        
        let transform = CGAffineTransform(scaleX: 20, y: 20)
        image = image?.applying(transform)

        var resultImage = UIImage(ciImage: image!)
        print(resultImage.size)
        
        let center = UIImage(named: "erha.png")
        resultImage = getNewImage(resultImage, center!)
        
        
        qrCodeImageView.image = resultImage;
    }
    
    private func getNewImage(_ sourceImage: UIImage, _ center: UIImage) -> UIImage {
        
        let size = sourceImage.size
        
        // 1.开启上下文
        UIGraphicsBeginImageContext(size)
        // 2.绘制大图
        sourceImage.draw(in: CGRect(x: 0, y: 0, width: size.width, height: size.height))
        
        // 3.绘制小图
        let width: CGFloat = 80
        let height: CGFloat = 80
        let x: CGFloat = (size.width - width) * 0.5
        let y: CGFloat = (size.height - height) * 0.5
        center.draw(in: CGRect(x: x, y: y, width: width, height: height))
        
        let resultImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return resultImage!
    }
}
