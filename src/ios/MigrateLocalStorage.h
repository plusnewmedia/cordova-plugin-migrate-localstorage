#import <Cordova/CDVPlugin.h>

@interface MigrateLocalStorage : CDVPlugin {}

- (id)settingForKey:(NSString *)key;
- (BOOL) copyFrom:(NSString*)src to:(NSString*)dest;
- (void) migrateLocalStorageWithScheme:(NSString *)scheme andHostname:(NSString *)hostname;
- (void) migrateIndexedDBWithScheme:(NSString *)scheme andHostname:(NSString *)hostname;

@end
