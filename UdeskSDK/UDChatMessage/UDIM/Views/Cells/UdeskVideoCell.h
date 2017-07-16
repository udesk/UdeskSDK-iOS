//
//  UdeskVideoCell.h
//  UdeskSDK
//
//  Created by xuchen on 2017/5/15.
//  Copyright © 2017年 Udesk. All rights reserved.
//

#import "UdeskBaseCell.h"

@interface UdeskVideoCell : UdeskBaseCell

@property (nonatomic, strong) UIView *videoFileView;
@property (nonatomic, strong) UILabel *videoNameLabel;
@property (nonatomic, strong) UIProgressView *videoProgressView;
@property (nonatomic, strong) UILabel *videoSizeLabel;
@property (nonatomic, strong) UIButton *videoPercentButton;

@end
