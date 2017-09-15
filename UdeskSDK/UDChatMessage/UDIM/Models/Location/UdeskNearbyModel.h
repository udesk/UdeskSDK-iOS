//
//  UdeskNearbyModel.h
//  UdeskSDK
//
//  Created by xuchen on 2017/8/16.
//  Copyright © 2017年 Udesk. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>

@interface UdeskNearbyModel : NSObject

@property (nonatomic, copy) NSString *name;// eg. Apple Inc
@property (nonatomic, copy) NSString *thoroughfare;//street name, eg. Infinite Loop
@property (nonatomic, copy) NSString *subThoroughfare;
@property (nonatomic, copy) NSString *city;
@property (nonatomic, assign) BOOL isSelect;
@property (nonatomic) CLLocationCoordinate2D coordinate;

@end
