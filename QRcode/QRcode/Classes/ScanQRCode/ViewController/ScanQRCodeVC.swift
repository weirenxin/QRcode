//
//  ScanQRCodeVC.swift
//  QRcode
//
//  Created by weirenxin on 2016/11/3.
//  Copyright © 2016年 广西家饰宝科技有限公司. All rights reserved.
//

import UIKit
import AVFoundation

class ScanQRCodeVC: UIViewController {

    @IBOutlet weak var scanBackView: UIView!
    @IBOutlet weak var scanView: UIImageView!
    @IBOutlet weak var scanViewBottomConstraint: NSLayoutConstraint!
    
    var session: AVCaptureSession?
    weak var layer: AVCaptureVideoPreviewLayer?
    
    @IBAction func startAction(_ sender: UIButton) {
        startAnimation()
        //startScan()
        
        QRCodeTool.shareInstance.setRectInterest(scanBackView.frame)
        QRCodeTool.shareInstance.scanQRCode(view, true, resultBlock:{ (resultStrs) in
            print(resultStrs)
        });
    }
    @IBAction func stopAction(_ sender: UIButton) {
        removeAnimation()
        
    }
}


// MARK: - 扫描区域 边框
extension ScanQRCodeVC {
    
    fileprivate func startScan() {
        // 1.设置输入/获取摄像头设备
        let cameraDevice = AVCaptureDevice.defaultDevice(withMediaType: AVMediaTypeVideo)
        
        // 把摄像头设备当做输入设备
        var input: AVCaptureDeviceInput?
        do {
            input = try AVCaptureDeviceInput(device: cameraDevice)
        } catch {
            print(error)
            return
        }
        
        // 2.设置输出
        let output = AVCaptureMetadataOutput()
        output.setMetadataObjectsDelegate(self, queue: DispatchQueue.main)
        
        // 3.创建会话/ 连接输入输出
        session = AVCaptureSession()
        if session!.canAddInput(input) && session!.canAddOutput(output) {
            
            session?.addInput(input)
            session?.addOutput(output)
        }else {
            return
        }
        
        /****  设置识别类型，必须在添加输入输出之后  ****/
        // 4.设置二维码可以识别的码制
        output.metadataObjectTypes = [AVMetadataObjectTypeQRCode]
        
        // 5.设置扫描区域
        
        let bounds = UIScreen.main.bounds
        let x: CGFloat = scanBackView.frame.origin.x / bounds.size.width
        let y: CGFloat = scanBackView.frame.origin.y / bounds.size.height
        let width: CGFloat = scanBackView.frame.size.width / bounds.size.width
        let height: CGFloat = scanBackView.frame.size.height / bounds.size.height
        output.rectOfInterest = CGRect(x: y, y: x, width: height, height: width)
        
        // 6.添加视频预览图层
        let layer = AVCaptureVideoPreviewLayer(session: session)
        layer?.frame = view.layer.bounds
        view.layer.insertSublayer(layer!, at: 0)
        self.layer = layer
        
        // 7.启动会话 [让输入开始采集数据, 输出对象,开始处理数据]
        session?.startRunning()
    }
}

// MARK: - AVCaptureMetadataOutputObjectsDelegate
extension ScanQRCodeVC : AVCaptureMetadataOutputObjectsDelegate {
    // 扫描到结果之后调用
    func captureOutput(_ captureOutput: AVCaptureOutput!, didOutputMetadataObjects metadataObjects: [Any]!, from connection: AVCaptureConnection!) {
        
        removeFrameLayer()
        
        for obj in metadataObjects {
            
            if (obj as AnyObject).isKind(of: AVMetadataMachineReadableCodeObject.self)
            {
                // 转换成为, 二维码, 在预览图层上的真正坐标
                // qrCodeObj.corners 代表二维码的四个角, 
                // 但是, 需要借助视频预览 图层,转换成为,我们需要的可以用的坐标
                
                let resultObj = self.layer?.transformedMetadataObject(for: obj as! AVMetadataObject)
                let qrCodeObj = resultObj as! AVMetadataMachineReadableCodeObject
                print(qrCodeObj.stringValue)
                print(qrCodeObj.corners)

                drawFrame(qrCodeObj)
            }
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
        layer?.addSublayer(shapLayer)
    }
    
    private func removeFrameLayer() -> () {
        guard let subLayers = layer?.sublayers else {return}
        
        for subLayer in subLayers
        {
            if subLayer.isKind(of: CAShapeLayer.self)
            {
                subLayer.removeFromSuperlayer()
            }
        }
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
