//
//  AddArtistViewController.m
//  fbu-project
//
//  Created by Rigre Reinier Garciandia Larquin on 7/16/21.
//

#import "AddArtistViewController.h"
#import "APIManager.h"

@interface AddArtistViewController ()
@property (weak, nonatomic) IBOutlet UITextField *searchTextField;
@property (weak, nonatomic) IBOutlet UIButton *addButton;

@end

@implementation AddArtistViewController


- (IBAction)searchTextDidChange:(UITextField *)sender {
    NSString *searchText = self.searchTextField.text;
    
    APIManager *apiManager = [APIManager new];
    [apiManager fetchArtist:searchText withCompletion:^(NSDictionary *_Nullable responseData, NSError *_Nullable error){
        if (responseData) {
            NSLog(@"%@", responseData);
        }
    }];
}

- (NSString *)formatText {
    
}



@end
