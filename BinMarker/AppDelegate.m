//
//  AppDelegate.m
//  BinMarker
//
//  Created by 彭子上 on 2016/11/17.
//  Copyright © 2016年 彭子上. All rights reserved.
//

#import "AppDelegate.h"
#import <Bugly/Bugly.h>
#import "iflyMSC/iflyMSC.h"
#import "BinMarker-Swift.h"
#import "IQKeyboardManager.h"
@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    [Bugly startWithAppId:@"7f4dfcd92a"];
    [FMDBFunctions.shareInstance translateData];
    [IQKeyboardManager sharedManager].enable = YES;
    [IQKeyboardManager sharedManager].enableAutoToolbar = YES;
    [IQKeyboardManager sharedManager].shouldShowTextFieldPlaceholder = YES;
    [[BluetoothManager getInstance] effect];
    
    self.window.rootViewController=[self rootView];
    // Override point for customization after application launch.
    return YES;
}

-(UIViewController *)rootView
{
    BOOL isSelect=[[[NSUserDefaults standardUserDefaults]objectForKey:@"Selected"] boolValue];
    UIStoryboard *board = [UIStoryboard storyboardWithName: @"Main" bundle: nil];
    return isSelect?[board instantiateViewControllerWithIdentifier:@"alreadySelected"]:[board instantiateViewControllerWithIdentifier:@"selecting"];
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
}


-(BOOL)application:(UIApplication *)app openURL:(NSURL *)url options:(NSDictionary<UIApplicationOpenURLOptionsKey,id> *)options
{
    return YES;
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}


- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
}


- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}


- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}


@end
