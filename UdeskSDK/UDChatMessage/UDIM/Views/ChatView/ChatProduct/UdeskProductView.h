//
//  UdeskProductView.h
//  UdeskSDK
//
//  Created by xuchen on 2019/3/14.
//  Copyright © 2019 Udesk. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>

/** 咨询对象height */
extern const CGFloat kUDProductHeight;

@interface UdeskProductView : UIView

@property (nonatomic, copy) void(^didTapProductSendBlock)(NSString *productURL);
@property (nonatomic, strong) NSDictionary *productData;

@end
