//
//  UdeskLoadingView.m
//  UdeskSDK
//
//  Created by xuchen on 2020/2/15.
//  Copyright © 2020 Udesk. All rights reserved.
//

#import "UdeskLoadingView.h"

@interface UdeskLoadingView()

@property (nonatomic, strong) UIActivityIndicatorView *indicatorView;

@end

@implementation UdeskLoadingView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        
        self.backgroundColor     = [UIColor colorWithWhite:.3 alpha:.8];
        self.layer.cornerRadius  = 5;
        self.layer.masksToBounds = YES;
        
        _indicatorView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
        _indicatorView.frame = CGRectMake(CGRectGetWidth(frame)/2, CGRectGetHeight(frame)/2, 0, 0);
        [self addSubview:_indicatorView];
    }
    return self;
}

- (void)start {
    
    self.alpha = 1;
    [self.indicatorView startAnimating];
}

- (void)stop {
    
    self.alpha = 0;
    [self.indicatorView stopAnimating];
    [self.indicatorView setHidesWhenStopped:YES];
}

- (void)dealloc
{
    NSLog(@"123");
}

@end
