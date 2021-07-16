//
//  AuthenticationViewController.m
//  fbu-project
//
//  Created by Rigre Reinier Garciandia Larquin on 7/12/21.
//

#import "AuthenticationViewController.h"
#import <Parse/Parse.h>

@interface AuthenticationViewController ()

@property (strong, nonatomic) IBOutlet UITextField *_Nonnull usernameField;
@property (strong, nonatomic) IBOutlet UITextField *_Nonnull passwordField;

@end

@implementation AuthenticationViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupGestures];
}

- (void)setupGestures {
    UITapGestureRecognizer *screenTapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(didTapScreen:)];
    [self.view addGestureRecognizer:screenTapGestureRecognizer];
    [self.view setUserInteractionEnabled:YES];
}

- (void)didTapScreen:(UITapGestureRecognizer *)sender {
    [self.view endEditing:YES];
}

- (UIAlertController *)createAlert {
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Error"
                                                                   message:@"Empty fields"
                                                            preferredStyle:(UIAlertControllerStyleAlert)];
    // create an OK action
    UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"OK"
                                                       style:UIAlertActionStyleDefault
                                                     handler:^(UIAlertAction * _Nonnull action) {
        // handle response here.
    }];
    // add the OK action to the alert controller
    [alert addAction:okAction];
    
    return alert;
}

- (void)presentAlertWithTitle:(NSString *)title
                   andMessage:(NSString *)message {
    UIAlertController *alert = [self createAlert];
    alert.title = title;
    alert.message = message;
    [self presentViewController:alert animated:YES completion:^{}];
}

- (void)registerUser {
    // initialize a user object
    PFUser *newUser = [PFUser user];
    
    // set user properties
    newUser.username = self.usernameField.text;
    newUser.password = self.passwordField.text;
    
    // call sign up function on the object
    [newUser signUpInBackgroundWithBlock:^(BOOL succeeded, NSError * error) {
        if (error != nil) {
            NSLog(@"Error: %@", error.localizedDescription);
            [self presentAlertWithTitle:@"Error" andMessage:[NSString stringWithFormat:@"%@",error.localizedDescription]];
        } else {
            // manually segue to logged in view
            [self performSegueWithIdentifier:@"loginSegue" sender:self];
        }
    }];
}

- (void)loginUser {
    NSString *username = self.usernameField.text;
    NSString *password = self.passwordField.text;
    
    [PFUser logInWithUsernameInBackground:username password:password block:^(PFUser * user, NSError *  error) {
        if (error != nil) {
            NSLog(@"User log in failed: %@", error.localizedDescription);
            [self presentAlertWithTitle:@"Error" andMessage:[NSString stringWithFormat:@"%@",error.localizedDescription]];
        } else {
            // display view controller that needs to shown after successful login
            [self performSegueWithIdentifier:@"loginSegue" sender:self];
        }
    }];
}
- (IBAction)didTapLogin:(UIButton *)sender {
    if(self.usernameField.text.length > 0 && self.passwordField.text.length > 0){
        [self loginUser];
    } else {
        [self presentAlertWithTitle:@"Error" andMessage:@"Empty fields"];
    }
}

- (IBAction)didTapSignUp:(UIButton *)sender {
    if(self.usernameField.text.length > 0 && self.passwordField.text.length > 0){
        [self registerUser];
    }
    else {
        [self presentAlertWithTitle:@"Error" andMessage:@"Empty fields"];
    }
}

@end
