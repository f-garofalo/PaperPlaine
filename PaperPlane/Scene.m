//
//  MyScene.m
//  firtProject
//
//  Created by Fortunato Garofalo on 29/08/14.
//  Copyright (c) 2014 com.felix. All rights reserved.
//

#import "Scene.h"
#import "SKBScores.h"
#import "SKScrollingNode.h"
#import "StartGameLayer.h"
#import "GameOverLayer.h"

@interface Scene ()  <SKPhysicsContactDelegate, StartGameLayerDelegate, GameOverLayerDelegate>
{
	CGFloat landscapeWidth;
	CGFloat landscapeHeight;
	
	NSTimeInterval _dt;
    NSTimeInterval _gameOverElapsed;
	
    float bottomScrollerHeight;
    
    BOOL _gameStarted;
    BOOL _gameOver;
	NSTimeInterval lastUpdateTimeInterval;
	NSTimeInterval lastSpawnTimeInterval;
	NSArray *coinTextures;
	CGFloat flootHeight;
	SKAction *collectedSound;
	NSInteger score;
	SKBScores *scoreNode;
	
    StartGameLayer* _startGameLayer;
    GameOverLayer* _gameOverLayer;
	
	NSMutableArray *explosionTextures;
	SKAction *explosionSound;
	AVAudioPlayer *backgroundMusicPlayer;
	
	SKSpriteNode *sun;
	SKSpriteNode *backgroundLaver0;
	
	SKSpriteNode *call;
	SKSpriteNode *callSub;
	BOOL runCall;
	AVAudioPlayer *callMusicPlayer;
	
	SKSpriteNode *paperPlaine;
	SKPhysicsBody *paperPlainePhysicsBody;
	BOOL isInModeInvulnerability;
}

@end

@implementation Scene

-(id)initWithSize:(CGSize)size {    
    if (self = [super initWithSize:size]) {
        score = 0;
		
		_gameOver = NO;
        _gameStarted = NO;
		
		// For landscape use
		CGRect screenRect = [[UIScreen mainScreen] bounds];
#ifdef __IPHONE_8_0
		landscapeWidth = screenRect.size.width;
		landscapeHeight = screenRect.size.height;
#else
		landscapeWidth = screenRect.size.height;
		landscapeHeight = screenRect.size.width;
#endif

		self.physicsWorld.contactDelegate = self;
		self.physicsWorld.gravity = CGVectorMake( 0.0, -5.0 );
		
		// Background
        [self initializeBackGround:(CGSize){landscapeWidth, landscapeHeight}];
	
		// Score
		scoreNode = [SKBScores new];
		[scoreNode createScoreNode:self atPoint: (CGPoint){5, landscapeHeight}];
		[scoreNode show:self mustShow:NO];
		
		// Sound Theme
        [self initializeSoundBackground];
		
		// Paper Plain
		[self initializePaperPlaine];
		
		// GameOver/GameStart
        [self initializeStartGameLayer];
        [self initializeGameOverLayer];
		
        //schedule clouds
        SKAction *wait = [SKAction waitForDuration:1];
        SKAction *callClouds = [SKAction runBlock:^{
            [self clouds:NO];
        }];
        [self clouds:YES];
		[self clouds:NO];
		[self clouds:NO];		
        SKAction *updateEnimies = [SKAction sequence:@[wait, callClouds]];
        [self runAction:[SKAction repeatActionForever:updateEnimies]];
		
		//  Coins
		SKTexture *f1 = [SKTexture textureWithImageNamed:kCoin1FileName];
		SKTexture *f2 = [SKTexture textureWithImageNamed:kCoin2FileName];
		SKTexture *f3 = [SKTexture textureWithImageNamed:kCoin3FileName];
		coinTextures = @[f1,f2,f3,f2];
		collectedSound = [SKAction playSoundFileNamed:@"CoinCollected.caf" waitForCompletion:NO];
		
        //load explosions
        SKTextureAtlas *explosionAtlas = [SKTextureAtlas atlasNamed:@"EXPLOSION"];
        NSArray *textureNames = [explosionAtlas textureNames];
        explosionTextures = [NSMutableArray new];
        for (NSString *name in textureNames) {
            SKTexture *texture = [explosionAtlas textureNamed:name];
            [explosionTextures addObject:texture];
        }
		explosionSound = [SKAction playSoundFileNamed:@"Explosion.caf" waitForCompletion:NO];

		// Telephone call
		__weak typeof(self) weakSelf = self;
		dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_LOW, 0), ^(void){
			dispatch_async(dispatch_get_main_queue(), ^(void){
				[weakSelf initializeCall];
			});
		});
		
		// GO!
		[self showStartGameLayer];
    }
    return self;
}

