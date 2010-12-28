
#import "SweepGeneratorViewController.h"
#import "AudioControlsViewController.h"
#import "NSString+Additions.h"
#import "STSmallSlider.h"
#import "ToneController.h"

#define MIN_DURATION 1
#define MAX_DURATION 30
#define DEFAULT_DURATION 15


NSNumberFormatter *__formatter = nil;

@interface SweepGeneratorViewController(privateMethods)
- (void)refreshInterface;
- (void)disableSliders;
- (void)enableSliders;
- (double)frequencyFromSlider:(STSmallSlider*)slider;
- (void)setSlider:(STSmallSlider*)slider toFrequency:(double)frequency;
@end


@implementation SweepGeneratorViewController

@synthesize startFrequencySlider = _startFrequencySlider;
@synthesize endFrequencySlider = _endFrequencySlider;
@synthesize durationSlider = _durationSlider;
@synthesize startFrequencyTitleLabel = _startFrequencyTitleLabel;
@synthesize startFrequencyLabel = _startFrequencyLabel;
@synthesize endFrequencyTitleLabel = _endFrequencyTitleLabel;
@synthesize endFrequencyLabel = _endFrequencyLabel;
@synthesize durationTitleLabel = _durationTitleLabel;
@synthesize durationLabel = _durationLabel;
@synthesize repeatSwitch = _repeatSwitch;


+ (void)initialize
{
	if (!__formatter) {
		__formatter = [[NSNumberFormatter alloc] init];
		[__formatter setRoundingIncrement:[NSNumber numberWithInt:1]];
	}
}


#pragma mark -
#pragma mark UIViewController lifecycle

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
		self.tabBarItem.image = [UIImage imageNamed:@"sweep.png"];
        self.tabBarItem.title = @"Frequency Sweep";
    }
    return self;
}


- (void)viewDidLoad
{
	[super viewDidLoad];
		
	self.durationSlider.minimumValue = MIN_DURATION;
	self.durationSlider.maximumValue = MAX_DURATION;
}


- (void)viewWillAppear:(BOOL)animated
{
	[super viewWillAppear:animated];
	
	//load last start and end frequencies
	double startFrequency = [[NSUserDefaults standardUserDefaults] doubleForKey:kLastSweepStartFrequency];
	double endFrequency = [[NSUserDefaults standardUserDefaults] doubleForKey:kLastSweepEndFrequency];
	
	if (startFrequency == 0 || endFrequency == 0) {
		//user hasn't saved defaults yet, so load global defaults
		startFrequency = MIN_FREQUENCY;
		endFrequency = MAX_FREQUENCY;
	}
	
	[self setSlider:_startFrequencySlider toFrequency:startFrequency];
	[self setSlider:_endFrequencySlider toFrequency:endFrequency];
	
	
	//load last duration
	int lastDuration = [[NSUserDefaults standardUserDefaults] integerForKey:kLastSweepDuration];
	
	if (lastDuration < MIN_DURATION || lastDuration > MAX_DURATION) {
		lastDuration = DEFAULT_DURATION;
	}
	self.durationSlider.value = lastDuration;
	
	[self refreshInterface];
	
	[[NSNotificationCenter defaultCenter] addObserver:self
											 selector:@selector(controllerWillStartSweep)
												 name:kToneControllerWillStartPlayingSweep
											   object:nil];
	
	[[NSNotificationCenter defaultCenter] addObserver:self
											 selector:@selector(controllerDidFinishSweep)
												 name:kToneControllerDidFinishPlayingSweep
											   object:nil];
	
	[[NSNotificationCenter defaultCenter] addObserver:self
											 selector:@selector(controllerDidInvalidatePausedSweep)
												 name:kToneControllerDidInvalidatePausedSweep
											   object:nil];
	
	[[NSNotificationCenter defaultCenter] addObserver:self
											 selector:@selector(controllerDidStop)
												 name:kToneControllerDidStop
											   object:nil];
}


- (void)viewDidAppear:(BOOL)animated
{
	[super viewDidAppear:animated];
	
	[AudioControlsViewController sharedInstance].visibleViewController = self;
}


