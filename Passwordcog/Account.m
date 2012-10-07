#import "Account.h"
#import "MF_Base64Additions.h"

@implementation Account

@dynamic uid;
@dynamic name;
@dynamic username;
@dynamic password;
@dynamic categoryId;
@dynamic notes;
@dynamic index;


#pragma mark - Helpers

- (NSString *)categoryText
{
  Category *category = [Category categoryFromId:self.categoryId];
  return category.name;
}

- (void)setCategoryText:(NSString *)categoryName
{
  Category *category = [Category categoryFromName:categoryName];
  self.categoryId = category.uid;
}

- (NSString *)usernameText
{
  return [Account decode:self.username];
}

- (void)setUsernameText:(NSString *)username
{
  self.username = [Account encode:username];
}

- (NSString *)passwordText
{
  return [Account decode:self.password];
}

- (void)setPasswordText:(NSString *)password
{
  self.password = [Account encode:password];
}

- (NSString *)notesText
{
  return [Account decode:self.notes];
}

- (void)setNotesText:(NSString *)notes
{
  self.notes = [Account encode:notes];
}


#pragma mark - Querying

+ (NSArray *)allAccountsInCategory:(NSString *)categoryName
{
  if (categoryName) {
    
    Category *category = [Category categoryFromName:categoryName];
    NSArray *accounts  = [NSMutableArray arrayWithArray:[Account findByAttribute:@"categoryId" withValue:category.uid]];
    
    NSArray *sortedAccounts = [accounts sortedArrayUsingComparator:^NSComparisonResult(id first, id second) {
      
      NSInteger firstIndex = [[(Account*) first index] intValue];
      NSInteger secondIndex = [[(Account*) second index] intValue];
      
      if (firstIndex < secondIndex) {
        return (NSComparisonResult) NSOrderedAscending;
      }
      else if (firstIndex > secondIndex) {
        return (NSComparisonResult) NSOrderedDescending;
      }
      else {
        return (NSComparisonResult) NSOrderedSame;
      }
    }];
    
    return [NSMutableArray arrayWithArray:sortedAccounts];
  }
  else {
    return nil;
  }
}

+ (NSArray *)allAccountsInCategorySorted:(NSString *)categoryName
{
  Category *category = [Category categoryFromName:categoryName];
  NSArray *accounts  = [Account findByAttribute:@"categoryId" withValue:category.uid];

  NSSortDescriptor *sorter = [[NSSortDescriptor alloc] initWithKey:@"name"
                                                         ascending:YES
                                                          selector:@selector(caseInsensitiveCompare:)];
  
  return [NSMutableArray arrayWithArray:[accounts sortedArrayUsingDescriptors:[NSArray arrayWithObject:sorter]]];
}

+ (NSArray *)searchAccountsWithNameLike:(NSString *)accountName
{
  NSPredicate *predicate = [NSPredicate predicateWithFormat:@"name contains[cd] %@", accountName];
  return [Account findAllWithPredicate:predicate];
}

+ (NSString *)totalOfAccountsInCategory:(NSString *)categoryName
{
  Category *category = [Category categoryFromName:categoryName];
  
  NSPredicate *predicate = [NSPredicate predicateWithFormat:@"categoryId == %@", category.uid];
  return [NSString stringWithFormat:@"%d", [Account countOfEntitiesWithPredicate:predicate]];
}


#pragma mark - Encoding/decoding

+ (NSData *)encode:(NSString *)plainText
{
  NSString *base64String = [plainText base64String];
  return [NSData dataWithBase64String:base64String];
}

+ (NSString *)decode:(NSData *)base64Data
{
  NSString *base64String = [base64Data base64String];
  return [NSString stringFromBase64String:base64String];
}

@end