/*
 //static inline double radians (double degrees) { return degrees * M_PI/180; }
 CGMutablePathRef createArcPathFromBottomOfRect(CGRect rect, CGFloat arcHeight)
 {
 CGRect arcRect = CGRectMake(rect.origin.x, rect.origin.y + rect.size.height - arcHeight, rect.size.width, arcHeight);
 
 CGFloat arcRadius = (arcRect.size.height/2) + (pow(arcRect.size.width, 2) / (8*arcRect.size.height));
 CGPoint arcCenter = CGPointMake(arcRect.origin.x + arcRect.size.width/2, arcRect.origin.y + arcRadius);
 
 CGFloat angle = acos(arcRect.size.width / (2*arcRadius));
 CGFloat startAngle = radians(180) + angle;
 CGFloat endAngle = radians(360) - angle;
 
 CGMutablePathRef path = CGPathCreateMutable();
 //CGPathAddArc(path, NULL, arcCenter.x, arcCenter.y, arcRadius, 0, M_PI*2, YES);
 //CGPathAddLineToPoint(path, NULL, CGRectGetMaxX(rect), CGRectGetMinY(rect));
 //CGPathAddLineToPoint(path, NULL, CGRectGetMinX(rect), CGRectGetMinY(rect));
 //CGPathAddLineToPoint(path, NULL, CGRectGetMinX(rect), CGRectGetMaxY(rect));
 
 CGPathMoveToPoint(path, NULL, CGRectGetMaxX(rect), CGRectGetMinY(rect));
 CGPathAddQuadCurveToPoint(path, NULL, CGRectGetMidX(rect), CGRectGetMaxY(rect), CGRectGetMinX(rect), CGRectGetMinY(rect));
 
 return path;
 }
 */


-(void) makePathRefForSun:(CGMutablePathRef) path withRect:(CGRect) rect
{
	CGPathMoveToPoint(path, NULL, rect.origin.x, rect.origin.y);
    CGPathAddQuadCurveToPoint(path, NULL, CGRectGetMidX(rect), CGRectGetMaxY(rect), CGRectGetMaxX(rect), CGRectGetMinY(rect));
}

-(void)shake:(NSInteger)times withNode:(SKSpriteNode *) node
{
    CGPoint initialPoint = node.position;
    NSInteger amplitudeX = 33;
    NSInteger amplitudeY = 3;
	if (node.hasActions) {
		return;
	}
    NSMutableArray * randomActions = [NSMutableArray arrayWithCapacity:times];
    for (NSInteger i=0; i<times; ++i) {
        NSInteger randX = node.position.x+arc4random() % amplitudeX - amplitudeX/2;
        NSInteger randY = node.position.y+arc4random() % amplitudeY - amplitudeY/2;
        SKAction *action = [SKAction moveTo:CGPointMake(randX, randY) duration:0.01];
        [randomActions addObject:action];
    }
	
    SKAction *rep = [SKAction sequence:randomActions];
	
    [node runAction:rep completion:^{
        node.position = initialPoint;
    }];
}

- (void) startGame
{
    score = 0;
    [Math setRandomSeed:(unsigned int) [Math getRandomNumberBetween:0 to:100]];
    _gameStarted = YES;
    
    [_startGameLayer removeFromParent];
    [_gameOverLayer removeFromParent];
	[scoreNode updateScore:self newScore:score];
	[scoreNode show:self mustShow:YES];
	
    CGMutablePathRef path = CGPathCreateMutable();
	[self makePathRefForSun:path withRect:CGRectMake(0-sun.frame.size.width*0.5, landscapeHeight-110, landscapeWidth+sun.frame.size.width, 270)];
	SKAction *followline = [SKAction followPath:path  asOffset:NO orientToPath:NO duration:TOTAL_GAME_TIME];
	CFRelease(path);
	
	[self addChild:sun];
	
	SKAction *completion = [SKAction runBlock:^{
		[sun removeFromParent];
		[self endGame];
	}];
	[sun runAction: [SKAction sequence:@[ [followline reversedAction], completion ] ] withKey:@"theSun"];
	
	// Call
	[self incomingCall];
	
	// Invulnerability
	completion = [SKAction runBlock:^{
		[self showBuddleInvulnerability];

	}];
	[self runAction: [SKAction sequence:@[ [SKAction waitForDuration:invulnerabilityToTime], completion ] ] withKey:@"invulnerability"];
}

- (void) endGame
{
	// TODO ....
	DLog(@"You Win");
    _gameOver = NO;
    _gameStarted = NO;
	paperPlaine.physicsBody.affectedByGravity = NO;
}

- (void) showBuddleInvulnerability
{
	SKSpriteNode *sprite = [SKSpriteNode spriteNodeWithImageNamed:invulnerabilityFileName];
	sprite.scale = 0.7;
	sprite.name = invulnerabilityCategoryName;
	sprite.position = CGPointMake(landscapeWidth + WIDTH(sprite)*0.5, landscapeHeight/3.55 ) ;
	sprite.zPosition = paperPlaineCategoryZIndex;
	
	sprite.physicsBody = [SKPhysicsBody bodyWithCircleOfRadius:sprite.size.width/2];
	sprite.physicsBody.allowsRotation = NO;
	sprite.physicsBody.restitution = 1.0f;
	sprite.physicsBody.friction = 0.0f;
	sprite.physicsBody.linearDamping = 0.0f;
	sprite.physicsBody.categoryBitMask = invulnerabilityCategory;
	sprite.physicsBody.collisionBitMask = floorCategory;
    sprite.physicsBody.contactTestBitMask = floorCategory ;
	sprite.physicsBody.mass = 0.04;
	
	[self addChild:sprite];
	
	[sprite.physicsBody applyImpulse:CGVectorMake(- 13, - 13 )];
}

