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
        
        let filter = CIFilter(name: "CIQRCodeGenerator")
        filter?.setDefaults()
        
        let data = "456".data(using: .utf8)
        filter?.setValue(data, forKey: "inputMessage")
        
        var image = filter?.outputImage
        
        let transform = CGAffineTransform(scaleX: 20, y: 20)
        image = image?.applying(transform)
        
        let resultImage = UIImage(ciImage: image!)
        print(resultImage.size)
        qrCodeImageView.image = resultImage;
    }
}
