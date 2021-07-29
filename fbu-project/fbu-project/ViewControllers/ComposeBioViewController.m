//
//  ComposeBioViewController.m
//  fbu-project
//
//  Created by Rigre Reinier Garciandia Larquin on 7/29/21.
//

#import "ComposeBioViewController.h"
#import "DictionaryConstants.h"
#import <Parse/Parse.h>

@interface ComposeBioViewController ()

@property (weak, nonatomic) IBOutlet UITextView *bioTextView;

@end

@implementation ComposeBioViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupTextView];
}

- (void)setupTextView {
    self.bioTextView.layer.borderColor = [UIColor lightGrayColor].CGColor;
    self.bioTextView.layer.borderWidth = 1;
    self.bioTextView.layer.cornerRadius = 10.0f;
    [self.bioTextView becomeFirstResponder];
}

- (IBAction)didTapSave:(UIButton *)sender {
    PFUser *currentUser = [PFUser currentUser];
    if (currentUser) {
        currentUser[BIO_KEY] = self.bioTextView.text;
        [currentUser saveInBackground];
    }
    
    if (self.didChangeBio) {
        self.didChangeBio(self.bioTextView.text);
    }
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)didTapCancel:(UIButton *)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
