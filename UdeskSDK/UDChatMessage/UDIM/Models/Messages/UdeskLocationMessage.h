//
//  UdeskLocationMessage.h
//  UdeskSDK
//
//  Created by xuchen on 2017/8/16.
//  Copyright © 2017年 Udesk. All rights reserved.
//

#import "UdeskBaseMessage.h"

@interface UdeskLocationMessage : UdeskBaseMessage

/** 地理位置frame */
@property (nonatomic, assign, readonly) CGRect locationFrame;
/** 地理位置街道frame */
@property (nonatomic, assign, readonly) CGRect locationThoroughfareFrame;
/** 地理位置名称frame */
@property (nonatomic, assign, readonly) CGRect locationNameFrame;
/** 地理位置快照frame */
@property (nonatomic, assign, readonly) CGRect locationSnapshotFrame;

@end