- (void)viewWillDisappear:(BOOL)animated
{
	[super viewWillDisappear:animated];
	
	[[NSUserDefaults standardUserDefaults] setDouble:[self startFrequency] forKey:kLastSweepStartFrequency];
	[[NSUserDefaults standardUserDefaults] setDouble:[self endFrequency] forKey:kLastSweepEndFrequency];
	[[NSUserDefaults standardUserDefaults] setInteger:[self duration] forKey:kLastSweepDuration];
	
	[[ToneController sharedInstance] invalidatePausedSweep];
	[[ToneController sharedInstance] stop];
}


#pragma mark -
#pragma mark Memory Management

- (void)viewDidUnload
{
	[super viewDidUnload];
	
	self.startFrequencySlider = nil;
    self.endFrequencySlider = nil;
    self.durationSlider = nil;
    self.startFrequencyTitleLabel = nil;
    self.startFrequencyLabel = nil;
    self.endFrequencyTitleLabel = nil;
    self.endFrequencyLabel = nil;
    self.durationTitleLabel = nil;
    self.durationLabel = nil;
	self.repeatSwitch = nil;
}


- (void)dealloc
{
	[[NSNotificationCenter defaultCenter] removeObserver:self];
	
    [_startFrequencySlider release];
    [_endFrequencySlider release];
    [_durationSlider release];
    [_startFrequencyTitleLabel release];
    [_startFrequencyLabel release];
    [_endFrequencyTitleLabel release];
    [_endFrequencyLabel release];
    [_durationTitleLabel release];
    [_durationLabel release];
	[_repeatSwitch release];
	
	[super dealloc];
}


#pragma mark -
#pragma mark Public methods

- (double)startFrequency
{
	return [self frequencyFromSlider:self.startFrequencySlider];
}


- (double)endFrequency
{
	return [self frequencyFromSlider:self.endFrequencySlider];
}


- (int)duration
{
	return ceil(self.durationSlider.value);
}


#pragma mark -
#pragma mark Notification responses

- (void)controllerWillStartSweep
{
	[self disableSliders];
}


- (void)controllerDidFinishSweep
{
	[self enableSliders];
}


- (void)controllerDidInvalidatePausedSweep
{
	[self enableSliders];
}


- (void)controllerDidStop
{
	[self enableSliders];
}


#pragma mark -
#pragma mark Private methods

- (void)refreshInterface
{
	self.startFrequencyLabel.text = [NSString stringForFrequency:[self startFrequency]];
	self.endFrequencyLabel.text = [NSString stringForFrequency:[self endFrequency]];
	self.durationLabel.text = [NSString stringWithFormat:@"%@ sec", [__formatter stringFromNumber:[NSNumber numberWithInt:[self duration]]]];
}


- (void)disableSliders
{
	self.startFrequencySlider.enabled = NO;
	self.endFrequencySlider.enabled = NO;
	self.durationSlider.enabled = NO;
}


- (void)enableSliders
{
	self.startFrequencySlider.enabled = YES;
	self.endFrequencySlider.enabled = YES;
	self.durationSlider.enabled = YES;
}


//slider methods
- (IBAction)sliderChangedValue:(STSmallSlider *)aSlider
{
	[[ToneController sharedInstance] invalidatePausedSweep];
	
	if (aSlider == self.startFrequencySlider) {
		self.startFrequencyLabel.text = [NSString stringForFrequency:[self startFrequency]];
		
	} else if (aSlider == self.endFrequencySlider) {
		self.endFrequencyLabel.text = [NSString stringForFrequency:[self endFrequency]];
		
	} else {
		//must be the time slider
		self.durationLabel.text = [NSString stringWithFormat:@"%@ sec", [__formatter stringFromNumber:[NSNumber numberWithInt:[self duration]]]];
	}
}


- (void)setSlider:(STSmallSlider *)slider toFrequency:(double)frequency
{
	slider.value = (log(frequency) - log(MIN_FREQUENCY)) / (log(MAX_FREQUENCY) - log(MIN_FREQUENCY));
}


- (double)frequencyFromSlider:(STSmallSlider*)slider
{
	//if linear
	//return slider.value * (MAX_FREQUENCY - MIN_FREQUENCY) + MIN_FREQUENCY;
	
	//if logarithmic
	double power = slider.value * (log(MAX_FREQUENCY) - log(MIN_FREQUENCY)) + log(MIN_FREQUENCY);
	return exp(power);
}


//switch
- (IBAction)repeatSwitchChangedValue:(id)aSwitch
{
	[[ToneController sharedInstance] invalidatePausedSweep];
}

@end
