//
//  UdeskDraggalbeView.h
//  WBLiveKit
//
//  Created by mincj on 2017/3/29.
//  Copyright © 2017年 Sina. All rights reserved.
//

#import <UIKit/UIKit.h>


@class UdeskDraggalbeView;

@protocol WBDraggalbeDelegate <NSObject>

- (void)tapView:(UdeskDraggalbeView *)view;

@end

@interface UdeskDraggalbeView : UIView
@property(weak, nonatomic)id <WBDraggalbeDelegate> delegate;
@property(assign, nonatomic)CGRect moveScreenArea;

@end
