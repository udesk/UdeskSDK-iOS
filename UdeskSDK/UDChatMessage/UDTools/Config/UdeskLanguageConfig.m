//
//  UdeskLanguageConfig.m
//  UdeskSDK
//
//  Created by Udesk on 16/9/5.
//  Copyright © 2016年 Udesk. All rights reserved.
//

#import "UdeskLanguageConfig.h"
#import "UdeskSDKUtil.h"
#import "UdeskSDKMacro.h"

@interface UdeskLanguageConfig()

@property (nonatomic,strong) NSBundle *bundle;

@end

@implementation UdeskLanguageConfig

+ (instancetype)sharedConfig {
    
    static UdeskLanguageConfig *sharedModel = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedModel = [[UdeskLanguageConfig alloc] init];
    });
    
    return sharedModel;
}

- (instancetype)init {
    self = [super init];
    
    if (self) {
        [self initLanguage];
    }
    
    return self;
}

- (void)initLanguage {
    @try {
        
        NSString *tmp = [[NSUserDefaults standardUserDefaults] objectForKey:LANGUAGE_SET];
        //未设置, 默认是中文
        if ([UdeskSDKUtil isBlankString:tmp]) {
            tmp = @"zh-Hans";
        }
        
        _language = tmp;
        [self updateBundle];
        
    } @catch (NSException *exception) {
        NSLog(@"%@",exception);
    } @finally {
    }
}

- (NSString *)getStringForKey:(NSString *)key withTable:(NSString *)table {
    
    if (self.bundle) {
        return NSLocalizedStringFromTableInBundle(key, table, self.bundle, @"");
    }
    
    return NSLocalizedStringFromTable(key, table, @"");
}

- (void)setSDKLanguageToEnglish {
    
    self.language = @"en";
}

- (void)setSDKLanguageToChinease {
    
    self.language = @"zh-Hans";
}

-(void)setLanguage:(NSString *)language{
    NSString *saveDefaults = @"";
    if (!language || ![language isKindOfClass:[NSString class]] || language.length == 0) { //未设置, 本地使用中文
        _language = @"zh-Hans";
        saveDefaults = @"";
    }
    else if ([language isEqualToString:@"en-us"]) { // 如果设置的是 en-us
        _language = @"en";
        saveDefaults = @"en";
    }
    else if([language isEqualToString:@"zh-cn"]){ //如果设置的是中文
        _language = @"zh-Hans";
        saveDefaults = @"zh-Hans";
    }
    else{
        _language = language;
        saveDefaults = language;
    }
    [self updateBundle];
    [self updateLanguageUserDefaults:saveDefaults];
}

- (void)updateBundle {
    
    NSString *path = [[NSBundle bundleForClass:[UdeskLanguageConfig class]] pathForResource:@"UdeskBundle" ofType:@"bundle"];
    NSBundle *bundle = [NSBundle bundleWithPath: path];
    path = [bundle pathForResource:self.language ofType:@"lproj"];
    self.bundle = [NSBundle bundleWithPath:path];
}

- (void)updateLanguageUserDefaults:(NSString *)language {
    
    [[NSUserDefaults standardUserDefaults]setObject:language?language:@"" forKey:LANGUAGE_SET];
    [[NSUserDefaults standardUserDefaults]synchronize];
}

@end
