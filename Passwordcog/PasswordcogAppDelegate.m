#import "PasswordcogAppDelegate.h"
#import "Account.h"
#import "BlockAlertView.h"
#import "CategoriesViewController.h"
#import "KKKeychain.h"
#import "KKPasscodeLock.h"
#import "KKPasscodeSettingsViewController.h"

@interface PasswordcogAppDelegate () <KKPasscodeViewControllerDelegate, UIAlertViewDelegate>

@end


@implementation PasswordcogAppDelegate

@synthesize window = _window;

static NSString *iCloudContainer = @"com.tapcogs.Passwordcog";
static NSString *LocalStoreName = @"Passwordcog.sqlite";

+ (BOOL)userInterfaceIdiomPad
{
  return UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad;
  //return [[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad;
}

- (BOOL)iCloudAvailable
{
  NSFileManager *fileManager = [NSFileManager defaultManager];
  NSURL *ubiquityURL = [fileManager URLForUbiquityContainerIdentifier:iCloudContainer];
  return ubiquityURL ? YES : NO;
}

// Override point for customization after application launch.
- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
  [self iCloudAvailable]
    ? [MagicalRecord setupCoreDataStackWithiCloudContainer:iCloudContainer localStoreNamed:LocalStoreName]
    : [MagicalRecord setupCoreDataStackWithStoreNamed:LocalStoreName];
  
  [[KKPasscodeLock sharedLock] setDefaultSettings];
  return YES;
}
							
// Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state. Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
- (void)applicationWillResignActive:(UIApplication *)application
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
  [self checkWhetherAppIsLaunchingForTheFirstTime];
  [self checkWhetherPasscodeIsRequired];
}

// Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
- (void)applicationWillTerminate:(UIApplication *)application
{
  [MagicalRecord cleanUp];
}


#pragma mark UIAlertViewDelegate

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
	if (buttonIndex == 0) {
		[self presentPasscodeView];
	}
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
  // https://github.com/gpambrozio/BlockAlertsAnd-ActionSheets/issues/1
  if ([PasswordcogAppDelegate userInterfaceIdiomPad]) {
    UIAlertView *alert = [[UIAlertView alloc] init];
    [alert setTitle:@"Passcode"];
    [alert setMessage:@"Would you like to set a passcode?"];
    [alert setDelegate:self];
    [alert addButtonWithTitle:@"Yes, please"];
    [alert addButtonWithTitle:@"No, thanks"];
    [alert show];
  }
  else {
    BlockAlertView *alert = [BlockAlertView alertWithTitle:@"Passcode"
                                                   message:@"Would you like to set a passcode?"];
    
    [alert addButtonWithTitle:@"Yes, please" block:^{
      [self presentPasscodeView];
    }];
    [alert addButtonWithTitle:@"No, thanks" block:^{}];
    
    [alert show];
  }
}

- (void)checkWhetherAppIsLaunchingForTheFirstTime
{
  NSUserDefaults *preferences = [NSUserDefaults standardUserDefaults];
  
  if (![preferences boolForKey:@"first_launch_over"]) {
    [self resetPasscode];
    [self askToSetPasscode];
    [preferences setBool:YES forKey:@"first_launch_over"];
    [preferences synchronize];
  }
}

- (void)checkWhetherPasscodeIsRequired
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
    [rootVC presentModalViewController:passcodeNavigationVC animated:YES];
  });
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
                                                 message:@"All passwords have been deleted. Passcode lock will be turned off now."];
  
  [alert addButtonWithTitle:@"OK" block:^{
    [self resetPasscode];
    [viewController dismissModalViewControllerAnimated:YES];
  }];

  [alert show];
}

@end
