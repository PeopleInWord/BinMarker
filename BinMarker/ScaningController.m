//
//  ScaningController.m
//  BinMarker
//
//  Created by 彭子上 on 2017/3/8.
//  Copyright © 2017年 彭子上. All rights reserved.
//

#import "ScaningController.h"
#import "BluetoothManager.h"
#import "AppDelegate.h"
#import "FLAnimatedImage.h"
@class CBPeripheral;
@interface ScaningController ()<CAAnimationDelegate>
{
    FLAnimatedImage *animationImage;
    FLAnimatedImageView *animationImageView;
}

@property (weak, nonatomic) IBOutlet UIButton *toMainBtn;
@property (weak, nonatomic) IBOutlet UILabel *loadingTitle;
@property (weak, nonatomic) IBOutlet UILabel *detailLog;
@property (weak, nonatomic) IBOutlet UIImageView *remoteBg1;
@property (weak, nonatomic) IBOutlet UIImageView *remoteBg2;

@property (nonatomic,strong)NSMutableArray <NSString *>*nearRemote;

@property (weak, nonatomic) IBOutlet UIView *animationView;


@end

static NSString *const targetName=@"IrRemoteControllerA";

@implementation ScaningController

-(NSMutableArray<NSString *> *)nearRemote
{
    if (!_nearRemote) {
        _nearRemote=[NSMutableArray array];
    }
    return _nearRemote;
}


- (void)viewDidLoad {
    [super viewDidLoad];
    [self loadUIView];
    [self loadBluetooth];
    
    // Do any additional setup after loading the view.
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    AppDelegate *app = (AppDelegate *) [[UIApplication sharedApplication] delegate];
    if (!app.autoScan.valid) {
        app.autoScan = [NSTimer scheduledTimerWithTimeInterval:1.5 target:self selector:@selector(autoScan:) userInfo:nil repeats:YES];
        [app.autoScan fire];
    }
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    AppDelegate *app = (AppDelegate *) [[UIApplication sharedApplication] delegate];
    if (app.autoScan.valid) {
        [app.autoScan invalidate];
    }
    [[BluetoothManager getInstance] removeObserver:self forKeyPath:@"peripheralsInfo"];
}

-(void)loadUIView
{
    [self animationOfScaning];
//    CABasicAnimation *anima1=[CABasicAnimation animationWithKeyPath:@"opacity"];
//    anima1.fromValue=@1.0;
//    anima1.toValue=@0.0;
//    anima1.duration=1.0;
//    anima1.beginTime=1;
//    CABasicAnimation *anima2 = [CABasicAnimation animationWithKeyPath:@"transform.scale"];
//    anima2.fromValue=@0.0;
//    anima2.toValue=@10.0;
//    anima2.duration=2.0;
//    anima2.beginTime=1;
//    anima2.timingFunction=[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseIn];
//    CAAnimationGroup *group = [CAAnimationGroup animation];
//    group.delegate = self;
//    group.duration = 3.0;
//    group.repeatCount = 100;
//    group.removedOnCompletion=NO;
//    group.fillMode=kCAFillModeForwards;
//    group.animations=@[anima2,anima1];
//    [self.scanBtn.layer addAnimation:group forKey:@"test"];
    
}

-(void)animationOfScaning
{
    NSURL *url1 = [[NSBundle mainBundle] URLForResource:@"searching" withExtension:@"gif"];
    animationImage = [FLAnimatedImage animatedImageWithGIFData:[NSData dataWithContentsOfURL:url1]];
    animationImageView = [[FLAnimatedImageView alloc] init] ;
    animationImageView.animatedImage = animationImage;
    animationImageView.frame = CGRectMake(self.view.center.x-self.view.frame.size.width*0.9/2, self.view.center.y*0.6, self.view.frame.size.width*0.9, self.view.frame.size.width*256/750*0.9);
    
    [self.view addSubview:animationImageView];
}


-(void)endScaning
{
    self.loadingTitle.text= NSLocalizedString(@"设备搜索成功", @"设备搜索成功");
    self.detailLog.text= NSLocalizedString(@"请点击下一步", @"请点击下一步");
    self.remoteBg1.alpha=1.0;
    self.remoteBg2.alpha=1.0;
    animationImageView.alpha=0;
}

/**
 * 动画开始时
 */
- (void)animationDidStart:(CAAnimation *)theAnimation
{
    NSLog(@"begin");
}

/**
 * 动画结束时
 */
- (void)animationDidStop:(CAAnimation *)theAnimation finished:(BOOL)flag
{
    NSLog(@"end");
}

-(void)loadBluetooth
{
    [[BluetoothManager getInstance]addObserver:self forKeyPath:@"peripheralsInfo" options:NSKeyValueObservingOptionOld context:nil];;
}

- (void)autoScan:(id)sender {
    [[BluetoothManager getInstance] scanPeriherals:NO AllowPrefix:@[@(ScanTypeAll)]];
}


- (IBAction)bindingLater:(UIButton *)sender {
    [self performSegueWithIdentifier:@"showMain" sender:nil];
}

-(void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context
{
    if ([keyPath isEqualToString:@"peripheralsInfo"]) {
        [[BluetoothManager getInstance].peripheralsInfo enumerateObjectsUsingBlock:
         ^(__kindof NSDictionary * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop)
         {
             NSString *deviceName=obj[AdvertisementData][@"kCBAdvDataLocalName"];
             if ([deviceName containsString:targetName]) {
                 if (![self.nearRemote containsObject:deviceName]) {
                     [self.nearRemote addObject:deviceName];
                 }
                 if (self.nearRemote.count==1) {
                     CBPeripheral *peripheral=obj[Peripheral];
                     NSString *uuid= peripheral.identifier.UUIDString;
                     [[NSUserDefaults standardUserDefaults]setObject:uuid forKey:@"CurrentDevice"];
                     
                     [[NSUserDefaults standardUserDefaults]synchronize];
                     [self moveToMain];
                 }
             }
         }];
    }
}

- (IBAction)toMain:(UIButton *)sender {
    [[NSUserDefaults standardUserDefaults]setBool:YES forKey:@"Selected"];
    [self performSegueWithIdentifier:@"showMain" sender:nil];
}


-(void)moveToMain
{
    [UIView animateWithDuration:1 delay:0 options:UIViewAnimationOptionCurveEaseIn animations:^{
        [self endScaning];
    } completion:^(BOOL finished) {
        self.toMainBtn.enabled=YES;
    }];
}

-(void)dealloc
{
//    [self removeObserver:self forKeyPath:@"peripheralsInfo"];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
