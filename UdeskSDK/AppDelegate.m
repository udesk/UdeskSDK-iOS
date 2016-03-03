//
//  AppDelegate.m
//  UdeskSDK
//
//  Created by xuchen on 16/1/29.
//  Copyright © 2016年 xuchen. All rights reserved.
//

#import "AppDelegate.h"
#import "ViewController.h"

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
    
//    [UDManager initWithAppkey:@"6c37f775019907785d85c027e29dae4e" domianName:@"udesksdk.udesk.cn"];
    
//    [UDManager initWithAppkey:@"3a4dc5e0cd39995448018c553048fdd4" domianName:@"reocar.udeskmonkey.com"];
    
    
//    [UDManager initWithAppkey:@"226a45c59ac9fb4d4ec963cdca382b71" domianName:@"reocar.udeskcat.com"];
    
    
//    [UDManager initWithAppkey:@"55d1fb287829dff0fea71d34c6cb3ebc" domianName:@"udesk.udesk.cn"];
    
//    [UDManager initWithAppkey:@"cc36f043f1e3bf71a0f73a51f4ac3fb5" domianName:@"rd-dota.udesk.cn"];
    
    [UDManager initWithAppkey:@"399bcc3cf728f7a18a15c0d9fc50f38f" domianName:@"reocar.udesk20.com"];
    
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
