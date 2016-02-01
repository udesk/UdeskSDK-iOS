//
//  UDKeywordRegularParser.m
//  UdeskSDK
//
//  Created by xuchen on 16/1/18.
//  Copyright © 2016年 xuchen. All rights reserved.
//

#import "UDKeywordRegularParser.h"

static NSString* emojiRegular = @"\\[([emoji0-9]+)\\]";

@implementation UDKeywordRegularParser

+ (NSArray *)keywordRangesOfEmotionInString:(NSString *)string trimedString:(NSString **)trimedString {
    NSError *error;
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:emojiRegular
                                                                           options:NSRegularExpressionCaseInsensitive
                                                                             error:&error];
    __block NSMutableArray *rangesArray = [NSMutableArray array];
    __block NSMutableString *mutableString = [string mutableCopy];
    __block NSInteger offset = 0;
    __block NSString* keyword = nil;
    __block UDPaserdKeyword* keywordEntity = nil;
    [regex enumerateMatchesInString:string
                            options:0
                              range:NSMakeRange(0, string.length)
                         usingBlock:^(NSTextCheckingResult *result, NSMatchingFlags flags, BOOL *stop) {
                             NSRange resultRange = [result range];
                             resultRange.location += offset;
                             // range & emotion
                             keyword = [regex replacementStringForResult:result
                                                                inString:mutableString
                                                                  offset:offset
                                                                template:@"$0"];
                             keywordEntity = [[UDPaserdKeyword alloc] init];
                             keywordEntity.keyword = keyword;
                             keywordEntity.range = resultRange;
                             [rangesArray addObject:keywordEntity];
                             [mutableString replaceCharactersInRange:resultRange withString:@""];
                             offset -= resultRange.length;
                             
                             *trimedString = mutableString;
                         }];
    return rangesArray;
}

@end
