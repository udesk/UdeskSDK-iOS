//
//  UdeskTableViewController.m
//  UdeskSDKExample
//
//  Created by xuchen on 16/3/17.
//  Copyright © 2016年 xuchen. All rights reserved.
//

#import "UdeskTableViewController.h"
#import "UDManager.h"
#import "UdeskAgentNavigationMenu.h"
#import "UdeskChatViewController.h"
#import "UdeskFoundationMacro.h"
#import "UdeskTools.h"
#import "UdeskAlertController.h"

@interface UdeskTableViewController ()

@property (nonatomic, strong) NSArray *udeskOtherApiArray;

@end

@implementation UdeskTableViewController

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
            
            UdeskAlertController *inputAgentIdAlert = [UdeskAlertController alertWithTitle:title message:nil];
            __weak UdeskAlertController *weakInputAgentIdAlert = inputAgentIdAlert;
            
            [inputAgentIdAlert addAction:[UdeskAlertAction actionWithTitle:@"确定" style:UDAlertActionStyleDefault handler:^(UdeskAlertAction * _Nonnull action) {
                
                [weakInputAgentIdAlert.textField resignFirstResponder];
                
                if (weakInputAgentIdAlert.textField.text.length>0) {
                    
                    UdeskChatViewController *chat = [[UdeskChatViewController alloc] init];
                    
                    chat.agent_id = weakInputAgentIdAlert.textField.text;
                    
                    [self.navigationController pushViewController:chat animated:YES];

                }
                else {
                    
                    UdeskAlertController *completionAlert = [UdeskAlertController alertWithTitle:nil message:@"请正确输入id"];
                    [completionAlert addCloseActionWithTitle:@"确定" Handler:NULL];
                    
                    [completionAlert showWithSender:nil controller:nil animated:YES completion:NULL];
                }

                
            }]];
            
            [inputAgentIdAlert addCloseActionWithTitle:@"取消" Handler:nil];
            [inputAgentIdAlert addTextFieldWithConfigurationHandler:nil];
            
            [inputAgentIdAlert showWithSender:nil controller:nil animated:YES completion:NULL];
            
            break;
        }
        case 1: {
            
            NSString *title = @"输入一个客服组 id 进行指定分配";
            
            UdeskAlertController *inputGroupIdAlert = [UdeskAlertController alertWithTitle:title message:nil];
            __weak UdeskAlertController *weakInputGroupIdAlert = inputGroupIdAlert;
            
            [inputGroupIdAlert addAction:[UdeskAlertAction actionWithTitle:@"确定" style:UDAlertActionStyleDefault handler:^(UdeskAlertAction * _Nonnull action) {
                
                [weakInputGroupIdAlert.textField resignFirstResponder];
                
                
                if (weakInputGroupIdAlert.textField.text.length>0) {
                    
                    UdeskChatViewController *chat = [[UdeskChatViewController alloc] init];
                    
                    chat.group_id = weakInputGroupIdAlert.textField.text;
                    
                    [self.navigationController pushViewController:chat animated:YES];
                }
                else {
                
                    UdeskAlertController *completionAlert = [UdeskAlertController alertWithTitle:nil message:@"请正确输入id"];
                    [completionAlert addCloseActionWithTitle:@"确定" Handler:NULL];
                    
                    [completionAlert showWithSender:nil controller:nil animated:YES completion:NULL];
                }
                
                
            }]];
             
            [inputGroupIdAlert addCloseActionWithTitle:@"取消" Handler:nil];
             
            [inputGroupIdAlert addTextFieldWithConfigurationHandler:nil];
            
            [inputGroupIdAlert showWithSender:nil controller:nil animated:YES completion:NULL];
            
            break;
        }
        case 2: {
            
            UdeskAgentNavigationMenu *agentMenu = [[UdeskAgentNavigationMenu alloc] init];
            
            [self.navigationController pushViewController:agentMenu animated:YES];
            
            
            break;
        }
            
        case 3: {
            
            NSString *title = [NSString stringWithFormat:@"当前Udesk SDK 版本号是：%@ ",[UDManager udeskSDKVersion]];
            
            UdeskAlertController *notNetworkAlert = [UdeskAlertController alertWithTitle:title message:nil];
            [notNetworkAlert addCloseActionWithTitle:@"确定" Handler:NULL];
            [notNetworkAlert showWithSender:nil controller:nil animated:YES completion:NULL];
            
            break;
        }
            
        default:
            break;
    }
    
}

- (void)viewWillAppear:(BOOL)animated {
    
    [super viewWillAppear:animated];
    
    if (ud_isIOS6) {
        self.navigationController.navigationBar.tintColor = [UdeskTools colorWithHexString:@"3565df"];
    } else {
        self.navigationController.navigationBar.barTintColor = [UdeskTools colorWithHexString:@"3565df"];
        self.navigationController.navigationBar.tintColor = [UIColor whiteColor];
    }

}

- (void)viewWillDisappear:(BOOL)animated {
    
    [super viewWillDisappear:animated];
    
    if (ud_isIOS6) {
        self.navigationController.navigationBar.tintColor = UdeskConfig.oneSelfNavcigtionColor;
    } else {
        self.navigationController.navigationBar.barTintColor = UdeskConfig.oneSelfNavcigtionColor;
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
