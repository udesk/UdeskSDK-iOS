//
//  UdeskFloatWindow.m
//  UdeskSDK
//
//  Created by mincj on 2017/3/29.
//  Copyright © 2017年 Sina. All rights reserved.
//

#import "UdeskFloatWindow.h"
#import "UdeskCallingView.h"

@interface UdeskWindow : UIWindow

@property(weak, nonatomic)UIView *gradView;
@end

@implementation UdeskWindow
- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event{
    return [self.gradView hitTest:[self convertPoint:point toView:self.gradView] withEvent:event];
}

- (void)sendEvent:(UIEvent *)event{
    [super sendEvent:event];
}
@end

@interface UdeskFloatWindow()<WBDraggalbeDelegate>

@property(strong, nonatomic)UdeskWindow *windows;
@property(strong, nonatomic)UIView *moveArea;
@property(assign, nonatomic)CGRect screenArea;

@end

@implementation UdeskFloatWindow

@synthesize windows = _windows;
@synthesize showView = _showView;
@synthesize moveInRect = _moveInRect;

+ (instancetype)floatWindow{
    static UdeskFloatWindow* global = nil;
    static dispatch_once_t token ;
    
    if(!global){
        dispatch_once(&token, ^{
            if(!global){
                global = [[[self class]alloc]init];
            }
        });
    }
    
    return global;
}

- (instancetype)init{
    self = [super init];
    self.screenArea = [UIScreen mainScreen].bounds;
    return self;
}

- (void)showView:(UIView *)view delegate:(id<WBFloatWindowProtcol>)delegate {
    self.showView = view;
    self.delegate = delegate;
    
    _hasFloatWindow = YES;
    //>
    [self.dragView insertSubview:self.showView atIndex:0];
    
    [self resetWindowPos];
    self.windows.hidden  = NO;
    
    [self.windows makeKeyAndVisible];
}

- (void)close{
    _hasFloatWindow = NO;
    self.windows.hidden = YES;
    for (UIView* sub in self.dragView.subviews) {
        if(sub == self.showView){
            [sub removeFromSuperview];
        }
    }
    self.showView = nil;
}

-(UdeskDraggalbeView *)dragView{
    if(!_dragView){
        _dragView = [[UdeskDraggalbeView alloc]initWithFrame:CGRectZero];
        _dragView.delegate = self;
        
        [self.moveArea addSubview:_dragView];
        self.windows.gradView = _dragView;
    }
    return _dragView;
}

- (UdeskWindow *)windows{
    if(!_windows){
        _windows = [[UdeskWindow alloc]initWithFrame:CGRectZero];
        _windows.windowLevel = UIWindowLevelAlert + 1;

        CGRect screen = [UIScreen mainScreen].bounds;
        _windows.center = CGPointMake(CGRectGetMidX(screen), CGRectGetMidY(screen));
        _windows.bounds = screen;
        _windows.backgroundColor = [UIColor clearColor];
    }
    return _windows;
}

- (UIView *)moveArea{
    if(!_moveArea){
        _moveArea = [[UIView alloc]initWithFrame:CGRectZero];
        [self.windows addSubview:_moveArea];
        _moveArea.frame = CGRectMake(0, 0, CGRectGetWidth(self.screenArea), CGRectGetHeight(self.screenArea));
    }
    return _moveArea;
}

- (void)resetWindowPos {

    [UIView animateWithDuration:0.35 animations:^{
        
        CGRect screen = [UIScreen mainScreen].bounds;
        self.dragView.center = CGPointMake(screen.size.width-50, 120);
        self.dragView.bounds = CGRectMake(0, 0, 100, 150);
        self.showView.frame = CGRectMake(0, 0, 100, 150);
        
        UdeskCallingView *videoView = (UdeskCallingView *)self.showView;
        videoView.remotoVideoView.frame = self.showView.frame;
    }];
}

#pragma mark -- delegate for drag view
- (void)tapView:(UdeskDraggalbeView *)view{
    
    if([self.delegate respondsToSelector:@selector(recoverFloatWindow:)]){
        [self.delegate recoverFloatWindow:self];
    }
    
    [self close];
}

@end
