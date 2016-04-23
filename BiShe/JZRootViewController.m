//
//  JZRootViewController.m
//  BiShe
//
//  Created by Jz on 16/1/10.
//  Copyright © 2016年 Jz. All rights reserved.
//

#import "JZRootViewController.h"
#import "JZRootCententView.h"
static const CGFloat JZDrawerControllerDrawerDepth = 260.0f;
static const CGFloat JZDrawerControllerLeftViewInitialOffset = -60.0f;
static const NSTimeInterval JZDrawerControllerAnimationDuration = 0.5;
static const CGFloat JZDrawerControllerOpeningAnimationSpringDamping = 0.7f;
static const CGFloat JZDrawerControllerOpeningAnimationSpringInitialVelocity = 0.1f;
static const CGFloat JZDrawerControllerClosingAnimationSpringDamping = 1.0f;
static const CGFloat JZDrawerControllerClosingAnimationSpringInitialVelocity = 0.5f;


typedef NS_ENUM(NSUInteger, JZDrawerControllerState)
{
    JZDrawerControllerStateClosed = 0,
    JZDrawerControllerStateOpening,
    JZDrawerControllerStateOpen,
    JZDrawerControllerStateClosing
};

@interface JZRootViewController ()<UIGestureRecognizerDelegate>
@property (nonatomic,strong)UIViewController<JZDrawerControllerProtocol> *leftViewController;
@property (nonatomic,strong)UIViewController<JZDrawerControllerProtocol> *centerViewController;
@property (nonatomic,strong)UIView *leftView;
@property (nonatomic,strong)JZRootCententView *centerView;

@property(nonatomic, strong) UITapGestureRecognizer *tapGestureRecognizer;
@property(nonatomic, strong) UIPanGestureRecognizer *panGestureRecognizer;
@property(nonatomic, assign) CGPoint panGestureStartLocation;
@property(nonatomic, assign) JZDrawerControllerState drawerState;
@end

@implementation JZRootViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.leftViewController = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:@"JZDrawerViewController"];
    self.leftViewController.drawer = self;
    self.centerViewController = [[UIStoryboard storyboardWithName:@"Main" bundle:[NSBundle mainBundle]]instantiateViewControllerWithIdentifier:@"JZHomeViewController"];
    self.centerViewController.drawer = self;
    self.leftView = [[UIView alloc] initWithFrame:self.view.bounds];
    self.centerView = [[JZRootCententView alloc] initWithFrame:self.view.bounds];

    
    [self.view addSubview:self.centerView];
    
    [self addCenterViewController];
    
    [self setupGestureRecognizers];
}

- (void)setupGestureRecognizers
{
    
    self.tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapGestureRecognized:)];
    self.panGestureRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panGestureRecognized:)];
    self.panGestureRecognizer.maximumNumberOfTouches = 1;
    self.panGestureRecognizer.delegate = self;
    
}

-(void)cententViewAddGestureRecognizer{
    [self.centerView addGestureRecognizer:self.panGestureRecognizer];
}

- (void)addGestureRecognizerWithView:(UIView *)view{
    [view addGestureRecognizer:self.panGestureRecognizer];
}
- (void)removeGestureRecognizerWithView:(UIView *)view{
    [view removeGestureRecognizer:self.panGestureRecognizer];
}
-(void)cententViewRemoveGestureRecognizer{
    [self.centerView removeGestureRecognizer:self.panGestureRecognizer];
}

