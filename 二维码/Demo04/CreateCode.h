//
//  CreateCode.h
//  Demo04
//
//  Created by Kevin on 16/2/25.
//  Copyright © 2016年 tarena. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Photos/Photos.h>

@interface CreateCode : NSObject

//生成二维码
+ (CIImage *)createString:(NSString *)string;
//自定义二维码清晰度
+ (UIImage *)createUIImageFromCIImage:(CIImage *)ciImage withSize:(CGSize)size;
//添加图片
+ (UIImage *)addBGImage:(UIImage *)bgImage withLogoImage:(UIImage *)logoImage byLogoSize:(CGSize)logoSize;
//二维码绘色
+ (UIImage *)changeImage:(UIImage *)image withRed:(CGFloat)red withGreen:(CGFloat)green withBlue:(CGFloat)blue;
//绘制二维码前后背景色（不推荐使用）
+ (UIImage *)createWithString:(NSString *)string withSize:(CGSize)size withColor:(UIColor*)color withBGColor:(UIColor*)bgColor;
//商品条码与Code128条码
+ (UIImage *)createCodeString:(NSString *)string codeSize:(CGSize)size CodeFomart:(NSString *)format;


@end
