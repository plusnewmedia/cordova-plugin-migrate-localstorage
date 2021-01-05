#import "MigrateLocalStorage.h"
/* #import <WebKit/WebKit.h> */
@implementation MigrateLocalStorage

- (id)settingForKey:(NSString *)key {
  return [self.commandDelegate.settings objectForKey:[key lowercaseString]];
}

- (BOOL)copyFrom:(NSString *)src to:(NSString *)dest {
  NSFileManager *fileManager = [NSFileManager defaultManager];

  // Bail out if source file does not exist
  if (![fileManager fileExistsAtPath:src]) {
    return NO;
  }

  // Bail out if dest file exists
  if ([fileManager fileExistsAtPath:dest]) {
    return NO;
  }

  // create path to dest
  if (![fileManager
                createDirectoryAtPath:[dest stringByDeletingLastPathComponent]
          withIntermediateDirectories:YES
                           attributes:nil
                                error:nil]) {
    return NO;
  }

  // copy src to dest
  return [fileManager copyItemAtPath:src toPath:dest error:nil];
}

- (void)migrateLocalStorageWithScheme:(NSString *)scheme andHostname:(NSString *)hostname {
  // Migrate UIWebView local storage files to WKWebView. Adapted from
  // https://github.com/Telerik-Verified-Plugins/WKWebView/blob/master/src/ios/MyMainViewController.m

  NSString *appLibraryFolder = [NSSearchPathForDirectoriesInDomains(
      NSLibraryDirectory, NSUserDomainMask, YES) objectAtIndex:0];
  NSString *original;

  if ([[NSFileManager defaultManager]
          fileExistsAtPath:
              [appLibraryFolder
                  stringByAppendingPathComponent:
                      @"WebKit/LocalStorage/file__0.localstorage"]]) {
    original = [appLibraryFolder
        stringByAppendingPathComponent:@"WebKit/LocalStorage"];
  } else {
    original = [appLibraryFolder stringByAppendingPathComponent:@"Caches"];
  }

  //@"Webkit/Caches/___IndexedDB/file__0
  //@"WebsiteData/IndexedDB/<@"CFBundleIdentifier"/DBNAME
  //

  original = [original stringByAppendingPathComponent:@"file__0.localstorage"];

  NSString *target = [[NSString alloc]
      initWithString:[appLibraryFolder
                         stringByAppendingPathComponent:@"WebKit"]];

#if TARGET_IPHONE_SIMULATOR
  // the simulutor squeezes the bundle id into the path
  NSString *bundleIdentifier = [[[NSBundle mainBundle] infoDictionary]
      objectForKey:@"CFBundleIdentifier"];
  target = [target stringByAppendingPathComponent:bundleIdentifier];
#endif

  //    @"WebsiteData/LocalStorage/scheme_hostname_0.localstorage"
  NSString* path = [NSString stringWithFormat:@"%@/%@_%@_%@", @"WebsiteData/LocalStorage", scheme , hostname , @"0.localstorage"];
  target = [target stringByAppendingPathComponent:path];


  // Only copy data if no existing localstorage data exists yet for wkwebview
  if (![[NSFileManager defaultManager] fileExistsAtPath:target]) {
    //        NSLog(@"No existing localstorage data found for WKWebView.
    //        Migrating data from UIWebView");
    [self copyFrom:original to:target];
    [self copyFrom:[original stringByAppendingString:@"-shm"]
                to:[target stringByAppendingString:@"-shm"]];
    [self copyFrom:[original stringByAppendingString:@"-wal"]
                to:[target stringByAppendingString:@"-wal"]];
  }
}

- (void)migrateIndexedDBWithScheme:(NSString *)scheme andHostname:(NSString *)hostname {
  // Migrate UIWebView indexDB files to WKWebView.
  NSLog(@"In INDEXEDDB MIGRATE");
  NSString *appLibraryFolder = [NSSearchPathForDirectoriesInDomains(
      NSLibraryDirectory, NSUserDomainMask, YES) objectAtIndex:0];
  NSString *original;
  if ([[NSFileManager defaultManager]
          fileExistsAtPath:[appLibraryFolder
                               stringByAppendingPathComponent:
                                   @"WebKit/IndexedDB/http_localhost_8080"]]) {
    original =
        [appLibraryFolder stringByAppendingPathComponent:@"WebKit/IndexDB"];
  } else {
    original = [appLibraryFolder stringByAppendingPathComponent:@"Caches"];
  }

  original = [original stringByAppendingPathComponent:@"___IndexedDB/file__0"];
  NSString *target = [[NSString alloc]
      initWithString:[appLibraryFolder
                         stringByAppendingPathComponent:@"WebKit"]];

#if TARGET_IPHONE_SIMULATOR
  // the simulutor squeezes the bundle id into the path
  NSString *bundleIdentifier = [[[NSBundle mainBundle] infoDictionary]
      objectForKey:@"CFBundleIdentifier"];
  target = [target stringByAppendingPathComponent:bundleIdentifier];
#endif

  //    @"WebsiteData/IndexedDB/scheme_hostname_0"
  NSString* path = [NSString stringWithFormat:@"%@/%@_%@_%@", @"WebsiteData/IndexedDB", scheme , hostname , @"0"];
  target = [target stringByAppendingPathComponent:path];


  // Only copy data if no existing indexedDB data exists yet for wkwebview
  if (![[NSFileManager defaultManager] fileExistsAtPath:target]) {
    NSLog(@"No existing indexedDB data found for WKWebView. Migrating data "
          @"from UIWebView");
    [self copyFrom:original to:target];
  }
}

- (void)pluginInitialize {
  NSString* setting;
  NSString* hostname = @"localhost";
  NSString* scheme = @"app";

    
  setting  = @"hostname";
  if ([self settingForKey:setting]) {
    hostname = [self settingForKey:setting];
  }
  setting  = @"scheme";
  if ([self settingForKey:setting]) {
    scheme = [self settingForKey:setting];
  }
    
  [self migrateLocalStorageWithScheme:scheme andHostname:hostname];
  [self migrateIndexedDBWithScheme:scheme andHostname:hostname];
}

@end
