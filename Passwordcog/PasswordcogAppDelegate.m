#import "PasswordcogAppDelegate.h"
#import "Account.h"
#import "CategoriesViewController.h"
#import "DataExport.h"
#import "KKKeychain.h"
#import "KKPasscodeLock.h"
#import "KKPasscodeSettingsViewController.h"
#import "Settings.h"

@interface PasswordcogAppDelegate () <KKPasscodeViewControllerDelegate, UIAlertViewDelegate>
@end

@implementation PasswordcogAppDelegate

@synthesize window = _window;

@synthesize dataExport = _dataExport;

- (DataExport *)dataExport
{
  if (!_dataExport) {
    _dataExport = [[DataExport alloc] init];
  }
  return _dataExport;
}

+ (PasswordcogAppDelegate *)sharedAppDelegate
{
  return (PasswordcogAppDelegate *) [UIApplication sharedApplication].delegate;
}

+ (BOOL)userInterfaceIdiomPhone
{
  return UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone;
}

+ (BOOL)userInterfaceIdiomPad
{
  return UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad;
}

// Override point for customization after application launch.
- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
  [[KKPasscodeLock sharedLock] setDefaultSettings];
  
  [self.dataExport setupDropbox];
  
  return YES;
}

// Return NO if the application can't open for some reason.
- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation
{
  [self.dataExport handleDropboxOpenURL:url];
  return YES;
}

// Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state. Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
- (void)applicationWillResignActive:(UIApplication *)application
{
}

// Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
- (void)applicationDidEnterBackground:(UIApplication *)application
{
  // Issue #2: Undo back-to-root-screen mechanism
  // [self goBackToRootView];
}

- (void)goBackToRootView __attribute__((deprecated))
{
  if ([PasswordcogAppDelegate userInterfaceIdiomPad]) {
    UINavigationController *rootVC = (UINavigationController *) self.window.rootViewController;
    UINavigationController *rootNavVC = [rootVC.viewControllers objectAtIndex:0];
    
    CategoriesViewController *categoriesVC = [rootNavVC.viewControllers lastObject];
    [categoriesVC navigationViewTapped:nil];
  }
  else {
    UINavigationController *rootVC = (UINavigationController *) self.window.rootViewController;
    [rootVC dismissModalViewControllerAnimated:NO];
    [rootVC popToRootViewControllerAnimated:NO];
  }
}

// Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
- (void)applicationWillEnterForeground:(UIApplication *)application
{
}

// Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
- (void)applicationDidBecomeActive:(UIApplication *)application
{
  [self firstLaunchCheckpoint];
  [self passcodeCheckpoint];
}

// Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
- (void)applicationWillTerminate:(UIApplication *)application
{
  [MagicalRecord cleanUp];
}


#pragma mark UIAlertViewDelegate

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
  if (buttonIndex == 1) [self presentPasscodeView];
}


#pragma mark Passcode lock

- (void)resetPasscode
{
  [KKKeychain setString:@"NO" forKey:@"passcode_on"];
}

- (void)presentPasscodeView
{
  KKPasscodeViewController *passcodeVC = [[KKPasscodeViewController alloc] initWithNibName:nil bundle:nil];
  passcodeVC.mode = KKPasscodeModeSet;
  [self showPasscodeViewController:passcodeVC];
}

- (void)askToSetPasscode
{
  UIAlertView *alert = [[UIAlertView alloc] init];
  [alert setTitle:@"Passcode"];
  [alert setMessage:@"Would you like to set a passcode?"];
  [alert setDelegate:self];
  [alert addButtonWithTitle:@"No, thanks"];
  [alert addButtonWithTitle:@"Yes, please"];
  [alert show];
}

- (void)firstLaunchCheckpoint
{
  if (![Settings firstLaunchOver]) {
    [self resetPasscode];
    [self askToSetPasscode];
    [Settings setFirstLaunchOver:YES];
  }
}

- (void)passcodeCheckpoint
{
  if ([[KKPasscodeLock sharedLock] isPasscodeRequired]) {
    
    KKPasscodeViewController *passcodeVC = [[KKPasscodeViewController alloc] initWithNibName:nil bundle:nil];
    passcodeVC.mode = KKPasscodeModeEnter;
    passcodeVC.delegate = self;
    
    [self showPasscodeViewController:passcodeVC];
  }
}

- (void)showPasscodeViewController:(KKPasscodeViewController *)passcodeVC
{
  dispatch_async(dispatch_get_main_queue(), ^{
    
    UINavigationController *passcodeNavigationVC = [[UINavigationController alloc] initWithRootViewController:passcodeVC];
    UINavigationController *rootVC = (UINavigationController *) self.window.rootViewController;
    
    if ([PasswordcogAppDelegate userInterfaceIdiomPad]) {
      passcodeNavigationVC.modalPresentationStyle = UIModalPresentationFormSheet;
      passcodeNavigationVC.navigationBar.barStyle = UIBarStyleBlack;
      passcodeNavigationVC.navigationBar.opaque = NO;
    }
    else {
      passcodeNavigationVC.navigationBar.tintColor = rootVC.navigationBar.tintColor;
      passcodeNavigationVC.navigationBar.translucent = rootVC.navigationBar.translucent;
      passcodeNavigationVC.navigationBar.opaque = rootVC.navigationBar.opaque;
      passcodeNavigationVC.navigationBar.barStyle = rootVC.navigationBar.barStyle;    
    }
    [rootVC dismissModalViewControllerAnimated:NO];
    [rootVC presentModalViewController:passcodeNavigationVC animated:YES];
  });
}

- (void)eraseApplicationData
{
  [Account truncateAll];
  [Category truncateAll];
}

- (void)shouldEraseApplicationData:(KKPasscodeViewController*)viewController
{
  [self eraseApplicationData];

  UIAlertView *alert = [[UIAlertView alloc] init];
  [alert setTitle:@"Data Erased"];
  [alert setMessage:@"All passwords have been deleted. Passcode will be turned off now."];
  [alert setDelegate:nil];
  [alert addButtonWithTitle:@"OK"];
  [alert show];
  
  [self resetPasscode];
  [viewController dismissModalViewControllerAnimated:YES];
}

@end
