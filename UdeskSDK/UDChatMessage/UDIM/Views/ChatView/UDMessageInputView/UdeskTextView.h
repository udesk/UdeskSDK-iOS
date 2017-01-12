//
//  SZTextView.h
//  SZTextView
//
//  Created by glaszig on 14.03.13.
//  Copyright (c) 2013 glaszig. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSUInteger, UDInputViewType) {
    UDInputViewTypeNormal = 0,
    UDInputViewTypeText,
    UDInputViewTypeEmotion,
    UDInputViewTypeVoice,
};

//! Project version number for SZTextView.
FOUNDATION_EXPORT double SZTextViewVersionNumber;

//! Project version string for SZTextView.
FOUNDATION_EXPORT const unsigned char SZTextViewVersionString[];


IB_DESIGNABLE

@interface UdeskTextView : UITextView

@property (copy, nonatomic) IBInspectable NSString *placeholder;
@property (nonatomic) IBInspectable double fadeTime;
@property (copy, nonatomic) NSAttributedString *attributedPlaceholder;
@property (retain, nonatomic) UIColor *placeholderTextColor UI_APPEARANCE_SELECTOR;

/**
 *  获取自身文本占据有多少行
 *
 *  @return 返回行数
 */
- (NSUInteger)numberOfLinesOfText;

/**
 *  获取每行的高度
 *
 *  @return 根据iPhone或者iPad来获取每行字体的高度
 */
+ (NSUInteger)maxCharactersPerLine;

/**
 *  获取某个文本占据自身适应宽带的行数
 *
 *  @param text 目标文本
 *
 *  @return 返回占据行数
 */
+ (NSUInteger)numberOfLinesForMessage:(NSString *)text;

@end
