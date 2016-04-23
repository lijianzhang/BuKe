//
//  AppDelegate.m
//  BiShe
//
//  Created by Jz on 15/12/22.
//  Copyright © 2015年 Jz. All rights reserved.
//

#import "AppDelegate.h"
#import "GKHScanQCodeViewController.h"
#import "JZSearchViewController.h"
#import "CoreDataHelper.h"
#import "JZWildDog.h"
#import "JZHomeViewController.h"
@interface AppDelegate ()
@property(nonatomic,strong)CoreDataHelper *helper;
@end

@implementation AppDelegate

- (CoreDataHelper *)helper{
    if (!_helper) {
        _helper = [CoreDataHelper helper];
    }
    return _helper;
}

- (void)application:(UIApplication *)application performActionForShortcutItem:(UIApplicationShortcutItem *)shortcutItem completionHandler:(void (^)(BOOL))completionHandler{
    if ([shortcutItem.type isEqualToString:@"one"]) {
        UINavigationController * rootnav = self.window.rootViewController.childViewControllers.firstObject;
        JZHomeViewController *vc = (JZHomeViewController *)rootnav.childViewControllers.firstObject;
        NSLog(@"%@",vc);
        UINavigationController *nav = [[UINavigationController alloc]initWithRootViewController:vc.GKHScanQCode];
        [self.window.rootViewController presentViewController:nav animated:YES completion:nil];
    }
    if([shortcutItem.type isEqualToString:@"two"]){
        JZSearchViewController *vc = [[UIStoryboard storyboardWithName:@"Main" bundle:[NSBundle mainBundle]] instantiateViewControllerWithIdentifier:@"JZSearchViewController"];
        UINavigationController *nav = (UINavigationController *)self.window.rootViewController.childViewControllers[0];
        
        [nav pushViewController:vc animated:YES];
    }
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.

    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    [self.helper saveContext];
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end
