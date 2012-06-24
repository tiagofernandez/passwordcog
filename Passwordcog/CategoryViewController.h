#import <UIKit/UIKit.h>

@protocol CategoryViewControllerDelegate <NSObject>

- (void)categorySelected:(NSString *)category;

@end


@interface CategoryViewController : UITableViewController

@property (weak, nonatomic) id<CategoryViewControllerDelegate> delegate;
@property (strong, nonatomic) NSString *category;

@end
