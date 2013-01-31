#import "PasswordcogDatabase.h"
#import "SVProgressHUD.h"

@interface PasswordcogDatabase ()

@end

@implementation PasswordcogDatabase

static NSString *iCloudContainer = @"6P59Z8EQFE.com.tapcogs.Passwordcog";
static NSString *localStoreName  = @"Passwordcog.sqlite";

- (PasswordcogDatabase *)loadWithCompletionBlock:(void(^)(void))completionBlock
{
  [MagicalRecord cleanUp];
  
  if ([self iCloudAvailable]) {
    
    [SVProgressHUD showWithStatus:@"Loading" maskType:SVProgressHUDMaskTypeGradient];
    
    NSString *contentNameKey = [[[NSBundle mainBundle] infoDictionary] objectForKey:(id)kCFBundleIdentifierKey];
    
    [MagicalRecord setupCoreDataStackWithiCloudContainer:iCloudContainer
                                          contentNameKey:contentNameKey
                                         localStoreNamed:localStoreName
                                 cloudStorePathComponent:nil
                                              completion:^{
      
      [SVProgressHUD dismiss];
      
      completionBlock();

    }];
  }
  else {
    [MagicalRecord setupCoreDataStackWithStoreNamed:localStoreName];
    completionBlock();
  }
  return self;
}

- (BOOL)iCloudAvailable
{
  NSFileManager *fileManager = [NSFileManager defaultManager];
  NSURL *ubiquityURL = [fileManager URLForUbiquityContainerIdentifier:iCloudContainer];
  
  BOOL status = ubiquityURL ? YES : NO;
  NSLog(@"iCloud available? %@", status ? @"yes" : @"no");
  
  return status;
}

@end
