//
//  UdeskEmojiPanelModel.h
//  UdeskSDK
//
//  Created by xuchen on 2018/3/26.
//  Copyright © 2018年 Udesk. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

typedef NS_ENUM(NSUInteger, UdeskEmojiType) {
    UdeskEmojiTypeDefault, //默认表情
    UdeskEmojiTypeSticker, //自定义表情
};

@interface UdeskEmojiPanelModel : NSObject

@property (nonatomic, assign) UdeskEmojiType emojiType;
@property (nonatomic, strong) UIImage        *emojiIcon;
@property (nonatomic, strong) NSArray        *contentArray;
//表情资源文件路径（具体用法参考文档或者demo，注：图片大小最好在50-60左右）
@property (nonatomic, strong) NSArray        *stickerPaths;
//自定义表情标题（非必填）
@property (nonatomic, strong) NSArray        *stickerTitles;

- (NSInteger)rowCount;
- (NSInteger)columnCount;
- (NSInteger)pageCount;
- (CGFloat)horizontalSpacing;
- (CGFloat)verticalSpacing;
- (CGFloat)itemSize;

- (NSArray *)checkItemsAtIndexedPage:(NSInteger)pageIndex;

@end

@interface UdeskEmojiPage : NSObject

@property (nonatomic, assign) NSInteger      pageIndex;
@property (nonatomic, assign) NSInteger      pageCount;
@property (nonatomic, weak  ) UdeskEmojiPanelModel *panelInfo;

@end

@interface UdeskEmojiContentModel : NSObject

@property (nonatomic, copy  ) NSString       *resource;
@property (nonatomic, copy  ) NSString       *stickerTitle;
@property (nonatomic, strong) UIImage        *stickerImage;
@property (nonatomic, assign) UdeskEmojiType emojiType;

- (NSInteger)checkCurrentPageInPackage:(UdeskEmojiPanelModel *)panel;
- (NSInteger)checkIndexInPage:(UdeskEmojiPanelModel *)panel;

@end

