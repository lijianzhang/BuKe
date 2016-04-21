//
//  JZPromptView.h
//  BiShe
//
//  Created by Jz on 16/1/12.
//  Copyright © 2016年 Jz. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface JZPromptView : UILabel

+ (instancetype)prompt;
- (void)starShow;
- (void)setError:(NSError *)error;
- (void)setColor:(UIColor*)color;
- (void)starShowWithTitle:(NSString *)title;
- (void)setTempColor:(UIColor*)color andTitle:(NSString *)title;
@end
