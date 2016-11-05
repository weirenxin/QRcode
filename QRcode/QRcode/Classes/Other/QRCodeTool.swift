//
//  QRCodeTool.swift
//  QRcode
//
//  Created by weirenxin on 2016/11/5.
//  Copyright © 2016年 广西家饰宝科技有限公司. All rights reserved.
//

import UIKit
import AVFoundation

typealias ScanResultBlock = ([String]) -> ()

// MARK: - 二维码扫描
class QRCodeTool: NSObject {
    
    static let shareInstance = QRCodeTool()
    
    // MARK: - lazy
    private lazy var input: AVCaptureDeviceInput? = {
        // 1.设置输入/获取摄像头设备
        let cameraDevice = AVCaptureDevice.defaultDevice(withMediaType: AVMediaTypeVideo)
        
        // 把摄像头设备当做输入设备
        var input: AVCaptureDeviceInput?
        do {
            input = try AVCaptureDeviceInput(device: cameraDevice)
            return input
        } catch {
            print(error)
            return nil
        }
    }()
    
    private lazy var output: AVCaptureMetadataOutput = {
        // 2.设置输出
        let output = AVCaptureMetadataOutput()
        output.setMetadataObjectsDelegate(self, queue: DispatchQueue.main)
        return output
    }()
    
    private lazy var session: AVCaptureSession = {
        // 3.创建会话/ 连接输入输出
        let session = AVCaptureSession()
        return session
    }()
    
    fileprivate lazy var layer: AVCaptureVideoPreviewLayer = {
        // 6.添加视频预览图层
        let layer = AVCaptureVideoPreviewLayer(session: self.session)
        return layer!
    }()
    
    fileprivate var scanResultBlock: ScanResultBlock?
    fileprivate var isDrawFrame: Bool = false
    
    func scanQRCode(_ inView: UIView, _ isDrawFrame: Bool, resultBlock: @escaping (_ resultStrs: [String]) -> ())  {
        
        // 记录闭包
        scanResultBlock = resultBlock
        self.isDrawFrame = isDrawFrame
        
        if  session.canAddInput(input) && session.canAddOutput(output) {
            session.addInput(input)
            session.addOutput(output)
        }else {
            return
        }
        
        /****  设置识别类型，必须在添加输入输出之后  ****/
        // 4.设置二维码可以识别的码制
        output.metadataObjectTypes = [AVMetadataObjectTypeQRCode]
        
        if inView.layer.sublayers == nil {
            layer.frame = inView.layer.bounds
            inView.layer.insertSublayer(layer, at: 0)
        }else {
            let subLayers = inView.layer.sublayers!
            if  !subLayers.contains(layer) {
                layer.frame = inView.layer.bounds
                inView.layer.insertSublayer(layer, at: 0)
            }
        }
        // 7.启动会话 [让输入开始采集数据, 输出对象,开始处理数据]
        session.startRunning()
    }
    
    func setRectInterest(_ orginRect: CGRect) {
        // 5.设置扫描区域
        //  CGRectMake(0, 0, 1, 1)  0.0 - 1.0
        // 0 0. 右上角
        let bounds = UIScreen.main.bounds
        let x: CGFloat = orginRect.origin.x / bounds.size.width
        let y: CGFloat = orginRect.origin.y / bounds.size.height
        let width: CGFloat = orginRect.size.width / bounds.size.width
        let height: CGFloat = orginRect.size.height / bounds.size.height
        output.rectOfInterest = CGRect(x: y, y: x, width: height, height: width)
    }
}

// MARK: - AVCaptureMetadataOutputObjectsDelegate
extension QRCodeTool : AVCaptureMetadataOutputObjectsDelegate {
    // 扫描到结果之后调用
    func captureOutput(_ captureOutput: AVCaptureOutput!, didOutputMetadataObjects metadataObjects: [Any]!, from connection: AVCaptureConnection!) {
        
        if isDrawFrame {
           removeFrameLayer()
        }
        
        var resultStrs = [String]()
        for obj in metadataObjects {
            
            if (obj as AnyObject).isKind(of: AVMetadataMachineReadableCodeObject.self)
            {
                // 转换成为, 二维码, 在预览图层上的真正坐标
                // qrCodeObj.corners 代表二维码的四个角,
                // 但是, 需要借助视频预览 图层,转换成为,我们需要的可以用的坐标
                
                let resultObj = layer.transformedMetadataObject(for: obj as! AVMetadataObject)
                let qrCodeObj = resultObj as! AVMetadataMachineReadableCodeObject
                resultStrs.append(qrCodeObj.stringValue)
                if isDrawFrame {
                    drawFrame(qrCodeObj)
                }
            }
        }
        if scanResultBlock != nil {
           scanResultBlock!(resultStrs)
        }
    }
    
    private func drawFrame(_ qrCodeObj: AVMetadataMachineReadableCodeObject) {
        let corners = qrCodeObj.corners
        
        // 1. 借助一个图形层, 来绘制
        let shapLayer = CAShapeLayer()
        shapLayer.fillColor = UIColor.clear.cgColor
        shapLayer.strokeColor = UIColor.red.cgColor
        shapLayer.lineWidth = 6
        
        // 2. 根据四个点, 创建一个路径
        let path = UIBezierPath()
        var index = 0
        for corner in corners! {
            
            let pointDic = corner as! CFDictionary
            let point = CGPoint(dictionaryRepresentation: pointDic)!
            
            // 第一个点
            if index == 0 {
                path.move(to: point)
            }else {
                path.addLine(to: point)
            }
            index += 1
        }
        
        path.close()
        
        // 3. 给图形图层的路径赋值, 代表, 图层展示怎样的形状
        shapLayer.path = path.cgPath
        
        // 4. 直接添加图形图层到需要展示的图层
        layer.addSublayer(shapLayer)
    }
    
    private func removeFrameLayer() -> () {
        guard let subLayers = layer.sublayers else {return}
        
        for subLayer in subLayers
        {
            if subLayer.isKind(of: CAShapeLayer.self)
            {
                subLayer.removeFromSuperlayer()
            }
        }
    }
}



// MARK: - 生成二维码

extension QRCodeTool {
    
    class func generatorQRCode(_ inputStr: String, centerImage: UIImage?) -> UIImage {
        
        let filter = CIFilter(name: "CIQRCodeGenerator")
        filter?.setDefaults()
        
        let data = inputStr.data(using: .utf8)
        filter?.setValue(data, forKey: "inputMessage")
        
        // 前景图片设置的前提：具备纠错率
        // 可以根据其他部分，计算出遮挡部分：保证三个角不能被遮挡
        // 纠错率：inputCorrectionLevel
        // L ： 7%的字码可被修正
        // M ： 15%
        // Q ： 25%
        // H ： 30%
        // 设置二维码纠错率
        filter?.setValue("M", forKey: "inputCorrectionLevel")
        
        var image = filter?.outputImage
        
        let transform = CGAffineTransform(scaleX: 20, y: 20)
        image = image?.applying(transform)
        
        var resultImage = UIImage(ciImage: image!)
        print(resultImage.size)
        
        if centerImage != nil {
            resultImage = getNewImage(resultImage, centerImage!)
        }
        
        return resultImage;
    }
    
    class private func getNewImage(_ sourceImage: UIImage, _ center: UIImage) -> UIImage {
        
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
