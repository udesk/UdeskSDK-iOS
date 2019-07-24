//
//  UdeskLocationViewModel.m
//  UdeskSDK
//
//  Created by xuchen on 2017/8/17.
//  Copyright © 2017年 Udesk. All rights reserved.
//

#import "UdeskLocationViewModel.h"
#import "UdeskSDKMacro.h"
#import "UdeskLocationModel.h"
#import "UdeskSDKUtil.h"

static CGFloat kUdeskNearbySpan = 50;

@interface UdeskLocationViewModel()

@property (nonatomic, strong, readwrite) NSMutableArray  *nearbyArray;

@property (nonatomic, strong) CLLocationManager *locationManager;
@property (nonatomic, strong) CLGeocoder *geocoder;
@property (nonatomic, copy  ) NSString *locationName;
@property (nonatomic, copy  ) NSString *thoroughfare; //街道相关信息，例如门牌等

@end

@implementation UdeskLocationViewModel

- (void)startPositioning {
    
    _geocoder = [[CLGeocoder alloc] init];
    _nearbyArray = [NSMutableArray array];
    //请求定位服务
    _locationManager=[[CLLocationManager alloc] init];
    if(![CLLocationManager locationServicesEnabled]||[CLLocationManager authorizationStatus]!=kCLAuthorizationStatusAuthorizedWhenInUse){
        [_locationManager requestWhenInUseAuthorization];
    }
    //设置定位精度
    _locationManager.desiredAccuracy = kCLLocationAccuracyBest;
}

//获取附近地点
- (void)getAroundInfoMationWithCoordinate:(CLLocationCoordinate2D)coordinate completion:(void(^)(void))completionHandler {
    
    MKCoordinateRegion region = MKCoordinateRegionMakeWithDistance(coordinate, kUdeskNearbySpan, kUdeskNearbySpan);
    MKLocalSearchRequest *request = [[MKLocalSearchRequest alloc]init];
    request.region = region;
    request.naturalLanguageQuery = @"landmark";
    MKLocalSearch *localSearch = [[MKLocalSearch alloc]initWithRequest:request];
    [localSearch startWithCompletionHandler:^(MKLocalSearchResponse *response, NSError *error){
        if (!error) {
            [self getAroundInfomation:response.mapItems];
            if (completionHandler) {
                completionHandler();
            }
        }
    }];
}

- (void)getAroundInfomation:(NSArray *)array {
    
    @try {
        
        for (MKMapItem *item in array) {
            MKPlacemark *placemark = item.placemark;
            UdeskNearbyModel *model = [[UdeskNearbyModel alloc]init];
            model.name = placemark.name;
            model.thoroughfare = placemark.thoroughfare;
            model.subThoroughfare = placemark.subThoroughfare;
            model.city = placemark.locality;
            model.coordinate = placemark.location.coordinate;
            [self.nearbyArray addObject:model];
        }
        UdeskNearbyModel *firstModel = (UdeskNearbyModel *)self.nearbyArray.firstObject;
        firstModel.isSelect = YES;
        self.locationName = firstModel.name;
        self.thoroughfare = firstModel.thoroughfare;
        
    } @catch (NSException *exception) {
        NSLog(@"%@",exception);
    } @finally {
    }
}

#pragma mark 根据坐标取得地名
- (void)getAddressByLatitude:(CLLocationDegrees)latitude longitude:(CLLocationDegrees)longitude completion:(void(^)(NSError *error))completionHandler{
    
    //反地理编码
    CLLocation *location=[[CLLocation alloc] initWithLatitude:latitude longitude:longitude];
    [_geocoder reverseGeocodeLocation:location completionHandler:^(NSArray *placemarks, NSError *error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (!error) {
                [self initialData:placemarks];
                [self getAroundInfoMationWithCoordinate:CLLocationCoordinate2DMake(latitude, longitude) completion:^{
             
                    if (completionHandler) {
                        completionHandler(nil);
                    }
                }];
            }else{
                NSLog(@"UdeskSDK：%@",error.localizedDescription);
                if (completionHandler) {
                    completionHandler(error);
                }
            }
        });
    }];
}

