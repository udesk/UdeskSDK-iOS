//
//  UdeskCustomLocationDataSource.m
//  UdeskSDK
//
//  Created by xuchen on 2017/9/7.
//  Copyright © 2017年 Udesk. All rights reserved.
//

#import "UdeskCustomLocationDataSource.h"
#import "UdeskNearbyModel.h"
#import "UIImage+UdeskSDK.h"

@implementation UdeskCustomLocationDataSource

#pragma mark － TableView datasource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.items.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *const UdeskLocationCellIdntifier = @"UdeskLocationCellIdntifier";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:UdeskLocationCellIdntifier];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:UdeskLocationCellIdntifier];
    }
    
    UdeskNearbyModel *model = self.items[indexPath.row];
    cell.textLabel.text = model.name;
    cell.detailTextLabel.text = model.thoroughfare;
    if (model.isSelect) {
        cell.accessoryView = [[UIImageView alloc] initWithImage:[UIImage udDefaultMarkImage]];
    }
    else {
        cell.accessoryView = nil;
    }
    
    return cell;
}

@end
