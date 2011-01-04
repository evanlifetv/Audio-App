
#import "ShareController.h"
#import "AppDelegate.h"

#define kViewControllerKey @"viewController"

@implementation ShareController

@synthesize presentingViewController = _presentingViewController;


#pragma mark -
#pragma mark Singleton Instance

+ (ShareController*)sharedInstance
{
	static ShareController *sharedInstance;
	@synchronized(self) {
		if (!sharedInstance) {
			sharedInstance = [[ShareController alloc] init];
		}
	}
	return sharedInstance;
}


#pragma mark -
#pragma mark Memory Management

- (void)dealloc
{
	[_presentingViewController release], _presentingViewController = nil;
	
	[super dealloc];
}


#pragma mark -
#pragma mark Share Methods

+ (BOOL)canSendEmail
{
	return [MFMailComposeViewController canSendMail];
}


- (void)sendEmailToAddress: (NSString*) toAddress
			   WithSubject: (NSString*) subject
					  body: (NSString*) body
{
	if ([[self class] canSendEmail]) {
		MFMailComposeViewController *emailVC = [[[MFMailComposeViewController alloc] init] autorelease];
		[emailVC setMailComposeDelegate:self];
		[emailVC setToRecipients:[NSArray arrayWithObject:toAddress]];
		[emailVC setSubject:subject];
		[emailVC setMessageBody:body isHTML:NO];
		[[emailVC navigationBar] setBarStyle:UIBarStyleBlack];
		
		AppDelegate *delegate = (AppDelegate*)[[UIApplication sharedApplication] delegate];
		[delegate.tabBarController presentModalViewController:emailVC animated:YES];
	}
}

#pragma mark -
#pragma MFMailComposeViewControllerDelegate

- (void)mailComposeController:(MFMailComposeViewController*)controller 
          didFinishWithResult:(MFMailComposeResult)result 
                        error:(NSError*)error
{
	[controller dismissModalViewControllerAnimated:YES];
}


@end
