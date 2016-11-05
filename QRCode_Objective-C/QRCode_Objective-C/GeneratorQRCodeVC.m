//
//  GeneratorQRCodeVC.m
//  QRCode_Objective-C
//
//  Created by weirenxin on 2016/11/5.
//  Copyright © 2016年 广西家饰宝科技有限公司. All rights reserved.
//

#import "GeneratorQRCodeVC.h"
#import <CoreImage/CoreImage.h>

@interface GeneratorQRCodeVC ()
    
@property (weak, nonatomic) IBOutlet UIImageView *qrCodeView;
    
@end

@implementation GeneratorQRCodeVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}
    
- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [self setupQRCode];
}

- (void)setupQRCode {
    
    // 创建滤镜对象
    CIFilter *filter = [CIFilter filterWithName:@"CIQRCodeGenerator"];
    
    [filter setDefaults];
    
    // 设置输入源
    NSString *inputStr = @"http://www.qq.com";
    NSData *inputData = [inputStr dataUsingEncoding:NSUTF8StringEncoding];
    [filter setValue:inputData forKey:@"inputMessage"];
    
    CIImage *outputImage = [filter outputImage];
    
    // 显示二维码
    self.qrCodeView.image = [self createNonInterpolatedUIImageFormCIImage:outputImage withSize:200];
}
    
- (UIImage *)createNonInterpolatedUIImageFormCIImage:(CIImage *)image withSize:(CGFloat) size {
    
    CGRect extent = CGRectIntegral(image.extent);
    CGFloat scale = MIN(size/CGRectGetWidth(extent), size/CGRectGetHeight(extent));
    
    // 1.创建bitmap;
    size_t width = CGRectGetWidth(extent) * scale;
    size_t height = CGRectGetHeight(extent) * scale;
    CGColorSpaceRef cs = CGColorSpaceCreateDeviceGray();
    CGContextRef bitmapRef = CGBitmapContextCreate(nil, width, height, 8, 0, cs, (CGBitmapInfo)kCGImageAlphaNone);
    CIContext *context = [CIContext contextWithOptions:nil];
    CGImageRef bitmapImage = [context createCGImage:image fromRect:extent];
    CGContextSetInterpolationQuality(bitmapRef, kCGInterpolationNone);
    CGContextScaleCTM(bitmapRef, scale, scale);
    CGContextDrawImage(bitmapRef, extent, bitmapImage);
    
    // 2.保存bitmap到图片
    CGImageRef scaledImage = CGBitmapContextCreateImage(bitmapRef);
    CGContextRelease(bitmapRef);
    CGImageRelease(bitmapImage);
    return [UIImage imageWithCGImage:scaledImage];
}

@end
