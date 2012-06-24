#import "NSString+NSStringUtils.h"

@implementation NSString (NSStringUtils)

- (NSString *)trim
{
  return [self stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
}

- (BOOL)isEmpty
{
  return [[self trim] length] == 0;
}

- (BOOL)isNotEmpty
{
  return ![self isEmpty];
}

@end
