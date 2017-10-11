//
//  IndexViewController.m
//  Warmer
//
//  Created by apple on 2016/11/20.
//  Copyright © 2016年 apple. All rights reserved.
//

#import "IndexViewController.h"
#import "RegisterViewController.h"
#import "AddDeviceViewController.h"
#import "DeviceControlViewController.h"
#import "CorporateCultureViewController.h"
#import "HelpViewController.h"
#import "AboutUsViewController.h"

#import "XlinkExportObject.h"
#import "UserModel.h"
#import "DeviceModel.h"

@interface IndexViewController ()<UITableViewDelegate,UITableViewDataSource>
{
    NSArray *menuIconArray;
    NSArray *menuLabelName;
    __weak IBOutlet UIView *menuBgView;
    int beganX;
}
@property (weak, nonatomic) IBOutlet UITableView *menuTable;
@property (weak, nonatomic) IBOutlet UITableView *deviceTable;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *menuTableWidthConstant;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *menuTableLeadingConstant;
@end

@implementation IndexViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.automaticallyAdjustsScrollViewInsets = false;
    self.navigationController.interactivePopGestureRecognizer.enabled = NO;
    
    [self setMenuTableView];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateDeviceList:) name:kUpdateDeviceList object:nil];
    
    [self AddExpDevice];
}

-(void)AddExpDevice{
    BOOL isAddExpDevice = [[NSUserDefaults standardUserDefaults] boolForKey:@"isAddExpDevice"];
    if (isAddExpDevice) {
        if (DATASOURCE.user.deviceList.count > 0) {
            DeviceModel *tempDeviceModel = DATASOURCE.user.deviceList[0];
            if (tempDeviceModel.isExpDevice.boolValue) {
                return;
            }
        }

        DeviceModel *deviceModel = [DeviceModel creatExpDevice];
        
        [DATASOURCE.user.deviceList insertObject:deviceModel atIndex:0];
        
        [DATASOURCE saveDeviceModelWithMac:nil withIsUpload:NO];
        
        [[NSNotificationCenter defaultCenter] postNotificationName:kUpdateDeviceList object:nil];
    }
}

-(void)updateDeviceList:(NSNotification *)noti{
    
    [_deviceTable performSelectorOnMainThread:@selector(reloadData) withObject:nil waitUntilDone:NO];
    
}

-(void)viewDidLayoutSubviews{
    if (!menuBgView.isHidden) {
        _menuTable.x = 0;
        menuBgView.hidden = NO;
        
        menuBgView.backgroundColor = [UIColor colorWithWhite:0 alpha:0.5f] ;
    }
}

#pragma mark - set tableview
-(void)setMenuTableView{
    self.menuTableWidthConstant.constant = MainWidth -75;
    self.menuTableLeadingConstant.constant = -(MainWidth - 75);
    //侧滑菜单图标名字数组
    menuLabelName = @[NSLocalStr(@"添加设备"),NSLocalStr(@"企业文化"),NSLocalStr(@"系统帮助"),NSLocalStr(@"关于软件"),NSLocalStr(@"退出登录")];
    menuIconArray = @[@"add_btn",@"culture_btn",@"help_btn",@"about_btn",@"dignout_btn"];
    //手势
    UIPanGestureRecognizer *swipeGesture = [[UIPanGestureRecognizer alloc]initWithTarget:self action:@selector(showMenu:)];
    [self.view addGestureRecognizer:swipeGesture];
    
    UIView *tableHeaderView = [[UIView alloc]init];
    tableHeaderView.width = 180;
    tableHeaderView.height = 200;
    tableHeaderView.backgroundColor = [UIColor colorWithWholeRed:233 green:233 blue:233];
    UIImageView *image = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"app-icon-iphone"]];
    image.width = 75;
    image.height = 75;
    image.x = 20;
    image.centerY = tableHeaderView.height*0.5f+10;
    [tableHeaderView addSubview:image];
    
    UILabel *nameLabel = [[UILabel alloc]init];
    nameLabel.text = DATASOURCE.user.nickName;
    [nameLabel sizeToFit];
    nameLabel.x = image.MaxX +10;
    nameLabel.y = image.y;
    nameLabel.textColor = [UIColor blackColor];
    [tableHeaderView addSubview:nameLabel];
    
    UILabel *accountLabel = [[UILabel alloc]init];
    accountLabel.text = DATASOURCE.user.email;
    accountLabel.font = [UIFont systemFontOfSize:17];
    [accountLabel sizeToFit];
    accountLabel.x = image.MaxX +10;
    accountLabel.y = image.MaxY-accountLabel.height;
    accountLabel.textColor = [UIColor blackColor];
    [tableHeaderView addSubview:accountLabel];
    
    _menuTable.tableHeaderView = tableHeaderView;
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(hideMenu)];
    [menuBgView addGestureRecognizer:tap];
}

#pragma mark MenuAction
-(void)showMenu:(UIPanGestureRecognizer *)paramSender{
    CGPoint imagePoint = [paramSender locationInView:self.view];
    
    if (paramSender.state == UIGestureRecognizerStateBegan) {
        
        beganX = imagePoint.x;
    }
    
    if (beganX < 40) {
        
        menuBgView.hidden = NO;
        
        [UIApplication sharedApplication].statusBarStyle = UIStatusBarStyleDefault;
        
        if (imagePoint.x < 0) {
            imagePoint.x = 0;
        }
        if (imagePoint.x > 220) {
            imagePoint.x = 220;
        }
        
        _menuTable.x = imagePoint.x-220;
        menuBgView.backgroundColor = [UIColor colorWithWhite:0 alpha:(imagePoint.x/180.0f)*0.5f] ;
    }
    
    if (paramSender.state == UIGestureRecognizerStateEnded) {
        
        if (beganX < 40) {
            if (imagePoint.x > 100) {
                
                [UIView animateWithDuration:0.3f animations:^{
                    _menuTable.x = 0;
                    menuBgView.hidden = NO;
                }];
                
            }else{
                
                [self hideMenu];
            }
        }
        
        beganX = 0;
    }
    
}

