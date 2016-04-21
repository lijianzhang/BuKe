//
//  JZRegisterViewController.m
//  BiShe
//
//  Created by Jz on 16/1/3.
//  Copyright © 2016年 Jz. All rights reserved.
//

#import "JZRegisterViewController.h"
#import "JZWildDog.h"
#import "JZPromptView.h"

@interface JZRegisterViewController ()
@property (weak, nonatomic) IBOutlet UITextField *email;
@property (weak, nonatomic) IBOutlet UITextField *name;
@property (weak, nonatomic) IBOutlet UITextField *password;
@property (weak, nonatomic) IBOutlet UITextField *repeatPassword;
@property (weak, nonatomic) IBOutlet UIButton *registerButton;
@property (nonatomic,strong) UIActivityIndicatorView * refurbish;
@end

@implementation JZRegisterViewController

- (UIActivityIndicatorView *)refurbish{
    if (!_refurbish) {
        _refurbish = [[UIActivityIndicatorView alloc]init];
    }
    return _refurbish;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (IBAction)createUser:(id)sender {

    self.refurbish.frame = CGRectMake(10, 10, 20, 20);
    [self.registerButton  addSubview:self.refurbish];
    __weak typeof(self) weakself = self;
    if (![self verifyUserData]) {
        return;
    }
    [self.refurbish startAnimating];

    [[JZWildDog WildDog]createUser:self.email.text password:self.password.text name:self.name.text withSuccess:^{
        [[JZWildDog WildDog] loginUser:weakself.email.text password:weakself.password.text WithBlock:^(NSError *error, WAuthData *authData) {
            [self.navigationController dismissViewControllerAnimated:YES completion:nil];
            [self.refurbish stopAnimating];
            [self.refurbish removeFromSuperview];
        } fail:^(NSString *string) {
            JZPromptView *prompt = [JZPromptView prompt];
            [prompt setColor:[UIColor redColor]];
            [prompt starShowWithTitle:string];
            [self.refurbish stopAnimating];
            [self.refurbish removeFromSuperview];


        }];
        
    } fail:^(NSString *string) {
        JZPromptView *prompt = [JZPromptView prompt];
        [prompt setColor:[UIColor redColor]];
        [prompt starShowWithTitle:string];
        [self.refurbish stopAnimating];


    }];
}

- (IBAction)close:(id)sender{

    [self.navigationController popViewControllerAnimated:YES];
}

- (BOOL)verifyUserData{
    JZPromptView *prompt = [JZPromptView prompt];
    [prompt setColor:[UIColor redColor]];
    NSString *emailRegex = @"[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}";
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", emailRegex];
    if (![predicate evaluateWithObject:self.email.text]) {
        [prompt starShowWithTitle:@"邮箱格式不正确"];
        return NO;
    }
    if (![self.password.text isEqual:self.repeatPassword.text]) {
        [prompt starShowWithTitle:@"密码不一致"];
        return NO;
    }
    NSString *passwordRegex = @"^[a-zA-Z0-9]\\w{5,17}$";
    NSPredicate *passwordPredicate = [NSPredicate predicateWithFormat:@"SELF MATCHES %@",passwordRegex];
    if (![passwordPredicate evaluateWithObject:self.password.text]) {
        [prompt starShowWithTitle:@"密码格式不正确"];
        return NO;
        
    }
    return YES;
}
@end
