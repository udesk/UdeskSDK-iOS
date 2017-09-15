//
//  UdeskCustomLocationViewModel.h
//  UdeskSDK
//
//  Created by xuchen on 2017/9/7.
//  Copyright © 2017年 Udesk. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <BaiduMapAPI_Map/BMKMapComponent.h>
#import <BaiduMapAPI_Search/BMKSearchComponent.h>
#import <BaiduMapAPI_Location/BMKLocationComponent.h>
#import <BaiduMapAPI_Base/BMKBaseComponent.h>

#import "UdeskNearbyModel.h"
#import "UdeskLocationModel.h"

@protocol UdeskCustomLocationViewModelDelegate <NSObject>

- (void)updateBMKUserLocation;
- (void)reloadLocationTableView;

- (void)updateSearchResult;

@end

@interface UdeskCustomLocationViewModel : NSObject

@property (nonatomic, strong, readonly) NSArray *locationArray;
@property (nonatomic, strong, readonly) NSArray *resultArray;

@property (nonatomic, weak) id<UdeskCustomLocationViewModelDelegate> delegate;

- (instancetype)initWithMapView:(BMKMapView *)mapView;

- (void)startUserLocationService;
- (void)stopUserLocationService;
- (void)beginReverseGeoCodeSearch:(CLLocationCoordinate2D)pt;
- (void)updateNearby:(NSInteger)row;
- (UdeskLocationModel *)getLocationModel;

//搜索
- (void)search:(NSString *)text;
- (void)selectSearchResult:(UdeskNearbyModel *)model;

@end
