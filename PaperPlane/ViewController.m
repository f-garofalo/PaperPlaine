//
//  ViewController.m
//  firtProject
//
//  Created by Fortunato Garofalo on 29/08/14.
//  Copyright (c) 2014 com.felix. All rights reserved.
//

#import "ViewController.h"
#import "Scene.h"

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

    // Configure the view.
    SKView * skView = (SKView *)self.view;
	
#ifdef DEBUG
    skView.showsFPS = YES;
    skView.showsNodeCount = YES;
	skView.showsDrawCount = NO;
	skView.showsPhysics = NO;
#endif
	
    // Create and configure the scene.
    SKScene * scene = [Scene sceneWithSize:skView.bounds.size];
    scene.scaleMode = SKSceneScaleModeResizeFill;
    
    // Present the scene.
    [skView presentScene:scene];
}

- (BOOL)shouldAutorotate
{
    return YES;
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations
{
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        return UIInterfaceOrientationMaskAllButUpsideDown;
    } else {
        return UIInterfaceOrientationMaskAll;
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Release any cached data, images, etc that aren't in use.
}

- (BOOL)prefersStatusBarHidden
{
	return YES;
}

@end
