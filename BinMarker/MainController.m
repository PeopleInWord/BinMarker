//
//  MainController.m
//  BinMarker
//
//  Created by 彭子上 on 2016/11/17.
//  Copyright © 2016年 彭子上. All rights reserved.
//

#import "MainController.h"
#import "BinMarker-Swift.h"
#import "UIImageView+WebCache.h"
#import "UIImage+MultiFormat.h"
#import "AppDelegate.h"
#import "MJRefresh.h"
static NSString *const targetName=@"IrRemoteControllerA";

@interface MainController ()<UIDocumentInteractionControllerDelegate,UIApplicationDelegate,UITableViewDelegate,UITableViewDataSource,LoginDelegate,UserDelegate>
@property (weak, nonatomic) IBOutlet UITableView *mainTableView;
@property (weak, nonatomic) IBOutlet UIButton *noneBtn;
@property (weak, nonatomic) IBOutlet UINavigationItem *navTitle;
@property (weak, nonatomic) IBOutlet UIVisualEffectView *noneView;
@property (strong,nonatomic) NSMutableArray <DeviceInfo *>*alldevices;
@property (strong,nonatomic) UIDocumentInteractionController *documentController;
@property (strong,nonatomic) UserInfo *user;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *barLeft;

@end


@implementation MainController

-(UserInfo *)user
{
    if (!_user) {
        _user=[[FMDBFunctions shareInstance]getUserDataWithTargetParameters:@"isLogin" content:@(YES)].firstObject;
        AppDelegate *app=(AppDelegate *)[UIApplication sharedApplication].delegate;
        app.user=_user;
        
    }
    return _user;
}

-(NSMutableArray<DeviceInfo *> *)alldevices
{
    if (!_alldevices) {
        _alldevices=[FMDBFunctions.shareInstance getAllData].mutableCopy;
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
    __weak MainController * weakself = self;
    
    
    MJRefreshNormalHeader *header = [MJRefreshNormalHeader headerWithRefreshingBlock:^{
        [CommonFunction startAnimation:@"同步中" :@""];
        HTTPFuntion *manger=[[HTTPFuntion alloc]init];
        [manger getAllChangeWith:weakself.user :^{
            _alldevices=nil;
            dispatch_async(dispatch_get_main_queue(), ^{
                [ weakself.mainTableView reloadData];
                _noneView.hidden=  weakself.alldevices.count != 0;
            });
            [CommonFunction stopAnimation:@"同步成功" :@"" :1];
            [ weakself.mainTableView.mj_header endRefreshing];
        } :^{
            [CommonFunction stopAnimation:@"同步失败" :@"" :2];
            NSLog(@"错误");
            [ weakself.mainTableView.mj_header endRefreshing];
        }];
        
    }];
    
    [header setTitle:@"下拉刷新数据" forState:MJRefreshStateIdle];
    [header setTitle:@"松开刷新数据" forState:MJRefreshStatePulling];
    [header setTitle:@"正在刷新数据" forState:MJRefreshStateRefreshing];
    
    self.mainTableView.mj_header = header;
    if (self.user) {
        [header beginRefreshing];
    }
    
    
    [[BluetoothManager getInstance] scanPeriherals:NO AllowPrefix:@[@(ScanTypeAll)]];
    
    if (self.user) {
        SDWebImageManager *manger=[SDWebImageManager sharedManager];
        NSURL *imageUrl=[NSURL URLWithString:[NSString stringWithFormat:@"http://120.76.74.87/PMSWebService/services/%@",self.user.photoAddress]];
        [manger loadImageWithURL:imageUrl options:SDWebImageHighPriority progress:^(NSInteger receivedSize, NSInteger expectedSize, NSURL * _Nullable targetURL) {
            
        } completed:^(UIImage * _Nullable image, NSData * _Nullable data, NSError * _Nullable error, SDImageCacheType cacheType, BOOL finished, NSURL * _Nullable imageURL) {
            if (image) {
                _barLeft.image=image;
            }
        }];
    } 

    [self.navigationController.navigationBar setTitleTextAttributes:@{NSForegroundColorAttributeName:[UIColor whiteColor]}];
    [self.navigationController.navigationItem.backBarButtonItem setTintColor:[UIColor whiteColor]];
    [self.navigationController.navigationBar setTintColor:[UIColor whiteColor]];
}

#pragma mark 视图

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
//    BOOL isChildrenMode =  [[NSUserDefaults standardUserDefaults]boolForKey:@"isChildrenMode"];
//    
//    if (isChildrenMode) {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            __block BOOL isContain = NO;
            [NSThread sleepForTimeInterval:0.5];
            dispatch_async(dispatch_get_main_queue(), ^{
                [[[FMDBFunctions shareInstance]getAllData] enumerateObjectsUsingBlock:^(DeviceInfo * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                    NSString *defalutDeviceID =  [[NSUserDefaults standardUserDefaults]stringForKey:@"DefaultDevice"];
                    if (!defalutDeviceID) {
                        return ;
                    }
                    if ([obj.deviceID isEqualToString:defalutDeviceID]) {
                        *stop = YES;
                        isContain = YES;
                        [self performSegueWithIdentifier:@"main2children" sender:obj];
                    }
                }];
                if (!isContain) {
                    [[NSUserDefaults standardUserDefaults]setBool:NO forKey:@"isChildrenMode"];
                }
            });
        });
