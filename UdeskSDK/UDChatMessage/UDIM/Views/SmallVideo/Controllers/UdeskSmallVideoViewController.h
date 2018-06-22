//
//  UdeskSmallVideoViewController.h
//  UdeskSDK
//
//  Created by xuchen on 2018/3/13.
//  Copyright © 2018年 Udesk. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol UdeskSmallVideoViewControllerDelegate <NSObject>

- (void)didFinishRecordSmallVideo:(NSDictionary *)videoInfo;
- (void)didFinishCaptureImage:(UIImage *)image;

@end

@interface UdeskSmallVideoViewController : UIViewController

@property (nonatomic, weak) id<UdeskSmallVideoViewControllerDelegate> delegate;

@end
