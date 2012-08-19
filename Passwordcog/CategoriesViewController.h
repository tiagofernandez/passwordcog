#import <UIKit/UIKit.h>

@interface CategoriesViewController : UITableViewController <UISplitViewControllerDelegate>

@property (strong, nonatomic) NSDictionary *categories;
@property (strong, nonatomic) NSDictionary *categoryImages;

- (IBAction)navigationViewTapped:(UITapGestureRecognizer *)sender;

+ (UIPopoverController *)staticSettingsPopoverController;

@end
