//
//  StartGameLayer.m
//  FlappyBird
//
//  Created by Fortunato Garofalo on 03/09/14.
//  Copyright (c) 2014 com.felix. All rights reserved.
//

#import "StartGameLayer.h"

@interface StartGameLayer()
{
	SKSpriteNode* tapToStart;
}
@property (nonatomic, retain) SKSpriteNode* playButton;
@end


@implementation StartGameLayer

- (id)initWithSize:(CGSize)size
{
    if(self = [super initWithSize:size])
    {
        SKSpriteNode* startGameText = [SKSpriteNode spriteNodeWithImageNamed:@"PaperPlaneText"];
        startGameText.position = CGPointMake(size.width * 0.5f, size.height * 0.8f);
        [self addChild:startGameText];
        
        SKSpriteNode* playButton = [SKSpriteNode spriteNodeWithImageNamed:@"PlayButton"];
        playButton.position = CGPointMake(size.width * 0.5f, size.height * 0.20f);
        [self addChild:playButton];

        tapToStart = [SKSpriteNode spriteNodeWithImageNamed:@"TapToStart"];
        tapToStart.position = CGPointMake(size.width * 0.5f, size.height * 0.50f);
        tapToStart.alpha = 0;
		[self addChild:tapToStart];
		
        [self setPlayButton:playButton];
    }
    
    return self;
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    UITouch *touch = [touches anyObject];
    CGPoint location = [touch locationInNode:self];
    
    if ([_playButton containsPoint:location])
    {
        if([self.delegate respondsToSelector:@selector(startGameLayer:tapRecognizedOnButton:)])
        {
            [self.delegate startGameLayer:self tapRecognizedOnButton:StartGameLayerPlayButton];
        }
    }
}

- (void) showTapToStart:(BOOL)show
{
	if (show) {
		[tapToStart runAction:[SKAction fadeInWithDuration:0.5f]];
	} else {
        tapToStart.alpha = 0;
	}
}
@end
