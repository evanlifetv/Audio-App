//
//  SweepGeneratorViewController.m
//  referenceaudio
//
//  Created by Evan Hamilton on 10/31/10.
//  Copyright 2010 Evan Hamilton. All rights reserved.
//

#import "SweepGeneratorViewController.h"


@implementation SweepGeneratorViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
		self.tabBarItem.image = [UIImage imageNamed:@"sweep.png"];
        self.tabBarItem.title = @"Frequency Sweep";
    }
    return self;
}

@end
