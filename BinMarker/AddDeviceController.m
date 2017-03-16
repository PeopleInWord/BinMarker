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
    NSArray *cellImage=@[@"btn_add_tv",@"btn_add_dvd",@"btn_add_amp",@"btn_add_box"];
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
    NSUInteger high=width*120/169;
    return CGSizeMake(width, high);
}

-(UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout insetForSectionAtIndex:(NSInteger)section
{
    return UIEdgeInsetsMake(10, 10, 0, 10);
}
//67346768
//UICollectionView被选中时调用的方法
-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    [self performSegueWithIdentifier:@"chooseBrand" sender:indexPath];
    
 
}

- (IBAction)temp:(UIBarButtonItem *)sender {
//    func copyNewData(with sourceName:String) -> String {//转化成文件
//        let sourcePath=Bundle.main.path(forResource: sourceName, ofType: "bin")
//        let sourceData=NSData.init(contentsOfFile: sourcePath!)
//        
//        let paths=NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)
//        let path=paths[0]
//        let targetPath = path + "/" + sourceName + ".bin"
//        
//        let manger=FileManager.default
//        if manger.createFile(atPath: targetPath, contents: nil, attributes: nil) {
//            let handle=FileHandle.init(forWritingAtPath: targetPath)
//            handle?.write(Data.init(referencing: sourceData!))
//            handle?.closeFile()
//            return targetPath
//        }
//        else
//        {
//            return ""
//        }
//    }
//    NSString *path=[[NSBundle mainBundle]pathForResource:@"Infrared_Datebase" ofType:@"bin"];
//    NSData *sourdata=[NSData dataWithContentsOfFile:path];
//    NSString *sourcePath=NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES)[0];
//    sourcePath=[NSString stringWithFormat:@"%@/target_Datebase.sqlite",sourcePath];
//    NSFileManager *manger=[NSFileManager defaultManager];
//    if (manger) {
//        <#statements#>
//    }
    
//    NSFileHandle *filemanger=[NSFileHandle fileHandleForWritingAtPath:sourcePath];
    
//    if ([manger createFileAtPath:targetPath contents:nil attributes:nil]) {
//        NSFileHandle *filemanger=[NSFileHandle fileHandleForWritingAtPath:targetPath];
//        [filemanger writeData:sourdata];
//        [filemanger closeFile];
//        NSLog(@"%@",targetPath);
//    }
    
    NSString *path=[[NSBundle mainBundle]pathForResource:@"InfraredBrandList" ofType:@"plist"];

    NSString *sourcePath=NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES)[0];
    sourcePath=[NSString stringWithFormat:@"%@/Infrared_Datebase.sqlite",sourcePath];
    FMDatabase *db=[FMDatabase databaseWithPath:sourcePath];
    if (![db open]) {
        return;
    }
    
    
    
    
    NSDictionary <NSString *,NSArray *>*root=[NSDictionary dictionaryWithContentsOfFile:path];
    __block NSUInteger IDX=0;
    [root enumerateKeysAndObjectsUsingBlock:^(NSString * _Nonnull key, NSArray <NSDictionary *>* _Nonnull obj1, BOOL * _Nonnull stop)
    {
        NSString *DeviceType=key;
        [obj1 enumerateObjectsUsingBlock:^(NSDictionary * _Nonnull obj2, NSUInteger idx, BOOL * _Nonnull stop)//TV AIR下
        {
            NSString *Brand=obj2[@"brand"];
            NSArray <NSString *>*code=obj2[@"code"];
            [code enumerateObjectsUsingBlock:^(NSString * _Nonnull obj3, NSUInteger idx, BOOL * _Nonnull stop) {
                NSString *DeviceNo=obj3;
//                IDX+=1;
                //写入
                NSString *sql1 = [NSString stringWithFormat:
                                  @"INSERT INTO '%@' ( '%@', '%@', '%@', '%@', '%@') VALUES ( '%@', '%@', '%@', '%@', '%@')",
                                  @"RemoteIndex", @"Brand", @"DeviceType", @"Model", @"DeviceNo", @"Group1",
                                                        Brand,  DeviceType,     @"",    DeviceNo,   @"0"];
                
                NSLog(@"%@",sql1);
                if([db executeUpdate:sql1])
                {
                    NSLog(@"成功");
                }
                
            }];
        }];
    }];
    
    
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(NSIndexPath *)sender {
    ChooseBrandController *target=segue.destinationViewController;
    NSString *path=[[NSBundle mainBundle]pathForResource:@"Infrared_Datebase" ofType:@"sqlite"];
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
