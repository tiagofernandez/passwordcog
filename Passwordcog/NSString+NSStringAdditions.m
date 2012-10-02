#import <CommonCrypto/CommonDigest.h>

#import "NSString+NSStringAdditions.h"

@implementation NSString (NSStringAditions)

- (BOOL) containsString:(NSString *)string
{
  return [self containsString:string options:0];
}

- (BOOL)containsString:(NSString *)string options:(NSStringCompareOptions)options
{
  NSRange range = [self rangeOfString:string options:options];
  return range.location != NSNotFound;
}

- (BOOL)isEmpty
{
  return [[self trim] length] == 0;
}

- (BOOL)isNotEmpty
{
  return ![self isEmpty];
}

- (NSString *)trim
{
  return [self stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
}

+ (NSString *)uuid
{
  CFUUIDRef uid = CFUUIDCreate(kCFAllocatorDefault);
	CFStringRef tmpString = CFUUIDCreateString(kCFAllocatorDefault, uid);
	CFRelease(uid);
  
	return (__bridge_transfer NSString *)tmpString;
}

@end
