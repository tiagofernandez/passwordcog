#import <Foundation/Foundation.h>

@interface PasswordcogDatabase : NSObject

- (PasswordcogDatabase *)loadWithCompletionBlock:(void(^)(void))completionBlock;

@end