- (void) enterInInvulnerabilityMode
{
	if (_gameStarted!= YES) {
		return;
	}
	[self runAction:[SKAction playSoundFileNamed:@"Jump.caf" waitForCompletion:NO] ];
	
	// Buddle
	SKSpriteNode *sprite = [SKSpriteNode spriteNodeWithImageNamed:invulnerabilityFileName];
	sprite.name = invulnerabilityCategoryName;
	paperPlaine.physicsBody = [SKPhysicsBody bodyWithCircleOfRadius:sprite.size.width/2 -2];
    paperPlaine.physicsBody.categoryBitMask = paperPlainePhysicsBody.categoryBitMask;
    paperPlaine.physicsBody.contactTestBitMask = paperPlainePhysicsBody.contactTestBitMask;
    paperPlaine.physicsBody.collisionBitMask = paperPlainePhysicsBody.collisionBitMask;
    paperPlaine.physicsBody.velocity = paperPlainePhysicsBody.velocity;
	paperPlaine.physicsBody.density = paperPlainePhysicsBody.density;
	paperPlaine.physicsBody.allowsRotation = paperPlainePhysicsBody.allowsRotation;
	[paperPlaine.physicsBody setMass:paperPlainePhysicsBody.mass];
	paperPlaine.physicsBody.affectedByGravity = paperPlainePhysicsBody.affectedByGravity;
	paperPlaine.physicsBody.angularVelocity = 0;
	paperPlaine.speed = 1.0;
	paperPlaine.zRotation = 0.0;
	[paperPlaine addChild:sprite];
	isInModeInvulnerability	= YES;
	
	SKAction *completion = [SKAction runBlock:^{
		[self terminateInvulnerabilityMode];
	}];
	[self runAction: [SKAction sequence:@[ [SKAction waitForDuration:invulnerabilityLiveTime], completion ] ] withKey:@"invulnerability"];
	
	[sprite runAction: [SKAction sequence:@[ [SKAction waitForDuration:invulnerabilityLiveTime-1.5], [SKAction fadeAlphaTo:0.3 duration:0.6]/*, [SKAction fadeAlphaTo:0.7 duration:0.6] */] ] withKey:@"invulnerability"];
}

- (void) terminateInvulnerabilityMode
{
	isInModeInvulnerability = NO;
	paperPlaine.physicsBody = paperPlainePhysicsBody;
	[paperPlaine enumerateChildNodesWithName:invulnerabilityCategoryName usingBlock:^(SKNode	*node, BOOL *stop) {
		[node removeFromParent];
	}];
}

- (void) incomingCall
{
	SKAction *callIncoming = [SKAction runBlock:^{
		SKAction *fadeOut = [SKAction fadeOutWithDuration:0.3f];
		SKAction *fadeIn = [SKAction fadeInWithDuration:0.3f ];
		SKAction *changeTexture = [SKAction setTexture:[SKTexture textureWithImageNamed:backgroundCategoryName_l0_ImgName_red]];
		SKAction *sound = [SKAction runBlock:^{ [callMusicPlayer play]; }];
		[backgroundLaver0 runAction:[SKAction sequence:@[fadeOut, sound, changeTexture, fadeIn, [SKAction waitForDuration:0.5], [SKAction runBlock:^{
			AudioServicesPlaySystemSound(kSystemSoundID_Vibrate);
			runCall = YES;
		}]]]];
	}];
	[backgroundLaver0 runAction:[SKAction sequence:@[ [SKAction waitForDuration:callAtTime], callIncoming ] ] withKey:@"call"];
}

- (void) endCall
{
	runCall = NO;
	[backgroundLaver0 removeActionForKey:@"call"];
	[callMusicPlayer stop];
	SKAction *callIncoming = [SKAction runBlock:^{
		SKAction *fadeOut = [SKAction fadeOutWithDuration:0.3f];
		SKAction *fadeIn = [SKAction fadeInWithDuration:0.3f ];
		SKAction *changeTexture = [SKAction setTexture:[SKTexture textureWithImageNamed:backgroundCategoryName_l0_ImgName]];
		[backgroundLaver0 runAction:[SKAction sequence:@[fadeOut,changeTexture,fadeIn]]];
		[call runAction:[SKAction moveTo:CGPointMake(landscapeWidth + call.size.width*0.5, landscapeHeight*0.5) duration:0]];
	}];
	[backgroundLaver0 runAction:[SKAction sequence:@[ callIncoming ] ]];
}

- (void) purgeScene
{
    //Remove currently exising on balls and coins from scene and purge them
    for (NSInteger i = self.children.count - 1; i >= 0; --i){
        SKNode* childNode = [self.children objectAtIndex:i];
        if (childNode.physicsBody.categoryBitMask == ballCategory || childNode.physicsBody.categoryBitMask == coinCategory) {
            [childNode removeFromParent];
        }
    }
	
	[backgroundLaver0 removeAllActions];
	[backgroundLaver0 setTexture:[SKTexture textureWithImageNamed:backgroundCategoryName_l0_ImgName]];

	[self endCall];
	[sun removeAllActions];
	
	[self removeActionForKey:@"invulnerability"];
}

