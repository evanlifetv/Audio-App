//
//  STSmallSlider.m
//  SoundTweak
//
//  Created by Bryan Montz on 11/15/10.
//  Copyright 2010 Evan Hamilton. All rights reserved.
//

#import "STSmallSlider.h"


@implementation STSmallSlider


- (void)awakeFromNib
{
	//Slider Images
	UIImage *stetchLeftTrack = [[UIImage imageNamed:@"sliderbackmax-small.png"] stretchableImageWithLeftCapWidth:12.0 topCapHeight:0.0];
	UIImage *stetchRightTrack = [[UIImage imageNamed:@"sliderbackmin-small.png"]  stretchableImageWithLeftCapWidth:12.0 topCapHeight:0.0];
	
	//Slider: Audio Title
	self.backgroundColor = [UIColor clearColor];	
	[self setThumbImage: [UIImage imageNamed:@"sliderthumb-small.png"] forState:UIControlStateNormal];
	[self setMinimumTrackImage:stetchLeftTrack forState:UIControlStateNormal];
	[self setMaximumTrackImage:stetchRightTrack forState:UIControlStateNormal];
}


@end
