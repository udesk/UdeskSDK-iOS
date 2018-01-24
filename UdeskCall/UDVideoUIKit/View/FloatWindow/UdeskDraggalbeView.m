//
//  UdeskDraggalbeView.m
//  WBLiveKit
//
//  Created by mincj on 2017/3/29.
//  Copyright © 2017年 Sina. All rights reserved.
//

#import "UdeskDraggalbeView.h"
#import <UIKit/UIGestureRecognizerSubclass.h>

#define VIEW_WIDTH(v) (CGRectGetWidth(v.bounds))
#define VIEW_HIGHT(v) (CGRectGetHeight(v.bounds))

@interface UdeskDraggalbeView()
@property(assign, nonatomic)BOOL moving;
@property(assign, nonatomic)CGPoint beginPos;
@property(assign, nonatomic)CGPoint endPos;
@property(assign, nonatomic)CGPoint offset;

@property(strong, nonatomic)NSDate *startTime;

@property(strong, nonatomic)UIDynamicAnimator *animator;
@property(strong, nonatomic)UIAttachmentBehavior *attchment;

@end

@implementation UdeskDraggalbeView

- (instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    self.backgroundColor = [UIColor clearColor];
    
    UIPanGestureRecognizer* gr = [[UIPanGestureRecognizer alloc]initWithTarget:self action:@selector(drag:)];
    [self addGestureRecognizer:gr];
    
    UITapGestureRecognizer* tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(recover:)];
    [self addGestureRecognizer:tap];
    self.animator = [[UIDynamicAnimator alloc]initWithReferenceView:self.superview];
    return self;
}

- (void)layoutSubviews{
    [super layoutSubviews];
    self.moveScreenArea = self.superview.bounds;
}

- (CGPoint)panoOffset:(CGPoint)pt{
    return CGPointMake(pt.x - VIEW_WIDTH(self)/2.0, pt.y - VIEW_HIGHT(self)/2.0);
}

- (CGPoint)touchOffset:(NSSet<UITouch *>*)touches{
    UITouch* touch = [touches anyObject];
    
    CGPoint pt = [touch locationInView:self];
    return CGPointMake(pt.x - VIEW_WIDTH(self)/2.0, pt.y - VIEW_HIGHT(self)/2.0);
}

- (CGPoint)ptWithPanPoint:(CGPoint)pt{
    return CGPointMake(pt.x - self.offset.x, pt.y - self.offset.y);
}

- (CGPoint)ptWithTouches:(NSSet<UITouch *>*)touches{
    UITouch* touch = [touches anyObject];
    
    CGPoint pt = [touch locationInView:self.superview];
    
    return CGPointMake(pt.x - self.offset.x, pt.y - self.offset.y);
}

- (CGPoint)ptInMoveArea:(CGPoint)pt{
    CGRect selfFrame = CGRectMake(pt.x - VIEW_WIDTH(self)/2.0, pt.y - VIEW_HIGHT(self)/2.0,\
                                  VIEW_WIDTH(self), VIEW_HIGHT(self));
    if(CGRectContainsRect(self.moveScreenArea, selfFrame)){
        return pt;
    }else{
        if(selfFrame.origin.x < self.moveScreenArea.origin.x){
            selfFrame.origin.x = self.moveScreenArea.origin.x;
        }
        if(selfFrame.origin.y < self.moveScreenArea.origin.y){
            selfFrame.origin.y = self.moveScreenArea.origin.y;
        }
        if(CGRectGetMaxX(selfFrame) > CGRectGetMaxX(self.moveScreenArea)){
            selfFrame.origin.x = (CGRectGetMaxX(self.moveScreenArea) - CGRectGetWidth(selfFrame));
        }
        if(CGRectGetMaxY(selfFrame) > CGRectGetMaxY(self.moveScreenArea)){
            selfFrame.origin.y = (CGRectGetMaxY(self.moveScreenArea) - CGRectGetHeight(selfFrame));
        }
    }
    return CGPointMake(CGRectGetMidX(selfFrame), CGRectGetMidY(selfFrame));
}

