//
//  NetWorkingManager.h
//  BinMarker
//
//  Created by 彭子上 on 2017/4/28.
//  Copyright © 2017年 彭子上. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AFNetworking.h"
@interface NetWorkingManager : NSObject
/**
 *  方法数据获取字典
 *
 *  
 */

- (void)sendDataToServerWithInterface:(NSString * _Nonnull)interfaceStr
                       requestBody:(NSDictionary <NSString *,NSString *>*_Nullable)body
                           success:(void (^ _Nonnull)(NSDictionary <NSString *,id >  * _Nonnull requestDic))success
                              fail:(void (^ _Nullable)(NSError *__nullable error))fail;


@end
