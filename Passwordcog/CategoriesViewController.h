#import <UIKit/UIKit.h>

#import "AccountListViewController.h"

@interface CategoriesViewController : UITableViewController <UISplitViewControllerDelegate, AccountListViewControllerDelegate>

@property (strong, nonatomic) NSDictionary *categories;
@property (strong, nonatomic) NSDictionary *categoryImages;

- (IBAction)navigationViewTapped:(UITapGestureRecognizer *)sender;

@end
