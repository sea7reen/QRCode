//
//  SaoQRViewController.m
//  Demo04
//
//  Created by Kevin on 16/3/24.
//  Copyright © 2016年 tarena. All rights reserved.
//

#import "SaoQRViewController.h"
#import <AVFoundation/AVFoundation.h>

@interface SaoQRViewController ()<AVCaptureMetadataOutputObjectsDelegate>
{
    AVCaptureDevice *device;
    AVCaptureDeviceInput *input;
    AVCaptureMetadataOutput *output;
    AVCaptureSession *session;
    AVCaptureVideoPreviewLayer *previewLayer;
    //扫描区域
    CGRect rectOfInterest;
    //滚动绿线
    UIView *scanLayerView;
}

@property (weak, nonatomic) IBOutlet UIView *scanView;
@property (weak, nonatomic) IBOutlet UILabel *scanLabel;
@property (weak, nonatomic) IBOutlet UIButton *lightButton;
@property (weak, nonatomic) IBOutlet UIButton *scanButton;

@property (nonatomic, strong) ScanSuccessed scanSuccess;
@property (nonatomic, strong) ScanFailed scanFail;
@property (nonatomic, assign) BOOL ScanResult;

@end

@implementation SaoQRViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    //[self creatScanLayerView];
    _ScanResult = YES;
}

//- (void)dealloc
//{
//    [self stopScan];
//}

- (void)startScan:(ScanSuccessed)successed failed:(ScanFailed)failed {
    _scanSuccess = successed;
    _scanFail = failed;
    NSError *error;
    AVCaptureDevice *dev = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    if (![AVCaptureDeviceInput deviceInputWithDevice:dev error:&error]) {
        failed(error.localizedDescription);
        return;
    }
}

//扫描按钮
- (IBAction)startScan:(UIButton *)sender {
    if ([self.scanButton.titleLabel.text isEqualToString:@"开始"]) {
        [self startScan];
    } else {
        [self stopScan];
    }
}

- (void)startScan {
    [self.scanButton setTitle:@"停止" forState:UIControlStateNormal];
    device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    NSError *error;
    input = [AVCaptureDeviceInput deviceInputWithDevice:device error:&error];
    if (!input) {
        [self videoFailed];
        return;
    }
    session = [[AVCaptureSession alloc]init];
    output = [[AVCaptureMetadataOutput alloc]init];
    [output setMetadataObjectsDelegate:self queue:dispatch_get_main_queue()];
    [session setSessionPreset:AVCaptureSessionPresetHigh];
    if ([session canAddInput:input]) {
        [session addInput:input];
    }
    if ([session canAddOutput:output]) {
        [session addOutput:output];
    }
    output.metadataObjectTypes =@[AVMetadataObjectTypeQRCode,AVMetadataObjectTypeEAN13Code, AVMetadataObjectTypeEAN8Code, AVMetadataObjectTypeCode128Code];
    previewLayer = [AVCaptureVideoPreviewLayer layerWithSession:session];
    previewLayer.videoGravity = AVLayerVideoGravityResizeAspectFill;
    previewLayer.frame = self.scanView.layer.bounds;
    [self.scanView.layer insertSublayer:previewLayer atIndex:0];
    [session startRunning];
}

- (void)stopScan {
    [self.scanButton setTitle:@"开始" forState:UIControlStateNormal];
    [session stopRunning];
    session = nil;
    [previewLayer removeFromSuperlayer];
}

- (void)videoFailed {
    UIAlertView *videoFailedScanView = [[UIAlertView alloc]initWithTitle:@"提示" message:@"开启摄像头失败" delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
    [videoFailedScanView show];
    self.scanLabel.text = @"摄像头开始失败";
}
#pragma mark - 代理方法
-(void) captureOutput:(AVCaptureOutput *)captureOutput didOutputMetadataObjects:(NSArray *)metadataObjects fromConnection:(AVCaptureConnection *)connection {
    if (metadataObjects != nil && metadataObjects.count > 0)
    {
        AVMetadataMachineReadableCodeObject *metadataObject = metadataObjects[0];
        NSString *result;
        if ([[metadataObject type]isEqualToString:AVMetadataObjectTypeQRCode]){
            result = metadataObject.stringValue;
            self.scanLabel.text = result;
        }else{
            [self failScan];
        }
        [self performSelectorOnMainThread:@selector(scanResult:) withObject:result waitUntilDone:NO];
    }
}

- (void)failScan {
    UIAlertView *failScanView = [[UIAlertView alloc]initWithTitle:@"提示" message:@"二维码扫描失败" delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
    [failScanView show];
    self.scanLabel.text = @"扫描的二维码错误";
}

- (void)scanResult:(NSString *)result {
    [self stopScan];
    if (!_ScanResult) {
        return;
    }
    _ScanResult = NO;
    UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"二维码扫描" message:result delegate:nil cancelButtonTitle:@"取消" otherButtonTitles:nil, nil];
    [alert show];
    _ScanResult = YES;
}

//灯光按钮
- (IBAction)lightOpen:(UIButton *)sender {
    if ([sender.titleLabel.text isEqualToString:@"开灯"]) {
        [self lightSwitch:YES];
    }else{
        [self lightSwitch:NO];
    }
}

- (void)lightSwitch:(BOOL)light {
    if (light) {
        [self.lightButton setTitle:@"关灯" forState:UIControlStateNormal];
    }else{
        [self.lightButton setTitle:@"开灯" forState:UIControlStateNormal];
    }
    AVCaptureDevice *dev = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    if ([dev hasTorch]) {
        [dev lockForConfiguration:nil];
        if (light) {
            [dev setTorchMode:AVCaptureTorchModeOn];
        }else{
            [dev setTorchMode:AVCaptureTorchModeOff];
        }
        [dev unlockForConfiguration];
    }
}

//生成绿色扫描线
- (void)creatScanLayerView {
    [self.scanView.layer setBorderWidth:4];
    self.scanView.layer.borderColor = [[UIColor lightGrayColor]CGColor];
    self.scanView.backgroundColor = [UIColor clearColor];
    scanLayerView = [[UIView alloc]initWithFrame:CGRectMake(4, 0, self.scanView.bounds.size.width - 8, 2)];
    scanLayerView.backgroundColor = [UIColor greenColor];
    [self.scanView addSubview:scanLayerView];
    [self startMoveScanLayerView];
}

- (void)startMoveScanLayerView {
    [UIView animateWithDuration:3 animations:^{
        scanLayerView.transform = CGAffineTransformMakeTranslation(0, self.scanView.frame.size.width - 8);
    } completion:^(BOOL finished) {
        scanLayerView.transform = CGAffineTransformIdentity;
        [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(startMoveScanLayerView) object:nil];
        [self performSelector:@selector(startMoveScanLayerView) withObject:nil afterDelay:0.5];
    }];
}

@end
