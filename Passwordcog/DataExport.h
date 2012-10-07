#import <Foundation/Foundation.h>

@interface DataExport : NSObject

- (void)backupToDropbox;

+ (void)setupDropbox;
+ (BOOL)isDropboxLinked;
+ (void)linkDropboxFromController:(UIViewController *)controller;
+ (void)handleDropboxOpenURL:(NSURL *)url;

@end
