//
//  UdeskSmallVideoBottomView.m
//  UdeskSDK
//
//  Created by xuchen on 2018/3/13.
//  Copyright © 2018年 Udesk. All rights reserved.
//

#import "UdeskSmallVideoBottomView.h"
#import "UdeskSmallVideoRecordView.h"
#import "UdeskBundleUtils.h"

@interface UdeskSmallVideoBottomView()<UdeskSmallVideoRecordViewDelegate>

@property (nonatomic, strong) UILabel *timeLabel;
@property (nonatomic, strong) UILabel *tipLabel;
@property (nonatomic, assign) CGFloat tempY;
@property (nonatomic, assign) CGFloat scaleNum;

@property (nonatomic, strong) UdeskSmallVideoRecordView *recordView;

@end

@implementation UdeskSmallVideoBottomView

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        
        _recordView = [[UdeskSmallVideoRecordView alloc] initWithFrame:CGRectMake(0, 0, 80, 80)];
        _recordView.center = CGPointMake(frame.size.width/2, 100);
        _recordView.layer.cornerRadius = 80/2;
        _recordView.delegate = self;
        [self addSubview:_recordView];
        
        _tipLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, CGRectGetMinY(_recordView.frame) - 30 - 20, frame.size.width, 20)];
        _tipLabel.text = getUDLocalizedString(@"udesk_small_video_tips");
        _tipLabel.textColor = [UIColor whiteColor];
        _tipLabel.font = [UIFont systemFontOfSize:13];
        _tipLabel.textAlignment = NSTextAlignmentCenter;
        [self addSubview:_tipLabel];
        
        _timeLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, CGRectGetMinY(_recordView.frame) - 30 - 20, frame.size.width, 20)];
        _timeLabel.textColor = [UIColor whiteColor];
        _timeLabel.font = [UIFont systemFontOfSize:13];
        _timeLabel.hidden = YES;
        _timeLabel.textAlignment = NSTextAlignmentCenter;
        [self addSubview:_timeLabel];
        
        _scaleNum = 1;
        _tempY = 0;
    }
    return self;
}

- (void)smallVideoRecordView:(UdeskSmallVideoRecordView *)recordView gestureRecognizer:(UIGestureRecognizer *)gest {
    
    if ([NSStringFromClass([gest class]) isEqualToString:@"UITapGestureRecognizer"]) {
        if (self.delegate && [self.delegate respondsToSelector:@selector(udSmallVideo:captureCurrentFrame:)]) {
            [self.delegate udSmallVideo:self captureCurrentFrame:YES];
        }
        return;
    }
    
    switch (gest.state) {
        case UIGestureRecognizerStateBegan:{
            _tipLabel.hidden = YES;
            _timeLabel.hidden = NO;
            if (self.delegate && [self.delegate respondsToSelector:@selector(udSmallVideo:isRecording:)]) {
                [self.delegate udSmallVideo:self isRecording:YES];
            }
        }
            break;
        case UIGestureRecognizerStateChanged:{
            CGPoint point = [gest locationInView:self];
            
            if (point.y <0)
            {
                if (_tempY - point.y> 0)
                {
                    if (_scaleNum <3)  _scaleNum += 0.05;
                }else {
                    if (_scaleNum >1)   _scaleNum -= 0.05;
                }
                _tempY = point.y;
            }
            if (self.delegate && [self.delegate respondsToSelector:@selector(udSmallVideo:zoomLens:)]) {
                [self.delegate udSmallVideo:self zoomLens:_scaleNum];
            }
        }
            break;
        case UIGestureRecognizerStateEnded:{
            _tipLabel.hidden = NO;
            _timeLabel.hidden = YES;
            if (self.delegate && [self.delegate respondsToSelector:@selector(udSmallVideo:isRecording:)]) {
                [self.delegate udSmallVideo:self isRecording:NO];
            }
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [self removeScaleTemp];
            });
        }
            break;
        default:
            break;
    }
}

- (void)smallVideoRecordView:(UdeskSmallVideoRecordView *)recordView recordDuration:(CGFloat)recordDuration {
    
    _timeLabel.text = [NSString stringWithFormat:@"%.f%@ / %ld%@",recordDuration,getUDLocalizedString(@"udesk_second"),(long)_duration,getUDLocalizedString(@"udesk_second")];
}

- (void)setDuration:(NSInteger)duration {
    _duration = duration;
    _recordView.duration = duration;
}

- (void)removeScaleTemp {
    _tempY = 0;
    _scaleNum = 1;
    if (self.delegate && [self.delegate respondsToSelector:@selector(udSmallVideo:zoomLens:)]) {
        [self.delegate udSmallVideo:self zoomLens:_scaleNum];
    }
}

@end
