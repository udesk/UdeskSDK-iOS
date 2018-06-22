//
//  UdeskLocationModel.h
//  UdeskSDK
//
//  Created by xuchen on 2017/8/18.
//  Copyright © 2017年 Udesk. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface UdeskLocationModel : NSObject

//位置名称（必填）
@property (nonatomic, copy  ) NSString *name;
//街道相关信息，例如门牌等（选填）
@property (nonatomic, copy  ) NSString *thoroughfare;
//位置缩略图（必填）
@property (nonatomic, strong) UIImage *image;
//维度（必填）
@property (nonatomic, assign) double latitude;
//经度（必填）
@property (nonatomic, assign) double longitude;
//缩放级别（这个可以不用写，默认是16）
@property (nonatomic, assign) NSInteger zoomLevel;

@end
