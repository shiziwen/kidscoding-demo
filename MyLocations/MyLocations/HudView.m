//
//  HudView.m
//  MyLocations
//
//  Created by mac on 16/1/19.
//  Copyright © 2016年 shiziwen. All rights reserved.
//

#import "HudView.h"

@implementation HudView

// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
    const CGFloat boxWidth = 96.0f;
    const CGFloat boxHeight = 96.0f;
    CGRect boxRect = CGRectMake(
                                (self.bounds.size.width - boxWidth) / 2,
                                (self.bounds.size.height - boxHeight) / 2,
                                boxWidth,
                                boxHeight);
    UIBezierPath *roundedRect = [UIBezierPath bezierPathWithRoundedRect:boxRect cornerRadius:10.0f];
    [[UIColor colorWithWhite:0.3f alpha:0.8f] setFill];
    [roundedRect fill];
    
    UIImage *image = [UIImage imageNamed:@"Checkmark"];
    CGPoint imagePoint = CGPointMake(self.center.x - round(image.size.width / 2),
                                     self.center.y - round(image.size.height / 2) - boxHeight / 8.0f);
    [image drawAtPoint:imagePoint];
    
    NSDictionary *attributes = @{
                                 NSFontAttributeName:[UIFont systemFontOfSize:16.0f],
                                 NSForegroundColorAttributeName:[UIColor whiteColor]
                                 };
    CGSize textSize = [self.text sizeWithAttributes:attributes];
    CGPoint textPoint = CGPointMake(
                                    self.center.x - round(textSize.width/2.0f),
                                    self.center.y - round(textSize.width/2.0f) + boxHeight/4.0f);
    [self.text drawAtPoint:textPoint withAttributes:attributes];
}

+ (instancetype)hudInView:(UIView *)view animated:(BOOL)animated {
    HudView *hudView = [[HudView alloc] initWithFrame:view.bounds];
    hudView.opaque = NO;
    
    [view addSubview:hudView];
    hudView.userInteractionEnabled = NO;
    
//    hudView.backgroundColor = [UIColor colorWithRed:1.0f green:0 blue:0 alpha:0.5f];
    [hudView showAnimated:animated];
    return hudView;
}

- (void)showAnimated:(BOOL)animated {
    if (animated) {
        self.alpha = 0.0f;
        self.transform = CGAffineTransformMakeScale(1.3f, 1.3f);
        
        [UIView animateWithDuration:0.3 animations:^{
            self.alpha = 1.0f;
            self.transform = CGAffineTransformIdentity;
        }];
    }
}

@end
