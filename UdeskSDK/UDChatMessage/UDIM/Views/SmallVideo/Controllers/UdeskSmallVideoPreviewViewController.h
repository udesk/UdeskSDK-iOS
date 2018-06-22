//
//  UdeskSmallVideoPreviewViewController.h
//  UdeskSDK
//
//  Created by xuchen on 2018/3/13.
//  Copyright © 2018年 Udesk. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UdeskSmallVideoPreviewViewController : UIViewController

@property (nonatomic, copy) void (^SubmitShootingBlock)(void);
@property (nonatomic, copy) void (^AbandonSmallVideoBlock)(void);

@property (nonatomic, copy  ) NSString *url;
@property (nonatomic, strong) UIImage  *image;

@end
