//
//  UdeskVideoLanguageHelper.m
//  UdeskSDK
//
//  Created by xuchen on 2017/11/29.
//  Copyright © 2017年 Udesk. All rights reserved.
//

#import "UdeskVideoLanguageHelper.h"

@interface UdeskVideoLanguageHelper()

@property (nonatomic,strong) NSBundle *bundle;
@property (nonatomic,copy  ) NSString *language;

@end

@implementation UdeskVideoLanguageHelper

+ (instancetype)shared
{
    static dispatch_once_t onceToken;
    static UdeskVideoLanguageHelper *instance = nil;
    dispatch_once(&onceToken,^{
        instance = [[self alloc] init];
    });
    return instance;
}

- (instancetype)init
{
    self = [super init];
    if (self)
    {
        [self initLanguage];
    }
    
    return self;
}

- (void)initLanguage
{
    @try {
        
        NSString *tmp = [[NSUserDefaults standardUserDefaults] objectForKey:UVC_LANGUAGE_SET];
        
        //默认是中文
        if (!tmp){
            tmp = @"zh-Hans";
        }
        
        self.language = tmp;
        
        NSString *path = [[NSBundle bundleForClass:[UdeskVideoLanguageHelper class]] pathForResource:@"UdeskVideoBundle" ofType:@"bundle"];
        NSBundle *bundle = [NSBundle bundleWithPath:path];
        
        path = [bundle pathForResource:self.language ofType:@"lproj"];
        
        self.bundle = [NSBundle bundleWithPath:path];
    } @catch (NSException *exception) {
        NSLog(@"%@",exception);
    } @finally {
    }
}

- (NSString *)getStringForKey:(NSString *)key withTable:(NSString *)table
{
    if (self.bundle)
    {
        return NSLocalizedStringFromTableInBundle(key, table, self.bundle, @"");
    }
    
    return NSLocalizedStringFromTable(key, table, @"");
}

- (void)setNewLanguage:(UVCLanguageType)language
{
    @try {
        
        NSString *languageStr = @"zh-Hans";
        if (language == UVCLanguageTypeEN) {
            languageStr = @"en";
        }
        
        NSString *path = [[NSBundle bundleForClass:[UdeskVideoLanguageHelper class]] pathForResource:@"UdeskVideoBundle" ofType:@"bundle"];
        NSBundle *bundle = [NSBundle bundleWithPath: path];
        path = [bundle pathForResource:languageStr ofType:@"lproj"];
        self.bundle = [NSBundle bundleWithPath:path];
        
        self.language = languageStr;
        
        [[NSUserDefaults standardUserDefaults] setObject:languageStr forKey:UVC_LANGUAGE_SET];
        [[NSUserDefaults standardUserDefaults] synchronize];
    } @catch (NSException *exception) {
        NSLog(@"%@",exception);
    } @finally {
    }
}

@end
