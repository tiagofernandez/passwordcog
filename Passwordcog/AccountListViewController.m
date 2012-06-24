#import "AccountListViewController.h"

@interface AccountListViewController ()

@property (strong, nonatomic) NSMutableArray *accounts;

@end


@implementation AccountListViewController

@synthesize accounts = _accounts;

- (NSMutableArray *)accounts
{
  if (!_accounts) _accounts = [NSMutableArray new];
  return _accounts;
}


#pragma mark Actions

- (IBAction)createAccount:(id)sender
{
  
}


#pragma mark AccountViewControllerDelegate

- (void)accountSaved:(Account *)account
{
  [self.accounts addObject:account];
  [self.tableView reloadData];
}


#pragma mark UITableViewDataSource & UITableViewDelegate

- (Account *)accountAtIndexPath:(NSIndexPath *)indexPath
{
  return (Account *) [self.accounts objectAtIndex:indexPath.row];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
  return [self.accounts count];
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

//- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
//{
//  
//}

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
  [self.accounts removeObjectAtIndex:sourceIndexPath.row];
  [self.accounts insertObject:account atIndex:destinationIndexPath.row];
}


#pragma mark Segue

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
  if ([segue.identifier isEqualToString:@"Account"]) {
    AccountViewController *accountVC = [[segue.destinationViewController viewControllers] objectAtIndex:0];
    [accountVC setDelegate:self];
  }
}


#pragma mark View lifecycle

- (void)setEditButton
{
  self.navigationItem.leftBarButtonItem = self.editButtonItem;
}

- (void)viewDidLoad
{
  [super viewDidLoad];
  [self setEditButton];
}

- (void)viewDidUnload
{
  // e.g. self.myOutlet = nil;
  [super viewDidUnload];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
  if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone)
    return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
  else
    return YES;
}

@end
