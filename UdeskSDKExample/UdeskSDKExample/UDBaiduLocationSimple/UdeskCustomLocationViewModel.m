//
//  UdeskCustomLocationViewModel.m
//  UdeskSDK
//
//  Created by xuchen on 2017/9/7.
//  Copyright © 2017年 Udesk. All rights reserved.
//

#import "UdeskCustomLocationViewModel.h"

@interface UdeskCustomLocationViewModel()<BMKPoiSearchDelegate, BMKLocationServiceDelegate, BMKGeoCodeSearchDelegate>

@property (nonatomic, strong, readwrite) NSArray *locationArray;
@property (nonatomic, strong, readwrite) NSArray *resultArray;

@property (nonatomic, strong) BMKLocationService *locService; //定位
@property (nonatomic, strong) BMKGeoCodeSearch   *codeSearch; //搜素
@property (nonatomic, strong) BMKPoiSearch       *poiSearch;
@property (nonatomic, strong) BMKMapView         *mapView;
@property (nonatomic, assign) BOOL               isNotFirstInit;
@property (nonatomic, copy  ) NSString           *locationName;
@property (nonatomic, strong) UdeskNearbyModel   *selectNearbyModel;

@end

@implementation UdeskCustomLocationViewModel

- (instancetype)initWithMapView:(BMKMapView *)mapView
{
    self = [super init];
    if (self) {
        
        _mapView = mapView;
        //开始定位
        _locService = [[BMKLocationService alloc] init];
        //设置代理
        _locService.delegate = self;
        [_locService startUserLocationService];
        
        _codeSearch = [[BMKGeoCodeSearch alloc] init];
        _codeSearch.delegate = self;
        
        _poiSearch = [[BMKPoiSearch alloc] init];
        _poiSearch.delegate = self;
    }
    return self;
}

- (void)startUserLocationService {
    [_locService startUserLocationService];
}

- (void)stopUserLocationService {
    [_locService stopUserLocationService];
}

/**
 *用户位置更新后，会调用此函数
 *@param userLocation 新的用户位置
 */
- (void)didUpdateBMKUserLocation:(BMKUserLocation *)userLocation
{
    [_mapView updateLocationData:userLocation];
    //如果不是第一次初始化视图, 那么定位点置中
    if (_isNotFirstInit == NO)
    {
        _mapView.centerCoordinate = _locService.userLocation.location.coordinate;
        _isNotFirstInit = YES;
        [self beginReverseGeoCodeSearch:_mapView.centerCoordinate];
        //更新
        if (self.delegate && [self.delegate respondsToSelector:@selector(updateBMKUserLocation)]) {
            [self.delegate updateBMKUserLocation];
        }
    }
}

/** 发起反地理编码搜索 */

- (void)beginReverseGeoCodeSearch:(CLLocationCoordinate2D)pt
{
    //发起反向地理编码检索
    BMKReverseGeoCodeSearchOption *reverseGeoCodeSearchOption = [[BMKReverseGeoCodeSearchOption alloc]init];
    reverseGeoCodeSearchOption.location = pt;
    [_codeSearch reverseGeoCode:reverseGeoCodeSearchOption];
}

#pragma mark - BMKGeoCodeSearchDelegate
/** 接收反向地理编码结果 */
- (void)onGetReverseGeoCodeResult:(BMKGeoCodeSearch *)searcher result:(BMKReverseGeoCodeSearchResult *)result errorCode:(BMKSearchErrorCode)error
{
    //检索结果正常返回
    if (error == BMK_SEARCH_NO_ERROR)
    {
        [self addNerbyModel:result];
    }
}

- (void)addNerbyModel:(BMKReverseGeoCodeSearchResult *)result {
    
    NSMutableArray *array = [NSMutableArray arrayWithArray:_locationArray];
    [array removeAllObjects];
    
    if (_selectNearbyModel) {
        _selectNearbyModel.isSelect = YES;
        [array addObject:_selectNearbyModel];
        _locationName = _selectNearbyModel.name;
    }
    else {
    
        UdeskNearbyModel *model = [[UdeskNearbyModel alloc] init];
        model.name = result.address;
        model.thoroughfare = result.addressDetail.streetName;
        model.coordinate = result.location;
        model.isSelect = YES;
        [array addObject:model];
        _locationName = model.name;
    }
    
    for (BMKPoiInfo *info in result.poiList) {
        
        UdeskNearbyModel *model = [[UdeskNearbyModel alloc] init];
        model.name = info.name;
        model.thoroughfare = info.address;
        model.coordinate = info.pt;
        [array addObject:model];
    }
    _locationArray = [array copy];
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(reloadLocationTableView)]) {
        [self.delegate reloadLocationTableView];
    }
}

- (void)updateNearby:(NSInteger)row {
    
    for (UdeskNearbyModel *model in _locationArray) {
        model.isSelect = NO;
    }
    
    UdeskNearbyModel *model = [_locationArray objectAtIndex:row];
    model.isSelect = YES;
    _locationName = model.name;
    
    [_mapView setCenterCoordinate:model.coordinate animated:YES];
}

//获取定位信息
- (UdeskLocationModel *)getLocationModel {
    
    UdeskLocationModel *model = [[UdeskLocationModel alloc] init];
    model.name = _locationName;
    model.image = [_mapView takeSnapshot];
    model.longitude = _mapView.region.center.longitude;
    model.latitude = _mapView.region.center.latitude;
    
    return model;
}

/*---------- 搜索 -------------*/

- (void)search:(NSString *)text {
    
    //初始化一个周边云检索对象
    BMKPOICitySearchOption *option = [[BMKPOICitySearchOption alloc] init];
    //索引 默认为0
    option.pageIndex = 0;
    //页数默认为10
    option.pageSize = 50;
    //搜索的关键字
    option.keyword = text;
    option.city = @"北京";
    
    //根据中心点、半径和检索词发起周边检索
    [self.poiSearch poiSearchInCity:option];
}

- (void)onGetPoiResult:(BMKPoiSearch*)searcher result:(BMKPOISearchResult*)poiResult errorCode:(BMKSearchErrorCode)errorCode {
    
    //检索结果正常返回
    if (errorCode == BMK_SEARCH_NO_ERROR)
    {
        [self addPoiResult:poiResult];
    }
}

- (void)addPoiResult:(BMKPOISearchResult *)result {
    
    NSMutableArray *array = [NSMutableArray arrayWithArray:_resultArray];
    [array removeAllObjects];
    
    for (BMKPoiInfo *info in result.poiInfoList) {
        
        UdeskNearbyModel *model = [[UdeskNearbyModel alloc] init];
        model.name = info.name;
        model.thoroughfare = info.address;
        model.coordinate = info.pt;
        [array addObject:model];
    }
    
    _resultArray = [array copy];
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(updateSearchResult)]) {
        [self.delegate updateSearchResult];
    }
}

- (void)selectSearchResult:(UdeskNearbyModel *)model {

    _selectNearbyModel = model;
    BMKCoordinateRegion region;
    region.center = model.coordinate;
    [_mapView setRegion:region animated:YES];
    [self beginReverseGeoCodeSearch:_mapView.centerCoordinate];
}

@end
