//
//  CreateCode.m
//  Demo04
//
//  Created by Kevin on 16/2/25.
//  Copyright © 2016年 tarena. All rights reserved.
//

#import "CreateCode.h"
#import <Photos/Photos.h>
#import "ZXBarcodeFormat.h"
#import "ZXMultiFormatWriter.h"
#import "ZXImage.h"

@implementation CreateCode

+ (CIImage *)createString:(NSString *)string {
    NSData *stringData = [string dataUsingEncoding:NSUTF8StringEncoding];
    CIFilter *filter = [CIFilter filterWithName:@"CIQRCodeGenerator"];
    [filter setValue:stringData forKey:@"inputMessage"];
    [filter setValue:@"H" forKey:@"inputCorrectionLevel"];
    return filter.outputImage;
}

+ (UIImage *)createUIImageFromCIImage:(CIImage *)ciImage withSize:(CGSize)size {
    CGImageRef imageRef = [[CIContext contextWithOptions:nil]createCGImage:ciImage fromRect:ciImage.extent];
    UIGraphicsBeginImageContext(size);
    CGContextRef contextRef = UIGraphicsGetCurrentContext();
    CGContextSetInterpolationQuality(contextRef, kCGInterpolationNone);
    CGContextScaleCTM(contextRef, 1.0, -1.0);
    CGContextDrawImage(contextRef, CGContextGetClipBoundingBox(contextRef), imageRef);
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    CGContextRelease(contextRef);
    CGImageRelease(imageRef);
    return image;
}

+ (UIImage *)addBGImage:(UIImage *)bgImage withLogoImage:(UIImage *)logoImage byLogoSize:(CGSize)logoSize {
    UIGraphicsBeginImageContext(bgImage.size);
    [bgImage drawInRect:CGRectMake(0, 0, bgImage.size.width, bgImage.size.height)];
    CGRect rect = CGRectMake(bgImage.size.width/2 - logoSize.width/2,bgImage.size.height/2 - logoSize.height/2 , logoSize.width, logoSize.height);
    [logoImage drawInRect:rect];
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return image;
}

+ (UIImage *)changeImage:(UIImage *)image withRed:(CGFloat)red withGreen:(CGFloat)green withBlue:(CGFloat)blue {
    const int imageWidth = image.size.width;
    const int imageHeight = image.size.height;
    size_t bytesPerRow = imageWidth * 4;
    uint32_t* rgbImageBuf = (uint32_t*)malloc(bytesPerRow * imageHeight);
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    CGContextRef context = CGBitmapContextCreate(rgbImageBuf, imageWidth, imageHeight, 8, bytesPerRow, colorSpace, kCGBitmapByteOrder32Little | kCGImageAlphaNoneSkipLast);
    CGContextDrawImage(context, CGRectMake(0, 0, imageWidth, imageHeight), image.CGImage);
    // 遍历像素
    int pixelNum = imageWidth * imageHeight;
    uint32_t* pCurPtr = rgbImageBuf;
    for (int i = 0; i < pixelNum; i++, pCurPtr++){
        if ((*pCurPtr & 0xFFFFFF00) < 0x99999900){
            // 将白色变成透明
            // 改成下面的代码，会将图片转成想要的颜色
            uint8_t* ptr = (uint8_t*)pCurPtr;
            ptr[3] = red; //0~255
            ptr[2] = green;
            ptr[1] = blue;
        }else{
            uint8_t* ptr = (uint8_t*)pCurPtr;
            ptr[0] = 0;
        }
    }
    // 输出图片
    CGDataProviderRef dataProvider = CGDataProviderCreateWithData(NULL, rgbImageBuf, bytesPerRow * imageHeight, ProviderReleaseData);
    CGImageRef imageRef = CGImageCreate(imageWidth, imageHeight, 8, 32, bytesPerRow, colorSpace, kCGImageAlphaLast | kCGBitmapByteOrder32Little, dataProvider, NULL, true, kCGRenderingIntentDefault);
    CGDataProviderRelease(dataProvider);
    UIImage* colorImage = [UIImage imageWithCGImage:imageRef];
    // 清理空间
    CGImageRelease(imageRef);
    CGContextRelease(context);
    CGColorSpaceRelease(colorSpace);
    return colorImage;
}

