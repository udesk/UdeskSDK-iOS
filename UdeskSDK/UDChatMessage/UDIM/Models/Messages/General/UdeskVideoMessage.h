//
//  UdeskVideoMessage.h
//  UdeskSDK
//
//  Created by xuchen on 2017/5/16.
//  Copyright © 2017年 Udesk. All rights reserved.
//

#import "UdeskBaseMessage.h"

@interface UdeskVideoMessage : UdeskBaseMessage

@property (nonatomic, assign, readonly) CGRect previewFrame;
@property (nonatomic, assign, readonly) CGRect playFrame;
@property (nonatomic, assign, readonly) CGRect downloadFrame;
@property (nonatomic, assign, readonly) CGRect videoDurationFrame;

@property (nonatomic, assign, readonly) CGRect uploadProgressFrame;

@property (nonatomic, strong, readonly) UIImage *previewImage;
@property (nonatomic, copy  , readonly) NSString *videoDuration;

@end
