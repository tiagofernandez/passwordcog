#import <DropboxSDK/DropboxSDK.h>

#import "DataExport.h"
#import "Account.h"
#import "Category.h"
#import "GRMustache.h"

@interface DataExport () <DBSessionDelegate, DBRestClientDelegate>

@property (nonatomic, strong) DBRestClient *dropboxClient;

@property (nonatomic, strong) id successBlock;
@property (nonatomic, strong) id failureBlock;

@end

@implementation DataExport

@synthesize dropboxClient = _dropboxClient;

@synthesize successBlock = _successBlock;
@synthesize failureBlock = _failureBlock;

- (DBRestClient *)dropboxClient
{
  if (!_dropboxClient) {
    _dropboxClient = [[DBRestClient alloc] initWithSession:[DBSession sharedSession]];
    _dropboxClient.delegate = self;
  }
  return _dropboxClient;
}

- (NSString *)generateCsv
{
  NSMutableArray *accounts = [NSMutableArray new];
  
  for (Category *category in [Category allCategoriesSorted]) {
    [accounts addObjectsFromArray:[Account allAccountsInCategorySorted:category.name]];
  }
  return [GRMustacheTemplate renderObject:accounts
                                      fromResource:@"CSV"
                                            bundle:nil
                                             error:NULL];
}

- (NSString *)generateFilename
{
  NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
  [dateFormat setDateFormat:@"yyyyMMddHHmmss"];
  
  return [NSString stringWithFormat:@"Passwordcog_%@.csv", [dateFormat stringFromDate:[NSDate new]]];
}

#pragma mark - Dropbox

- (void)setupDropbox
{
  DBSession* dbSession = [[DBSession alloc] initWithAppKey:@"xd5s07n4pjthv34"
                                                 appSecret:@"aqp89gff3n64791"
                                                      root:kDBRootAppFolder];
  dbSession.delegate = self;
  
  [DBSession setSharedSession:dbSession];
}

- (BOOL)isDropboxLinked
{
  return [[DBSession sharedSession] isLinked];
}

- (void)linkDropboxFromController:(UIViewController *)controller
{
  [[DBSession sharedSession] linkFromController:controller];
}

- (void)handleDropboxOpenURL:(NSURL *)url
{
  if ([[DBSession sharedSession] handleOpenURL:url]) {
    if ([[DBSession sharedSession] isLinked])
      NSLog(@"Dropbox account linked successfully!");
    else
      NSLog(@"Dropbox account failed to be linked.");
  }
}

- (void)backupToDropboxWithSuccessBlock:(void (^)())successBlock andFailureBlock:(void (^)())failureBlock
{
  NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
	NSString *path = [[paths objectAtIndex:0] stringByAppendingPathComponent:[self generateFilename]];
  
  NSString *csv = [self generateCsv];
  [csv writeToFile:path atomically:YES encoding:NSUTF8StringEncoding error:nil];
  
  self.successBlock = successBlock;
  self.failureBlock = failureBlock;
  
  [self.dropboxClient uploadFile:[path lastPathComponent] toPath:@"/" withParentRev:nil fromPath:path];
}

#pragma mark - DBRestClientDelegate

- (void)restClient:(DBRestClient*)client uploadedFile:(NSString*)destPath
              from:(NSString*)srcPath metadata:(DBMetadata*)metadata
{
  NSLog(@"File uploaded successfully to path: %@", metadata.path);
  [self.successBlock invoke];
}

- (void)restClient:(DBRestClient*)client uploadProgress:(CGFloat)progress
           forFile:(NSString*)destPath from:(NSString*)srcPath
{
  NSLog(@"File being uploaded from %@ to %@ with progress: %f", srcPath, destPath, progress);
}

- (void)restClient:(DBRestClient*)client uploadFileFailedWithError:(NSError*)error
{
  NSLog(@"File upload failed with error: %@", error);
  [self.failureBlock invoke];
}

#pragma mark - DBSessionDelegate

- (void)sessionDidReceiveAuthorizationFailure:(DBSession *)session userId:(NSString *)userId
{
  NSLog(@"Session invalidated for user ID: %@", userId);
  [session unlinkUserId:userId];
}

@end
