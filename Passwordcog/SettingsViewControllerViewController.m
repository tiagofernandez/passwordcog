#import "SettingsViewControllerViewController.h"

@interface SettingsViewControllerViewController ()

@end


@implementation SettingsViewControllerViewController


#pragma mark Actions

- (IBAction)done:(id)sender
{
  [self.navigationController dismissModalViewControllerAnimated:YES];
}

@end
