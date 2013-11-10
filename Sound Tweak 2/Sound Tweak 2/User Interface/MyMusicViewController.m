/*!
 *  MyMusicViewController.m
 *
 * Copyright (c) 2013 OpenSky, LLC
 *
 * Created by Skylar Schipper on 11/8/13
 */

#import "MyMusicViewController.h"
#import "SDTAudioManager.h"
#import "MyMusicAddMusicCell.h"
#import "AudioFileCell.h"
#import "UIImage+OSDImageHelpers.h"
#import "AudioFileDisplayView.h"

static NSString * const kAudioFileCell = @"kAudioFileCell";
static NSString * const kAudioPickItemsCell = @"kAudioPickItemsCell";

@interface MyMusicViewController () <NSFetchedResultsControllerDelegate, AudioFileDisplayViewDelegate, UIActionSheetDelegate>

@property (nonatomic, strong) NSFetchedResultsController *fetchedResultsController;

@property (nonatomic, weak) AudioFileDisplayView *displayView;
@property (nonatomic, weak) UIView *backdropView;

@property (nonatomic, weak) AudioFile *stagedToDelete;

@end

@implementation MyMusicViewController

- (NSString *)title {
    return NSLocalizedString(@"My Music", nil);
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.collectionView.alwaysBounceVertical = YES;
    [self.collectionView registerClass:[AudioFileCell class] forCellWithReuseIdentifier:kAudioFileCell];
    [self.collectionView registerClass:[MyMusicAddMusicCell class] forCellWithReuseIdentifier:kAudioPickItemsCell];
    
    self.collectionView.contentInset = UIEdgeInsetsMake(0, 0, self.tabBarController.tabBar.frame.size.height, 0);
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [[SDTAudioManager sharedManager] dumpMemCache];
}

#pragma mark -
#pragma mark - Lazy Loaders
- (NSFetchedResultsController *)fetchedResultsController {
    if (!_fetchedResultsController) {
        NSFetchRequest *fetch = [AudioFile fetchRequest];
        fetch.predicate = [NSPredicate predicateWithFormat:@"assetName != NULL"];
        fetch.sortDescriptors = @[
                                  [NSSortDescriptor sortDescriptorWithKey:@"title" ascending:YES],
                                  [NSSortDescriptor sortDescriptorWithKey:@"artist" ascending:YES],
                                  [NSSortDescriptor sortDescriptorWithKey:@"albumTitle" ascending:YES]
                                  ];
        
        _fetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetch
                                                                        managedObjectContext:[[OSDCoreDataManager sharedManager] managedObjectContext]
                                                                          sectionNameKeyPath:nil
                                                                                   cacheName:nil];
        _fetchedResultsController.delegate = self;
        
        NSError *fetchError = nil;
        if (![_fetchedResultsController performFetch:&fetchError]) {
            NSLog(@"%@",fetchError);
        }
    }
    return _fetchedResultsController;
}


#pragma mark -
#pragma mark - Add Media
- (IBAction)pickMediaButtonAction:(id)sender {
    MPMediaPickerController *controller = [[MPMediaPickerController alloc] initWithMediaTypes:MPMediaTypeMusic];
    controller.allowsPickingMultipleItems = YES;
    controller.delegate = self;
    controller.prompt = NSLocalizedString(@"Pick some music.", nil);
    controller.showsCloudItems = NO;
    
    [self presentViewController:controller animated:YES completion:nil];
}

- (NSIndexPath *)addMediaIndexPath {
    return [NSIndexPath indexPathForRow:[self.collectionView numberOfItemsInSection:0] - 1 inSection:0];
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

#pragma mark -
#pragma mark - Collection view data source
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return [[self.fetchedResultsController fetchedObjects] count] + 1;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    if ([indexPath isEqual:[self addMediaIndexPath]]) {
        MyMusicAddMusicCell *myCell = [collectionView dequeueReusableCellWithReuseIdentifier:kAudioPickItemsCell forIndexPath:indexPath];
        
        myCell.addItemLabel.text = NSLocalizedString(@"Add Music", @"add music label title");
        
        return myCell;
    }
    AudioFileCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:kAudioFileCell forIndexPath:indexPath];
    
    
    AudioFile *file = [self.fetchedResultsController objectAtIndexPath:indexPath];
    cell.audioFile = file;
    
    return cell;
}

#pragma mark -
#pragma mark - Collection view delegate
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    CGFloat width = CGRectGetWidth(collectionView.frame);
    if ([[UIDevice currentDevice] isPad]) {
        width = width / 3;
    }
    return CGSizeMake(width, 60.0);
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    [collectionView deselectItemAtIndexPath:indexPath animated:YES];
    
    if ([indexPath isEqual:[self addMediaIndexPath]]) {
        [self pickMediaButtonAction:indexPath];
    } else {
        [self showAudioFile:[self.fetchedResultsController objectAtIndexPath:indexPath]];
    }
}

