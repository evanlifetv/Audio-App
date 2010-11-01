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
		self.tabBarItem.image = [UIImage imageNamed:@"volume_up.png"];
        self.tabBarItem.title = @"Sweep";
    }
    return self;
}

@end
