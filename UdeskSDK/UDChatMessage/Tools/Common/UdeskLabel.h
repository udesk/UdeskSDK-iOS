//
//  UdeskLabel.h
//  UdeskSDK
//
//  Created by xuchen on 16/3/15.
//  Copyright (c) 2015年 xuchen. All rights reserved.
//

#import <UIKit/UIKit.h>

@class UdeskLabel;
@protocol UDLabelDelegate <NSObject>

@optional

//手指离开当前超链接文本响应的协议方法
- (void)toucheEndUDLabel:(UdeskLabel *)udLabel withContext:(NSString *)context;
//手指接触当前超链接文本响应的协议方法
- (void)toucheBenginUDLabel:(UdeskLabel *)udLabel withContext:(NSString *)context;
//检索文本的正则表达式的字符串
- (NSString *)contentsOfRegexStringWithUDLabel:(UdeskLabel *)udLabel;
//设置当前链接文本的颜色
- (UIColor *)linkColorWithUDLabel:(UdeskLabel *)udLabel;
//设置当前文本手指经过的颜色
- (UIColor *)passColorWithUDLabel:(UdeskLabel *)udLabel;

@end



@interface UdeskLabel : UILabel

@property (nonatomic, assign) id<UDLabelDelegate> udLabelDelegate;//代理对象
@property (nonatomic, assign) CGFloat linespace;//行间距   default = 10.0f
@property (nonatomic, assign) CGFloat mutiHeight;//行高(倍数) default = 1.0f
@property (nonatomic, assign) float textHeight;
@property (nonatomic, strong) NSMutableArray *matchArray;//需要响应点击事件的数组

//计算文本内容的高度
+ (float)getAttributedStringHeightWithString:(NSString *)text
                                WidthValue:(float)width
                                  delegate:(id<UDLabelDelegate>)delegate
                                      font:(UIFont*)font;
@end
