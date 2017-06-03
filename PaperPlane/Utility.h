//
//  Utility.h
//  firtProject
//
//  Created by Fortunato Garofalo on 13/09/14.
//  Copyright (c) 2014 com.felix. All rights reserved.
//

//-----------------------------------------------------------------------------------------------------
/*
static inline CGFloat skRandf(){
    return arc4random() / (CGFloat) RAND_MAX;
}
static inline CGFloat skRand(CGFloat low, CGFloat high){
    return skRandf() * (high - low) + low;
}

static inline NSInteger getRandomNumberBetween(NSInteger from,NSInteger to) {
    
    return (NSInteger) from + arc4random() % (to-from+1);
}
*/
static inline CGPoint CGPointAdd(const CGPoint a, const CGPoint b)
{
    return CGPointMake(a.x + b.x, a.y + b.y);
}

static inline CGPoint CGPointMultiplyScalar(const CGPoint a, const CGFloat b)
{
    return CGPointMake(a.x * b, a.y * b);
}


static inline CGPoint CGPointSubtract(const CGPoint a,
                                      const CGPoint b)
{
	return CGPointMake(a.x - b.x, a.y - b.y);
}

static inline CGFloat CGPointLength(const CGPoint a)
{
	return sqrtf(a.x * a.x + a.y * a.y);
}

static inline CGPoint CGPointNormalize(const CGPoint a)
{
	CGFloat length = CGPointLength(a);
	return CGPointMake(a.x / length, a.y / length);
}

static inline CGFloat CGPointToAngle(const CGPoint a)
{
	return atan2f(a.y, a.x);
}

static inline CGFloat ScalarSign(CGFloat a)
{
	return a >= 0 ? 1 : -1;
}

// Returns shortest angle between two angles,
// between -M_PI and M_PI
static inline CGFloat ScalarShortestAngleBetween(const CGFloat a, const CGFloat b)
{
	CGFloat difference = b - a;
	CGFloat angle = fmodf(difference, M_PI * 2);
	if (angle >= M_PI) {
		angle -= M_PI * 2;
	}
	return angle;
}

//-----------------------------------------------------------------------------------------------------

@interface Utility : NSObject

+ (CGFloat) clamp:(CGFloat) min withMax:(CGFloat) max currentValur:(CGFloat) value;

+ (SKColor*)colorWithHex:(NSInteger)hexValue alpha:(CGFloat)alphaValue;

@end