-(void)hideMenu{
    
    menuBgView.hidden = YES;
    
    [UIView animateWithDuration:0.3f animations:^{
        _menuTable.x = -self.menuTableWidthConstant.constant;
        [UIApplication sharedApplication].statusBarStyle = UIStatusBarStyleLightContent;
    }];
    
    
}

#pragma mark showMenuBtnAction
- (IBAction)showMenuBtn:(id)sender {
    
    [UIApplication sharedApplication].statusBarStyle = UIStatusBarStyleDefault;
    
    [UIView animateWithDuration:0.3f animations:^{
        _menuTable.x = 0;
        menuBgView.hidden = NO;
        
        menuBgView.backgroundColor = [UIColor colorWithWhite:0 alpha:0.5f] ;
    }];
    
}

#pragma mark - tableViewDelegate

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if (tableView == _menuTable) {
        return menuIconArray.count;
    }else{
        return DATASOURCE.user.deviceList.count;
    }
    
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    if (tableView == _menuTable) {
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"menuCell"];
        
        UIImageView *menuImage = [cell viewWithTag:111];
        menuImage.image = [UIImage imageNamed:menuIconArray[indexPath.row]];
        
        UILabel *menuName = [cell viewWithTag:112];
        menuName.text = menuLabelName[indexPath.row];
        
        
        [cell setNeedsDisplay];
        
        return cell;
    }else{
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"deviceCell"];
     
        DeviceModel *deviceModel = DATASOURCE.user.deviceList[indexPath.row];

//        UIImageView *deviceImage = [cell viewWithTag:111];
        
        UILabel *deviceName = [cell viewWithTag:112];
        deviceName.text = deviceModel.name;
        
        [cell setNeedsDisplay];

        return cell;
    }
    
    
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
    
    if (tableView == _menuTable) {
        switch (indexPath.row) {
            case 0:
            {
                menuBgView.hidden = YES;
                [self hideMenu];
                [self addDeviceAction:nil];
            }
                break;
            case 1:
            {
                //企业文化
                CorporateCultureViewController *vc = [self loadViewControllerWithStoryboardName:@"Index" withViewControllerName:@"CorporateCultureViewController"];
                
                [self.navigationController pushViewController:vc animated:YES];
            }
                break;
            case 2:
            {
                //系统帮助
                HelpViewController *vc = [self loadViewControllerWithStoryboardName:@"Index" withViewControllerName:@"HelpViewController"];
                
                [self.navigationController pushViewController:vc animated:YES];
            }
                break;
            case 3:
            {
                //关于软件
                AboutUsViewController *vc = [self loadViewControllerWithStoryboardName:@"Index" withViewControllerName:@"AboutUsViewController"];
                
                [self.navigationController pushViewController:vc animated:YES];
            }
                break;
            case 4:
            {
                //退出登陆
                UIAlertController *alertC = [UIAlertController alertControllerWithTitle:NSLocalStr(@"是否退出登录") message:nil preferredStyle:UIAlertControllerStyleAlert];
                
                UIAlertAction *okAction = [UIAlertAction actionWithTitle:NSLocalStr(@"确定") style:(UIAlertActionStyleDefault) handler:^(UIAlertAction *action) {
                    
                    
                    for (UIViewController *subVC in self.navigationController.childViewControllers) {
                        if ([subVC isKindOfClass:[IndexViewController class]]) {
                            [subVC dismissViewControllerAnimated:NO completion:^{
                                [subVC removeFromParentViewController];
                            }];
                        }
                        
                    }
                    
                    [[NSNotificationCenter defaultCenter] postNotificationName:kLogout object:nil];
                    
                }];
                
                UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:NSLocalStr(@"取消") style:(UIAlertActionStyleDestructive) handler:^(UIAlertAction *action) {
                    
                }];

                [alertC addAction:cancelAction];
                [alertC addAction:okAction];
                
                [self presentViewController:alertC animated:YES completion:nil];
            }
                break;
            default:
                break;
        }
    }else{
        DeviceModel *deviceModel = DATASOURCE.user.deviceList[indexPath.row];
        
        //            if (deviceModel.device.isConnected) {
        
        DeviceControlViewController *vc =
        [self loadViewControllerWithStoryboardName:@"DeviceControl" withViewControllerName:@"DeviceControlViewController"];
        vc.deviceModel = deviceModel;
        
        [self.navigationController pushViewController:vc animated:YES];
        
        //            }else{
        
        //                [[XLinkExportObject sharedObject] connectDevice:deviceModel.device andAuthKey:deviceModel.device.accessKey];
        //                [self showWarningAlert:@"设备不在线"];
        //                UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"DeviceControl" bundle:nil];
        //
        //                DeviceControlViewController *vc =[storyboard instantiateViewControllerWithIdentifier:@"DeviceControlViewController"];
        //                vc.deviceModel = deviceModel;
        //
        //                [self.navigationController pushViewController:vc animated:YES];
        //            }

        
     
        
    }
    
    
}

#pragma mark - addDevice
- (IBAction)addDeviceAction:(id)sender {
    
    //添加设备
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"AddDevice" bundle:nil];
    
    AddDeviceViewController *vc =[storyboard instantiateViewControllerWithIdentifier:@"AddDeviceViewController"];
    
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
