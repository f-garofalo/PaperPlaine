//
//  SKBScores.h
//  firtProject
//
//  Created by Fortunato Garofalo on 03/09/14.
//  Copyright (c) 2014 com.felix. All rights reserved.
//

@interface SKBScores : NSObject

- (void)createScoreNode:(SKScene *)whichScene atPoint:(CGPoint) startWhere;
- (void)updateScore:(SKScene *)whichScene newScore:(NSInteger)playerScore;
- (void) show:(SKScene *)whichScene mustShow:(BOOL)mustShow;
@end
