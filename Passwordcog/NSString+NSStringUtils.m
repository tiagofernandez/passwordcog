#import "NSString+NSStringUtils.h"

@implementation NSString (NSStringUtils)

- (BOOL)isEmpty
{
  return [self length] == 0;
}

- (BOOL)isNotEmpty
{
  return ![self isEmpty];
}

@end