- (void) showGameOverLayer:(BOOL) withDelay
{
    _gameOver = YES;
    _gameStarted = NO;

	[self purgeScene];
	
    [paperPlaine removeAllActions];
    paperPlaine.physicsBody.affectedByGravity = NO;
    paperPlaine.physicsBody.velocity = CGVectorMake(0, 0);
	paperPlaine.physicsBody.angularVelocity = 0;
	paperPlaine.speed = 1.0;
	paperPlaine.zRotation = 0.0;
	
	[paperPlaine runAction:[SKAction rotateToAngle:0 duration:0] ];

    //Move Paper Plain node to center of the scene
	//[_paperPlain runAction:[SKAction moveTo:CGPointMake(landscapeWidth * 0.5f, landscapeHeight * 0.5f) duration:0.5f]];

    _dt = 0;
    lastUpdateTimeInterval = 0;
    lastSpawnTimeInterval = 0;
    
    [_startGameLayer removeFromParent];
	
	if (withDelay) {
		[self runAction:[SKAction waitForDuration:1] completion:^{
			[self addChild:_gameOverLayer];

		}];
	} else {
    	[self addChild:_gameOverLayer];
	}
	[backgroundMusicPlayer stop];
}

- (void) showStartGameLayer
{
	[self purgeScene];

	[sun removeFromParent];
	[sun removeAllActions];
	
    [_gameOverLayer removeFromParent];
	[_startGameLayer showTapToStart:NO];
	paperPlaine.hidden = NO;
    //Move Paper Plain node to center of the scene
    paperPlaine.position = CGPointMake(0, landscapeHeight * 0.5f);
	
	SKAction *completion = [SKAction runBlock:^{
		[_startGameLayer showTapToStart:YES];
	}];
	SKAction *sequence = [SKAction sequence:@[ [SKAction moveTo:CGPointMake(landscapeWidth * 0.5f, landscapeHeight * 0.5f) duration:0.4f], completion ]];
	
	[paperPlaine runAction: sequence];
	
    [self addChild:_startGameLayer];
	
	[backgroundMusicPlayer play];
	[scoreNode show:self mustShow:NO];
}

- (void) initializeBackGround:(CGSize) sceneSize
{
    
	// Floor
	SKSpriteNode *floor = [SKSpriteNode spriteNodeWithColor:[SKColor clearColor] size:(CGSize){sceneSize.width, 17}];
	[floor setAnchorPoint:(CGPoint){0, 0}];
	[floor setName:floorCategoryName];
	[floor setPhysicsBody:[SKPhysicsBody bodyWithEdgeLoopFromRect:floor.frame]];
	floor.physicsBody.dynamic = NO;
	floor.physicsBody.friction = 0.0f;
	floor.physicsBody.categoryBitMask = floorCategory;
	[self addChild:floor];
	flootHeight = floor.frame.size.height;
	
	// Roof
	SKSpriteNode *roof = [SKSpriteNode spriteNodeWithColor:[SKColor clearColor] size:(CGSize){sceneSize.width, 1}];
	[roof setAnchorPoint:(CGPoint){0, 0}];
	[roof setPhysicsBody:[SKPhysicsBody bodyWithEdgeLoopFromRect:floor.frame]];
	roof.physicsBody.dynamic = NO;
	roof.physicsBody.friction = 0.0f;
	roof.physicsBody.categoryBitMask = floorCategory;
	roof.position = CGPointMake(0, sceneSize.height);
	[self addChild:roof];
	
	
	self.backgroundColor = [Utility colorWithHex:0x91bae4 alpha:1];
	// Color Background
	backgroundLaver0 = [SKSpriteNode spriteNodeWithImageNamed:backgroundCategoryName_l0_ImgName];
	backgroundLaver0.anchorPoint = (CGPoint){0, 0};
	backgroundLaver0.position = (CGPoint){0, 0};
	backgroundLaver0.name = backgroundCategoryName_l0;
	backgroundLaver0.zPosition = backgroundCategoryName_l0ZIndex;
	[self addChild:backgroundLaver0];
	
	// Background city
	SKSpriteNode *bg;
	for (NSUInteger i=0; i<2; ++i) {
		bg = [SKSpriteNode spriteNodeWithImageNamed:backgroundCategoryName_l1_ImgName];
		bg.anchorPoint = (CGPoint){0, 0};
		bg.position = (CGPoint){i*bg.frame.size.width, 0};
		bg.zPosition = backgroundCategoryName_l1ZIndex;
		bg.name = backgroundCategoryName_l1;
		[self addChild:bg];
		
		bg = [SKSpriteNode spriteNodeWithImageNamed:backgroundCategoryName_l2_ImgName];
		bg.anchorPoint = (CGPoint){0, 0};
		bg.position = (CGPoint){i*bg.frame.size.width, 0};
		bg.zPosition = backgroundCategoryName_l2ZIndex;
		bg.name = backgroundCategoryName_l2;
		[self addChild:bg];
	}
	
	sun = [SKSpriteNode spriteNodeWithImageNamed:@"sun"];
	sun.anchorPoint = CGPointMake(0.5, 1);
	sun.zPosition = sunCategoryNameZIndex;
}

