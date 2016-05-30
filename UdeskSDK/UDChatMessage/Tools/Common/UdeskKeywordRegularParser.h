//
//  UdeskKeywordRegularParser.h
//  UdeskSDK
//
//  Created by xuchen on 16/1/18.
//  Copyright © 2016年 xuchen. All rights reserved.
//

#import "UdeskPaserdKeyword.h"

@interface UdeskKeywordRegularParser : NSObject

// 返回表情的range数组，和去掉表情字符的trimed字符串
+ (NSArray *)keywordRangesOfEmotionInString:(NSString *)string trimedString:(NSString **)trimedString;

@end
