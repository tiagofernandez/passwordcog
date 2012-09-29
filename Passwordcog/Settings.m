#import "Settings.h"

@implementation Settings

+ (BOOL)firstLaunchOver
{
  return [[NSUserDefaults standardUserDefaults] boolForKey:@"first_launch_over"];
}

+ (void)setFirstLaunchOver:(BOOL)value
{
  NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
  [defaults setBool:value forKey:@"first_launch_over"];
  [defaults synchronize];
}

+ (BOOL)hidePasswords
{
  return [[NSUserDefaults standardUserDefaults] boolForKey:@"hide_passwords"];
}

+ (void)setHidePasswords:(BOOL)value
{
  NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
  [defaults setBool:value forKey:@"hide_passwords"];
  [defaults synchronize];
}

@end