- (void) initializeSoundBackground
{
	// Sound Theme
	//SKAction *themeSong = [SKAction playSoundFileNamed:@"Theme.caf" waitForCompletion:YES];
	//[self runAction:[SKAction repeatActionForever:themeSong]];
	
	NSError *error;
	NSURL * backgroundMusicURL = [[NSBundle mainBundle] URLForResource:@"Theme" withExtension:@"caf"];
	backgroundMusicPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:backgroundMusicURL error:&error];
	backgroundMusicPlayer.numberOfLoops = -1;
	[backgroundMusicPlayer prepareToPlay];
}

- (void)moveBackgroundScroller:(CFTimeInterval)timeSinceLast
{

	CGFloat padding = 0.3;
	__block SKSpriteNode * bg = nil;
	__block CGPoint newPosition;
	CGPoint bgVelocity = CGPointMake(- BG_VELOCITY_PER_SEC_LAYER0 , 0);
	CGPoint amtToMove = CGPointMultiplyScalar(bgVelocity, timeSinceLast);
	
    [self enumerateChildNodesWithName:backgroundCategoryName_l1 usingBlock: ^(SKNode *node, BOOL *stop)
     {
         bg = (SKSpriteNode *) node;
         newPosition = CGPointAdd(bg.position, amtToMove);
         
         //Checks if bg node is completely scrolled of the screen, if yes then put it at the end of the other node
         if (newPosition.x + bg.size.width-padding  <= 0) {
             bg.position = CGPointMake(bg.size.width - padding,  bg.position.y);
         } else {
			 bg.position = newPosition;
		 }
     }];
	
	bgVelocity = CGPointMake(- BG_VELOCITY_PER_SEC_LAYER1 , 0);
	amtToMove = CGPointMultiplyScalar(bgVelocity, timeSinceLast);
	[self enumerateChildNodesWithName:backgroundCategoryName_l2 usingBlock: ^(SKNode *node, BOOL *stop)
     {
         bg = (SKSpriteNode *) node;
         newPosition = CGPointAdd(bg.position, amtToMove);
         
         //Checks if bg node is completely scrolled of the screen, if yes then put it at the end of the other node
         if (newPosition.x + bg.size.width-padding  <= 0) {
             bg.position = CGPointMake(bg.size.width - padding,  bg.position.y);
         } else {
			 bg.position = newPosition;
		 }
     }];
}

- (void) clouds:(BOOL) force
{
    //not always come
    NSInteger GoOrNot = [Math getRandomNumberBetween:0 to:2];
    
    if(force == NO && GoOrNot != 1) {
		return;
	}
	
	SKSpriteNode *cloud = [SKSpriteNode spriteNodeWithImageNamed:@"cloud"];
	cloud.name = cloudCategoryName;
	NSInteger randomYAxix = [Math getRandomNumberBetween:200 to:landscapeHeight];
	cloud.position = CGPointMake(landscapeWidth + cloud.size.width*0.5, randomYAxix);
	cloud.zPosition = cloudCategoryNameZIndex;
	cloud.alpha =  [Math rand:0.6 to:1];
	cloud.scale = [Math rand:0.5 to:1];
	NSInteger randomTimeCloud = [Math getRandomNumberBetween:10 to:19];
	
	SKAction *move =[SKAction moveTo:CGPointMake(0 - cloud.size.width, randomYAxix) duration:randomTimeCloud];
	SKAction *remove = [SKAction removeFromParent];
	[cloud runAction:[SKAction sequence:@[move, remove]]];
	[self addChild:cloud];
	
}

- (SKSpriteNode *) makeBall:(CGPoint) location
{
	SKSpriteNode *sprite = [SKSpriteNode spriteNodeWithImageNamed:@"ball"];
	sprite.name = ballCategoryName;
	
	sprite.position = CGPointMake(location.x, location.y) ;
	
	sprite.physicsBody = [SKPhysicsBody bodyWithCircleOfRadius:sprite.size.width/2];
	sprite.physicsBody.allowsRotation = NO;
	sprite.physicsBody.restitution = 1.0f;
	sprite.physicsBody.friction = 0.0f;
	sprite.physicsBody.linearDamping = 0.0f;
	//ball is not moving at the beginning
	//sprite.physicsBody.velocity = CGVectorMake(-150, 0);
	
	sprite.physicsBody.categoryBitMask = ballCategory;
	sprite.physicsBody.collisionBitMask = floorCategory;
    sprite.physicsBody.contactTestBitMask = floorCategory ;
	sprite.zPosition = ballCategoryZIndex;
	
	NSString *firePath = [[NSBundle mainBundle] pathForResource:@"fireBall" ofType:@"sks"];
	SKEmitterNode *_fireBall = [NSKeyedUnarchiver unarchiveObjectWithFile:firePath];
	_fireBall.position = CGPointMake(-_fireBall.frame.size.width*0.5, - _fireBall.frame.size.height*0.5 - 11 );
	[sprite addChild:_fireBall];
	
	return  sprite;
}

