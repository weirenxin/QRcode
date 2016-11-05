//
//  CustomQRCodeVC.m
//  QRCode_Objective-C
//
//  Created by weirenxin on 2016/11/5.
//  Copyright © 2016年 广西家饰宝科技有限公司. All rights reserved.
//

#import "CustomQRCodeVC.h"
#import "XMGQRCodeTool.h"

@interface CustomQRCodeVC ()
    
@property (weak, nonatomic) IBOutlet UIView *scanbackView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *scanViewBottomConstraint;

@end

@implementation CustomQRCodeVC

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    
    [self beginScanAnimation];
    [self beginScan];
}
    
// 开始扫描
- (void)beginScan {
        
    [XMGQRCodeTool sharedXMGQRCodeTool].isDrawQRCodeRect = YES;
    [[XMGQRCodeTool sharedXMGQRCodeTool] setInsteretRect:self.scanbackView.frame];
    [[XMGQRCodeTool sharedXMGQRCodeTool] beginScanInView:self.view result:^(NSArray<NSString *> *resultStrs) {
        NSLog(@"%@", resultStrs);
        [[XMGQRCodeTool sharedXMGQRCodeTool] stopScan];
        
    }];
}
    
// 开始扫描动画
- (void)beginScanAnimation {
    self.scanViewBottomConstraint.constant = self.scanbackView.frame.size.height;
    [self.view layoutIfNeeded];
    
    [UIView animateWithDuration:1 animations:^{
        [UIView setAnimationRepeatCount:CGFLOAT_MAX];
        self.scanViewBottomConstraint.constant = - self.scanbackView.frame.size.height;
        [self.view layoutIfNeeded];
        
    }];
}
    

@end
