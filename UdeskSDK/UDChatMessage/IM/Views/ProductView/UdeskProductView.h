//
//  UdeskProductView.h
//  UdeskSDK
//
//  Created by xuchen on 16/3/29.
//  Copyright © 2016年 xuchen. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UdeskProductView : UIView

@property (nonatomic, weak) UIButton    *productSendButton;

- (void)shouldUpdateProductViewWithObject:(id)object;

@end
