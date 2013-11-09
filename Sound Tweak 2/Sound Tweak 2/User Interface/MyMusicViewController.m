/*!
 *  MyMusicViewController.m
 *
 * Copyright (c) 2013 OpenSky, LLC
 *
 * Created by Skylar Schipper on 11/8/13
 */

#import "MyMusicViewController.h"
#import "SDTAudioManager.h"

@implementation MyMusicViewController

- (NSString *)title {
    return NSLocalizedString(@"My Music", nil);
}

- (IBAction)pickMediaButtonAction:(id)sender {
    MPMediaPickerController *controller = [[MPMediaPickerController alloc] initWithMediaTypes:MPMediaTypeMusic];
    controller.allowsPickingMultipleItems = YES;
    controller.delegate = self;
    controller.prompt = NSLocalizedString(@"Pick some music.", nil);
    controller.showsCloudItems = NO;
    
    [self presentViewController:controller animated:YES completion:nil];
}

#pragma mark -
#pragma mark - Media Picker Delegate
- (void)mediaPicker:(MPMediaPickerController *)mediaPicker didPickMediaItems:(MPMediaItemCollection *)mediaItemCollection {
    [self dismissViewControllerAnimated:YES completion:nil];
    for (MPMediaItem *item in mediaItemCollection.items) {
        [[SDTAudioManager sharedManager] saveMediaItem:item completion:^(NSError *error) {
            NSLog(@"Completion Error: %@",error);
        }];
    }
}
- (void)mediaPickerDidCancel:(MPMediaPickerController *)mediaPicker {
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