//    }
    _alldevices=nil;
    [self.mainTableView reloadData];
    _noneView.hidden= self.alldevices.count != 0;
    
    
    
    
}

#pragma mark 托线


- (IBAction)userInfo:(UIBarButtonItem *)sender {
    BOOL isLogin= [[NSUserDefaults standardUserDefaults]objectForKey:@"isLogin"];
    if (!isLogin) {
        [self performSegueWithIdentifier:@"loginIn" sender:nil];
    } else {
        [self performSegueWithIdentifier:@"userInfo" sender:self.user];
    }
}


-(void)loadBluetooth
{
    [[BluetoothManager getInstance]addObserver:self forKeyPath:@"peripheralsInfo" options:NSKeyValueObservingOptionOld context:nil];
    
}

- (IBAction)didClickVoice:(UIButton *)sender {
    NSString *defaultDevice = [[NSUserDefaults standardUserDefaults]stringForKey:@"defaultDevice"];
    if (defaultDevice) {
        DeviceInfo *device = [FMDBFunctions.shareInstance getSelectDataWithTable:@"T_DeviceInfo" targetParameters:@"DeviceID" content:defaultDevice].firstObject;
        if (device) {
            [self performSegueWithIdentifier:@"mainVoice" sender:device];
        }
        else
        {
            [[NSUserDefaults standardUserDefaults]removeObjectForKey:@"defaultDevice"];
            NSArray *tvList = [FMDBFunctions.shareInstance getSelectDataWithTable:@"T_DeviceInfo" targetParameters:@"devicetype" content:@"TV"];
            [self performSegueWithIdentifier:@"setdefault" sender:tvList];
        }
        
        //进入语音界面
    } else {
        
        NSArray *tvList = [FMDBFunctions.shareInstance getSelectDataWithTable:@"T_DeviceInfo" targetParameters:@"devicetype" content:@"TV"];
        [self performSegueWithIdentifier:@"setdefault" sender:tvList];
    }
}



- (IBAction)didClickSetting:(UIBarButtonItem *)sender event:(UIEvent *)event{
    [FTPopOverMenuConfiguration defaultConfiguration].menuWidth=100;
    [FTPopOverMenu showFromEvent:event withMenuArray:@[NSLocalizedString(@"添加设备", @"添加设备顶部"), NSLocalizedString(@"寻找设备", @"寻找设备"), NSLocalizedString(@"设置", @"设置"), NSLocalizedString(@"当前版本", @"当前版本")] doneBlock:^(NSInteger selectedIndex) {
        switch (selectedIndex) {
            case 0:
            {
                BOOL isLogin= [[NSUserDefaults standardUserDefaults]objectForKey:@"isLogin"];
                if (!isLogin) {
                    [self performSegueWithIdentifier:@"loginIn" sender:nil];
                }
                else
                {
                    [self performSegueWithIdentifier:@"addDevice" sender:nil];
                }
                
            }
                break;
            case 1:
                [self foundRemote];
                break;
            case 2:
                [self performSegueWithIdentifier:@"setting" sender:nil];
                break;
            default:
                break;
        }
    }               dismissBlock:^{
        
    }];
}

