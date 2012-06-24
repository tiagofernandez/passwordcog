#import "CategoryViewController.h"

@interface CategoryViewController ()


@end


@implementation CategoryViewController

@synthesize delegate = _delegate;
@synthesize category = _category;


#pragma mark UITableViewDataSource & UITableViewDelegate

- (UITableViewCell *)categoryCellAtIndexPath:(NSIndexPath *)indexPath
{
  return [self.tableView cellForRowAtIndexPath:indexPath];
}

- (NSString *)categoryAtIndexPath:(NSIndexPath *)indexPath
{
  return [self categoryCellAtIndexPath:indexPath].textLabel.text;
}

- (void)checkCategoryAtIndexPath:(NSIndexPath *)indexPath
{
  [self categoryCellAtIndexPath:indexPath].accessoryType = UITableViewCellAccessoryCheckmark;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
  [self checkCategoryAtIndexPath:indexPath];
  [self.delegate categorySelected:[self categoryAtIndexPath:indexPath]];
  [self.navigationController popViewControllerAnimated:YES];
}


#pragma mark View lifecycle

- (void)checkCurrentCategory
{
  for (int index = 0; index < [self.tableView numberOfRowsInSection:0]; index++) {
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:index inSection:0];
    UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:indexPath];
    
    if ([cell.textLabel.text isEqualToString:self.category]) {
      cell.accessoryType = UITableViewCellAccessoryCheckmark;
    }
  }
}

- (void)viewWillAppear:(BOOL)animated
{
  [super viewWillAppear:animated];
  [self checkCurrentCategory];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
  if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone)
    return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
  else
    return YES;
}

@end
