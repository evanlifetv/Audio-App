//
//  SupportViewController.m
//  referenceaudio
//
//  Created by Evan Hamilton on 10/31/10.
//  Copyright 2010 Evan Hamilton. All rights reserved.
//

#import "SupportViewController.h"
#import "AppDelegate.h"

@implementation SupportViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
		self.tabBarItem.image = [UIImage imageNamed:@"forward.png"];
        self.tabBarItem.title = @"Support";
    }
    return self;
}

- (void)viewWillAppear:(BOOL)animated
{
	[super viewWillAppear:animated];
	
	self.tabBarController.view.frame = CGRectMake(0, 0, 768, 1024);
}

- (void)viewWillDisappear:(BOOL)animated
{
	[super viewWillDisappear:animated];
	
	self.tabBarController.view.frame = CGRectMake(0, 530, 768, 494);
}

@end