- (void)foundRemote {
    NSString *codeStr=[[BinMakeManger shareInstance] foundCommand];
    [CommonFunction startAnimation:NSLocalizedString(@"寻找遥控器中", @"寻找遥控器中") :nil];
    [[BluetoothManager getInstance]sendByteCommandWithString:codeStr deviceID:@"IrRemoteControllerA" sendType:SendTypeRemoteTemp success:^(NSData * _Nullable stateData) {
        [CommonFunction stopAnimation:NSLocalizedString(@"命令发送成功", @"命令发送成功") :nil :1];
    } fail:^NSUInteger(NSString * _Nullable stateCode) {
        [CommonFunction stopAnimation:NSLocalizedString(@"命令发送失败", @"命令发送失败") :nil :1];
        return 0;
    }];
}

- (IBAction)addDevice:(UIButton *)sender {
    BOOL isLogin= [[NSUserDefaults standardUserDefaults]objectForKey:@"isLogin"];
    if (!isLogin) {
        [self performSegueWithIdentifier:@"loginIn" sender:nil];
    }
    else
    {
        [self performSegueWithIdentifier:@"addDevice" sender:nil];
    }
//    [self performSegueWithIdentifier:@"addDevice" sender:nil];
}

- (IBAction)buildingBin:(UIButton *)sender {
    //    self.alldevices=[self addIndex:self.alldevices];
    //    BinMakeManger *manger=[BinMakeManger shareInstance];
    //    NSString *binPath=[manger makeTypeWith:self.alldevices];
    //    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"成功" message:@"下一步,用Starter打开" preferredStyle: UIAlertControllerStyleAlert];
    //    UIAlertAction *OKAction = [UIAlertAction actionWithTitle:@"用刷固件软件打开" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
    //        [self openWithPath:[NSURL fileURLWithPath:binPath]];
    //    }];
    //    [alertController addAction:OKAction];
    //    [self presentViewController:alertController animated:YES completion:nil];
}

-(void)openWithPath:(NSURL *)url
{
    _documentController=[UIDocumentInteractionController interactionControllerWithURL:url];
    _documentController.delegate=self;
    [_documentController presentOptionsMenuFromRect: CGRectMake(self.view.frame.size.width/2,self.view.frame.size.height/2, 0.0, 0.0) inView:self.view animated:YES];
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

#pragma mark 表格

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSArray *deviceTypeArray=@[@"TV",@"DVD",@"COMBI",@"SAT"];
    NSUInteger rowCount = [FMDBFunctions.shareInstance returnSectionRowCountWithParameters:@"devicetype" content:deviceTypeArray[indexPath.section]];
    return rowCount==0?0:100;
}

-(CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    NSArray *deviceTypeArray=@[@"TV",@"DVD",@"COMBI",@"SAT"];
    NSUInteger rowCount = [FMDBFunctions.shareInstance returnSectionRowCountWithParameters:@"devicetype" content:deviceTypeArray[section]];
    return  rowCount==0?0:10;
}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return section==0?10:0;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSArray *deviceTypeArray=@[@"TV",@"DVD",@"COMBI",@"SAT"];
    NSUInteger rowCount = [FMDBFunctions.shareInstance returnSectionRowCountWithParameters:@"devicetype" content:deviceTypeArray[section]];
    
    return rowCount;
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 4;
}



- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell;
    NSArray *deviceTypeArray=@[@"TV",@"DVD",@"COMBI",@"SAT"];
    NSUInteger rowCount = [FMDBFunctions.shareInstance returnSectionRowCountWithParameters:@"devicetype" content:deviceTypeArray[indexPath.section]];
    if (rowCount==0) {
        cell=[tableView dequeueReusableCellWithIdentifier:@"noneCell" forIndexPath:indexPath];
    } else {
        cell=[tableView dequeueReusableCellWithIdentifier:@"brandcell" forIndexPath:indexPath];
        NSArray *deviceArray =[[FMDBFunctions shareInstance]getSelectDataWithTable:@"T_DeviceInfo" targetParameters:@"deviceType" content:deviceTypeArray[indexPath.section]];
        DeviceInfo *device=deviceArray[indexPath.row];
        NSDictionary *imageDic=@{@"TV":@"icon_TV",@"DVD":@"icon_DVD",@"COMBI":@"icon_AMP",@"SAT":@"icon_BOX"};
        UIImageView *iconImage=[cell viewWithTag:1001];
        UILabel *brandName=[cell viewWithTag:1003];
        UILabel *codeName=[cell viewWithTag:1004];
        codeName.text= [NSString stringWithFormat:NSLocalizedString(@"码组号:%@", @"码组号:%@"), device.code];
        iconImage.image=[UIImage imageNamed:imageDic[device.devicetype]];
        brandName.text=[device.customname length]>0?device.customname:device.brandname;
    }
    
    
    return cell;
}

-(void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    CABasicAnimation *animation= [CABasicAnimation animationWithKeyPath:@"opacity"];
    animation.fromValue = @0;
    animation.toValue = @1;
    animation.duration = 1;
    [cell.layer addAnimation:animation forKey:@"ddd"];
    
}



-(BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    return YES;
}


