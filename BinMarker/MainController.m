//
//  MainController.m
//  BinMarker
//
//  Created by 彭子上 on 2016/11/17.
//  Copyright © 2016年 彭子上. All rights reserved.
//

#import "MainController.h"
#import "ReactiveObjC.h"
#import "BinMarker-swift.h"
#import "FTPopOverMenu.h"
#import "BluetoothManager.h"
#import "AppDelegate.h"


static NSString *const targetName=@"IrRemoteControllerA";

@interface MainController ()<UITableViewDelegate,UITableViewDataSource,UIDocumentInteractionControllerDelegate,UIApplicationDelegate>
@property (weak, nonatomic) IBOutlet UITableView *mainTableView;
@property (strong,nonatomic)NSMutableArray <NSDictionary <NSString *,id>*>*alldevices;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *testItem;
@property (nonatomic, strong) UIDocumentInteractionController *documentController;
@property (weak, nonatomic) IBOutlet UIButton *selectDevice;

@end


@implementation MainController

-(NSMutableArray< NSDictionary<NSString *, id> *> *)alldevices
{
    if (!_alldevices) {
        _alldevices=[NSMutableArray arrayWithArray:[[NSUserDefaults standardUserDefaults]objectForKey:@"deviceInfo"]];
    }
    return _alldevices;
}

-(NSMutableArray<NSString *> *)nearRemote
{
    if (!_nearRemote) {
        _nearRemote=[NSMutableArray array];
    }
    return _nearRemote;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self loadBluetooth];
        // Do any additional setup after loading the view.
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    _alldevices=nil;
    [self.mainTableView reloadData];
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
}



- (void)autoScan:(id)sender {
    [[BluetoothManager getInstance] scanPeriherals:NO AllowPrefix:@[@(ScanTypeAll)]];
}


-(void)loadBluetooth
{
    [[BluetoothManager getInstance]addObserver:self forKeyPath:@"peripheralsInfo" options:NSKeyValueObservingOptionOld context:nil];;
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
                    [self.selectDevice setTitle:deviceName forState:UIControlStateNormal];
                    [[NSUserDefaults standardUserDefaults]setObject:self.nearRemote[0] forKey:@"CurrentDevice"];
                    [[NSUserDefaults standardUserDefaults]synchronize];
                }
            }
        }];
    }
}

- (IBAction)chooseRemote:(UIButton *)sender {
    [FTPopOverMenuConfiguration defaultConfiguration].menuWidth=180;
    [FTPopOverMenu showForSender:sender withMenuArray:self.nearRemote doneBlock:^(NSInteger selectedIndex) {
        [sender setTitle:self.nearRemote[selectedIndex] forState:UIControlStateNormal];
        [[NSUserDefaults standardUserDefaults]setObject:self.nearRemote[selectedIndex] forKey:@"CurrentDevice"];
        [[NSUserDefaults standardUserDefaults]synchronize];
    } dismissBlock:^{
        
    }];
    
    
}



- (IBAction)addDevice:(UIButton *)sender {
    if (self.alldevices.count<4) {
        [self performSegueWithIdentifier:@"addDevice" sender:nil];
    }
    else
    {
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"错误" message:@"最多添加4个设备,请删除多余的设备" preferredStyle: UIAlertControllerStyleAlert];
        UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil];
        [alertController addAction:cancelAction];
        [self presentViewController:alertController animated:YES completion:nil];
    }
}

- (IBAction)buildingBin:(UIButton *)sender {
    self.alldevices=[self addIndex:self.alldevices];
    BinMakeManger *manger=[BinMakeManger shareInstance];
    NSString *binPath=[manger makeTypeWith:self.alldevices];
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"成功" message:@"下一步,用Starter打开" preferredStyle: UIAlertControllerStyleAlert];
    UIAlertAction *OKAction = [UIAlertAction actionWithTitle:@"用刷固件软件打开" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [self openWithPath:[NSURL fileURLWithPath:binPath]];
    }];
    [alertController addAction:OKAction];
    [self presentViewController:alertController animated:YES completion:nil];
}

-(void)openWithPath:(NSURL *)url
{
    _documentController=[UIDocumentInteractionController interactionControllerWithURL:url];
    _documentController.delegate=self;
    [_documentController presentOptionsMenuFromRect: CGRectMake(self.view.frame.size.width/2,self.view.frame.size.height/2, 0.0, 0.0) inView:self.view animated:YES];
}


-(void)documentInteractionControllerWillPresentOpenInMenu:(UIDocumentInteractionController *)controller
{
    NSLog(@"documentInteractionControllerWillPresentOpenInMenu");
}

-(void)documentInteractionControllerWillPresentOptionsMenu:(UIDocumentInteractionController *)controller
{
    NSLog(@"documentInteractionControllerWillPresentOptionsMenu");
}

-(void)documentInteractionControllerDidEndPreview:(UIDocumentInteractionController *)controller
{
    NSLog(@"documentInteractionControllerDidEndPreview");
}

-(void)documentInteractionController:(UIDocumentInteractionController *)controller willBeginSendingToApplication:(NSString *)application
{
    NSLog(@"willBeginSendingToApplication");
}


-(NSMutableArray *)addIndex:(NSMutableArray < NSDictionary<NSString *, id> *> *)array
{
    NSMutableArray *tempArray=[NSMutableArray arrayWithArray:array];
    [tempArray enumerateObjectsUsingBlock:^(NSDictionary<NSString *,id> * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        NSMutableDictionary *temp=[NSMutableDictionary dictionaryWithDictionary:obj];
        temp[@"index"]=@(idx);
        array[idx]=temp;
    }];
    return array;
}


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return (self.view.bounds.size.height-64)/5;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.alldevices.count+1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell=nil;
    if (indexPath.row<self.alldevices.count) {
        NSDictionary *subDic=_alldevices[indexPath.row];
        NSDictionary *imageDic=@{@"TV":@"icon_tv",@"DVD":@"icon_dvd",@"COMBI":@"icon_amp",@"SAT":@"icon_box"};
        cell=[tableView dequeueReusableCellWithIdentifier:@"brandcell" forIndexPath:indexPath];
        UIImageView *iconImage=[cell viewWithTag:1001];
        UILabel *deviceType=[cell viewWithTag:1002];
        UILabel *brandName=[cell viewWithTag:1003];
        UILabel *brandType=[cell viewWithTag:1004];
        iconImage.image=[UIImage imageNamed:imageDic[subDic[@"deviceType"]]];
        deviceType.text=subDic[@"deviceType"];
        brandName.text=subDic[@"brandName"];
        brandType.text=subDic[@"versionName"];
    }
    else
    {
        cell=[tableView dequeueReusableCellWithIdentifier:@"empty" forIndexPath:indexPath];
        UIButton *btn=[cell viewWithTag:1000];
        btn.tag=10000+indexPath.row;
        
    }
    return cell;
}

-(BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    return indexPath.row==_alldevices.count?NO:YES;
}

-(void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle ==UITableViewCellEditingStyleDelete) {
        [_alldevices removeObjectAtIndex:indexPath.row];
        if (_alldevices.count==4) {
            [tableView reloadData];
        }
        else
        {
            [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
        }
        
        [[NSUserDefaults standardUserDefaults]setObject:_alldevices forKey:@"deviceInfo"];
    }
}

-(NSString *)tableView:(UITableView *)tableView titleForDeleteConfirmationButtonForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return @"删除这一条";
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}


@end