- (SKSpriteNode *) makeCoin:(CGPoint) location
{
    SKTexture *coinTexture = [SKTexture textureWithImageNamed:kCoin1FileName];
    SKSpriteNode *coin = [SKSpriteNode spriteNodeWithTexture:coinTexture];
    coin.name = coinCategoryName;
    coin.position = CGPointMake(location.x, location.y + coin.frame.size.width);
    coin.physicsBody = [SKPhysicsBody bodyWithRectangleOfSize:coin.size];
    coin.physicsBody.categoryBitMask = coinCategory;
    coin.physicsBody.contactTestBitMask = paperPlaineCategory;
    coin.physicsBody.collisionBitMask = floorCategory;
    coin.physicsBody.density = 1.0;
    coin.physicsBody.linearDamping = 0.1;
    coin.physicsBody.restitution = 0.2;
    coin.physicsBody.allowsRotation = NO;
	coin.physicsBody.affectedByGravity = NO;
	coin.zPosition = coinCategoryZIndex;
	
    SKAction *walkAnimation = [SKAction animateWithTextures:coinTextures timePerFrame:0.08];
    SKAction *walkForever = [SKAction repeatActionForever:walkAnimation];
    [coin runAction:walkForever];
	
	return coin;
}

- (void) addBall
{
	if ([Math getRandomNumberBetween:0 to:3] == 1) {
		return;
	}
	
	SKSpriteNode *sprite = [self makeBall:CGPointMake(landscapeWidth + 1,  [Math rand:flootHeight+7 to:landscapeHeight/3.55] )];
	
	[self addChild:sprite];
	[sprite.physicsBody applyImpulse:CGVectorMake(- [Math rand:8 to:12], - [Math rand:8 to:12] )];
}

- (void) addCoin
{
	SKSpriteNode *sprite = [self makeCoin:CGPointMake(self.frame.size.width + 1, [Math rand:flootHeight to:landscapeHeight/3.2] )];
	
	[self addChild:sprite];
	
    SKAction *actionMove = [SKAction moveTo:CGPointMake(-sprite.size.width/2, sprite.frame.origin.y) duration:(TIME * 5)];
    SKAction *actionMoveDone = [SKAction removeFromParent];
    [sprite runAction:[SKAction sequence:@[actionMove, actionMoveDone]]];
}

- (void) initializeCall
{
	// Telephone call
	callSub = [SKSpriteNode spriteNodeWithImageNamed:@"telephone"];
	call = [SKSpriteNode spriteNodeWithColor:[SKColor clearColor] size:callSub.size];
	call.position = CGPointMake(landscapeWidth + call.size.width*0.5, landscapeHeight*0.5);
	call.zPosition = ballCategoryZIndex + 0.01;
	call.physicsBody = [SKPhysicsBody bodyWithRectangleOfSize:call.size];
	call.physicsBody.affectedByGravity = NO;
	call.physicsBody.categoryBitMask = callCategory;
	call.physicsBody.contactTestBitMask = paperPlaineCategory;
	call.physicsBody.collisionBitMask = floorCategory;
	call.physicsBody.dynamic  = NO;
	call.scale = 0.7;
	call.name = callCategoryName;
	[self addChild:call];
	[call addChild:callSub];
	
	NSURL * backgroundMusicURL = [[NSBundle mainBundle] URLForResource:@"Telephone_Ring" withExtension:@"caf"];
	callMusicPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:backgroundMusicURL error:nil];
	callMusicPlayer.numberOfLoops = -1;
	[callMusicPlayer prepareToPlay];
}

#pragma mark -Initialize PaperPlaine
- (void)initializePaperPlaine
{
    
    paperPlaine = [SKSpriteNode spriteNodeWithImageNamed:@"paperPlane"];
    paperPlaine.name = paperPlaineCategoryName;
    /*
     * Create a physics and specify its geometrical shape so that collision algorithm
     * can work more prominently
     */
    paperPlaine.physicsBody = [SKPhysicsBody bodyWithRectangleOfSize:paperPlaine.size];
	//_paperPlaine.physicsBody = [SKPhysicsBody bodyWithTexture:_paperPlaine.texture size:_paperPlaine.texture.size]; ios8
    
    //Category to which this object belongs to
    paperPlaine.physicsBody.categoryBitMask = paperPlaineCategory;
    
    //To notify intersection with objects
    paperPlaine.physicsBody.contactTestBitMask = coinCategory | ballCategory | invulnerabilityCategory;
    
    //To detect collision with category of objects
    paperPlaine.physicsBody.collisionBitMask = floorCategory;
    
    paperPlaine.physicsBody.velocity = CGVectorMake(0, 0);
	
	paperPlaine.physicsBody.density = 1.5;
	
	paperPlaine.physicsBody.allowsRotation = NO;
	
	paperPlaine.physicsBody.mass = 1.3e-6f;
	
	// NO Gravity at Start
	paperPlaine.physicsBody.affectedByGravity = NO;
	
	// Save original PhysicsBody
	paperPlainePhysicsBody = paperPlaine.physicsBody;
	
	paperPlaine.zPosition = paperPlaineCategoryZIndex;
	
	// Smoke
	NSString *smokePath = [[NSBundle mainBundle] pathForResource:@"Smoke" ofType:@"sks"];
	SKEmitterNode *_smokeTrail = [NSKeyedUnarchiver unarchiveObjectWithFile:smokePath];
	_smokeTrail.position = CGPointMake(- paperPlaine.frame.size.width/2 +2, -1);
	[paperPlaine addChild:_smokeTrail];
	

	[self addChild:paperPlaine];
}

