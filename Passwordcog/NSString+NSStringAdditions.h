#import <Foundation/Foundation.h>

@interface NSString (NSStringAdditions)

- (BOOL)containsString:(NSString *)string;
- (BOOL)containsString:(NSString *)string options:(NSStringCompareOptions)options;

- (BOOL)isEmpty;
- (BOOL)isNotEmpty;

- (NSString *)trim;

@end
