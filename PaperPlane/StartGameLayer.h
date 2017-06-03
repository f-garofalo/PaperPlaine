//
//  StartGameLayer.h
//  FlappyBird
//
//  Created by Fortunato Garofalo on 03/09/14.
//  Copyright (c) 2014 com.felix. All rights reserved.
//

#import <SpriteKit/SpriteKit.h>
#import "GameHelperLayer.h"

typedef NS_ENUM(NSUInteger, StartGameLayerButtonType)
{
    StartGameLayerPlayButton = 0
};


@protocol StartGameLayerDelegate;
@interface StartGameLayer : GameHelperLayer
@property (nonatomic, assign) id<StartGameLayerDelegate> delegate;
- (void) showTapToStart:(BOOL)show;
@end


//**********************************************************************
@protocol StartGameLayerDelegate <NSObject>
@optional

- (void) startGameLayer:(StartGameLayer*)sender tapRecognizedOnButton:(StartGameLayerButtonType) startGameLayerButton;
@end