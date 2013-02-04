#import "SNAccountViewController.h"
#import "SNAppDelegate.h"

@implementation SNAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
  self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
  self.window.backgroundColor = [UIColor whiteColor];
  self.window.rootViewController = [[SNAccountViewController alloc] initWithNibName:@"SNAccountViewController" bundle:nil];
  [self.window makeKeyAndVisible];
  return YES;
}

@end
