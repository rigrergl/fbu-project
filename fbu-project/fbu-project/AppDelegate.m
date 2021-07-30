//
//  AppDelegate.m
//  fbu-project
//
//  Created by Rigre Reinier Garciandia Larquin on 7/12/21.
//

#import "AppDelegate.h"
#import <Parse/Parse.h>

@interface AppDelegate ()

@end

static NSString * const APP_ID_KEY = @"app_id";
static NSString * const CLIENT_KEY = @"client_key";
static NSString * const KEYS_PATH = @"Keys";
static NSString * const KEYS_PATH_FILE_TYPE = @"plist";
static NSString * const PARSE_URL_STRING = @"https://parseapi.back4app.com";
static NSString * const DEFAULT_SCENE_CONFIGURATION = @"Default Configuration";

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    NSString *path = [[NSBundle mainBundle] pathForResource: KEYS_PATH ofType: KEYS_PATH_FILE_TYPE];
    NSDictionary *dict = [NSDictionary dictionaryWithContentsOfFile: path];
    NSString *appId = [dict objectForKey: APP_ID_KEY];
    NSString *clientKey = [dict objectForKey: CLIENT_KEY];
    
    ParseClientConfiguration *config = [ParseClientConfiguration  configurationWithBlock:^(id<ParseMutableClientConfiguration> configuration) {
        
        configuration.applicationId = appId;
        configuration.clientKey = clientKey;
        configuration.server = PARSE_URL_STRING;
    }];
    
    [Parse initializeWithConfiguration:config];
    
    return YES;
}

#pragma mark - UISceneSession lifecycle

- (UISceneConfiguration *)application:(UIApplication *)application configurationForConnectingSceneSession:(UISceneSession *)connectingSceneSession options:(UISceneConnectionOptions *)options {
    // Called when a new scene session is being created.
    // Use this method to select a configuration to create the new scene with.
    return [[UISceneConfiguration alloc] initWithName:DEFAULT_SCENE_CONFIGURATION sessionRole:connectingSceneSession.role];
}


- (void)application:(UIApplication *)application didDiscardSceneSessions:(NSSet<UISceneSession *> *)sceneSessions {
    // Called when the user discards a scene session.
    // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
    // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
}

@end
