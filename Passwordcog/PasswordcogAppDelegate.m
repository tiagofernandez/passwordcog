#import "PasswordcogAppDelegate.h"
#import "Account.h"
#import "BlockAlertView.h"
#import "KKKeychain.h"
#import "KKPasscodeLock.h"

@interface PasswordcogAppDelegate () <KKPasscodeViewControllerDelegate>

@end


@implementation PasswordcogAppDelegate

@synthesize window = _window;

// Override point for customization after application launch.
- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
  [MagicalRecord setupCoreDataStackWithStoreNamed:@"Passwordcog.sqlite"];
  [[KKPasscodeLock sharedLock] setDefaultSettings];
  return YES;
}
							
// Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state. Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
- (void)applicationWillResignActive:(UIApplication *)application
{
  UINavigationController *rootVC = (UINavigationController *) self.window.rootViewController;
  [rootVC dismissModalViewControllerAnimated:NO];
  [rootVC popToRootViewControllerAnimated:NO];
}

// Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
- (void)applicationDidEnterBackground:(UIApplication *)application
{
}

// Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
- (void)applicationWillEnterForeground:(UIApplication *)application
{
}

// Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
- (void)applicationDidBecomeActive:(UIApplication *)application
{
  [self resetPasscodeInFirstLaunch];
  [self checkWhetherPasscodeIsRequired];
}

// Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
- (void)applicationWillTerminate:(UIApplication *)application
{
  [MagicalRecord cleanUp];
}


#pragma mark Passcode lock

- (void)resetPasscode
{
  [KKKeychain setString:@"NO" forKey:@"passcode_on"];
}

- (void)resetPasscodeInFirstLaunch
{
  NSUserDefaults *preferences = [NSUserDefaults standardUserDefaults];
  
  if (![preferences boolForKey:@"first_launch_done"]) {
    [self resetPasscode];
    [preferences setBool:YES forKey:@"first_launch_done"];
    [preferences synchronize];
  }
}

- (void)checkWhetherPasscodeIsRequired
{
  if ([[KKPasscodeLock sharedLock] isPasscodeRequired]) {
    
    KKPasscodeViewController *passcodeVC = [[KKPasscodeViewController alloc] initWithNibName:nil bundle:nil];
    passcodeVC.mode = KKPasscodeModeEnter;
    passcodeVC.delegate = self;
    
    dispatch_async(dispatch_get_main_queue(), ^{
      
      UINavigationController *passcodeNavigationVC = [[UINavigationController alloc] initWithRootViewController:passcodeVC];
      UINavigationController *rootVC = (UINavigationController *) self.window.rootViewController;
      
      if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        passcodeNavigationVC.modalPresentationStyle = UIModalPresentationFormSheet;
        passcodeNavigationVC.navigationBar.barStyle = UIBarStyleBlack;
        passcodeNavigationVC.navigationBar.opaque = NO;
      }
      else if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
        passcodeNavigationVC.navigationBar.tintColor = rootVC.navigationBar.tintColor;
        passcodeNavigationVC.navigationBar.translucent = rootVC.navigationBar.translucent;
        passcodeNavigationVC.navigationBar.opaque = rootVC.navigationBar.opaque;
        passcodeNavigationVC.navigationBar.barStyle = rootVC.navigationBar.barStyle;    
      }
      [rootVC presentModalViewController:passcodeNavigationVC animated:YES];
    });
  }
}

- (void)eraseApplicationData
{
  [Account truncateAll];
  [[NSManagedObjectContext contextForCurrentThread] save];
}

- (void)shouldEraseApplicationData:(KKPasscodeViewController*)viewController
{
  [self eraseApplicationData];
  
  BlockAlertView *alert = [BlockAlertView alertWithTitle:@"Data Erased"
                                                 message:@"All passwords have been destroyed. Your passcode will be turned off now."];
  
  [alert addButtonWithTitle:@"OK" block:^{
    [self resetPasscode];
    [viewController dismissModalViewControllerAnimated:YES];
  }];

  [alert show];
}

@end
