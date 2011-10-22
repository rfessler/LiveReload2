
#import "ExtensionsController.h"
#import "MD5OfFile.h"
#import "VersionNumber.h"


static ExtensionsController *sharedExtensionsController;


@implementation ExtensionsController

+ (ExtensionsController *)sharedExtensionsController {
    if (sharedExtensionsController == nil) {
        sharedExtensionsController = [[ExtensionsController alloc] init];
    }
    return sharedExtensionsController;
}

- (void)installExtensionWithAppId:(NSString *)appId {
    NSURL *url = [NSURL URLWithString:@"http://help.livereload.com/kb/general-use/browser-extensions"];
    if (![[NSWorkspace sharedWorkspace] openURLs:[NSArray arrayWithObject:url] withAppBundleIdentifier:appId options:NSWorkspaceLaunchDefault additionalEventParamDescriptor:NULL launchIdentifiers:NULL]) {
        [[NSWorkspace sharedWorkspace] openURL:url];
    }
}

- (IBAction)installSafariExtension:(id)sender {
    [self installExtensionWithAppId:@"com.apple.Safari"];
}

- (IBAction)installChromeExtension:(id)sender {
    [self installExtensionWithAppId:@"com.google.Chrome"];
}

- (IBAction)installFirefoxExtension:(id)sender {
    [self installExtensionWithAppId:@"org.mozilla.firefox"];
}

@end
