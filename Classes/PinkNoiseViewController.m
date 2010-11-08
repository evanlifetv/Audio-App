//
//  PinkNoiseViewController.m
//  SoundTweak
//
//  Created by Evan Hamilton on 10/31/10.
//  Copyright 2010 Evan Hamilton. All rights reserved.
//

#import "PinkNoiseViewController.h"


@implementation PinkNoiseViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
		self.tabBarItem.image = [UIImage imageNamed:@"pinknoise.png"];
        self.tabBarItem.title = @"Pink Noise";
    }
    return self;
}

@end
