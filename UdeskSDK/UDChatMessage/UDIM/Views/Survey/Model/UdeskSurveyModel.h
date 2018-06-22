//
//  UdeskSurveyModel.h
//  UdeskSDK
//
//  Created by xuchen on 2018/3/29.
//  Copyright © 2018年 Udesk. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSUInteger, UdeskSurveyOptionType) {
    UdeskSurveyOptionTypeText, //文本
    UdeskSurveyOptionTypeExpression, //表情
    UdeskSurveyOptionTypeStar, //星星
};

typedef NS_ENUM(NSUInteger, UdeskRemarkOptionType) {
    UdeskRemarkOptionTypeHide, //隐藏
    UdeskRemarkOptionTypeRequired, //必填
    UdeskRemarkOptionTypeOptional, //选填
};

@interface UdeskSurveyOption : NSObject

@property (nonatomic, strong) NSNumber *optionId;
@property (nonatomic, strong) NSNumber *enabled; //是否启用
@property (nonatomic, copy  ) NSString *text;
@property (nonatomic, copy  ) NSString *desc;
@property (nonatomic, copy  ) NSString *tags;
@property (nonatomic, copy  ) NSString *remarkOption;
@property (nonatomic, assign) UdeskRemarkOptionType remarkOptionType;

@end

@interface UdeskStarSurvey : NSObject

@property (nonatomic, strong) NSNumber *defaultOptionId;
@property (nonatomic, strong) NSArray<UdeskSurveyOption *>  *options;

@end

@interface UdeskExpressionSurvey : NSObject

@property (nonatomic, strong) NSNumber *defaultOptionId;
@property (nonatomic, strong) NSArray<UdeskSurveyOption *>  *options;

@end

@interface UdeskTextSurvey : NSObject

@property (nonatomic, strong) NSNumber *defaultOptionId;
@property (nonatomic, strong) NSArray<UdeskSurveyOption *>  *options;

@end

@interface UdeskSurveyModel : NSObject

@property (nonatomic, strong) NSNumber *enabled; //是否开启
@property (nonatomic, strong) NSNumber *remarkEnabled; //评价备注开关
@property (nonatomic, copy  ) NSString *remark; //评价内容
@property (nonatomic, copy  ) NSString *name;
@property (nonatomic, copy  ) NSString *title;
@property (nonatomic, copy  ) NSString *desc;
@property (nonatomic, copy  ) NSString *showType;
@property (nonatomic, strong) UdeskTextSurvey *text;
@property (nonatomic, strong) UdeskExpressionSurvey *expression;
@property (nonatomic, strong) UdeskStarSurvey *star;

@property (nonatomic, assign) UdeskSurveyOptionType optionType;

- (instancetype)initWithDictionary:(NSDictionary *)dictionary;

- (NSString *)stringWithOptionType;

@end
