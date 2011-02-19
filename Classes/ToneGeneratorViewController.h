//
//  ToneGeneratorViewController.h
//  SoundTweak
//
//  Created by Bryan Montz on 10/30/10.
//  Copyright 2010 Evan Hamilton. All rights reserved.
//
@class STSmallSlider;
#import <UIKit/UIKit.h>
#import <AudioUnit/AudioUnit.h>

@interface ToneGeneratorViewController : UIViewController {
	UILabel                 *_frequencyLabel;
	STSmallSlider           *_slider;
	AudioComponentInstance  _toneUnit;
    
    UIButton                *_hotButton60;
    UIButton                *_hotButton250;
    UIButton                *_hotButton500;
    UIButton                *_hotButton750;
    UIButton                *_hotButton1000;
    UIButton                *_hotButton2500;
    UIButton                *_hotButton10k;
    UIButton                *_hotButton18k;
}

@property (nonatomic, retain) IBOutlet UILabel *frequencyLabel;
@property (nonatomic, retain) IBOutlet STSmallSlider *slider;
@property (nonatomic, retain) IBOutlet UIButton *hotButton60;
@property (nonatomic, retain) IBOutlet UIButton *hotButton250;
@property (nonatomic, retain) IBOutlet UIButton *hotButton500;
@property (nonatomic, retain) IBOutlet UIButton *hotButton750;
@property (nonatomic, retain) IBOutlet UIButton *hotButton1000;
@property (nonatomic, retain) IBOutlet UIButton *hotButton2500;
@property (nonatomic, retain) IBOutlet UIButton *hotButton10k;
@property (nonatomic, retain) IBOutlet UIButton *hotButton18k;


-(IBAction) sliderChangedValue:(UISlider *)aSlider;
-(IBAction) hotButtonPressed: (id) sender;

@end
