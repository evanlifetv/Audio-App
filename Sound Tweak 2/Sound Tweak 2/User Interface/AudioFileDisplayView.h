/*!
 * AudioFileDisplayView.h
 *
 * Copyright (c) 2013 OpenSky, LLC
 *
 * Created by Skylar Schipper on 11/9/13
 */

#ifndef AudioFileDisplayView_h
#define AudioFileDisplayView_h

#import <UIKit/UIKit.h>
#import "SDTAudioManager.h"

@class AudioFileDisplayView;
@protocol AudioFileDisplayViewDelegate <NSObject>

@required
- (void)audioFileDisplayView:(AudioFileDisplayView *)displayView shouldRemoveAudioFile:(AudioFile *)audioFile;

@end

@interface AudioFileDisplayView : UIView

@property (nonatomic, assign) id<AudioFileDisplayViewDelegate> delegate;

@property (nonatomic, weak) AudioFile *audioFile;

- (void)showInterfaceCompletion:(void(^)(void))completion;
- (void)hideInterfaceCompletion:(void(^)(void))completion;

@property (nonatomic) CGFloat bottomOffset;

@end

#endif
