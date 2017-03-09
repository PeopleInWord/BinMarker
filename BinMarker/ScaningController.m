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
@interface ScaningController ()
@property (weak, nonatomic) IBOutlet UIButton *toMainBtn;
@property (weak, nonatomic) IBOutlet UIButton *scanBtn;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *loading;
@property (weak, nonatomic) IBOutlet UILabel *loadingTitle;
@property (nonatomic,strong)NSMutableArray <NSString *>*nearRemote;
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
    self.toMainBtn.layer.cornerRadius=20.0;
    self.toMainBtn.layer.borderWidth=2.0;
    self.scanBtn.layer.cornerRadius=25.0;
    [self.loading startAnimating];
}
-(void)loadBluetooth
{
    [[BluetoothManager getInstance]addObserver:self forKeyPath:@"peripheralsInfo" options:NSKeyValueObservingOptionOld context:nil];;
}

- (void)autoScan:(id)sender {
    [[BluetoothManager getInstance] scanPeriherals:NO AllowPrefix:@[@(ScanTypeAll)]];
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
                     [self moveToMain];
                     [self.loading stopAnimating];
                     [[NSUserDefaults standardUserDefaults]setObject:self.nearRemote[0] forKey:@"CurrentDevice"];
                     [[NSUserDefaults standardUserDefaults]synchronize];
                 }
             }
         }];
    }
}

- (IBAction)toMain:(UIButton *)sender {
    [self performSegueWithIdentifier:@"showMain" sender:nil];
}


-(void)moveToMain
{
    [UIView animateWithDuration:0.3 delay:1 options:UIViewAnimationOptionCurveEaseIn animations:^{
        self.scanBtn.alpha=1.0;
        self.loadingTitle.alpha=0.0;
    } completion:^(BOOL finished) {
        
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
