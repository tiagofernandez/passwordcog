#import <UIKit/UIKit.h>

@protocol NotesViewControllerDelegate <NSObject>

- (void)notesUpdated:(NSString *)notes;

@end


@interface NotesViewController : UIViewController

@property (weak, nonatomic) id<NotesViewControllerDelegate> delegate;
@property (strong, nonatomic) NSString *notes;

@end
