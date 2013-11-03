#import "CategoriesViewController.h"
#import "AccountListViewController.h"
#import "PasswordcogDatabase.h"
#import "SettingsViewController.h"


#pragma mark - CategoryImageCell

@interface CategoryImageCell : UITableViewCell
@end

@implementation CategoryImageCell

- (void)layoutSubviews
{
  [super layoutSubviews];
  self.textLabel.frame = CGRectMake(60, UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad ? 10 : 2, 150, 44);
}

@end


#pragma mark - CategoriesViewController

@interface CategoriesViewController()

@property (nonatomic, strong) PasswordcogDatabase *database;

@property (nonatomic, weak) UIPopoverController *settingsPopoverController;
@property (nonatomic, strong) NSTimer *refreshTimer;

@end

@implementation CategoriesViewController

@synthesize settingsPopoverController = _settingsPopoverController;

@synthesize categories = _categories;
@synthesize categoryImages = _categoryImages;

@synthesize database = _database;

- (NSDictionary *)categories
{
  if (!_categories) {
    _categories = [Category allCategoryNames];
  }
  return _categories;
}

- (NSDictionary *)categoryImages
{
  if (!_categoryImages) {
    _categoryImages = [Category allCategoryImages];
  }
  return _categoryImages;
}


#pragma mark - Actions

- (IBAction)showSettingsPopover:(UIBarButtonItem *)sender
{
  if ([self.settingsPopoverController isPopoverVisible])
    [self.settingsPopoverController dismissPopoverAnimated:YES];
  else
    [self performSegueWithIdentifier:@"Settings" sender:sender];
}

- (IBAction)navigationViewTapped:(UITapGestureRecognizer *)sender
{
  if ([PasswordcogAppDelegate userInterfaceIdiomPad]) {
    [[self accountListViewController] reloadWithCategory:nil];
    
    for (int index = 0; index < [self.categories count]; index++) {
      NSIndexPath *indexPath = [NSIndexPath indexPathForRow:index inSection:0];
      UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:indexPath];
      [cell setSelected:NO animated:NO];
    }
  }
}

- (AccountListViewController *)accountListViewController
{
  UINavigationController *detailsVC = [self.splitViewController.viewControllers lastObject];
  AccountListViewController *accountListVC = [detailsVC.viewControllers lastObject];
  accountListVC.delegate = self;
  return accountListVC;
}


#pragma mark AccountListViewControllerDelegate

- (void)categoryModified:(NSString *)categoryName
{
  [self refreshView];
}


#pragma mark - Segue

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(UITableViewCell *)sender
{
  if ([segue.identifier isEqualToString:@"Account List"]) {
    AccountListViewController *accountListVC = segue.destinationViewController;
    accountListVC.categoryName = sender.textLabel.text;
  }
  else if ([segue.identifier isEqualToString:@"Settings"]) {
    
    if ([PasswordcogAppDelegate userInterfaceIdiomPad]) {
      UIStoryboardPopoverSegue *popoverSegue = (UIStoryboardPopoverSegue*) segue;
      self.settingsPopoverController = popoverSegue.popoverController;
      
      UINavigationController *contentNC = (UINavigationController *) self.settingsPopoverController.contentViewController;
      SettingsViewController *settingsVC = [contentNC.viewControllers lastObject];
      settingsVC.customPopoverController = popoverSegue.popoverController;
    }
  }
}


#pragma mark - UISplitViewControllerDelegate

- (BOOL)splitViewController:(UISplitViewController *)svc
   shouldHideViewController:(UIViewController *)vc
              inOrientation:(UIInterfaceOrientation)orientation
{
  return NO; //UIInterfaceOrientationIsPortrait(orientation);
}


#pragma mark - UITableViewDataSource & UITableViewDelegate

- (NSString *)categoryIndexForIndexPath:(NSIndexPath *)indexPath
{
  return [NSString stringWithFormat:@"%d", indexPath.row];
}

- (NSString *)categoryForIndexPath:(NSIndexPath *)indexPath
{
  NSString *categoryIndex = [self categoryIndexForIndexPath:indexPath];
  return [self.categories objectForKey:categoryIndex];
}

- (NSString *)categoryImageForIndexPath:(NSIndexPath *)indexPath
{
  NSString *categoryIndex = [self categoryIndexForIndexPath:indexPath];
  return [self.categoryImages objectForKey:categoryIndex];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
  return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
  return [self.categories count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
  static NSString *TableCell = @"Category Cell";
  
  UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:TableCell];
  if (!cell) cell = [[CategoryImageCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:TableCell];
  
  NSString *categoryName = [self categoryForIndexPath:indexPath];
  
  cell.textLabel.text = categoryName;
  
  if (self.database) {
    cell.detailTextLabel.text = [Account totalOfAccountsInCategory:categoryName];
  }
  cell.imageView.image = [UIImage imageNamed:[self categoryImageForIndexPath:indexPath]];
  
  return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
  if ([PasswordcogAppDelegate userInterfaceIdiomPad]) {
    AccountListViewController *accountListVC = [self accountListViewController];
    [accountListVC reloadWithCategory:[self categoryForIndexPath:indexPath]];
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
  }
}


#pragma mark - View lifecycle

- (void)awakeFromNib
{
  [super awakeFromNib];
  self.splitViewController.delegate = self;
}

- (void)viewWillAppear:(BOOL)animated
{
  [super viewWillAppear:animated];
  [self refreshView];
}

- (void)viewDidAppear:(BOOL)animated
{
  [super viewDidAppear:animated];
  if (!self.database) [self initDatabase];
}

- (void)viewDidDisappear:(BOOL)animated
{
  [self.refreshTimer invalidate];
  self.refreshTimer = nil;
  
  [super viewWillDisappear:animated];
}

- (void)viewDidLoad
{
  [super viewDidLoad];
  [self.settingsButton setAccessibilityLabel:@"Settings"];
  [self.searchButton setAccessibilityLabel:@"Search"];
}

- (void)viewDidUnload
{
  self.settingsButton = nil;
  self.searchButton = nil;
  [super viewDidUnload];
}

- (void)refreshView
{
  [self.tableView reloadData];
}


#pragma mark - Database initialization

- (void)initDatabase
{
  self.database = [[PasswordcogDatabase new] loadWithCompletionBlock:^{
    self.refreshTimer = [NSTimer scheduledTimerWithTimeInterval:5.0
                                                         target:self
                                                       selector:@selector(refreshView)
                                                       userInfo:nil
                                                        repeats:YES];
  }];
}


#pragma mark - Rotation

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
  if ([PasswordcogAppDelegate userInterfaceIdiomPad])
    return YES;
  else
    return interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown;
}

@end
