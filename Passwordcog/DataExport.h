#import <Foundation/Foundation.h>

@interface DataExport : NSObject

- (void)backupToDropboxWithSuccessBlock:(void (^)())successBlock andFailureBlock:(void (^)())failureBlock;

+ (void)setupDropbox;
+ (BOOL)isDropboxLinked;
+ (void)linkDropboxFromController:(UIViewController *)controller;
+ (void)handleDropboxOpenURL:(NSURL *)url;

@end