- (NSArray<UITableViewRowAction *> *)tableView:(UITableView *)tableView editActionsForRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewRowAction *deleteAction;
    deleteAction = [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleDestructive title:@"删除" handler:^(UITableViewRowAction * _Nonnull action, NSIndexPath * _Nonnull indexPath) {
        NSArray *deviceTypeArray=@[@"TV",@"DVD",@"COMBI",@"SAT"];
        NSArray *deviceArray =[[FMDBFunctions shareInstance]getSelectDataWithTable:@"T_DeviceInfo" targetParameters:@"deviceType" content:deviceTypeArray[indexPath.section]];
        DeviceInfo *device=deviceArray[indexPath.row];
        [FMDBFunctions.shareInstance delDataWithTable:@"T_DeviceInfo" parameters:@"deviceID" :device.deviceID success:^{
            
        } fail:^{
            
        }];
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
        
        if (self.user) {
            HTTPFuntion *updata = [[HTTPFuntion alloc]init];
            [updata uploadAllDataWithUser:self.user success:^{
                [CommonFunction showForShortTime:0.5 :@"更新成功" :@""];
            } fail:^{
                [CommonFunction showForShortTime:1.5 :@"更新失败" :@""];
            }];
        }
        
        if ([[FMDBFunctions shareInstance] getAllData].count==0) {
            _noneView.hidden=NO;
        }
    }];
    UITableViewRowAction *editAction = [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleNormal title:NSLocalizedString(@"编辑", @"编辑") handler:^(UITableViewRowAction *_Nonnull action, NSIndexPath *_Nonnull indexPath) {
        NSArray *deviceTypeArray=@[@"TV",@"DVD",@"COMBI",@"SAT"];
        NSArray *deviceArray =[[FMDBFunctions shareInstance]getSelectDataWithTable:@"T_DeviceInfo" targetParameters:@"deviceType" content:deviceTypeArray[indexPath.section]];
        DeviceInfo *device=deviceArray[indexPath.row];
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"名称", @"名称") message:NSLocalizedString(@"输入设备名称", @"输入设备名称") preferredStyle:UIAlertControllerStyleAlert];
        [alertController addTextFieldWithConfigurationHandler:^(UITextField *_Nonnull textField) {
            textField.text=[device.customname length]>1?device.customname:device.brandname;
        }];
        [alertController addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"确定", @"确定") style:UIAlertActionStyleDefault handler:^(UIAlertAction *_Nonnull action) {
            device.customname=alertController.textFields.firstObject.text.length > 0?alertController.textFields.firstObject.text:device.brandname;
            [FMDBFunctions.shareInstance setDataWithTable:@"T_DeviceInfo" targetParameters:@"customname" targetContent:device.customname parameters:@"deviceID" content:device.deviceID];//更新
            
            if (self.user) {
                HTTPFuntion *updata = [[HTTPFuntion alloc]init];
                [updata uploadAllDataWithUser:self.user success:^{
                    [CommonFunction showForShortTime:0.5 :@"更新成功" :@""];
                } fail:^{
                    [CommonFunction showForShortTime:1.5 :@"更新失败" :@""];
                }];
            }
            
            
            
            [tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
        }]];
        [alertController addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"取消", @"取消") style:UIAlertActionStyleCancel handler:^(UIAlertAction *_Nonnull action) {
            [tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
        }]];
        [self presentViewController:alertController animated:YES completion:nil];
    }];
    editAction.backgroundColor = [UIColor blueColor];
    return @[deleteAction, editAction];
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSArray *deviceTypeArray=@[@"TV",@"DVD",@"COMBI",@"SAT"];
    NSArray *deviceArray =[[FMDBFunctions shareInstance]getSelectDataWithTable:@"T_DeviceInfo" targetParameters:@"deviceType" content:deviceTypeArray[indexPath.section]];
    DeviceInfo *deviceInfo=deviceArray[indexPath.row];
    NSString *deviceType=deviceInfo.devicetype;
    if ([deviceType isEqualToString:@"TV"]) {
        [self performSegueWithIdentifier:@"tv" sender:deviceInfo];
    }
    else if ([deviceType isEqualToString:@"DVD"]){
        [self performSegueWithIdentifier:@"dvd" sender:deviceInfo];
    }
    else if ([deviceType isEqualToString:@"COMBI"]){
        [self performSegueWithIdentifier:@"amp" sender:deviceInfo];
    }
    else if ([deviceType isEqualToString:@"SAT"]){
        [self performSegueWithIdentifier:@"box" sender:deviceInfo];
    }
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
#pragma mark -login
-(void)didLoginWithUser:(UserInfo *)user
{
    
    [[NSUserDefaults standardUserDefaults]setBool:YES forKey:@"isLogin"];
    [[FMDBFunctions shareInstance]setDataWithTable:@"T_UserInfo" targetParameters:@"isLogin" targetContent:@(YES) parameters:@"mobile" content:user.mobile];
    self.user=user;
    AppDelegate *app=(AppDelegate *)[UIApplication sharedApplication].delegate;
    app.user=_user;
    SDWebImageManager *manger=[SDWebImageManager sharedManager];
    NSURL *imageUrl=[NSURL URLWithString:[NSString stringWithFormat:@"http://120.76.74.87/PMSWebService/services/%@",self.user.photoAddress]];
    [manger loadImageWithURL:imageUrl options:SDWebImageHighPriority progress:^(NSInteger receivedSize, NSInteger expectedSize, NSURL * _Nullable targetURL) {
        
    } completed:^(UIImage * _Nullable image, NSData * _Nullable data, NSError * _Nullable error, SDImageCacheType cacheType, BOOL finished, NSURL * _Nullable imageURL) {
        if (image) {
            _barLeft.image=image;
        }
    }];
    
//    UIAlertController *alert=[UIAlertController alertControllerWithTitle:@"导入数据" message:@"是否导入当前数据" preferredStyle:UIAlertControllerStyleAlert];
//    [alert addAction:[UIAlertAction actionWithTitle:@"是(网络数据与本地合并)" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
//        [CommonFunction startAnimation:@"同步中" :@""];
//        [FMDBFunctions.shareInstance syncDataWith:self.user successSync:^{//首先把本地库转换
//            HTTPFuntion *manger=[[HTTPFuntion alloc]init];
//            [manger getAllChangeWith:self.user :^{//下载网络库
//                [manger uploadAllDataWithUser:self.user success:^{//合并两库
//                    [CommonFunction stopAnimation:@"同步成功" :@"" :2];
//                    _alldevices=nil;
//                    dispatch_async(dispatch_get_main_queue(), ^{
//                        [self.mainTableView reloadData];
//                        _noneView.hidden= self.alldevices.count != 0;
//                    });
//                    
//                } fail:^{
//                    [CommonFunction stopAnimation:@"同步失败" :@"" :2];
//                }];
//            } :^{
//                [CommonFunction stopAnimation:@"同步失败" :@"" :2];
//                NSLog(@"错误");
//            }];
//        } failSync:^{
//            
//        }];
//        
//        
//    }]];
//    [alert addAction:[UIAlertAction actionWithTitle:@"否(本地数据删除)" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
//        [FMDBFunctions.shareInstance delAllWithSuccess:^{
//            
//        } fail:^{
//            
//        }];//多一步删除
//        
//        HTTPFuntion *manger=[[HTTPFuntion alloc]init];
//        [manger getAllChangeWith:self.user :^{
//            [CommonFunction showForShortTime:0.5 :@"更新成功" :@""];
//            _alldevices=nil;
//            dispatch_async(dispatch_get_main_queue(), ^{
//                [self.mainTableView reloadData];
//                _noneView.hidden= self.alldevices.count != 0;
//            });
//        } :^{
//            [CommonFunction showForShortTime:1.5 :@"更新失败" :@""];
//        }];
//    }]];
//    
//    [self presentViewController:alert animated:YES completion:^{
//        
//    }];
    HTTPFuntion *mangerhttp=[[HTTPFuntion alloc]init];
    [mangerhttp getAllChangeWith:self.user :^{
        [CommonFunction showForShortTime:0.5 :@"更新成功" :@""];
        _alldevices=nil;
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.mainTableView reloadData];
            _noneView.hidden= self.alldevices.count != 0;
        });
    } :^{
        [CommonFunction showForShortTime:1.5 :@"更新失败" :@""];
    }];
    
}

