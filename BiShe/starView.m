//
//  startView.m
//  DouBan
//
//  Created by 李健章 on 15/12/14.
//  Copyright © 2015年 JZ. All rights reserved.
//

#import "starView.h"

@implementation starView

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/
- (instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
        self.maxStar         = 10.0;
        self.emptyColor      = [UIColor colorWithRed:217/255.0 green:217/255.0  blue:217/255.0  alpha:1];
        self.fullColor       = [UIColor colorWithRed:1 green:173/255.0 blue:14/255.0 alpha:1];
        self.starSize        = 8;
        self.showStar        = 0;
    }
    return self;
}

- (void)awakeFromNib{
    [super awakeFromNib];
    self.backgroundColor = [UIColor clearColor];
    self.maxStar         = 10.0;
    self.emptyColor      = [UIColor colorWithRed:217/255.0 green:217/255.0  blue:217/255.0  alpha:1];
    self.fullColor       = [UIColor colorWithRed:1 green:173/255.0 blue:14/255.0 alpha:1];
    self.starSize        = 13;

}

- (void)setShowStar:(NSNumber *)showStar{
    _showStar = showStar;
    [self setNeedsDisplay];
    
}
- (void)drawRect:(CGRect)rect{
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    NSString* stars = @"★★★★★";
    
    rect = self.bounds;
    NSDictionary *dict = @{NSFontAttributeName:[UIFont systemFontOfSize:self.starSize],NSForegroundColorAttributeName:self.emptyColor};
    CGSize starSize = [stars sizeWithAttributes:dict];
    rect.size=starSize;
    [stars drawInRect:rect withAttributes:dict];
    CGRect clip = rect;
    clip.size.width =  clip.size.width *[self.showStar floatValue] / self.maxStar ;
    CGContextClipToRect(context,clip);


        NSDictionary *dict2 = @{NSFontAttributeName:[UIFont systemFontOfSize:self.starSize],NSForegroundColorAttributeName:self.fullColor};
    [stars drawInRect:rect withAttributes:dict2];
    
}
@end
