//
//  UdeskEmojiManager.m
//  UdeskSDK
//
//  Created by xuchen on 2018/3/26.
//  Copyright © 2018年 Udesk. All rights reserved.
//

#import "UdeskEmojiManager.h"
#import "UdeskBundleUtils.h"
#import "UdeskSDKConfig.h"
#import "UdeskImageUtil.h"

@interface UdeskEmojiManager()

@property (nonatomic, strong, readwrite) NSArray<UdeskEmojiPanelModel *> *emojiPanels;
@property (nonatomic, strong, readwrite) NSArray<UdeskEmojiPage *> *emojiContents;

@end

@implementation UdeskEmojiManager

- (instancetype)init
{
    self = [super init];
    if (self) {
        
        [self defaultEmoji];
        [self customEmoji];
        [self updateEmojiContent];
        
    }
    return self;
}

- (void)defaultEmoji {
    
    NSMutableArray *contents = [NSMutableArray array];
    NSMutableArray *panels = [NSMutableArray array];
    
    //默认表情
    NSArray *array = [NSArray arrayWithContentsOfFile:getUDBundlePath(@"UDEmojiList.plist")];
    for (NSString *text in array) {
        
        UdeskEmojiContentModel *contentModel = [[UdeskEmojiContentModel alloc] init];
        contentModel.emojiType = UdeskEmojiTypeDefault;
        contentModel.resource = text;
        [contents addObject:contentModel];
    }
    
    //默认表情面板
    UdeskEmojiPanelModel *panelModel = [[UdeskEmojiPanelModel alloc] init];
    panelModel.emojiType = UdeskEmojiTypeDefault;
    panelModel.contentArray = [contents copy];
    panelModel.emojiIcon = [UIImage imageWithContentsOfFile:getUDBundlePath(@"udEmojiIcon")];
    [panels addObject:panelModel];
    self.emojiPanels = [panels copy];
}

- (void)customEmoji {
    
    @try {
     
        NSArray *customEmojis = [UdeskSDKConfig customConfig].customEmojis;
        if (customEmojis.count < 1) {
            return;
        }
        
        NSMutableArray *array = [NSMutableArray arrayWithArray:self.emojiPanels];
        for (UdeskEmojiPanelModel *panelModel in customEmojis) {
            
            if (![panelModel isKindOfClass:[UdeskEmojiPanelModel class]]) return;
            if (!panelModel.stickerPaths || panelModel.stickerPaths == (id)kCFNull) return ;
            if (![panelModel.stickerPaths.firstObject isKindOfClass:[NSString class]]) return ;
            
            NSMutableArray *emojiContent = [NSMutableArray new];
            for (NSString *path in panelModel.stickerPaths) {
                UdeskEmojiContentModel *model = [UdeskEmojiContentModel new];
                model.resource = path;
                model.stickerImage = [UdeskImageUtil imageResize:[UIImage imageWithContentsOfFile:model.resource] toSize:CGSizeMake(140, 140)];
                model.emojiType = UdeskEmojiTypeSticker;
                NSInteger index = [panelModel.stickerPaths indexOfObject:path];
                model.stickerTitle = panelModel.stickerTitles[index];
                [emojiContent addObject:model];
            }
            
            panelModel.contentArray = emojiContent;
            panelModel.emojiType = UdeskEmojiTypeSticker;
            [array addObject:panelModel];
        }
        
        self.emojiPanels = [array copy];
        
    } @catch (NSException *exception) {
        NSLog(@"%@",exception);
    } @finally {
    }
}

- (void)updateEmojiContent {
    
    @try {
     
        NSMutableArray *pages = [NSMutableArray array];
        for (UdeskEmojiPanelModel *panelModel in self.emojiPanels) {
            if (![panelModel isKindOfClass:[UdeskEmojiPanelModel class]]) return;
            
            for (int pageIndex = 0; pageIndex < [panelModel pageCount]; pageIndex++) {
                UdeskEmojiPage *pageInfo = [UdeskEmojiPage new];
                pageInfo.panelInfo = panelModel;
                pageInfo.pageIndex = pageIndex;
                pageInfo.pageCount = [panelModel pageCount];
                [pages addObject:pageInfo];
            }
        }
        self.emojiContents = [pages copy];
        
    } @catch (NSException *exception) {
        NSLog(@"%@",exception);
    } @finally {
    }
}

@end
