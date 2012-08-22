#import "SettingsViewController.h"
#import "KKPasscodeLock.h"
#import "KKPasscodeSettingsViewController.h"

@interface SettingsViewController () <KKPasscodeSettingsViewControllerDelegate>
@end

@implementation SettingsViewController

@synthesize customPopoverController = _customPopoverController;


#pragma mark Actions

- (IBAction)done:(id)sender
{
  [self.navigationController dismissModalViewControllerAnimated:YES];
}


#pragma mark UITableViewDelegate

- (void)passcodeCellSelected
{
  KKPasscodeSettingsViewController *passcodeSettingsVC = [[KKPasscodeSettingsViewController alloc] initWithStyle:UITableViewStyleGrouped];
  passcodeSettingsVC.contentSizeForViewInPopover = self.contentSizeForViewInPopover;
  passcodeSettingsVC.delegate = self;
  
  [self.navigationController pushViewController:passcodeSettingsVC animated:YES];
}

- (void)rateCellSelected
{
  static NSString *AppId = @"549240714";
  
  NSString* url = [NSString stringWithFormat:@"http://itunes.apple.com/WebObjects/MZStore.woa/wa/viewContentsUserReviews?id=%@&pageNumber=0&sortOrdering=1&type=Purple+Software&mt=8", AppId];
  
  [[UIApplication sharedApplication] openURL:[NSURL URLWithString:url]];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
  if (indexPath.section == 0 && indexPath.row == 0)
    [self passcodeCellSelected];
  
  else if (indexPath.section == 1 && indexPath.row == 0)
    [self rateCellSelected];
}


#pragma mark KKPasscodeSettingsViewControllerDelegate

- (void)passcodeLockWillBePresented
{
  [self.customPopoverController dismissPopoverAnimated:YES];
}


#pragma mark View lifecycle

- (void)refreshPasscodeCell
{
  NSIndexPath *indexPath = [NSIndexPath indexPathForRow:0 inSection:0];
  
  UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:indexPath];
  cell.detailTextLabel.text = [[KKPasscodeLock sharedLock] isPasscodeRequired] ? @"On" : @"Off";
  
  [self.tableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationNone];
}

- (void)viewWillAppear:(BOOL)animated
{
  [super viewWillAppear:animated];
  [self refreshPasscodeCell];
}

- (void)viewDidUnload
{
  [super viewDidUnload];
}

@end
