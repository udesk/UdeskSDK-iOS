//
//  UdeskLocationResultViewModel.m
//  UdeskSDK
//
//  Created by xuchen on 2017/8/17.
//  Copyright © 2017年 Udesk. All rights reserved.
//

#import "UdeskLocationResultViewModel.h"
#import "UdeskNearbyModel.h"
#import "NSArray+UdeskSDK.h"

#define UdeskLocationResultCellIdntifier @"UdeskLocationResultCellIdntifier"

@interface UdeskLocationResultViewModel()

@property (nonatomic, strong) NSMutableArray *resultArray;

@end

@implementation UdeskLocationResultViewModel

- (instancetype)init
{
    self = [super init];
    if (self) {
        _resultArray = [NSMutableArray array];
    }
    return self;
}

- (void)searchPlace:(NSString *)place completion:(void(^)(void))completion {

    [self.resultArray removeAllObjects];
    MKLocalSearchRequest *request = [[MKLocalSearchRequest alloc]init];
    request.naturalLanguageQuery = place;
    MKLocalSearch *localSearch = [[MKLocalSearch alloc]initWithRequest:request];
    [localSearch startWithCompletionHandler:^(MKLocalSearchResponse *response, NSError *error){
        
        if (!error) {
            //遍历结果数组
            [self getAroundInfomation:response.mapItems];
            if (completion) {
                completion();
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
            [self.resultArray addObject:model];
        }
    } @catch (NSException *exception) {
        NSLog(@"%@",exception);
    } @finally {
    }
}

#pragma mark － TableView datasource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.resultArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:UdeskLocationResultCellIdntifier];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:UdeskLocationResultCellIdntifier];
    }
    
    UdeskNearbyModel *model = [self.resultArray objectAtIndexCheck:indexPath.row];
    cell.textLabel.text = model.name;
    cell.detailTextLabel.text = model.thoroughfare;
    
    return cell;
}

#pragma mark - TableView delegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
    
    UdeskNearbyModel *model = [self.resultArray objectAtIndexCheck:indexPath.row];
    if (self.didSeledctSearchResultBlock) {
        self.didSeledctSearchResultBlock(model);
    }
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    if (self.scrollViewWillBeginDraggingBlock) {
        self.scrollViewWillBeginDraggingBlock(scrollView);
    }
}

@end