- (void) updateScore:(NSInteger)valueToAdd
{
	score+= valueToAdd;
	[scoreNode updateScore:self newScore:score];
}

- (void) coinCollected:(SKSpriteNode *) coinNode
{
	[self runAction:collectedSound];
	
    // show amount of winnings
    SKLabelNode *moneyText = [SKLabelNode labelNodeWithFontNamed:@"Courier-Bold"];
    moneyText.text = [NSString stringWithFormat:@"+ %d", 1];
    moneyText.fontSize = 9;
    moneyText.fontColor = [SKColor whiteColor];
    moneyText.position = CGPointMake(coinNode.position.x-10, coinNode.position.y+28);
	moneyText.zPosition = coinCategoryZIndex;
    [self addChild:moneyText];
    
    SKAction *fadeAway = [SKAction fadeOutWithDuration:1];
    [moneyText runAction:fadeAway completion:^{ [moneyText removeFromParent]; }];
    
    // particle special effect
    NSString *emitterPath = [[NSBundle mainBundle] pathForResource:@"CoinCollected" ofType:@"sks"];
    SKEmitterNode *bling = [NSKeyedUnarchiver unarchiveObjectWithFile:emitterPath];
    bling.position = coinNode.position;
    bling.name = @"coinCollected";
    bling.targetNode = self.scene;
	bling.zPosition = coinCategoryZIndex;
    [self addChild:bling];
    
    [coinNode removeFromParent];
	
	// Score some bonus points
	[self updateScore:+1];
}


- (void) ballCollected:(SKSpriteNode *) nodeA andNodeB:(SKSpriteNode *) nodeB
{
	if (isInModeInvulnerability) {
		[nodeB removeAllActions];
		if ([nodeB.name isEqualToString:callCategoryName]) {
			runCall = NO;
			[self endCall];
		}
		nodeB.physicsBody.categoryBitMask = 0;
		nodeB.physicsBody.collisionBitMask = 0;
    	nodeB.physicsBody.contactTestBitMask = 0;
		nodeB.physicsBody.velocity = CGVectorMake(0, 0);
		[nodeB.physicsBody applyImpulse: CGVectorMake(-nodeB.physicsBody.velocity.dx, -nodeB.physicsBody.velocity.dy*2)];
		return;
	}
	
	// Else
	[backgroundMusicPlayer stop];
	
	//add explosion
	SKSpriteNode *explosion = [SKSpriteNode spriteNodeWithTexture:[explosionTextures objectAtIndex:0]];
	explosion.zPosition = paperPlaineCategoryZIndex;
	explosion.scale = 0.3;
	explosion.position = nodeA.position;
	[self addChild:explosion];
	
    [self runAction:explosionSound];
	
	paperPlaine.hidden = YES;
	
	SKAction *explosionAction = [SKAction animateWithTextures:explosionTextures timePerFrame:0.07];
	SKAction *remove = [SKAction removeFromParent];
	[explosion runAction:[SKAction sequence:@[explosionAction,remove]]];
	
	[self showGameOverLayer:YES];
}

- (void) invulnerabilityCollected:(SKSpriteNode *) nodeA andNodeB:(SKSpriteNode *) nodeB
{
	[self enterInInvulnerabilityMode];
	[nodeB removeAllActions];
	[nodeB removeFromParent];
}

#pragma mark -Initialize Helper Layers
- (void) initializeStartGameLayer
{
    _startGameLayer = [[StartGameLayer alloc]initWithSize:(CGSize){landscapeWidth, landscapeHeight}];
    _startGameLayer.userInteractionEnabled = YES;
    _startGameLayer.zPosition = 1500;
    _startGameLayer.delegate = self;
}

- (void) initializeGameOverLayer
{
    _gameOverLayer = [[GameOverLayer alloc]initWithSize:(CGSize){landscapeWidth, landscapeHeight}];
    _gameOverLayer.userInteractionEnabled = YES;
    _gameOverLayer.zPosition = 1000;
    _gameOverLayer.delegate = self;
}


#pragma mark - Delegates
#pragma mark -StartGameLayer
- (void)startGameLayer:(StartGameLayer *)sender tapRecognizedOnButton:(StartGameLayerButtonType)startGameLayerButton
{
    _gameOver = NO;
    _gameStarted = YES;
    
    [self startGame];
}

