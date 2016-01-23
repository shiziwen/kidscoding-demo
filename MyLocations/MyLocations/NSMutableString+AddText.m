//
//  NSMutableString+AddText.m
//  MyLocations
//
//  Created by mac on 16/1/23.
//  Copyright © 2016年 shiziwen. All rights reserved.
//

#import "NSMutableString+AddText.h"

@implementation NSMutableString (AddText)

- (void)addText:(NSString *)text withSeparator:(NSString *)separator {
    if (text != nil) {
        if ([self length] > 0) {
            [self appendString:separator];
        }
        [self appendString:text];
    }
}
@end