- (void)showAudioFile:(AudioFile *)audioFile {
    if (!_backdropView) {
        UIView *back = [[UIView alloc] initWithFrame:self.view.bounds];
        back.backgroundColor = [UIColor whiteColor];
        _backdropView = back;
        [self.view addSubview:back];
    }
    _backdropView.alpha = 0.0;
    
    UIGraphicsBeginImageContextWithOptions(_backdropView.bounds.size, YES, 0.5);
    
    [self.collectionView drawViewHierarchyInRect:CGRectMake(0, 0, _backdropView.bounds.size.width, _backdropView.bounds.size.height) afterScreenUpdates:YES];
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    UIImageView *imageView = [[UIImageView alloc] initWithFrame:_backdropView.bounds];
    
    imageView.image = [image osd_bluredImageWithRadius:10 tintColor:[[UIColor soundTweakHairLinePurple] colorWithAlphaComponent:0.2] error:nil];
    [_backdropView addSubview:imageView];
    
    AudioFileDisplayView *display = [[AudioFileDisplayView alloc] initWithFrame:_backdropView.frame];
    display.audioFile = audioFile;
    display.backgroundColor = [UIColor clearColor];
    display.bottomOffset = CGRectGetHeight(self.tabBarController.tabBar.bounds);
    display.delegate = self;
    [_backdropView addSubview:display];
    
    [display addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dismissAudioFile:)]];
    
    _displayView = display;
    
    [UIView animateWithDuration:0.2 animations:^{
        _backdropView.alpha = 1.0;
    } completion:^(BOOL finished) {
        [_displayView showInterfaceCompletion:nil];
    }];
}
- (void)dismissAudioFile:(UITapGestureRecognizer *)tapper {
    [_displayView hideInterfaceCompletion:^{
        [UIView animateWithDuration:0.2 animations:^{
            _backdropView.alpha = 0.0;
        } completion:^(BOOL finished) {
            [_displayView removeFromSuperview];
            _displayView = nil;
            [_backdropView removeFromSuperview];
            _backdropView = nil;
        }];
    }];
}

#pragma mark -
#pragma mark - AudioFileDisplayViewDelegate
- (void)audioFileDisplayView:(AudioFileDisplayView *)displayView shouldRemoveAudioFile:(AudioFile *)audioFile {
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:nil
                                                             delegate:self
                                                    cancelButtonTitle:nil
                                               destructiveButtonTitle:nil
                                                    otherButtonTitles:nil, nil];
    actionSheet.tintColor = [UIColor soundTweakPurple];
    
    self.stagedToDelete = audioFile;
    
    NSInteger removeIndex = [actionSheet addButtonWithTitle:NSLocalizedString(@"Remove", nil)];
    actionSheet.destructiveButtonIndex = removeIndex;
    
    NSInteger cancelIndex = [actionSheet addButtonWithTitle:NSLocalizedString(@"Cancel", nil)];
    actionSheet.cancelButtonIndex = cancelIndex;
    
    [actionSheet showFromTabBar:self.tabBarController.tabBar];
}
- (void)audioFileDisplayView:(AudioFileDisplayView *)displayView shouldPlayAudioFile:(AudioFile *)audioFile {
    BOOL isCurrent = [audioFile isPlayerItem:[[OSDAudioPlayer sharedPlayer] currentlyPlayingItem]];
    if (isCurrent && [[OSDAudioPlayer sharedPlayer] isPlaying]) {
        [[OSDAudioPlayer sharedPlayer] pause];
    } else if (isCurrent && [[OSDAudioPlayer sharedPlayer] isPaused]) {
        [[OSDAudioPlayer sharedPlayer] play];
    } else if (isCurrent) {
        [[OSDAudioPlayer sharedPlayer] playCurrentItem];
    } else {
        OSDAudioPlayerItem *item = [[SDTAudioManager sharedManager] playerItemForAudioFile:audioFile];
        [[OSDAudioPlayer sharedPlayer] insertItemIntoQueue:item atIndex:0];
        [[OSDAudioPlayer sharedPlayer] playNextItem];
    }
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (buttonIndex == actionSheet.destructiveButtonIndex) {
        [self commitDeleteForItem:self.stagedToDelete];
    }
    _stagedToDelete = nil;
}

- (void)commitDeleteForItem:(AudioFile *)audioFile {
    if ([audioFile isPlayerItem:[[OSDAudioPlayer sharedPlayer] currentlyPlayingItem]]) {
        [[OSDAudioPlayer sharedPlayer] stop];
    }
    [[[OSDCoreDataManager sharedManager] managedObjectContext] deleteObject:audioFile];
    [[OSDCoreDataManager sharedManager] save];
    [self.collectionView reloadData];
    [self dismissAudioFile:nil];
}

#pragma mark -
#pragma mark - Fetch controller delegate
- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller {
    [self.collectionView reloadData];
}

@end