- (void)gameOverLayer:(GameOverLayer *)sender tapRecognizedOnButton:(GameOverLayerButtonType)gameOverLayerButtonType
{
    _gameOver = NO;
    _gameStarted = NO;
    [self showStartGameLayer];
}

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    /* Called when a touch begins */
    /*
    for (UITouch *touch in touches) {
        //CGPoint location = [touch locationInNode:self];
		
    }
	 */
	
    if(_gameStarted && _gameOver == NO) {
		if (paperPlaine.physicsBody.affectedByGravity) {
			paperPlaine.physicsBody.velocity = CGVectorMake(0, 300);
		} else {
			paperPlaine.physicsBody.affectedByGravity = YES;
			paperPlaine.physicsBody.velocity = CGVectorMake(0, 70);
		}
    }
}
#pragma mark -
- (void) didBeginContact:(SKPhysicsContact *)contact
{
    SKPhysicsBody *firstBody, *secondBody;
    
    if (contact.bodyA.categoryBitMask < contact.bodyB.categoryBitMask)
    {
        firstBody = contact.bodyA;
        secondBody = contact.bodyB;
    }
    else {
        firstBody = contact.bodyB;
        secondBody = contact.bodyA;
    }
    
    // contact body name
    //NSString *firstBodyName = firstBody.node.name;
	
    // Player / Coins
    if ( (firstBody.categoryBitMask & paperPlaineCategory) != 0 && (secondBody.categoryBitMask & coinCategory) != 0 ) {
        [self coinCollected:(SKSpriteNode *)secondBody.node];
    }

    // Player / Balls
    if ( (firstBody.categoryBitMask & paperPlaineCategory) != 0 && (secondBody.categoryBitMask & ballCategory) != 0 ) {
        [self ballCollected:(SKSpriteNode *)firstBody.node andNodeB:(SKSpriteNode *)secondBody.node];
    }

    // Player / Call
    if ( (firstBody.categoryBitMask & paperPlaineCategory) != 0 && (secondBody.categoryBitMask & callCategory) != 0 ) {
        [self ballCollected:(SKSpriteNode *)firstBody.node andNodeB:(SKSpriteNode *)secondBody.node];
    }

    // Player / Invulnerability
    if ( (firstBody.categoryBitMask & paperPlaineCategory) != 0 && (secondBody.categoryBitMask & invulnerabilityCategory) != 0 ) {
        [self invulnerabilityCollected:(SKSpriteNode *)firstBody.node andNodeB:(SKSpriteNode *)secondBody.node];
    }
}

#pragma mark - Update
-(void)update:(CFTimeInterval)currentTime {
    /* Called before each frame is rendered */

    if(_gameOver == NO)
    {
        if (lastUpdateTimeInterval) {
            _dt = currentTime - lastUpdateTimeInterval;
        } else {
            _dt = 0;
        }
		
        CFTimeInterval timeSinceLast = currentTime - lastUpdateTimeInterval;
        lastUpdateTimeInterval = currentTime;
        if (timeSinceLast > TIME)
        {
            timeSinceLast = 1.0 / (TIME * 60.0);
            lastUpdateTimeInterval = currentTime;
        }

		[self moveBackgroundScroller:timeSinceLast];

        if(_gameStarted) {
			_gameOverElapsed += _dt;
            [self updateWithTimeSinceLastUpdate:timeSinceLast];
        }
		
		/*
		static CFTimeInterval nextGameWorldUpdateTime = 0;
		if (currentTime >= nextGameWorldUpdateTime) {
			// game world updates at a fixed 30 Hz (30 times per second)
			// with fps below 30 fps this block will run every frame
			nextGameWorldUpdateTime = currentTime + (1.0 / 30.0);
		}
		 */
		
    } else {
		_gameOverElapsed = 0;
	}
}

#pragma mark _
- (void)updateWithTimeSinceLastUpdate:(CFTimeInterval)timeSinceLast
{
	
	if (isInModeInvulnerability == NO) {
		paperPlaine.zRotation = [Utility clamp:-1 withMax:0.0 currentValur: paperPlaine.physicsBody.velocity.dy * ( paperPlaine.physicsBody.velocity.dy < 0 ? 0.002 : 0.001 ) ];
	}
	lastSpawnTimeInterval += timeSinceLast;
    if (lastSpawnTimeInterval > TIME) {
        lastSpawnTimeInterval = 0;
		[self addCoin];
        [self addBall];
    }
	
	if (runCall) {
		CGFloat y = (sinf(_gameOverElapsed * 5.0f)) * BG_VELOCITY_PER_SEC_LAYER1 *4 ;
		CGPoint bgVelocity = CGPointMake(- BG_VELOCITY_PER_SEC_LAYER1*4, y);
		CGPoint amtToMove = CGPointMultiplyScalar(bgVelocity, timeSinceLast);
		call.position = CGPointAdd(call.position, amtToMove);
		[self shake:2 withNode:callSub];
		if (call.position.x + call.size.width*0.5 < 0) {
			[self endCall];
		}
	}
	
    static int maxSpeed = 600;
	[self enumerateChildNodesWithName:ballCategoryName usingBlock:^(SKNode	*node, BOOL *stop) {
		float speed = sqrt(node.physicsBody.velocity.dx*node.physicsBody.velocity.dx + node.physicsBody.velocity.dy * node.physicsBody.velocity.dy);
		if (speed > maxSpeed) {
			node.physicsBody.linearDamping = 0.4f;
		} else {
			node.physicsBody.linearDamping = 0.0f;
		}
		// Remove the ball is out of scene
		if (node.position.x + node.frame.size.width/2 < 0 ||
			node.position.x - node.frame.size.width/2 > landscapeWidth ||
			node.position.y + node.frame.size.height/2 < 0 ||
			node.position.y - node.frame.size.height/2 > landscapeHeight)
		{
			[node removeFromParent];
		}
		
		
	}];
}


@end
