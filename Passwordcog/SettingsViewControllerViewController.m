#import "SettingsViewControllerViewController.h"
#import "KKPasscodeLock.h"
#import "KKPasscodeSettingsViewController.h"

@interface SettingsViewControllerViewController () <KKPasscodeSettingsViewControllerDelegate>

@property (strong, nonatomic) IBOutlet UISwitch *iCloudSync;

@end


@implementation SettingsViewControllerViewController

@synthesize iCloudSync = _iCloudSync;


#pragma mark Actions

// [[KKPasscodeLock sharedLock] isPasscodeRequired]

- (IBAction)done:(id)sender
{
  [self.navigationController dismissModalViewControllerAnimated:YES];
}

- (IBAction)iCloudSwitchChanged:(id)sender
{
  
}


#pragma mark UITableViewDelegate

- (void)passcodeCellSelected
{
  KKPasscodeSettingsViewController *passcodeSettingsVC = [[KKPasscodeSettingsViewController alloc] initWithStyle:UITableViewStyleGrouped];
  passcodeSettingsVC.delegate = self;
  
  [self.navigationController pushViewController:passcodeSettingsVC animated:YES];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
  if (indexPath.section == 0 && indexPath.row == 0) {
    [self passcodeCellSelected];
  }
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
  self.iCloudSync = nil;
  [super viewDidUnload];
}

@end
