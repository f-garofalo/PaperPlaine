//
//  SKBScores.m
//  firtProject
//
//  Created by Fortunato Garofalo on 03/09/14.
//  Copyright (c) 2014 com.felix. All rights reserved.
//

#import "SKBScores.h"

#define kTextPlayerHeaderFileName           @"Text_PlayerScoreHeader.png"
#define kTextHighHeaderFileName             @"Text_HighScoreHeader.png"

#define kTextNumber0FileName                @"Text_Number_0.png"
#define kTextNumber1FileName                @"Text_Number_1.png"
#define kTextNumber2FileName                @"Text_Number_2.png"
#define kTextNumber3FileName                @"Text_Number_3.png"
#define kTextNumber4FileName                @"Text_Number_4.png"
#define kTextNumber5FileName                @"Text_Number_5.png"
#define kTextNumber6FileName                @"Text_Number_6.png"
#define kTextNumber7FileName                @"Text_Number_7.png"
#define kTextNumber8FileName                @"Text_Number_8.png"
#define kTextNumber9FileName                @"Text_Number_9.png"

#define kScoreDigitCount                    5
#define kScoreNumberSpacing                 16
#define kScorePlayerDistanceFromLeft        10
#define kScoreDistanceFromTop               10

@interface SKBScores() {
	NSArray *arrayOfNumberTextures;
}

@end

@implementation SKBScores

- (void)createScoreNumberTextures
{
    NSMutableArray *textureArray = [NSMutableArray arrayWithCapacity:10];
	SKTexture *numberTexture;
	
    numberTexture = [SKTexture textureWithImageNamed:kTextNumber0FileName];
    [textureArray insertObject:numberTexture atIndex:0];
    numberTexture = [SKTexture textureWithImageNamed:kTextNumber1FileName];
    [textureArray insertObject:numberTexture atIndex:1];
    numberTexture = [SKTexture textureWithImageNamed:kTextNumber2FileName];
    [textureArray insertObject:numberTexture atIndex:2];
    numberTexture = [SKTexture textureWithImageNamed:kTextNumber3FileName];
    [textureArray insertObject:numberTexture atIndex:3];
    numberTexture = [SKTexture textureWithImageNamed:kTextNumber4FileName];
    [textureArray insertObject:numberTexture atIndex:4];
    numberTexture = [SKTexture textureWithImageNamed:kTextNumber5FileName];
    [textureArray insertObject:numberTexture atIndex:5];
    numberTexture = [SKTexture textureWithImageNamed:kTextNumber6FileName];
    [textureArray insertObject:numberTexture atIndex:6];
    numberTexture = [SKTexture textureWithImageNamed:kTextNumber7FileName];
    [textureArray insertObject:numberTexture atIndex:7];
    numberTexture = [SKTexture textureWithImageNamed:kTextNumber8FileName];
    [textureArray insertObject:numberTexture atIndex:8];
    numberTexture = [SKTexture textureWithImageNamed:kTextNumber9FileName];
    [textureArray insertObject:numberTexture atIndex:9];
    
    arrayOfNumberTextures = [NSArray arrayWithArray:textureArray];
}

- (void)createScoreNode:(SKScene *)whichScene atPoint:(CGPoint) startWhere
{
    if (!arrayOfNumberTextures) {
        [self createScoreNumberTextures];
    }
	
	
    //CGPoint startWhere = CGPointMake(CGRectGetMinX(whichScene.frame)+kScorePlayerDistanceFromLeft, CGRectGetMaxY(whichScene.frame)-kScoreDistanceFromTop);
    // High score
    SKTexture *headerTexture = [SKTexture textureWithImageNamed:kTextHighHeaderFileName];
	
    startWhere = CGPointMake(startWhere.x+kScorePlayerDistanceFromLeft, startWhere.y-kScoreDistanceFromTop);
    
    // Header
    SKSpriteNode *header = [SKSpriteNode spriteNodeWithTexture:headerTexture];
    header.name = @"score_high_header";
    header.position = startWhere;
    header.xScale = 2;
    header.yScale = 2;
    header.physicsBody.dynamic = NO;
	header.zPosition = 500;
    [whichScene addChild:header];
	
    // Score, 5-digits
    SKTexture *textNumber0Texture = [SKTexture textureWithImageNamed:kTextNumber0FileName];
    for (NSInteger index=1; index <= kScoreDigitCount; ++index) {
        SKSpriteNode *zero = [SKSpriteNode spriteNodeWithTexture:textNumber0Texture];
        zero.name = [NSString stringWithFormat:@"score_high_digit%ld", (long)index];
        zero.position = CGPointMake(startWhere.x+8+(kScoreNumberSpacing*index), startWhere.y);
        zero.xScale = 2;
        zero.yScale = 2;
        zero.physicsBody.dynamic = NO;
		zero.zPosition = 500;
        [whichScene addChild:zero];
    }
}

- (void)updateScore:(SKScene *)whichScene newScore:(NSInteger)playerScore
{
    NSString *numberString = [NSString stringWithFormat:@"00000%ld", (long)playerScore];
    NSString *substring = [numberString substringFromIndex:[numberString length] - 5];
    
    for (NSInteger index = 1; index <= kScoreDigitCount; ++index) {
        [whichScene enumerateChildNodesWithName:[NSString stringWithFormat:@"score_high_digit%ld", (long)index] usingBlock:^(SKNode *node, BOOL *stop) {
            NSString *charAtIndex = [substring substringWithRange:NSMakeRange(index-1, 1)];
            NSInteger charIntValue = [charAtIndex integerValue];
            SKTexture *digitTexture = [arrayOfNumberTextures objectAtIndex:charIntValue];
            SKAction *newDigit = [SKAction animateWithTextures:@[digitTexture] timePerFrame:0.1];
            [node runAction:newDigit]; }];
    }
}

- (void) show:(SKScene *)whichScene mustShow:(BOOL)mustShow
{
    for (NSInteger index = 1; index <= kScoreDigitCount; ++index) {
        [whichScene enumerateChildNodesWithName:[NSString stringWithFormat:@"score_high_digit%ld", (long)index] usingBlock:^(SKNode *node, BOOL *stop) {
			node.hidden = !mustShow;
		}];
    }
	
	[whichScene enumerateChildNodesWithName:@"score_high_header" usingBlock:^(SKNode *node, BOOL *stop) {
		node.hidden = !mustShow;
	}];
}
@end
