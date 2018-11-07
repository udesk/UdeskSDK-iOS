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

static UdeskLanguageConfig *sharedModel;

@interface UdeskLanguageConfig()

@property (nonatomic,strong) NSBundle *bundle;
@property (nonatomic,copy  ) NSString *language;

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
        //默认是中文
        if ([UdeskSDKUtil isBlankString:tmp]) {
            tmp = @"zh-Hans";
        }
        
        self.language = tmp;
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
    [self updateBundle];
    [self updateLanguageUserDefaults];
}

- (void)setSDKLanguageToChinease {
    
    self.language = @"zh-Hans";
    [self updateBundle];
    [self updateLanguageUserDefaults];
}

- (void)updateBundle {
    
    NSString *path = [[NSBundle bundleForClass:[UdeskLanguageConfig class]] pathForResource:@"UdeskBundle" ofType:@"bundle"];
    NSBundle *bundle = [NSBundle bundleWithPath: path];
    path = [bundle pathForResource:self.language ofType:@"lproj"];
    self.bundle = [NSBundle bundleWithPath:path];
}

- (void)updateLanguageUserDefaults {
    
    [[NSUserDefaults standardUserDefaults]setObject:self.language forKey:LANGUAGE_SET];
    [[NSUserDefaults standardUserDefaults]synchronize];
}

@end
