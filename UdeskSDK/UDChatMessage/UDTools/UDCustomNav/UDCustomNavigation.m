//
//  UDCustomNavigation.m
//  Demo
//
//  Created by xuchen on 2017/3/16.
//  Copyright © 2017年 xushichen. All rights reserved.
//

#import "UDCustomNavigation.h"

@implementation UDCustomNavigation

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        
        self.backgroundColor = [UIColor colorWithRed:0.976f  green:0.976f  blue:0.976f alpha:1];
        [self initNavTitleLabel];
        [self initNavCloseButton];
    }
    return self;
}

- (void)initNavTitleLabel {

    _titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(75, 20, [[UIScreen mainScreen] bounds].size.width-(75*2), 44)];
    _titleLabel.textAlignment = NSTextAlignmentCenter;
    [self addSubview:_titleLabel];
}

- (void)initNavCloseButton {

    _closeButton = [UIButton buttonWithType:UIButtonTypeCustom];
    _closeButton.frame = CGRectMake(10, 20, 50, 44);
    _closeButton.titleLabel.font = [UIFont systemFontOfSize:16];
    [_closeButton setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
    [_closeButton setTitle:@"关闭" forState:UIControlStateNormal];
    [_closeButton addTarget:self action:@selector(closeViewControllerAction) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:_closeButton];
}

- (void)closeViewControllerAction {

    if (self.closeViewController) {
        self.closeViewController();
    }
}

- (void)drawRect:(CGRect)rect {
    [super drawRect:rect];
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    CGContextSetLineWidth(ctx, 1.0);
    CGContextSetStrokeColorWithColor(ctx, [UIColor colorWithWhite:0.8 alpha:1].CGColor);
    CGContextMoveToPoint(ctx, 0, 0);
    CGContextAddLineToPoint(ctx, rect.size.width, 0);
    
    CGContextMoveToPoint(ctx, 0, 64);
    CGContextAddLineToPoint(ctx, rect.size.width, 64);
    
    CGContextClosePath(ctx);
    CGContextStrokePath(ctx);
}


@end