- (void)addCenterViewController
{

    UINavigationController *nav = [[UINavigationController alloc]initWithRootViewController:self.centerViewController];
    [self addChildViewController:nav];
    self.centerViewController.view.frame = self.view.bounds;
    [self.centerView addSubview:nav.view];
    [self.centerViewController didMoveToParentViewController:self];
}
#pragma mark 手势
- (void)tapGestureRecognized:(UITapGestureRecognizer *)tapGestureRecognizer
{
    if (tapGestureRecognizer.state == UIGestureRecognizerStateEnded) {
        [self close];
    }
}
- (void)panGestureRecognized:(UIPanGestureRecognizer *)panGestureRecognizer
{
    UIGestureRecognizerState state = panGestureRecognizer.state;
    CGPoint location = [panGestureRecognizer locationInView:self.view];
    CGPoint velocity = [panGestureRecognizer velocityInView:self.view];
    
    switch (state) {
            
        case UIGestureRecognizerStateBegan:
            self.panGestureStartLocation = location;
            if (self.drawerState == JZDrawerControllerStateClosed) {
                [self willOpen];
            }
            else {
                [self willClose];
            }
            break;
            
        case UIGestureRecognizerStateChanged:
        {
            CGFloat delta = 0.0f;
            if (self.drawerState == JZDrawerControllerStateOpening) {
                delta = location.x - self.panGestureStartLocation.x;
            }
            else if (self.drawerState == JZDrawerControllerStateClosing) {
                delta = JZDrawerControllerDrawerDepth - (self.panGestureStartLocation.x - location.x);
            }
            
            CGRect l = self.leftView.frame;
            CGRect c = self.centerView.frame;
            if (delta > JZDrawerControllerDrawerDepth) {
                l.origin.x = 0.0f;
                c.origin.x = JZDrawerControllerDrawerDepth;
            }
            else if (delta < 0.0f) {
                l.origin.x = JZDrawerControllerLeftViewInitialOffset;
                c.origin.x = 0.0f;
            }
            else {
                l.origin.x = JZDrawerControllerLeftViewInitialOffset- (delta * JZDrawerControllerLeftViewInitialOffset) / JZDrawerControllerDrawerDepth;
                
                c.origin.x = delta;
            }
            
            self.leftView.frame = l;
            self.centerView.frame = c;
            
            break;
        }
            
        case UIGestureRecognizerStateEnded:
            
            if (self.drawerState == JZDrawerControllerStateOpening) {
                CGFloat centerViewLocation = self.centerView.frame.origin.x;
                if (centerViewLocation == JZDrawerControllerDrawerDepth) {
                    [self setNeedsStatusBarAppearanceUpdate];
                    [self didOpen];
                }
                else if (centerViewLocation > self.view.bounds.size.width / 3
                         && velocity.x > 0.0f) {
                    [self animateOpening];
                }
                else {

                    [self didOpen];
                    [self willClose];
                    [self animateClosing];
                }
                
            } else if (self.drawerState == JZDrawerControllerStateClosing) {
                CGFloat centerViewLocation = self.centerView.frame.origin.x;
                if (centerViewLocation == 0.0f) {
                    [self setNeedsStatusBarAppearanceUpdate];
                    [self didClose];
                }
                else if (centerViewLocation < (2 * self.view.bounds.size.width) / 3
                         && velocity.x < 0.0f) {
                    [self animateClosing];
                }
                else {

                    [self didClose];

                    CGRect l = self.leftView.frame;
                    [self willOpen];
                    self.leftView.frame = l;
                    
                    [self animateOpening];
                }
            }
            break;
            
        default:
            break;
    }
}
#pragma mark Opening animation
- (void)animateOpening
{
 
    
    CGRect leftViewFinalFrame = self.view.bounds;
    CGRect centerViewFinalFrame = self.view.bounds;
    centerViewFinalFrame.origin.x = JZDrawerControllerDrawerDepth;
    
    [UIView animateWithDuration:JZDrawerControllerAnimationDuration
                          delay:0
         usingSpringWithDamping:JZDrawerControllerOpeningAnimationSpringDamping
          initialSpringVelocity:JZDrawerControllerOpeningAnimationSpringInitialVelocity
                        options:UIViewAnimationOptionCurveLinear
                     animations:^{
                         self.centerView.frame = centerViewFinalFrame;
                         self.leftView.frame = leftViewFinalFrame;
                         
                         [self setNeedsStatusBarAppearanceUpdate];
                     }
                     completion:^(BOOL finished) {
                         if (finished) {
                             [self didOpen];
                         }
                     }];
}
#pragma mark Closing animation
- (void)animateClosing
{
    
    CGRect leftViewFinalFrame = self.leftView.frame;
    leftViewFinalFrame.origin.x = JZDrawerControllerLeftViewInitialOffset;
    CGRect centerViewFinalFrame = self.view.bounds;
    
    [UIView animateWithDuration:JZDrawerControllerAnimationDuration
                          delay:0
         usingSpringWithDamping:JZDrawerControllerClosingAnimationSpringDamping
          initialSpringVelocity:JZDrawerControllerClosingAnimationSpringInitialVelocity
                        options:UIViewAnimationOptionCurveLinear
                     animations:^{
                         self.centerView.frame = centerViewFinalFrame;
                         self.leftView.frame = leftViewFinalFrame;
                         
                         [self setNeedsStatusBarAppearanceUpdate];
                     }
                     completion:^(BOOL finished) {
                         if (finished) {
                             [self didClose];
                         }
                     }];
}

#pragma mark - Opening the drawer

