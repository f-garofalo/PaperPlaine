//
//  Utility.m
//  firtProject
//
//  Created by Fortunato Garofalo on 13/09/14.
//  Copyright (c) 2014 com.felix. All rights reserved.
//

#import "Utility.h"

@implementation Utility

+ (CGFloat) clamp:(CGFloat) min withMax:(CGFloat) max currentValur:(CGFloat) value
{
    if( value > max ) {
        return max;
    } else if( value < min ) {
        return min;
    } else {
        return value;
    }
}

+ (SKColor*)colorWithHex:(NSInteger)hexValue alpha:(CGFloat)alphaValue
{
    return [SKColor colorWithRed:((float)((hexValue & 0xFF0000) >> 16))/255.0
                           green:((float)((hexValue & 0xFF00) >> 8))/255.0
                            blue:((float)(hexValue & 0xFF))/255.0 alpha:alphaValue];
}

@end
