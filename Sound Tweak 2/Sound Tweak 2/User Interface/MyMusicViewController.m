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

static NSString * const kAudioFileCell = @"kAudioFileCell";
static NSString * const kAudioPickItemsCell = @"kAudioPickItemsCell";

@interface MyMusicViewController () <NSFetchedResultsControllerDelegate>

@property (nonatomic, strong) NSFetchedResultsController *fetchedResultsController;

@property (nonatomic, weak) UIView *backdropView;

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
        back.backgroundColor = [[UIColor soundTweakHairLinePurple] colorWithAlphaComponent:0.8];
        [back addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dismissAudioFile:)]];
        _backdropView = back;
        [self.view addSubview:back];
    }
    _backdropView.alpha = 0.0;
    
    UIView *snapshot = [self.collectionView snapshotViewAfterScreenUpdates:YES];
    snapshot.frame = _backdropView.bounds;
    
    [_backdropView addSubview:snapshot];
    
    [UIView animateWithDuration:0.2 animations:^{
        _backdropView.alpha = 1.0;
    }];
}
- (void)dismissAudioFile:(UITapGestureRecognizer *)tapper {
    
    [UIView animateWithDuration:0.2 animations:^{
        _backdropView.alpha = 0.0;
    } completion:^(BOOL finished) {
        [_backdropView removeFromSuperview];
        _backdropView = nil;
    }];
}

#pragma mark -
#pragma mark - Fetch controller delegate
- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller {
    [self.collectionView reloadData];
}

@end
