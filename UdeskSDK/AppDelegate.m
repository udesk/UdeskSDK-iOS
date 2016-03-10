//
//  AppDelegate.m
//  UdeskSDK
//
//  Created by xuchen on 16/1/29.
//  Copyright © 2016年 xuchen. All rights reserved.
//

#import "AppDelegate.h"
#import "ViewController.h"
#import "UDManager.h"

@interface AppDelegate ()

@end

@implementation AppDelegate

//初始化Udesk
- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    
    ViewController *view = [[ViewController alloc] init];
    UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:view];
    self.window.rootViewController = nav;
    
//    [UDManager initWithAppkey:@"公司密钥" domianName:@"公司域名"];
    
    [UDManager initWithAppkey:@"6c37f775019907785d85c027e29dae4e" domianName:@"udesksdk.udesk.cn"];
    
//    [UDManager initWithAppkey:@"2f04e99ff44ec68165c585a209efdd6d" domianName:@"reocar.tiyanudesk.com"];
    
//    [UDManager initWithAppkey:@"c7663d315dc698892fb9c5dfb7a49e1c" domianName:@"schxit.udesk.cn"];
    
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    //设置客户离线
    [UDManager setCustomerOffline];
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    //设置客户在线
    [UDManager setCustomerOnline];
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end
