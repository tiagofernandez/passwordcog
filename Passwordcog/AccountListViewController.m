#import "AccountListViewController.h"
#import "NSString+NSStringUtils.h"

@interface AccountListViewController ()

@property (strong, nonatomic) NSMutableArray *accounts;

@end


@implementation AccountListViewController

@synthesize category = _category;
@synthesize accounts = _accounts;

- (NSMutableArray *)accounts
{
  if (!_accounts) {
    _accounts = [NSMutableArray new];
  }
  return _accounts;
}


#pragma mark AccountViewControllerDelegate

- (void)accountSaved:(Account *)account
{
  if (!account.uuid) {
    account.uuid = [NSString uuid];
    [self.accounts addObject:account];
  }
  [self.tableView reloadData];
}


#pragma mark UITableViewDataSource & UITableViewDelegate

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
  return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
  return [self.accounts count];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
  return 55;
}

- (Account *)accountAtIndexPath:(NSIndexPath *)indexPath
{
  return [self.accounts objectAtIndex:indexPath.row];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
  static NSString *TableCell = @"Account Cell";
  
  UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:TableCell];
  if (!cell) cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:TableCell];
  
  Account *account = [self accountAtIndexPath:indexPath];
  
  cell.textLabel.text = account.service;
  cell.detailTextLabel.text = [NSString stringWithFormat:@"%@ - %@", account.username, account.password];
  
  return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
  [self performSegueWithIdentifier:@"Edit Account" sender:self];
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
  if (editingStyle == UITableViewCellEditingStyleDelete) {
    [self.accounts removeObject:[self accountAtIndexPath:indexPath]];
    [self.tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:YES];
  }  
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
  return YES;
}

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath
{
  return UITableViewCellEditingStyleDelete;
}

- (BOOL)tableView:(UITableView *)tableView shouldIndentWhileEditingRowAtIndexPath:(NSIndexPath *)indexPath
{
  return YES;
}

- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
  return YES;
}

- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)sourceIndexPath toIndexPath:(NSIndexPath *)destinationIndexPath
{
  Account *account = [self accountAtIndexPath:sourceIndexPath];
  [self.accounts removeObject:account];
  [self.accounts insertObject:account atIndex:destinationIndexPath.row];
}


#pragma mark Segue

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
  AccountViewController *accountVC = [[segue.destinationViewController viewControllers] objectAtIndex:0];
  [accountVC setDelegate:self];
  
  if ([segue.identifier containsString:@"Create Account"]) {
    [accountVC setAccount:[[Account alloc] initWithCategory:self.category]];
  }
  else if ([segue.identifier containsString:@"Edit Account"]) {
    NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
    [accountVC setAccount:[self accountAtIndexPath:indexPath]];
  }
}


#pragma mark View lifecycle

- (void)setEditButton
{
  UIBarButtonItem *flexibleSpace = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
  [self setToolbarItems:[NSArray arrayWithObjects:flexibleSpace, self.editButtonItem, nil]];
}

- (void)viewDidLoad
{
  [super viewDidLoad];
  [self setEditButton];
  [self setTitle:self.category];
}


#pragma mark Rotation

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
  if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone)
    return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
  else
    return YES;
}

@end
