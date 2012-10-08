#import <UIKit/UIKit.h>

#import "DataExport.h"

@interface PasswordcogAppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;

@property (strong, nonatomic) DataExport *dataExport;

+ (PasswordcogAppDelegate *)sharedAppDelegate;

+ (BOOL)userInterfaceIdiomPhone;
+ (BOOL)userInterfaceIdiomPad;

@end
