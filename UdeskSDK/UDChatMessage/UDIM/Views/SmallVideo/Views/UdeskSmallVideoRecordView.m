//
//  UdeskSmallVideoRecordView.m
//  UdeskSDK
//
//  Created by xuchen on 2018/3/13.
//  Copyright © 2018年 Udesk. All rights reserved.
//

#import "UdeskSmallVideoRecordView.h"
#import "UdeskThrottleUtil.h"

@implementation UdeskSmallVideoRecordView {
    
    UIView *_outerView;
    UIView *_centerView;
    CAShapeLayer *_progressLayer;
    NSTimer *_timer;
    CGFloat _progress;
    CGFloat _width;
    CGFloat _recordTime;
    
    CGFloat _animationTime;// 动画调用间隔
    CGFloat _animationIncr;// 每次动画调用的增量
}

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        
        self.backgroundColor = [UIColor clearColor];
        _outerView = [[UIView alloc] initWithFrame:self.bounds];
        _outerView.layer.cornerRadius = self.bounds.size.width/2;
        _outerView.backgroundColor = [UIColor colorWithRed:0.851f  green:0.831f  blue:0.82f alpha:1];
        _outerView.alpha = 0.7;
        [self addSubview:_outerView];
        
        _centerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 55, 55)];
        _centerView.backgroundColor = [UIColor whiteColor];
        _centerView.layer.cornerRadius = 55/2;
        _centerView.center = CGPointMake(frame.size.width/2, frame.size.height/2);
        [self addSubview:_centerView];
        
        UILongPressGestureRecognizer *longPress = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longPress:)];
        [_centerView addGestureRecognizer:longPress];
        
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapAction:)];
        [_centerView addGestureRecognizer:tap];
        
        _width = 5;
        
        _progressLayer = [CAShapeLayer new];
        [_outerView.layer addSublayer:_progressLayer];
        _progressLayer.fillColor = nil;
        _progressLayer.lineCap = kCALineCapSquare;
        _progressLayer.frame = _outerView.bounds;
        _progressLayer.lineWidth = _width;
        _progressLayer.strokeColor = [UIColor colorWithRed:0.165f  green:0.576f  blue:0.98f alpha:1].CGColor;
        [self setProgress];
    }
    return self;
}

- (void)longPress:(UIGestureRecognizer *)longPress {
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(smallVideoRecordView:gestureRecognizer:)]) {
        [self.delegate smallVideoRecordView:self gestureRecognizer:longPress];
    }
    
    switch (longPress.state) {
        case UIGestureRecognizerStateBegan:{
            [UIView animateWithDuration:0.3 animations:^{
                _centerView.transform = CGAffineTransformMakeScale(0.7, 0.7);
                _outerView.transform = CGAffineTransformMakeScale(1.5, 1.5);
            }];
            [self start];
        }
            break;
            
        case UIGestureRecognizerStateCancelled:
            [self stop];
            break;
            
        case UIGestureRecognizerStateEnded:{
            [UIView animateWithDuration:0.3 animations:^{
                _centerView.transform = CGAffineTransformMakeScale(1, 1);
                _outerView.transform = CGAffineTransformMakeScale(1, 1);
            }];
            [self stop];
        }
            break;
            
        case UIGestureRecognizerStateChanged:
            break;
        default:
            break;
    }
}

- (void)tapAction:(UIGestureRecognizer *)gest {
    
    ud_dispatch_throttle(0.35, ^{
        if (self.delegate && [self.delegate respondsToSelector:@selector(smallVideoRecordView:gestureRecognizer:)]) {
            [self.delegate smallVideoRecordView:self gestureRecognizer:gest];
        }
    });
}

- (void)setDuration:(NSInteger)duration {
    _duration = duration;
    _animationTime = 1/(CGFloat)(duration*duration);
    _animationIncr = 1/(CGFloat)(duration*duration*duration);
}

#pragma mark - Progress
- (void)setProgress{
    _progress = 0;
    UIBezierPath *progressPath = [UIBezierPath bezierPathWithArcCenter:_centerView.center
                                                                radius:(CGRectGetWidth(_outerView.frame) - (1.5*_width))/3
                                                            startAngle:(M_PI_2 *3)
                                                              endAngle:-M_PI_2
                                                             clockwise:YES];
    _progressLayer.path = progressPath.CGPath;
}

- (void)updataProgress {
    // 1倍的宽度有问题，需要1.5倍
    UIBezierPath *progressPath = [UIBezierPath bezierPathWithArcCenter:_centerView.center
                                                                radius:(CGRectGetWidth(_outerView.frame) - (1.5*_width))/3
                                                            startAngle:(M_PI_2 *3)
                                                              endAngle:(M_PI*2) *_progress +(-M_PI_2)
                                                             clockwise:YES];
    _progressLayer.path = progressPath.CGPath;
}

#pragma mark - action
- (void)start {
    _timer = [NSTimer scheduledTimerWithTimeInterval:_animationTime target:self selector:@selector(addprogress) userInfo:nil repeats:YES];
}

- (void)addprogress {
    
    dispatch_async(dispatch_get_main_queue(), ^{
        _progress += _animationIncr;
        if (self.delegate && [self.delegate respondsToSelector:@selector(smallVideoRecordView:recordDuration:)]) {
            [self.delegate smallVideoRecordView:self recordDuration:_progress*_duration];
        }
        [self updataProgress];
        if (_progress >1) {
            [self stop];
        }
    });
}

- (void)stop {
    
    [_timer invalidate];
    _timer = nil;
    [self setProgress];
}

@end
