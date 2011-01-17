//
//  PlaylistViewController.h
//  SoundTweak
//
//  Created by Bryan Montz on 10/31/10.
//  Copyright 2010 Evan Hamilton. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface PlaylistViewController : UIViewController <UITableViewDataSource, UITableViewDelegate> {

	UITableView				*_tableView;
}

@property (nonatomic, retain) IBOutlet UITableView *tableView;

@end
