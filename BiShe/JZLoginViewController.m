//
//  JZLoginViewController.m
//  BiShe
//
//  Created by Jz on 16/1/2.
//  Copyright © 2016年 Jz. All rights reserved.
//

#import "JZLoginViewController.h"
#import "JZWildDog.h"
#import "userStroe.h"

#import "JZPromptView.h"
#import "JZHUD.h"
IB_DESIGNABLE
@interface JZLoginViewController ()
@property (weak, nonatomic) IBOutlet UITextField *userTextField;
@property (weak, nonatomic)IBInspectable IBOutlet UITextField *passWordTextField;
@property(nonatomic,strong)JZPromptView *promptView;;/**<<#text#> */
@property (weak, nonatomic) IBOutlet UIButton *sumbitButton;
@end

@implementation JZLoginViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.promptView = [JZPromptView prompt];
    self.userTextField.transform = CGAffineTransformMakeTranslation(-300, 0);
    self.passWordTextField.transform = CGAffineTransformMakeTranslation(300, 0);
    self.sumbitButton.enabled = NO;
    self.sumbitButton.alpha = 0.8f;
    [self.userTextField addTarget:self action:@selector(changeText) forControlEvents:UIControlEventEditingChanged];
    [self.passWordTextField addTarget:self action:@selector(changeText) forControlEvents:UIControlEventEditingChanged];
    self.navigationController.navigationBarHidden = YES;

}
- (void)changeText{
    if (![self.userTextField.text isEqualToString:@""]&&![self.passWordTextField.text isEqualToString:@""]) {
        self.sumbitButton.enabled = YES;
        self.sumbitButton.alpha = 1;
    }else{
        self.sumbitButton.enabled = NO;
        self.sumbitButton.alpha = 0.8f;
    }

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];

    [UIView animateWithDuration:1.0f delay:0 usingSpringWithDamping:0.5 initialSpringVelocity:1 options:0 animations:^{
        self.userTextField.transform = CGAffineTransformIdentity;
        self.passWordTextField.transform = CGAffineTransformIdentity;

    } completion:nil];
}

- (IBAction)logining:(id)sender {
    NSString *emailRegex = @"[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}";
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", emailRegex];
    if (![predicate evaluateWithObject:self.userTextField.text]) {
        [self.promptView setColor:[UIColor redColor]];
        [self.promptView starShowWithTitle:@"邮箱格式不正确"];

        return;
    }
    NSString *passwordRegex = @"^[a-zA-Z0-9]\\w{5,17}$";
    NSPredicate *passwordPredicate = [NSPredicate predicateWithFormat:@"SELF MATCHES %@",passwordRegex];
    if (![passwordPredicate evaluateWithObject:self.passWordTextField.text]) {
        [self.promptView setColor:[UIColor redColor]];
        [self.promptView starShowWithTitle:@"密码格式不正确"];
        return;

    }
    [JZHUD showHUDandTitle:@""];
    [[JZWildDog WildDog]loginUser:self.userTextField.text password:self.passWordTextField.text WithBlock:^(NSError *error, WAuthData *authData) {
        [self.navigationController dismissViewControllerAnimated:YES completion:nil];
        [JZHUD showSuccessandTitle:@""];
    }fail:^(NSString *string) {
        [JZHUD dismissHUD];
        [self.promptView setColor:[UIColor redColor]];
        [self.promptView starShowWithTitle:string];
    }];
    

}
/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/
- (void)dealloc{

}
- (IBAction)closeView:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];

}
- (void)drawerControllerWillOpen:(JZRootViewController *)drawerController{
    self.view.userInteractionEnabled = NO;
}

- (void)drawerControllerDidClose:(JZRootViewController *)drawerController{
    self.view.userInteractionEnabled = YES;
}



@end
