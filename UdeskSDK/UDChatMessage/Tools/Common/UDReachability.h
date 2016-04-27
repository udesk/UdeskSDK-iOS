//
//  UDReachability.h
//  UdeskSDK
//
//  Created by xuchen on 16/4/15.
//  Copyright © 2016年 xuchen. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <SystemConfiguration/SystemConfiguration.h>

//! Project version number for MacOSReachability.
FOUNDATION_EXPORT double UDReachabilityVersionNumber;

//! Project version string for MacOSReachability.
FOUNDATION_EXPORT const unsigned char UDReachabilityVersionString[];

/**
 * Create NS_ENUM macro if it does not exist on the targeted version of iOS or OS X.
 *
 * @see http://nshipster.com/ns_enum-ns_options/
 **/
#ifndef NS_ENUM
#define NS_ENUM(_type, _name) enum _name : _type _name; enum _name : _type
#endif

extern NSString *const kUDReachabilityChangedNotification;

typedef NS_ENUM(NSInteger, UDNetworkStatus) {
    // Apple NetworkStatus Compatible Names.
    UDNotReachable = 0,
    UDReachableViaWiFi = 2,
    UDReachableViaWWAN = 1
};

@class UDReachability;

typedef void (^UDNetworkReachable)(UDReachability * reachability);
typedef void (^UDNetworkUnreachable)(UDReachability * reachability);
typedef void (^UDNetworkReachability)(UDReachability * reachability, SCNetworkConnectionFlags flags);


@interface UDReachability : NSObject

@property (nonatomic, copy) UDNetworkReachable    reachableBlock;
@property (nonatomic, copy) UDNetworkUnreachable  unreachableBlock;
@property (nonatomic, copy) UDNetworkReachability reachabilityBlock;

@property (nonatomic, assign) BOOL uDreachableOnWWAN;


+(instancetype)reachabilityWithHostname:(NSString*)hostname;
// This is identical to the function above, but is here to maintain
//compatibility with Apples original code. (see .m)
+(instancetype)reachabilityWithHostName:(NSString*)hostname;
+(instancetype)reachabilityForInternetConnection;
+(instancetype)reachabilityWithAddress:(void *)hostAddress;
+(instancetype)reachabilityForLocalWiFi;

-(instancetype)initWithReachabilityRef:(SCNetworkReachabilityRef)ref;

-(BOOL)startNotifier;
-(void)stopNotifier;

-(BOOL)isReachable;
-(BOOL)isReachableViaWWAN;
-(BOOL)isReachableViaWiFi;

// WWAN may be available, but not active until a connection has been established.
// WiFi may require a connection for VPN on Demand.
-(BOOL)isConnectionRequired; // Identical DDG variant.
-(BOOL)connectionRequired; // Apple's routine.
// Dynamic, on demand connection?
-(BOOL)isConnectionOnDemand;
// Is user intervention required?
-(BOOL)isInterventionRequired;

-(UDNetworkStatus)currentReachabilityStatus;
-(SCNetworkReachabilityFlags)reachabilityFlags;
-(NSString*)currentReachabilityString;
-(NSString*)currentReachabilityFlags;


@end
