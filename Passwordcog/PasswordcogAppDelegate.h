#import <UIKit/UIKit.h>

@interface PasswordcogAppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;

+ (BOOL)userInterfaceIdiomPhone;
+ (BOOL)userInterfaceIdiomPad;

@end
