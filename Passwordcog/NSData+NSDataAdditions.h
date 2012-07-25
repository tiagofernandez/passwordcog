#import <Foundation/Foundation.h>

@interface NSData (NSDataAdditions)

- (NSData *)AES256EncryptWithKey:(NSString *)key;
- (NSData *)AES256DecryptWithKey:(NSString *)key;

- (NSString *)decryptWithKey:(NSString *)key;

@end
