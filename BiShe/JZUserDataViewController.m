//
//  JZUserDataViewController.m
//  BiShe
//
//  Created by Jz on 16/1/11.
//  Copyright © 2016年 Jz. All rights reserved.
//

#import "JZUserDataViewController.h"
#import "JZWildDog.h"
#import "userStroe.h"
#import "CoreDataHelper.h"
@interface JZUserDataViewController ()<UIImagePickerControllerDelegate,UINavigationControllerDelegate>
@property (weak, nonatomic) IBOutlet UIImageView *userImage;
@end

@implementation JZUserDataViewController

- (void)viewDidLoad{
    [super viewDidLoad];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(changeData) name:@"changeUserData" object:nil];

}
- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self changeData];
}


- (IBAction)editUserImage:(id)sender {
    if (![UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypePhotoLibrary]) { //判断设备是否支持相册
        
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"提示" message:@"设未开启访问相册权限，现在去开启!"preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *action = [UIAlertAction actionWithTitle:@"确认" style:UIAlertActionStyleCancel handler:nil];
        [alert addAction:action];
        [self presentViewController:alert animated:YES completion:nil];
        return;
    }
    UIImagePickerController *mediaUI = [[UIImagePickerController alloc] init];
    mediaUI.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    mediaUI.mediaTypes = [UIImagePickerController         availableMediaTypesForSourceType:UIImagePickerControllerSourceTypeSavedPhotosAlbum];
    mediaUI.allowsEditing = NO;
    mediaUI.delegate = self;
    [self presentViewController:mediaUI animated:YES completion:^{
        [UIApplication sharedApplication].statusBarStyle = UIStatusBarStyleDefault;
    }];
}
#pragma mark--imagePicker delgate
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    
    UIImage *image = [info objectForKey:UIImagePickerControllerEditedImage];
    if (!image){
        image = [info objectForKey:UIImagePickerControllerOriginalImage];
        
    }
    
    UIGraphicsBeginImageContext(CGSizeMake(200, 200));
    [image drawInRect:CGRectMake(0, 0, 200, 200)];
    image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    
    [self.userImage setImage:image];
    [[JZWildDog WildDog]editUserIamge:image withSuccess:^{
        NSLog(@"成功");
        [[NSNotificationCenter defaultCenter]postNotificationName:@"changeUserData" object:nil];
        
        [self dismissViewControllerAnimated:YES completion:nil];
    } fail:nil];

}
- (IBAction)exitUser:(id)sender {
    UIViewController<JZDrawerControllerProtocol > *vc = [[UIStoryboard storyboardWithName:@"Main" bundle:[NSBundle mainBundle]] instantiateViewControllerWithIdentifier:@"JZUserController"];
//    [self.drawer replaceCenterViewControllerWithViewController:vc];
    [self presentViewController:vc animated:YES completion:^{
        [userStroe removeUser];
        [[CoreDataHelper helper]removeAllComment];
    }];
    

    
}
- (void)changeData{
    userStroe *user = [userStroe loadUser];
    if (user.imageString) {
        UIImage *userImage = [user Base64StrToUIImage];
        [self.userImage setImage:userImage];
    }else{
        [self.userImage setImage:[UIImage imageNamed:@"login_default_icon"]];
    }
}
- (void)dealloc{
    [[NSNotificationCenter defaultCenter]removeObserver:self];
}

- (void)drawerControllerWillOpen:(JZRootViewController *)drawerController{
    self.view.userInteractionEnabled = NO;
}

- (void)drawerControllerDidClose:(JZRootViewController *)drawerController{
    self.view.userInteractionEnabled = YES;
}
@end