- (void)drag:(UIPanGestureRecognizer *)pan{
    CGPoint pt = [self ptWithPanPoint:[pan locationInView:self.superview]];
    
    BOOL swip = NO;
    if(pan.state == UIGestureRecognizerStateBegan){
        
        self.offset = [self panoOffset:[pan locationInView:self]];
        pt = [self ptWithPanPoint:[pan locationInView:self.superview]];
        self.attchment = nil;
        [self.animator removeAllBehaviors];
    }else if(pan.state == UIGestureRecognizerStateEnded){
        
        CGPoint vel = [pan velocityInView:pan.view];
        if(fabs(vel.x) > 1000.0 || fabs(vel.y) > 1000.0){
            swip = YES;
        }
    }
    
    CGPoint center = [self ptInMoveArea:pt];
    
    if(!swip){
        if(!self.attchment){
            UIOffset offset = UIOffsetMake(0, 0);
            self.attchment = [[UIAttachmentBehavior alloc]initWithItem:self offsetFromCenter:offset attachedToAnchor:center];
            
            UIDynamicItemBehavior* behavior = [[UIDynamicItemBehavior alloc]initWithItems:@[self]];
            behavior.allowsRotation = NO;
            [self.animator addBehavior:behavior];
            [self.animator addBehavior:self.attchment];
        }
        else{
            [self.attchment setAnchorPoint:center];
        }
    }
    else{
        
        center = [self bestAttachPoint:center];
        [self.animator removeAllBehaviors];
        UISnapBehavior* snap = [[UISnapBehavior alloc]initWithItem:self snapToPoint:center];
        snap.damping = 0.1;
        [self.animator addBehavior:snap];
        
        UIDynamicItemBehavior* behavior = [[UIDynamicItemBehavior alloc]initWithItems:@[self]];
        behavior.allowsRotation = NO;
        
        [self.animator addBehavior:behavior];
    }
}


CGFloat distanceBetweenPoints1 (CGPoint first, CGPoint second) {
    CGFloat deltaX = fabs(second.x - first.x);
    CGFloat deltaY = fabs(second.y - first.y);
    return sqrt(deltaX*deltaX + deltaY*deltaY );
};

- (CGPoint)bestAttachPoint:(CGPoint)pt{
    CGPoint best = pt;
    CGFloat length = distanceBetweenPoints1(CGPointMake(0, 0), CGPointMake(VIEW_WIDTH(self.superview), VIEW_HIGHT(self.superview)));
    
    CGFloat l1 = distanceBetweenPoints1(CGPointMake(0, 0), pt);
    if(l1 < length){
        best = CGPointMake(VIEW_WIDTH(self)/2.0, VIEW_HIGHT(self)/2.0);
        length = l1;
    }
    
    CGFloat l2 = distanceBetweenPoints1(CGPointMake(0, VIEW_HIGHT(self.superview)), pt);
    if(l2 < length){
        best = CGPointMake(VIEW_WIDTH(self)/2.0, VIEW_HIGHT(self.superview) - VIEW_HIGHT(self)/2.0);
        length = l2;
    }
    CGFloat l3 = distanceBetweenPoints1(CGPointMake(VIEW_WIDTH(self.superview), 0), pt);
    if(l3 < length){
        best = CGPointMake(VIEW_WIDTH(self.superview) - VIEW_WIDTH(self)/2.0, VIEW_HIGHT(self)/2.0);
        length = l3;
    }
    CGFloat l4 = distanceBetweenPoints1(CGPointMake(VIEW_WIDTH(self.superview), VIEW_HIGHT(self.superview)), pt);
    if(l4 < length){
        best = CGPointMake(VIEW_WIDTH(self.superview) - VIEW_WIDTH(self)/2.0, VIEW_HIGHT(self.superview) - VIEW_HIGHT(self)/2.0);
        length = l4;
    }
    return best;
}

- (void)recover:(id)sender{
    
    if(self.delegate && [self.delegate respondsToSelector:@selector(tapView:)]){
        [self.delegate tapView:self];
    }
}

@end

