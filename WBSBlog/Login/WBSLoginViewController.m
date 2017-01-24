//
//  WBSLoginViewController.m
//  WBSBlog
//
//  Created by Weberson on 16/7/20.
//  Copyright © 2016年 Weberson. All rights reserved.
//

#import "WBSLoginViewController.h"
#import "WBSSelectBlogViewController.h"
#import "WBSNetRequest.h"



@interface WBSLoginViewController () <UITextFieldDelegate, UIGestureRecognizerDelegate>

/**
 *  xmlrpcURL
 */

@property (weak, nonatomic) IBOutlet UITextField *baseURLField;
/**
 *  用户名
 */
@property (weak, nonatomic) IBOutlet UITextField *usernameField;
/**
 *  密码
 */
@property (weak, nonatomic) IBOutlet UITextField *passwordField;
/**
 *  是否启用JSON API
 */
@property (weak, nonatomic) IBOutlet UIButton* apiTypeButton;

/**
 *  网址api博客类型尾巴
 */
@property(nonatomic, copy) NSString *footerPrefix;
/**
 *  网址尾巴api
 */
@property(nonatomic, copy) NSString *footerApi;


@end

@implementation WBSLoginViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    //判断登录状态
    WBSApiInfo *apiInfo = [WBSConfig getAuthoizedApiInfo];
    if (apiInfo) {
        // 已经登录
        KLog(@"Current baseURL:%@ username:%@ password:%@-- 已经登录！", apiInfo.baseURL, apiInfo.username, apiInfo.password);
        //已经登录过，跳转到主界面，停止程序继续
        [WBSUtils goToMainViewController];
        return;
    }
    
    //初始化导航栏
    self.navigationItem.title = @"登录";
    
    self.navigationItem.rightBarButtonItem                                                     = [[UIBarButtonItem alloc] initWithTitle:@"选择" style:UIBarButtonItemStylePlain target:self action:@selector(selectBlogAction:)];
    
    self.view.backgroundColor = [UIColor themeColor];
    
    // 默认为wordpress博客
    self.footerApi = @"xmlrpc.php";
    UIView *indexView = [[[NSBundle mainBundle]loadNibNamed:@"WBSLogin" owner:self options:nil]lastObject];
    self.view = indexView;
    
    
}



#pragma mark 温馨提示 按钮
- (IBAction)tipsButtonDidClick:(UIButton *)sender {
    
    // 修改提示文字信息
    KLog(@"修改提示文字信息");
    
}

#pragma mark 选择api接口类型按钮
- (IBAction)apiTypeButtonDidClick:(UIButton *)sender {
    
    self.baseURLField.text = @"";
    if (!self.apiTypeButton.isSelected) {
        KLog(@"开启JSON API");
        self.apiTypeButton.selected = YES;
        _baseURLField.placeholder = @"请输入JSON API入口地址";
    } else {
        KLog(@"开启XMLRPC API");
        self.apiTypeButton.selected = NO;
        _baseURLField.placeholder = @"www.jack_blog.com";
    }
}



#pragma mark 选择博客类型
- (void)selectBlogAction:(UIButton *)button {
    
    WBSSelectBlogViewController *selectBlogController = [[WBSSelectBlogViewController alloc] init];
    [self.navigationController pushViewController:selectBlogController animated:YES];
    
}

#pragma mark 登录相关
- (IBAction)loginButtonDidClick:(UIButton *)sender {
    
    // 临时添加默认账号
    _baseURLField.text = KbaseUrl;
    _usernameField.text = KuserName;
    _passwordField.text = KpassWord;
    
    NSString *baseURL = [_baseURLField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    NSString *username = [_usernameField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    NSString *password = [_passwordField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    
    // 验证账号密码 格式
    if ([WBSUtils checkUrlString:baseURL userNameStr:username passWord:password]) {
       [WBSUtils showStatusMessage:@"登录中..."];
    }else{
        return;
    }
    
//    BOOL isLoginSuccess  = [WBSNetRequest postToLoginWithSiteUrlStr:baseURL userNameStr:username PassWordStr:password isJsonAPi:self.apiTypeButton.isSelected];
    
    [WBSNetRequest postToLogin:^(BOOL isLoginSuccess, NSString * errorMsg) {
        // 登录结果
        if (isLoginSuccess) {
            [WBSUtils saveDataWithBool:NO forKey:WBSGuestLoginMode];
            [WBSUtils goToMainViewController];
        }else{
            [WBSUtils showErrorMessage:errorMsg];
        }
    } SiteUrlStr:baseURL userNameStr:username PassWordStr:password isJsonAPi:self.apiTypeButton.isSelected];
    
    
}
/// 游客登录
- (IBAction)guestLogin:(UIButton *)sender {

    [WBSUtils saveDataWithBool:YES forKey:WBSGuestLoginMode];
    [WBSUtils goToMainViewController];
    
}







@end
