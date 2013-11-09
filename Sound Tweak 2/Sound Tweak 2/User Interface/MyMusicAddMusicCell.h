/*!
 * MyMusicAddMusicCell.h
 *
 * Copyright (c) 2013 OpenSky, LLC
 *
 * Created by Skylar Schipper on 11/9/13
 */

#ifndef MyMusicAddMusicCell_h
#define MyMusicAddMusicCell_h

#import <UIKit/UIKit.h>

@interface MyMusicAddMusicCellAddView : UIView

@end

@interface MyMusicAddMusicCell : UICollectionViewCell

@property (nonatomic, weak) MyMusicAddMusicCellAddView *addView;
@property (nonatomic, weak) UILabel *addItemLabel;

@end

#endif
