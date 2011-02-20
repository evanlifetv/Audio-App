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
    
    UILabel                 *_artistLabel;
    UILabel                 *_songTitleLabel;
    UIImageView             *_artworkView;
}

@property (nonatomic, retain) IBOutlet UITableView *tableView;
@property (nonatomic, retain) IBOutlet UILabel *artistLabel;
@property (nonatomic, retain) IBOutlet UILabel *songTitleLabel;
@property (nonatomic, retain) IBOutlet UIImageView *artworkView;

@end
