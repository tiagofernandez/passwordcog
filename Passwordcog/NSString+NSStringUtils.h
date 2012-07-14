#import <Foundation/Foundation.h>

@interface NSString (NSStringUtils)

- (BOOL)containsString:(NSString *)string;
- (BOOL)containsString:(NSString *)string options:(NSStringCompareOptions)options;

- (BOOL)isEmpty;
- (BOOL)isNotEmpty;

- (NSString *)trim;

+ (NSString *)uuid;

@end
