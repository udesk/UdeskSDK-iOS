//
//  UdeskLanguageTool.m
//  UdeskSDK
//
//  Created by Udesk on 16/9/5.
//  Copyright © 2016年 Udesk. All rights reserved.
//

#import "UdeskLanguageTool.h"
#import "UdeskTools.h"

static UdeskLanguageTool *sharedModel;

@interface UdeskLanguageTool()

@property (nonatomic,strong) NSBundle *bundle;
@property (nonatomic,copy  ) NSString *language;

@end

@implementation UdeskLanguageTool

+ (id)sharedInstance
{
    if (!sharedModel)
    {
        sharedModel = [[UdeskLanguageTool alloc]init];
    }
    
    return sharedModel;
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
        
        NSString *tmp = [[NSUserDefaults standardUserDefaults] objectForKey:LANGUAGE_SET];
        
        //默认是中文
        if ([UdeskTools isBlankString:tmp])
        {
            tmp = CNS;
        }
        
        self.language = tmp;
        
        NSString *path = [[NSBundle bundleForClass:[UdeskLanguageTool class]] pathForResource:@"UdeskBundle" ofType:@"bundle"];
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

- (void)changeNowLanguage
{
    if ([self.language isEqualToString:EN])
    {
        [self setNewLanguage:CNS];
    }
    else
    {
        [self setNewLanguage:EN];
    }
}

- (void)setNewLanguage:(NSString *)language
{
    @try {
        
        if ([language isEqualToString:self.language])
        {
            return;
        }
        
        if ([language isEqualToString:EN] || [language isEqualToString:CNS])
        {
            
            NSString *path = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:@"UdeskBundle.bundle"];
            NSBundle *bundle = [NSBundle bundleWithPath: path];
            path = [bundle pathForResource:language ofType:@"lproj"];
            self.bundle = [NSBundle bundleWithPath:path];
        }
        
        self.language = language;
        [[NSUserDefaults standardUserDefaults]setObject:language forKey:LANGUAGE_SET];
        [[NSUserDefaults standardUserDefaults]synchronize];
    } @catch (NSException *exception) {
        NSLog(@"%@",exception);
    } @finally {
    }
}

@end
