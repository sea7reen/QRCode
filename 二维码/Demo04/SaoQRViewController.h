//
//  SaoQRViewController.h
//  Demo04
//
//  Created by Kevin on 16/3/24.
//  Copyright © 2016年 tarena. All rights reserved.
//

#import <UIKit/UIKit.h>


typedef void (^ScanSuccessed)(NSString *successMsg);
typedef void (^ScanFailed)(NSString *failMsg);

@interface SaoQRViewController : UIViewController


- (void)startScan:(ScanSuccessed)successed failed:(ScanFailed)failed;

@end
