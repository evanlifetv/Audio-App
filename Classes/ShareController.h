
#import <Foundation/Foundation.h>
#import <MessageUI/MessageUI.h>


@interface ShareController : NSObject <MFMailComposeViewControllerDelegate> {
	UIViewController *_presentingViewController;
}

@property (nonatomic, retain) UIViewController *presentingViewController;

+ (ShareController*)sharedInstance;
+ (BOOL)canSendEmail;

- (void)sendEmailToAddress: (NSString*) toAddress
			   WithSubject: (NSString*) subject
					  body: (NSString*) body;

@end
