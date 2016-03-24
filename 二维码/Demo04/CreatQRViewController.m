//
//  CreatQRViewController.m
//  Demo04
//
//  Created by Kevin on 16/3/24.
//  Copyright © 2016年 tarena. All rights reserved.
//

#import "CreatQRViewController.h"
#import <CoreImage/CoreImage.h>
#import "CreateCode.h"

@interface CreatQRViewController ()<UIAlertViewDelegate>
@property (nonatomic, strong) UIView *ewView;
@property (nonatomic, strong) UIImageView *ewImageView;

@property (nonatomic, strong) UIView *txView;
@property (nonatomic, strong) UIImageView *txImageView;

@property (nonatomic, strong) UITextField *textField;
@end

@implementation CreatQRViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    if ([self respondsToSelector:@selector(setEdgesForExtendedLayout:)]) {
        self.edgesForExtendedLayout = UIRectEdgeNone;
    }
    self.view.backgroundColor = [UIColor yellowColor];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    UIButton *button = [[UIButton alloc]initWithFrame:CGRectMake(50, self.view.frame.size.height - 60, self.view.frame.size.width - 100, 40)];
    [button setTitle:@"切换二维码的样式以类型" forState:UIControlStateNormal];
    [button setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
    [button addTarget:self action:@selector(codeChoose) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:button];
    
    self.textField = [[UITextField alloc]initWithFrame:CGRectMake(self.view.frame.size.width/2 - 120, self.view.frame.size.height - 140, 240, 40)];
    self.textField.textAlignment = NSTextAlignmentCenter;
    self.textField.textColor = [UIColor blackColor];
    [self.view addSubview:self.textField];
    
    self.ewView = [[UIView alloc]initWithFrame:CGRectMake(80, 160, self.view.frame.size.width - 160, self.view.frame.size.width - 160)];
    self.ewView.backgroundColor = [UIColor whiteColor];
    self.ewView.layer.shadowColor = [UIColor darkGrayColor].CGColor;
    self.ewView.layer.shadowOffset = CGSizeMake(2, 2);
    self.ewView.layer.shadowRadius = 2;
    self.ewView.layer.shadowOpacity = 0.6;
    self.ewImageView = [[UIImageView alloc]initWithFrame:CGRectMake(5, 5, self.ewView.frame.size.width - 10, self.ewView.frame.size.width - 10)];
    self.ewImageView.image = [UIImage imageNamed:@"ipod1.jpg"];
    [self.ewView addSubview:self.ewImageView];
    
    self.txView = [[UIView alloc]initWithFrame:CGRectMake(40, 240, self.view.frame.size.width - 80, 160)];
    self.txView.backgroundColor = [UIColor whiteColor];
    self.txView.layer.shadowColor = [UIColor blackColor].CGColor;
    self.txView.layer.shadowOffset = CGSizeMake(2, 2);
    self.txView.layer.shadowRadius = 2;
    self.txView.layer.shadowOpacity = 0.8;
    self.txImageView = [[UIImageView alloc]initWithFrame:CGRectMake(5, 5, self.txView.frame.size.width - 10, self.txView.frame.size.height - 10)];
    self.txImageView.image = [UIImage imageNamed:@"ipod1.jpg"];
    [self.txView addSubview:self.txImageView];
    
    [self.view addSubview:self.ewView];
    [self.view addSubview:self.txView];
    [self createEW1];
}

- (void)codeChoose {
    UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:@"关于二维码的一切" message:nil delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"二维码", @"高清二维码", @"高清二维码+图片", @"高清二维码+颜色", @"高清二维码+前后背景色", @"商品条形码（支付宝可用）", @"其他条形码", nil];
    [alertView show];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    NSLog(@"%ld",buttonIndex);
    if (buttonIndex == 1) {
        [self createEW1];
        self.textField.text = @"二维码";
    }else if (buttonIndex == 2) {
        [self createEW2];
        self.textField.text = @"高清二维码";
    }else if (buttonIndex == 3) {
        [self createEW3];
        self.textField.text = @"高清二维码+图片";
    }else if (buttonIndex == 4) {
        [self createEW4];
        self.textField.text = @"高清二维码+颜色";
    }else if (buttonIndex == 5) {
        [self createEW5];
        self.textField.text = @"高清二维码+前后背景色";
    }else if (buttonIndex == 6) {
        [self createTX1];
        self.textField.text = @"商品条形码（支付宝可用）";
    }else if (buttonIndex == 7){
        [self createTX2];
        self.textField.text = @"其他条形码";
    }
}

- (void)createEW1 {
    self.ewView.hidden = NO;
    self.txView.hidden = YES;
    NSString *source = @"https://www.baidu.com";
    CIImage *ciImage = [CreateCode createString:source];
    UIImage *image = [UIImage imageWithCIImage:ciImage];
    self.ewImageView.image = image;
}

- (void)createEW2 {
    self.ewView.hidden = NO;
    self.txView.hidden = YES;
    NSString *source = @"https://www.baidu.com";
    //自定义二维码清晰度
    CGSize size = CGSizeMake(300, 300);
    UIImage *image = [CreateCode createUIImageFromCIImage:[CreateCode createString:source] withSize:size];
    self.ewImageView.image = image;
}

- (void)createEW3 {
    self.ewView.hidden = NO;
    self.txView.hidden = YES;
    NSString *source = @"https://www.baidu.com";
    CGSize size = CGSizeMake(300, 300);
    //添加图片
    UIImage *bgImage = [CreateCode createUIImageFromCIImage:[CreateCode createString:source] withSize:size];
    UIImage *logoImage = [UIImage imageNamed:@"IMG_5753.JPG"];
    self.ewImageView.image = [CreateCode addBGImage:bgImage withLogoImage:logoImage byLogoSize:CGSizeMake(100, 100)];
}

- (void)createEW4 {
    self.ewView.hidden = NO;
    self.txView.hidden = YES;
    NSString *source = @"https://www.baidu.com";
    //改变颜色
    UIImage *image = [CreateCode createUIImageFromCIImage:[CreateCode createString:source] withSize:CGSizeMake(300, 300)];
    self.ewImageView.image = [CreateCode changeImage:image withRed:80.f withGreen:180.f withBlue:80.f];
}

- (void)createEW5 {
    self.ewView.hidden = NO;
    self.txView.hidden = YES;
    NSString *source = @"https://www.baidu.com";
    //改变前后背景色
    UIColor *color = [UIColor colorWithRed:255./255 green:255./255 blue:255./255 alpha:1.0];
    UIColor *bgColor = [UIColor colorWithRed:100./255 green:100./255 blue:100./255 alpha:1.0];
    self.ewImageView.image = [CreateCode createWithString:source withSize:self.ewImageView.bounds.size withColor:color withBGColor:bgColor];
}

- (void)createTX1 {
    self.ewView.hidden = YES;
    self.txView.hidden = NO;
    NSString *source = @"140202198707023531";
    //添加128字符集的条形码
    self.txImageView.image = [CreateCode createCodeString:source codeSize:self.txImageView.bounds.size CodeFomart:AVMetadataObjectTypeCode128Code];
}

- (void)createTX2 {
    self.ewView.hidden = YES;
    self.txView.hidden = NO;
    NSString *source = @"6951635100495";
    //EAN13商品条码
    self.txImageView.image = [CreateCode createCodeString:source codeSize:self.txImageView.bounds.size CodeFomart:AVMetadataObjectTypeEAN13Code];
}
@end