-(void)didUnLogin
{
    [[FMDBFunctions shareInstance] delAllWithSuccess:^{
        _alldevices=nil;
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.mainTableView reloadData];
            _noneView.hidden= self.alldevices.count != 0;
            self.user=nil;
            AppDelegate *app=(AppDelegate *)[UIApplication sharedApplication].delegate;
            app.user=nil;
            [[NSUserDefaults standardUserDefaults]removeObjectForKey:@"DefaultDevice"];
            [[NSUserDefaults standardUserDefaults]removeObjectForKey:@"isChildrenMode"];
        });
    } fail:^{
        
    }];
}

#pragma mark - Navigation


// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"tv"]) {
        TVController *target=segue.destinationViewController;
        target.favoriteDB=[[FMDBFunctions shareInstance]getChannelDataWith:sender];
        target.deviceInfo=sender;
        target.user=self.user;
    }
    else if ([segue.identifier isEqualToString:@"dvd"]){
        DVDController *target=segue.destinationViewController;
        target.deviceInfo=sender;
    }
    else if ([segue.identifier isEqualToString:@"amp"]){
        AMPController *target=segue.destinationViewController;
        target.deviceInfo=sender;
    }
    else if ([segue.identifier isEqualToString:@"box"]){
        BOXController *target=segue.destinationViewController;
        target.favoriteDB=[[FMDBFunctions shareInstance]getChannelDataWith:sender];
        target.deviceInfo=sender;
        target.user=self.user;
    }
    else if ([segue.identifier isEqualToString:@"loginIn"]){
        LoginController *target=segue.destinationViewController;
        target.delegate=self;
    }
    else if ([segue.identifier isEqualToString:@"userInfo"]){
        UserInfoController *target=segue.destinationViewController;
        target.delegate=self;
        target.user=sender;
        target.userPic.image=_barLeft.image;
    }
    else if ([segue.identifier isEqualToString:@"main2children"]){
        ChildrenModeController *target = segue.destinationViewController;
        target.device = sender;
    }
    else if ([segue.identifier isEqualToString:@"setdefault"]){
        DefaultDeviceController *target = segue.destinationViewController;
        target.deviceList = sender;
    }
    else if ([segue.identifier isEqualToString:@"mainVoice"]){
        VoiceController *target = segue.destinationViewController;
        target.device = sender;
    }
}


@end
