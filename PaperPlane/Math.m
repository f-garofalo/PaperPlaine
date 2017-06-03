//
//  Math.m
//  spritybird
//
//  Created by Alexis Creuzot on 09/02/2014.
//  Copyright (c) 2014 Alexis Creuzot. All rights reserved.
//

#import "Math.h"

static unsigned int _seed = 0;

@implementation Math

+ (void)setRandomSeed:(unsigned int)seed
{
    _seed = seed;
    srand(_seed);
}

+ (CGFloat) randomFloatBetween:(CGFloat) min and:(CGFloat) max
{
    CGFloat random = ((rand()%RAND_MAX)/(RAND_MAX*1.0))*(max-min)+min;
    return random;
}

+ (CGFloat) randf
{
    return arc4random() / (CGFloat) RAND_MAX;
}

+ (CGFloat) rand:(CGFloat) low to:(CGFloat) high
{
    return [[self class] randf] * (high - low) + low;
}

+ (NSInteger) getRandomNumberBetween:(NSInteger) from to:(NSInteger) to
{
    return (NSInteger) from + arc4random() % (to-from+1);
}

@end
