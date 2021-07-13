//
//  ProfileViewController.m
//  fbu-project
//
//  Created by Rigre Reinier Garciandia Larquin on 7/12/21.
//

#import "ProfileViewController.h"
#import <Parse/Parse.h>
#import "SceneDelegate.h"
#import "AuthenticationViewController.h"

@interface ProfileViewController ()

@end

@implementation ProfileViewController

- (IBAction)didTapLogout:(UIBarButtonItem *)sender {
    SceneDelegate *sceneDelegate = (SceneDelegate *)[UIApplication sharedApplication].connectedScenes.allObjects[0].delegate;
    
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    AuthenticationViewController *userAuthenticationViewController = [storyboard instantiateViewControllerWithIdentifier:@"AuthenticationViewController"];
    sceneDelegate.window.rootViewController = userAuthenticationViewController;
    
    [PFUser logOutInBackgroundWithBlock:^(NSError *_Nullable error){
        if (error) {
            NSLog(@"%@", error.localizedDescription);
        }
    }];
}

@end