void ProviderReleaseData (void *info, const void *data, size_t size){
    free((void*)data);
}

+ (UIImage *)createWithString:(NSString *)string withSize:(CGSize)size withColor:(UIColor *)color withBGColor:(UIColor *)bgColor {
    NSData *stringData = [string dataUsingEncoding:NSUTF8StringEncoding];
    CIFilter *filter = [CIFilter filterWithName:@"CIQRCodeGenerator"];
    [filter setValue:stringData forKey:@"inputMessage"];
    [filter setValue:@"H" forKey:@"inputCorrectionLevel"];
    CIColor *colorA = [CIColor colorWithCGColor:color.CGColor];
    CIColor *colorB = [CIColor colorWithCGColor:bgColor.CGColor];
    CIFilter *colorFilter = [CIFilter filterWithName:@"CIFalseColor" keysAndValues:@"inputImage",filter.outputImage, @"inputColor0",colorA, @"inputColor1",colorB, nil];
    CIImage *ciImage = colorFilter.outputImage;
    
    CGImageRef imageRef = [[CIContext contextWithOptions:nil] createCGImage:ciImage fromRect:ciImage.extent];
    UIGraphicsBeginImageContext(size);
    CGContextRef contextRef = UIGraphicsGetCurrentContext();
    CGContextSetInterpolationQuality(contextRef, kCGInterpolationNone);
    CGContextScaleCTM(contextRef, 1.0, -1.0);
    CGContextDrawImage(contextRef, CGContextGetClipBoundingBox(contextRef), imageRef);
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return image;
}

+ (UIImage *)createCodeString:(NSString *)string codeSize:(CGSize)size  CodeFomart:(NSString *)format{
    ZXBarcodeFormat zxformat = [CreateCode convertCodeFomratToZXBarcodeFormat:format];
    NSError *error = nil;
    ZXMultiFormatWriter *writer = [ZXMultiFormatWriter writer];
    ZXBitMatrix *result = [writer encode:string format:zxformat width:size.width height:size.width error:&error];
    if (result) {
        CGImageRef imageRef = [[ZXImage imageWithMatrix:result]cgimage];
        NSLog(@"%@",string);
        return [UIImage imageWithCGImage:imageRef];
    }else{
        NSString *errorMessage = [error localizedDescription];
        NSLog(@"errorMessage:%@",errorMessage);
        return nil;
    }
}

+ (ZXBarcodeFormat)convertCodeFomratToZXBarcodeFormat:(NSString*)strCodeType
{
    
    if ([strCodeType isEqualToString:AVMetadataObjectTypeQRCode])
    {
        return kBarcodeFormatQRCode;
    }
    
    if ([strCodeType isEqualToString:AVMetadataObjectTypeEAN13Code])
    {
        return kBarcodeFormatEan13;
    }
    
    if ([strCodeType isEqualToString:AVMetadataObjectTypeEAN8Code])
    {
        return kBarcodeFormatEan8;
    }
    
    if ([strCodeType isEqualToString:AVMetadataObjectTypePDF417Code])
    {
        return kBarcodeFormatPDF417;
    }
    
    if ([strCodeType isEqualToString:AVMetadataObjectTypeAztecCode])
    {
        return kBarcodeFormatAztec;
    }
    
    
    if ([strCodeType isEqualToString:AVMetadataObjectTypeCode39Code])
    {
        return kBarcodeFormatCode39;
    }
    
    if ([strCodeType isEqualToString:AVMetadataObjectTypeCode93Code])
    {
        return kBarcodeFormatCode93;
    }
    //支付宝付款码条形码格式
    if ([strCodeType isEqualToString:AVMetadataObjectTypeCode128Code])
    {
        return kBarcodeFormatCode128;
    }
    
    if ([strCodeType isEqualToString:AVMetadataObjectTypeDataMatrixCode])
    {
        return kBarcodeFormatDataMatrix;
    }
    
    if ([strCodeType isEqualToString:AVMetadataObjectTypeUPCECode])
    {
        return kBarcodeFormatUPCE;
    }
    
    return kBarcodeFormatQRCode;
}

@end
