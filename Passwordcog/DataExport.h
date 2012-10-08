#import <Foundation/Foundation.h>

@interface DataExport : NSObject

- (void)setupDropbox;
- (BOOL)isDropboxLinked;
- (void)linkDropboxFromController:(UIViewController *)controller;
- (void)handleDropboxOpenURL:(NSURL *)url;
- (void)backupToDropboxWithSuccessBlock:(void (^)())successBlock andFailureBlock:(void (^)())failureBlock;

@end
