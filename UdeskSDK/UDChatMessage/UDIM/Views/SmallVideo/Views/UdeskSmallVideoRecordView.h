//
//  UdeskSmallVideoRecordView.h
//  UdeskSDK
//
//  Created by xuchen on 2018/3/13.
//  Copyright © 2018年 Udesk. All rights reserved.
//

#import <UIKit/UIKit.h>

@class UdeskSmallVideoRecordView;
@protocol UdeskSmallVideoRecordViewDelegate <NSObject>

@required
- (void)smallVideoRecordView:(UdeskSmallVideoRecordView *)recordView gestureRecognizer:(UIGestureRecognizer *)gest;
- (void)smallVideoRecordView:(UdeskSmallVideoRecordView *)recordView recordDuration:(CGFloat)recordDuration;

@end

@interface UdeskSmallVideoRecordView : UIView

@property (nonatomic, weak  )id <UdeskSmallVideoRecordViewDelegate>delegate;
@property (nonatomic, assign)NSInteger duration;

@end
