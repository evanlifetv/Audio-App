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

// How many extra touchable pixels you want above and below the 23px slider
#define SIZE_EXTENSION_Y -10

- (BOOL) pointInside:(CGPoint)point withEvent:(UIEvent*)event {
    CGRect bounds = self.bounds;
    bounds = CGRectInset(bounds, 0, SIZE_EXTENSION_Y);
    return CGRectContainsPoint(bounds, point);
}

@end
