//
//  UdeskSurveyTitleView.m
//  UdeskSDK
//
//  Created by xuchen on 2018/3/29.
//  Copyright © 2018年 Udesk. All rights reserved.
//

#import "UdeskSurveyTitleView.h"
#import "UIImage+UdeskSDK.h"
#import "UIView+UdeskSDK.h"

@implementation UdeskSurveyTitleView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        
        [self setupUI];
    }
    return self;
}

- (void)setupUI {
    
    self.backgroundColor = [UIColor whiteColor];
    _closeButton = [UdeskButton buttonWithType:UIButtonTypeCustom];
    [_closeButton setImage:[UIImage udDefaultSurveyCloseImage] forState:UIControlStateNormal];
    [self addSubview:_closeButton];
    
    _titleLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    _titleLabel.textColor = [UIColor colorWithRed:0.2f  green:0.2f  blue:0.2f alpha:1];
    _titleLabel.textAlignment = NSTextAlignmentCenter;
    _titleLabel.numberOfLines = 2;
    [self addSubview:_titleLabel];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    _closeButton.frame = CGRectMake(self.udWidth-14-20, (self.udHeight-14)/2, 14, 14);
    _titleLabel.frame = CGRectMake(14+20, 0, _closeButton.udLeft-20-14, self.udHeight);
    
    [self setNeedsDisplay];
}

- (void)drawRect:(CGRect)rect {
    [super drawRect:rect];
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    CGContextSetLineWidth(ctx, 1.0);
    CGContextSetStrokeColorWithColor(ctx, [UIColor colorWithWhite:0.9 alpha:1].CGColor);
    
    CGContextMoveToPoint(ctx, 0, 58);
    CGContextAddLineToPoint(ctx, rect.size.width, 58);
    
    CGContextClosePath(ctx);
    CGContextStrokePath(ctx);
}

@end
