#import <UIKit/UIKit.h>

#import "AccountListViewController.h"

@interface CategoriesViewController : UITableViewController <UISplitViewControllerDelegate, AccountListViewControllerDelegate>

@property (strong, nonatomic) NSDictionary *categories;
@property (strong, nonatomic) NSDictionary *categoryImages;

@property (strong, nonatomic) IBOutlet UIBarButtonItem *settingsButton;
@property (strong, nonatomic) IBOutlet UIBarButtonItem *searchButton;

- (IBAction)navigationViewTapped:(UITapGestureRecognizer *)sender;

@end
