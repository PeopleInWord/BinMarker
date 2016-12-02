//
//  MainController.m
//  BinMarker
//
//  Created by 彭子上 on 2016/11/17.
//  Copyright © 2016年 彭子上. All rights reserved.
//

#import "MainController.h"

@interface MainController ()<UITableViewDelegate,UITableViewDataSource>
@property (weak, nonatomic) IBOutlet UITableView *mainTableView;
@property (strong,nonatomic)NSMutableArray <NSDictionary <NSString *,NSString *>*>*alldevices;


@end


@implementation MainController

-(NSMutableArray< NSDictionary<NSString *, NSString *  > *> *)alldevices
{
    if (!_alldevices) {
        _alldevices=[NSMutableArray arrayWithArray:[[NSUserDefaults standardUserDefaults]objectForKey:@"deviceInfo"]];
    }
    return _alldevices;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    NSLog(@"%@",[[NSUserDefaults standardUserDefaults]dictionaryRepresentation]);
    // Do any additional setup after loading the view.
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    _alldevices=nil;
    [self.mainTableView reloadData];
}

- (IBAction)addDevice:(UIButton *)sender {
    [self performSegueWithIdentifier:@"addDevice" sender:nil];
}

- (IBAction)buildingBin:(UIButton *)sender {
    
    
    
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return self.view.bounds.size.height/5;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (self.alldevices.count<4) {
        return self.alldevices.count+1;
    }
    else
    {
        return 4;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell=[[UITableViewCell alloc]init];
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
    return YES;
}

-(void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle ==UITableViewCellEditingStyleDelete) {
        [_alldevices removeObjectAtIndex:indexPath.row];
        if (_alldevices.count==3) {
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
