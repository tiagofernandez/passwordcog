#import <Foundation/Foundation.h>

@interface Settings : NSObject

+ (BOOL)firstLaunchOver;
+ (void)setFirstLaunchOver:(BOOL)value;

+ (BOOL)hidePasswords;
+ (void)setHidePasswords:(BOOL)value;

@end