#pragma mark - Initial Data
- (void)initialData:(NSArray *)places {
    
    @try {
     
        [self.nearbyArray removeAllObjects];
        
        for (CLPlacemark *placemark in places) {
            UdeskNearbyModel *model = [[UdeskNearbyModel alloc]init];
            model.name = placemark.name;
            model.thoroughfare = placemark.thoroughfare;
            model.subThoroughfare = placemark.subThoroughfare;
            model.city = placemark.locality;
            model.coordinate = placemark.location.coordinate;
            [self.nearbyArray insertObject:model atIndex:0];
        }
        
        UdeskNearbyModel *firstModel = (UdeskNearbyModel *)self.nearbyArray.firstObject;
        firstModel.isSelect = YES;
        self.locationName = firstModel.name;
        self.thoroughfare = firstModel.thoroughfare;
        
    } @catch (NSException *exception) {
        NSLog(@"%@",exception);
    } @finally {
    }
}

//地名取坐标
- (void)getAddressString:(NSString *)addressString completionHandler:(void(^)(CLPlacemark *placemark, NSError *error))completionHandler{
    
    [_geocoder geocodeAddressString:addressString completionHandler:^(NSArray<CLPlacemark *> * _Nullable placemarks, NSError * _Nullable error) {
        
        if (!error) {
            
            CLPlacemark *placemark = placemarks.firstObject;
            if (completionHandler) {
                completionHandler(placemark,nil);
            }
            
        }else{
            NSLog(@"UdeskSDK：%@",error.localizedDescription);
            if (completionHandler) {
                completionHandler(nil,error);
            }
        }
    }];
}

//获取定位信息
- (UdeskLocationModel *)getLocationModel:(CLLocationCoordinate2D)coordinate image:(UIImage *)image {
    
    @try {
     
        UdeskLocationModel *model = [[UdeskLocationModel alloc] init];
        if ([UdeskSDKUtil isBlankString:self.locationName]) {
            self.locationName = @"";
        }
        model.name = self.locationName;
        if ([UdeskSDKUtil isBlankString:self.thoroughfare]) {
            self.thoroughfare = @"";
        }
        model.thoroughfare = self.thoroughfare;
        model.image = image;
        model.longitude = coordinate.longitude;
        model.latitude = coordinate.latitude;
        
        return model;
        
    } @catch (NSException *exception) {
        NSLog(@"%@",exception);
    } @finally {
    }
}

/**
 地图快照
 */
- (void)getMapSnapshotWithRegion:(MKCoordinateRegion)region
                     mapViewSize:(CGSize)mapViewSize
                      completion:(void(^)(UIImage *snapshot))completion {
    // 截图附加选项
    MKMapSnapshotOptions * options = [[MKMapSnapshotOptions alloc] init];
    options.region = region; // 设置截图区域 （地图上的区域）
    options.size = mapViewSize; // 设置截图大小
    options.scale = [UIScreen mainScreen].scale;
    
    MKMapSnapshotter * snapShotter = [[MKMapSnapshotter alloc] initWithOptions:options];
    [snapShotter startWithCompletionHandler:^(MKMapSnapshot * _Nullable snapshot, NSError * _Nullable error) {
        if (!error) {
            UIImage *shotImage = snapshot.image;
            if (shotImage) {
                if (completion) {
                    completion(shotImage);
                }
            }
        }else {
            NSLog(@"UdeskSDK：%@", error.localizedDescription);
        }
    }];
}

- (void)removeAllObjects {

    [self.nearbyArray removeAllObjects];
}

- (NSString *)updateNearby:(NSInteger)row {

    @try {
     
        for (UdeskNearbyModel *model in self.nearbyArray) {
            model.isSelect = NO;
        }
        
        if (row >= self.nearbyArray.count) {
            return @"";
        }
        
        UdeskNearbyModel *model = self.nearbyArray[row];
        model.isSelect = YES;
        self.locationName = model.name;
        self.thoroughfare = model.thoroughfare;
        
        return model.name;
        
    } @catch (NSException *exception) {
        NSLog(@"%@",exception);
    } @finally {
    }
}

@end
