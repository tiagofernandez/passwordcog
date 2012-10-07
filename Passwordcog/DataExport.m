#import <DropboxSDK/DropboxSDK.h>

#import "DataExport.h"
#import "Account.h"
#import "Category.h"
#import "GRMustache.h"

@interface DataExport () <DBRestClientDelegate>

@property (nonatomic, strong) DBRestClient *dropboxClient;

@end

@implementation DataExport

@synthesize dropboxClient = _dropboxClient;

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
  return [GRMustacheTemplate renderObject:[Account findAll]
                                      fromResource:@"CSV"
                                            bundle:nil
                                             error:NULL];
}

#pragma mark - Dropbox

- (void)backupToDropbox
{
  NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
	NSString *path = [[paths objectAtIndex:0] stringByAppendingPathComponent:@"Passwordcog_20121006.csv"];
                    
  NSString *csv = [self generateCsv];
  [csv writeToFile:path atomically:YES encoding:NSUTF8StringEncoding error:nil];

  // NSLog(@"File path: %@", path);
  // NSLog(@"Content to be uploaded:\n%@", [[NSString alloc] initWithContentsOfFile:path encoding:NSUTF8StringEncoding error:nil]);

  [self.dropboxClient uploadFile:[path lastPathComponent] toPath:@"/" withParentRev:nil fromPath:path];
}

+ (void)setupDropbox
{
  DBSession* dbSession = [[DBSession alloc] initWithAppKey:@"xd5s07n4pjthv34"
                                                 appSecret:@"aqp89gff3n64791"
                                                      root:kDBRootAppFolder];
  [DBSession setSharedSession:dbSession];
}

+ (BOOL)isDropboxLinked
{
  return [[DBSession sharedSession] isLinked];
}

+ (void)linkDropboxFromController:(UIViewController *)controller
{
  [[DBSession sharedSession] linkFromController:controller];
}

+ (void)handleDropboxOpenURL:(NSURL *)url
{
  if ([[DBSession sharedSession] handleOpenURL:url]) {
    if ([[DBSession sharedSession] isLinked])
      NSLog(@"Dropbox account linked successfully!");
    else
      NSLog(@"Dropbox account failed to be linked.");
  }
}

#pragma mark - DBRestClientDelegate

- (void)restClient:(DBRestClient*)client uploadedFile:(NSString*)destPath
              from:(NSString*)srcPath metadata:(DBMetadata*)metadata
{
  NSLog(@"File uploaded successfully to path: %@", metadata.path);
}

- (void)restClient:(DBRestClient*)client uploadProgress:(CGFloat)progress
           forFile:(NSString*)destPath from:(NSString*)srcPath
{
  NSLog(@"File being uploaded from %@ to %@ with progress: %f", srcPath, destPath, progress);
}

- (void)restClient:(DBRestClient*)client uploadFileFailedWithError:(NSError*)error
{
  NSLog(@"File upload failed with error: %@", error);
}

@end
