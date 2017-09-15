//
//  UdeskLocationViewModel.h
//  UdeskSDK
//
//  Created by xuchen on 2017/8/17.
//  Copyright © 2017年 Udesk. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "UdeskNearbyModel.h"
@class UdeskLocationModel;

@interface UdeskLocationViewModel : NSObject

@property (nonatomic, strong, readonly) NSMutableArray  *nearbyArray;

//开始定位
- (void)startPositioning;

//坐标取得地名
- (void)getAddressByLatitude:(CLLocationDegrees)latitude longitude:(CLLocationDegrees)longitude completion:(void(^)(NSError *error))completionHandler;

//地名取坐标
- (void)getAddressString:(NSString *)addressString completionHandler:(void(^)(CLPlacemark *placemark, NSError *error))completionHandler;

//获取定位信息
- (UdeskLocationModel *)getLocationModel:(CLLocationCoordinate2D)coordinate image:(UIImage *)image;

//地图快照
- (void)getMapSnapshotWithRegion:(MKCoordinateRegion)region
                     mapViewSize:(CGSize)mapViewSize
                      completion:(void(^)(UIImage *snapshot))completion;

- (void)removeAllObjects;

- (NSString *)updateNearby:(NSInteger)row;

@end
