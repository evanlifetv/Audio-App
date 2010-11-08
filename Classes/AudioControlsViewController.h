//
//  AudioControlsViewController.h
//  SoundTweak
//
//  Created by Bryan Montz on 10/31/10.
//  Copyright 2010 Evan Hamilton. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface AudioControlsViewController : UIViewController {
	UIButton *_playButton;
	id _visibleViewController;
}

@property (nonatomic, retain) IBOutlet UIButton *playButton;
@property (nonatomic, retain) id visibleViewController;

//class methods
+ (AudioControlsViewController*)sharedInstance;

//instance methods
- (IBAction)playButtonPressed;

@end
