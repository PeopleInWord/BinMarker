//
//  MainController.m
//  BinMarker
//
//  Created by 彭子上 on 2016/11/17.
//  Copyright © 2016年 彭子上. All rights reserved.
//

#import "MainController.h"
#import "BinMarker-swift.h"
#import "FTPopOverMenu.h"
#import "BluetoothManager.h"
#import "AppDelegate.h"
#import "MBProgressHUD.h"

static NSString *const targetName=@"IrRemoteControllerA";

@interface MainController ()<UIDocumentInteractionControllerDelegate,UIApplicationDelegate>
@property (weak, nonatomic) IBOutlet UITableView *mainTableView;
@property (weak, nonatomic) IBOutlet UIButton *noneBtn;
@property (weak, nonatomic) IBOutlet UINavigationItem *navTitle;
@property (weak, nonatomic) IBOutlet UIVisualEffectView *noneView;
@property (strong,nonatomic)NSMutableArray <NSDictionary <NSString *,id>*>*alldevices;
@property (nonatomic, strong) UIDocumentInteractionController *documentController;
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
    [self.navigationController.navigationBar setTitleTextAttributes:@{NSForegroundColorAttributeName:[UIColor whiteColor]}];
    [self.navigationController.navigationItem.backBarButtonItem setTintColor:[UIColor whiteColor]];
    [self.navigationController.navigationBar setTintColor:[UIColor whiteColor]];
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    _alldevices=nil;
    [self.mainTableView reloadData];
    _noneView.hidden=self.alldevices.count==0?NO:YES;
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
    [[BluetoothManager getInstance]addObserver:self forKeyPath:@"peripheralsInfo" options:NSKeyValueObservingOptionOld context:nil];
    NSLog(@"11");
}

- (IBAction)didClickSetting:(UIBarButtonItem *)sender event:(UIEvent *)event{
    [FTPopOverMenuConfiguration defaultConfiguration].menuWidth=100;
    [FTPopOverMenu showFromEvent:event withMenuArray:@[@"添加设备",@"设置",@"关于我们"] doneBlock:^(NSInteger selectedIndex) {
        switch (selectedIndex) {
            case 0:
                [self performSegueWithIdentifier:@"addDevice" sender:nil];
                break;
                case 1:
                
                break;
            default:
                break;
        }
    } dismissBlock:^{
        
    }];
}

- (IBAction)foundRemote:(UIBarButtonItem *)sender {
    NSString *codeStr=[[BinMakeManger shareInstance] foundCommand];
    MBProgressHUD *mbp=[MBProgressHUD showHUDAddedTo:self.view animated:YES];
    mbp.removeFromSuperViewOnHide=YES;
    [mbp showAnimated:YES];
    mbp.label.text=@"寻找遥控器中";
    [[BluetoothManager getInstance]sendByteCommandWithString:codeStr deviceID:@"IrRemoteControllerA" sendType:SendTypeRemoteTemp success:^(NSData * _Nullable stateData) {
        mbp.label.text=@"命令发送成功";
        [mbp hideAnimated:YES afterDelay:1];
    } fail:^NSUInteger(NSString * _Nullable stateCode) {
        mbp.label.text=@"命令发送失败";
        [mbp hideAnimated:YES afterDelay:1];
        return 0;
    }];
}

- (IBAction)addDevice:(UIButton *)sender {
        [self performSegueWithIdentifier:@"addDevice" sender:nil];
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
    return 100;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.alldevices.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell=nil;
    
    NSDictionary *subDic=_alldevices[indexPath.row];
    NSDictionary *imageDic=@{@"\"TV\"":@"icon_TV",@"\"DVD\"":@"icon_DVD",@"\"COMBI\"":@"icon_AMP",@"\"SAT\"":@"icon_BOX"};
    cell=[tableView dequeueReusableCellWithIdentifier:@"brandcell" forIndexPath:indexPath];
    UIImageView *iconImage=[cell viewWithTag:1001];
    UILabel *brandName=[cell viewWithTag:1003];
    UILabel *codeName=[cell viewWithTag:1004];
    codeName.text=[NSString stringWithFormat:@"码组号:%@",subDic[@"codeString"]];
    iconImage.image=[UIImage imageNamed:imageDic[subDic[@"deviceType"]]];
    if ([subDic[@"defineName"] length]>1) {
        brandName.text=subDic[@"defineName"];
    }
    else
    {
        brandName.text=subDic[@"brandName"];
    }
    return cell;
}

-(BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    return YES;
}

//-(void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
//{
//    if (editingStyle ==UITableViewCellEditingStyleDelete) {
//        
//    }
//}

- (NSArray<UITableViewRowAction *> *)tableView:(UITableView *)tableView editActionsForRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewRowAction *deleteAction = [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleDestructive title:@"删除" handler:^(UITableViewRowAction * _Nonnull action, NSIndexPath * _Nonnull indexPath) {
        [_alldevices removeObjectAtIndex:indexPath.row];
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
        if (self.alldevices.count==0) {
            _noneView.hidden=NO;
        }
        
        [[NSUserDefaults standardUserDefaults]setObject:_alldevices forKey:@"deviceInfo"];
    }];
    UITableViewRowAction *editAction = [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleNormal title:@"编辑" handler:^(UITableViewRowAction * _Nonnull action, NSIndexPath * _Nonnull indexPath) {
        NSMutableDictionary *deviceInfo=self.alldevices[indexPath.row].mutableCopy;
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"名称" message:@"输入设备名称" preferredStyle: UIAlertControllerStyleAlert];
        [alertController addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
            if ([deviceInfo[@"defineName"] length]>1) {
                textField.text=deviceInfo[@"defineName"];
            }
            else
            {
                textField.text=deviceInfo[@"brandName"];
            }
        }];
        [alertController addAction:[UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            if(alertController.textFields.firstObject.text.length>0){
                deviceInfo[@"defineName"]=alertController.textFields.firstObject.text;
            }
            else
            {
                deviceInfo[@"defineName"]=deviceInfo[@"brandName"];
            }
            [_alldevices removeObjectAtIndex:indexPath.row];
            [self.alldevices addObject:deviceInfo];
            [[NSUserDefaults standardUserDefaults]setObject:_alldevices forKey:@"deviceInfo"];
            
            [tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
        }]];
        [alertController addAction:[UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil]];
        [self presentViewController:alertController animated:YES completion:nil];
    }];
    editAction.backgroundColor = [UIColor blueColor];
    return @[deleteAction, editAction];
}


//-(NSString *)tableView:(UITableView *)tableView titleForDeleteConfirmationButtonForRowAtIndexPath:(NSIndexPath *)indexPath
//{
//    return @"删除这一条";
//}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSDictionary *deviceInfo= self.alldevices[indexPath.row];
    NSString *deviceType=deviceInfo[@"deviceType"];
    if ([deviceType isEqualToString:@"\"TV\""]) {
        [self performSegueWithIdentifier:@"tv" sender:deviceInfo];
    }
    else if ([deviceType isEqualToString:@"\"DVD\""]){
        [self performSegueWithIdentifier:@"dvd" sender:deviceInfo];
    }
    else if ([deviceType isEqualToString:@"\"COMBI\""]){
        [self performSegueWithIdentifier:@"amp" sender:deviceInfo];
    }
    else if ([deviceType isEqualToString:@"\"SAT\""]){
        [self performSegueWithIdentifier:@"box" sender:deviceInfo];
    }
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"tv"]) {
        TVController *target=segue.destinationViewController;
        target.deviceInfo=sender;
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
        target.deviceInfo=sender;
    }
}


@end
