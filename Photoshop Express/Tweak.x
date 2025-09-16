// GermGuardian Login & iOS Version Bypass
// Tweak.x

#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>

// Hook the main tab controller to bypass login
%hook TabHomeViewController

- (void)viewDidLoad {
    NSLog(@"[GermGuardian] TabHomeViewController viewDidLoad called");
    %orig;
    
    // Ensure we're always in a "logged in" state
    // This will bypass any login checks in the main view
}

- (void)viewWillAppear:(BOOL)animated {
    NSLog(@"[GermGuardian] TabHomeViewController viewWillAppear");
    %orig;
}

// Hook common login check methods
- (BOOL)isLoggedIn {
    NSLog(@"[GermGuardian] isLoggedIn bypassed - returning YES");
    return YES;
}

- (BOOL)hasValidSession {
    NSLog(@"[GermGuardian] hasValidSession bypassed - returning YES");
    return YES;
}

%end

// Hook AppDelegate for initial app flow and version checks
%hook AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    NSLog(@"[GermGuardian] AppDelegate didFinishLaunchingWithOptions");
    BOOL result = %orig;
    
    // Skip any initial login prompts or version checks
    return result;
}

// Override any iOS version compatibility checks
- (BOOL)isIOSVersionSupported {
    NSLog(@"[GermGuardian] iOS version check bypassed - returning YES");
    return YES;
}

- (BOOL)checkSystemCompatibility {
    NSLog(@"[GermGuardian] System compatibility check bypassed - returning YES");
    return YES;
}

%end

// Hook any Login ViewControllers that might exist
%hook LoginViewController

- (void)viewDidLoad {
    NSLog(@"[GermGuardian] LoginViewController bypassed - navigating to main");
    
    // Instead of showing login, navigate directly to main interface
    // Try common navigation patterns
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 0.5 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
        // Try to find and present the main interface
        if ([self respondsToSelector:@selector(dismissViewControllerAnimated:completion:)]) {
            [self dismissViewControllerAnimated:YES completion:nil];
        }
        
        // Alternative: try to trigger successful login flow
        if ([self respondsToSelector:@selector(loginSuccessful)]) {
            [self performSelector:@selector(loginSuccessful)];
        }
    });
}

- (void)performLogin {
    NSLog(@"[GermGuardian] Login bypassed - simulating success");
    // Simulate successful login
    if ([self respondsToSelector:@selector(loginSuccessful)]) {
        [self performSelector:@selector(loginSuccessful)];
    }
}

%end

// Hook UIDevice to always return a supported iOS version
%hook UIDevice

- (NSString *)systemVersion {
    NSString *originalVersion = %orig;
    NSLog(@"[GermGuardian] Original iOS version: %@, returning: 15.0", originalVersion);
    return @"15.0"; // Return a version that should be supported
}

%end

// Hook NSProcessInfo for system version checks (alternative method)
%hook NSProcessInfo

- (NSOperatingSystemVersion)operatingSystemVersion {
    NSOperatingSystemVersion originalVersion = %orig;
    NSLog(@"[GermGuardian] Original OS version: %ld.%ld.%ld", 
          originalVersion.majorVersion, 
          originalVersion.minorVersion, 
          originalVersion.patchVersion);
    
    // Return iOS 15.0 which should be supported
    NSOperatingSystemVersion fakeVersion;
    fakeVersion.majorVersion = 15;
    fakeVersion.minorVersion = 0;
    fakeVersion.patchVersion = 0;
    return fakeVersion;
}

- (BOOL)isOperatingSystemAtLeastVersion:(NSOperatingSystemVersion)version {
    NSLog(@"[GermGuardian] OS version check for %ld.%ld.%ld - returning YES", 
          version.majorVersion, version.minorVersion, version.patchVersion);
    return YES;
}

%end

// Hook ZeemoteLibrary version checks specifically
%hook ZeemoteLibrary

+ (BOOL)isVersionSupported {
    NSLog(@"[GermGuardian] ZeemoteLibrary version check bypassed - returning YES");
    return YES;
}

+ (void)checkVersion {
    NSLog(@"[GermGuardian] ZeemoteLibrary checkVersion bypassed");
    // Do nothing, skip the version check
}

%end

// Hook any potential authentication managers
%hook AuthenticationManager

- (BOOL)isAuthenticated {
    NSLog(@"[GermGuardian] AuthenticationManager isAuthenticated bypassed - returning YES");
    return YES;
}

- (void)authenticate {
    NSLog(@"[GermGuardian] AuthenticationManager authenticate bypassed");
    // Skip authentication, call success callback if available
    if ([self respondsToSelector:@selector(authenticationDidSucceed)]) {
        [self performSelector:@selector(authenticationDidSucceed)];
    }
}

%end

// Hook UserDefaults to fake login state
%hook NSUserDefaults

- (BOOL)boolForKey:(NSString *)key {
    if ([key containsString:@"login"] || [key containsString:@"auth"] || [key containsString:@"logged"]) {
        NSLog(@"[GermGuardian] NSUserDefaults login-related key '%@' intercepted - returning YES", key);
        return YES;
    }
    return %orig;
}

- (id)objectForKey:(NSString *)key {
    if ([key containsString:@"token"] || [key containsString:@"session"]) {
        NSLog(@"[GermGuardian] NSUserDefaults token/session key '%@' intercepted - returning dummy value", key);
        return @"dummy_token_12345";
    }
    return %orig;
}

%end

// Constructor
%ctor {
    NSLog(@"[GermGuardian] Tweak loaded successfully!");
}
