//
//  AddDeviceController.m
//  BinMarker
//
//  Created by 彭子上 on 2016/11/18.
//  Copyright © 2016年 彭子上. All rights reserved.
//


#import "AddDeviceController.h"
#import "BinMarker-swift.h"
#import "FMDB.h"
@interface AddDeviceController ()

@property (weak, nonatomic) IBOutlet UICollectionView *mainView;



@end

@implementation AddDeviceController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return 4;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    NSArray *cellImage=@[@"icon_tv",@"icon_dvd",@"icon_amp",@"icon_box"];
    NSArray *cellTitle=@[@"电视",@"DVD",@"功放机",@"机顶盒"];
    UICollectionViewCell *infraredCell=[collectionView dequeueReusableCellWithReuseIdentifier:@"infraredCell" forIndexPath:indexPath];
    infraredCell.layer.cornerRadius=5.0;
    UIImageView *cellIcon=[infraredCell viewWithTag:1001];
    UILabel *cellLab=[infraredCell viewWithTag:1002];
    cellIcon.image=[UIImage imageNamed:cellImage[indexPath.row]];
    cellLab.text=cellTitle[indexPath.row];
    return infraredCell;
}

//定义展示的Section的个数
-(NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 1;
}

//定义每个UICollectionView 的大小
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    NSUInteger width=(self.view.bounds.size.width-10-10-10)/2;
    NSUInteger high=width+15;
    return CGSizeMake(width, high);
}

-(UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout insetForSectionAtIndex:(NSInteger)section
{
    return UIEdgeInsetsMake(10, 10, 0, 10);
}

//UICollectionView被选中时调用的方法
-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    [self performSegueWithIdentifier:@"chooseBrand" sender:indexPath];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(NSIndexPath *)sender {
    ChooseBrandController *target=segue.destinationViewController;
    NSString *path=[[NSBundle mainBundle]pathForResource:@"NSE_Database" ofType:@"sqlite"];
    FMDatabase *db=[FMDatabase databaseWithPath:path];
    if ([db open]) {
        NSDictionary *selectWord=@{@(0):@"TV",@(1):@"DVD",@(2):@"COMBI",@(3):@"SAT"};
        FMResultSet *result = [db executeQuery:[NSString stringWithFormat:@"select DISTINCT (brand) from RemoteIndex where DeviceType = \"%@\" order by brand",selectWord[@(sender.row)]]];
        NSMutableArray *brandNameList=[NSMutableArray array];
        while ([result next]) {
            NSString *str=[result stringForColumn:@"Brand"];
            [brandNameList addObject:str];
        }
        target.deviceBrandList=brandNameList;
        target.deviceType=sender;
    }
    else
    {
        NSLog(@"创建表fail");
    }
    
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}


@end
