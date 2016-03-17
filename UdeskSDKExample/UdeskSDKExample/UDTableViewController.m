//
//  UDTableViewController.m
//  UdeskSDKExample
//
//  Created by xuchen on 16/3/17.
//  Copyright © 2016年 xuchen. All rights reserved.
//

#import "UDTableViewController.h"
#import "UDManager.h"
#import "UDAgentNavigationMenu.h"
#import "UDChatViewController.h"
#import "UDFoundationMacro.h"
#import "UDTools.h"

typedef enum : NSUInteger {
    
    UDSDKDemoManagerAgentId,
    UDSDKDemoManagerGroupId,
    UDSDKDemoManagerSDKVersion,
    UDSDKDemoManagerAgentMenu,
    
} UDSDKDemoManager;

@interface UDTableViewController () <UIAlertViewDelegate>

@property (nonatomic, strong) NSArray *udeskOtherApiArray;

@end

@implementation UDTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    UILabel *sdkLabel = [[UILabel alloc] initWithFrame:CGRectMake((UD_SCREEN_WIDTH-100)/2, 0, 100, 44)];
    sdkLabel.text = @"其它API";
    sdkLabel.backgroundColor = [UIColor clearColor];
    sdkLabel.textAlignment = NSTextAlignmentCenter;
    sdkLabel.textColor = [UIColor whiteColor];
    self.navigationItem.titleView = sdkLabel;
    
    //删除多余的cell
    UIView *footerView = [[UIView alloc] initWithFrame:CGRectZero];
    [self.tableView setTableFooterView:footerView];
    
    
    self.udeskOtherApiArray = @[
                                @"指定客服 id 进行分配",
                                @"指定客服组 id 进行分配",
                                @"指引客户选择客服组",
                                @"查看当前 SDK 版本号"
                                ];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {

    return self.udeskOtherApiArray.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *developerCellId =  @"developerCellId";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:developerCellId];
    
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:developerCellId];
    }
    
    cell.textLabel.text = self.udeskOtherApiArray[indexPath.row];
    
    cell.textLabel.font = [UIFont systemFontOfSize:15];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    //取消点击效果
    [tableView deselectRowAtIndexPath:indexPath animated:YES];

    switch (indexPath.row) {
        case 0: {
            
            NSString *title = @"输入一个客服 id 进行指定分配";
            
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:title message:nil delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
            alertView.alertViewStyle = UIAlertViewStylePlainTextInput;
            
            alertView.tag = 1000+UDSDKDemoManagerAgentId;
            
            [alertView show];
            
            break;
        }
        case 1: {
            
            NSString *title = @"输入一个客服组 id 进行指定分配";
            
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:title message:nil delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
            alertView.alertViewStyle = UIAlertViewStylePlainTextInput;
            
            alertView.tag = 1000+UDSDKDemoManagerGroupId;
            
            [alertView show];
            
            break;
        }
        case 2: {
            

            UDAgentNavigationMenu *agentMenu = [[UDAgentNavigationMenu alloc] init];
            
            [self.navigationController pushViewController:agentMenu animated:YES];
            
            
            break;
        }
            
        case 3: {
            
            NSString *title = [NSString stringWithFormat:@"当前Udesk SDK 版本号是：%@ ",[UDManager udeskSDKVersion]];
            
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:title message:nil delegate:self cancelButtonTitle:nil otherButtonTitles:@"确定", nil];
            
            alertView.tag = 1000+UDSDKDemoManagerSDKVersion;
            
            [alertView show];
            
            break;
        }
            
        default:
            break;
    }
    
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {

    if (buttonIndex == 1) {

        switch (alertView.tag) {
            case 1000+UDSDKDemoManagerAgentId: {
                
                NSString *agent_id = [alertView textFieldAtIndex:0].text;
                
                UDChatViewController *chat = [[UDChatViewController alloc] init];
                
                chat.agent_id = agent_id;
                
                [self.navigationController pushViewController:chat animated:YES];
                
                break;
            }
            case 1000+UDSDKDemoManagerGroupId: {
                
                NSString *group_id = [alertView textFieldAtIndex:0].text;
                
                UDChatViewController *chat = [[UDChatViewController alloc] init];
                
                chat.group_id = group_id;
                
                [self.navigationController pushViewController:chat animated:YES];
                
                break;
            }
            case 1000+UDSDKDemoManagerAgentMenu:{
                
                
                
                break;
            }
            case 1000+UDSDKDemoManagerSDKVersion:{
                
                
                
                break;
                
            }
            default:
                break;
        }
    
    }
    
}

- (void)viewWillAppear:(BOOL)animated {
    
    [super viewWillAppear:animated];
    
    if (ud_isIOS6) {
        self.navigationController.navigationBar.tintColor = [UDTools colorWithHexString:@"3565df"];
    } else {
        self.navigationController.navigationBar.barTintColor = [UDTools colorWithHexString:@"3565df"];
        self.navigationController.navigationBar.tintColor = [UIColor whiteColor];
    }

}

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
