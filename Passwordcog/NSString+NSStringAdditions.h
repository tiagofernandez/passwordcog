#import <Foundation/Foundation.h>

@interface NSString (NSStringAdditions)

- (BOOL)containsString:(NSString *)string;
- (BOOL)containsString:(NSString *)string options:(NSStringCompareOptions)options;

- (NSData *)encryptWithKey:(NSString *)key;

- (BOOL)isEmpty;
- (BOOL)isNotEmpty;

- (NSString *)md5Hex;

- (NSString *)trim;

+ (NSString *)uuid;

@end