- (void)open
{

    
    [self willOpen];
    
    [self animateOpening];
}

- (void)willOpen
{

    
    self.drawerState = JZDrawerControllerStateOpening;
    
    CGRect f = self.view.bounds;
    f.origin.x = JZDrawerControllerLeftViewInitialOffset;
    self.leftView.frame = f;
    
    [self addChildViewController:self.leftViewController];
    self.leftViewController.view.frame = self.leftView.bounds;
    [self.leftView addSubview:self.leftViewController.view];
    
    [self.view insertSubview:self.leftView belowSubview:self.centerView];
    
    if ([self.leftViewController respondsToSelector:@selector(drawerControllerWillOpen:)]) {
        [self.leftViewController drawerControllerWillOpen:self];
    }
    if ([self.centerViewController respondsToSelector:@selector(drawerControllerWillOpen:)]) {
        [self.centerViewController drawerControllerWillOpen:self];
    }
}

- (void)didOpen
{

    
    [self.leftViewController didMoveToParentViewController:self];
    
    [self.centerView addGestureRecognizer:self.tapGestureRecognizer];
    
    self.drawerState = JZDrawerControllerStateOpen;
    
    // Notify the child view controllers that the drawer is open
    if ([self.leftViewController respondsToSelector:@selector(drawerControllerDidOpen:)]) {
        [self.leftViewController drawerControllerDidOpen:self];
    }
    if ([self.centerViewController respondsToSelector:@selector(drawerControllerDidOpen:)]) {
        [self.centerViewController drawerControllerDidOpen:self];
    }
}

#pragma mark - Closing the drawer

- (void)close
{
    
    [self willClose];
    
    [self animateClosing];
}

- (void)willClose
{

    
    [self.leftViewController willMoveToParentViewController:nil];
    
    self.drawerState = JZDrawerControllerStateClosing;
    
    if ([self.leftViewController respondsToSelector:@selector(drawerControllerWillClose:)]) {
        [self.leftViewController drawerControllerWillClose:self];
    }
    if ([self.centerViewController respondsToSelector:@selector(drawerControllerWillClose:)]) {
        [self.centerViewController drawerControllerWillClose:self];
    }
}

- (void)didClose
{

    
    [self.leftViewController.view removeFromSuperview];
    [self.leftViewController removeFromParentViewController];
    
    [self.leftView removeFromSuperview];
    
    [self.centerView removeGestureRecognizer:self.tapGestureRecognizer];
    
    self.drawerState = JZDrawerControllerStateClosed;
    
    if ([self.leftViewController respondsToSelector:@selector(drawerControllerDidClose:)]) {
        [self.leftViewController drawerControllerDidClose:self];
    }
    if ([self.centerViewController respondsToSelector:@selector(drawerControllerDidClose:)]) {
        [self.centerViewController drawerControllerDidClose:self];
    }
}

#pragma mark - Reloading/Replacing the center view controller

- (void)reloadCenterViewControllerUsingBlock:(void (^)(void))reloadBlock
{

    
    [self willClose];
    
    CGRect f = self.centerView.frame;
    f.origin.x = self.view.bounds.size.width;
    
    [UIView animateWithDuration: JZDrawerControllerAnimationDuration / 2
                     animations:^{
                         self.centerView.frame = f;
                     }
                     completion:^(BOOL finished) {
                         if (finished) {
                             if (reloadBlock) {
                                 reloadBlock();
                             }
                             [self animateClosing];
                         }
                     }];
}

- (void)replaceCenterViewControllerWithViewController:(UIViewController<JZDrawerControllerProtocol> *)viewController
{

    
    [self willClose];
    
    CGRect f = self.centerView.frame;
    f.origin.x = self.view.bounds.size.width;
    
    [self.centerViewController willMoveToParentViewController:nil];
    [UIView animateWithDuration: JZDrawerControllerAnimationDuration / 2
                     animations:^{
                         self.centerView.frame = f;
                     }
                     completion:^(BOOL finished) {
                         if (finished) {
                             
                             if ([self.centerViewController respondsToSelector:@selector(setDrawer:)]) {
                                 self.centerViewController.drawer = nil;
                             }
                             [self.centerViewController.view removeFromSuperview];
                             [self.centerViewController removeFromParentViewController];
                             
                             self.centerViewController = viewController;
                             if ([self.centerViewController respondsToSelector:@selector(setDrawer:)]) {
                                 self.centerViewController.drawer = self;
                             }
                             
                             [self addCenterViewController];
                             
                             [self animateClosing];
                         }
                     }];
}
@end
