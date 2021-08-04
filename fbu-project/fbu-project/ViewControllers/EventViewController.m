//
//  NewEventViewController.m
//  fbu-project
//
//  Created by Rigre Reinier Garciandia Larquin on 7/21/21.
//

#import "EventViewController.h"
#import "InviteeCollectionViewCell.h"
#import "DictionaryConstants.h"
#import "AddInviteeViewController.h"
#import "CommonFunctions.h"
#import "EventLocationPickerViewController.h"
#import "ProfileViewController.h"
#import "FoursquareVenue.h"
#import <Parse/Parse.h>

@interface EventViewController () <UICollectionViewDelegate, UICollectionViewDataSource, UITextFieldDelegate>

@property (weak, nonatomic) IBOutlet UIButton *addInviteeButton;
@property (weak, nonatomic) IBOutlet UIButton *changeImageButton;
@property (weak, nonatomic) IBOutlet UIImageView *eventPictureView;
@property (weak, nonatomic) IBOutlet UICollectionView *inviteesCollectionView;
@property (strong, nonatomic) NSMutableArray<PFUser *> *_Nonnull invitees;
@property (weak, nonatomic) IBOutlet UITextField *titleField;
@property (weak, nonatomic) IBOutlet UITextField *locationField;
@property (strong, nonatomic) FoursquareVenue *_Nullable venue;
@property (weak, nonatomic) IBOutlet UIDatePicker *datePicker;
@property (weak, nonatomic) IBOutlet UIView *closeIndicator;
@property (assign, nonatomic) BOOL canEdit;
@property (weak, nonatomic) IBOutlet UIButton *saveButton;
@property (weak, nonatomic) IBOutlet UILabel *screenTitleLabel;

@end

static NSString * const NEW_EVENT_SCREEN_TITLE = @"New Event";
static NSString * const EDIT_EVENT_SCREEN_TITLE = @"Edit Event";
static NSString * const NEW_EVENT_TO_ADD_INVITEE_SEGUE_TITLE = @"newEventToAddInvitee";
static NSString * const NEW_EVENT_TO_PROFILE_SEGUE_IDENTIFIER = @"eventToProfile";
static NSString * const NEW_EVENT_TO_MAP_SEGUE_IDENTIFIER = @"newEventToMap";
static NSString * const EMPTY_FIELDS_ALERT_TITLE = @"Error";
static NSString * const EMPTY_FIELDS_ALERT_MESSAGE = @"Empty Fields";
static NSString * const INVITEE_CELL_IDENTIFIER = @"InviteeCollectionViewCell";
static NSString * const CHOOSE_ACTION_TITLE = @"Choose From Photos";
static NSString * const TAKE_ACTION_TITLE = @"Take Photo";
static NSString * const CANCEL_ACTION_TITLE = @"Cancel";
static NSString * const TEXT_FIELD_COPY_ITEM_TITLE = @"Copy";
static NSInteger IMAGE_STANDARD_DIMENSIONS = 500;
static const CGFloat EVENT_PICTURE_CORNER_RADIUS = 14;
static const CGFloat CLOSE_INDICATOR_CORNER_RADIUS = 4;
static const NSInteger INVITEE_CELL_WIDTH = 60;

@implementation EventViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self styleScreen];
    [self setupCollectionView];
    
    if (self.event) {
        [self setEvent:self.event];
        self.screenTitleLabel.text = EDIT_EVENT_SCREEN_TITLE;
    } else {
        self.invitees = [[NSMutableArray alloc] init];
        self.canEdit = YES;
        self.screenTitleLabel.text = NEW_EVENT_SCREEN_TITLE;
    }
}

- (void)setEvent:(Event *)event {
    _event = event;
    self.canEdit = [event.organizer.objectId isEqualToString:[PFUser currentUser].objectId];
    self.invitees = event.invited;
    self.titleField.text = event.title;
    self.locationField.text = event.location;
    self.datePicker.date = event.date;
    [self fetchInvitees];
    [self setEditingRights];
    
    [event[EVENT_IMAGE_KEY] getDataInBackgroundWithBlock:^(NSData *_Nullable data, NSError *_Nullable error){
        if (data) {
            self.eventPictureView.image = [UIImage imageWithData:data];
        }
    }];
}

- (void)fetchInvitees {
    NSMutableArray<NSString *> *userIds = [[NSMutableArray alloc] initWithCapacity:self.invitees.count];
    
    for (PFUser *user in self.invitees) {
        [userIds addObject:user.objectId];
    }
    
    PFQuery *inviteesQuery = [PFQuery queryWithClassName:[PFUser parseClassName]];
    [inviteesQuery whereKey:OBJECT_ID_KEY containedIn:userIds];
    [inviteesQuery includeKey:PROFILE_IMAGE_KEY];
    
    [inviteesQuery findObjectsInBackgroundWithBlock:^(NSArray *_Nullable invitees, NSError *_Nullable error){
        if (invitees) {
            self.invitees = invitees;
            [self.inviteesCollectionView reloadData];
        }
    }];
}

- (void)setEditingRights {
    if (!self.canEdit) {
        disableButton(self.saveButton);
        disableButton(self.addInviteeButton);
        disableButton(self.changeImageButton);
        self.datePicker.enabled = NO;
        
        //delegate used for copy only restriction
        self.titleField.delegate = self;
        self.locationField.delegate = self;
    }
}

- (void)styleScreen {
    self.eventPictureView.layer.cornerRadius = EVENT_PICTURE_CORNER_RADIUS;
    self.eventPictureView.layer.masksToBounds = YES;
    
    self.closeIndicator.layer.cornerRadius = CLOSE_INDICATOR_CORNER_RADIUS;
    self.closeIndicator.layer.masksToBounds = YES;
}

- (IBAction)didTapCancel:(UIButton *)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)didTapSave:(UIButton *)sender {
    PFFileObject *imageObject = getFileFromImage(self.eventPictureView.image);
    
    if ([self isFormValid]) {
        //update existing event
        if (self.event) {
            self.event.venue = self.venue;
            self.event.date = self.datePicker.date;
            self.event.location = self.locationField.text;
            self.event.title = self.titleField.text;
            self.event.image = imageObject;
            self.event.invited = self.invitees;
            
            [self.event saveInBackground];
        } else {
            //upload new event to Parse database
            self.event = [Event postEvent:[PFUser currentUser]
                                    venue:self.venue
                                     date:self.datePicker.date
                                 location:self.locationField.text
                                    title:self.titleField.text
                                    image:imageObject
                                  invited:self.invitees
                                 accepted:nil];
        }
        [self dismissViewControllerAnimated:YES completion:^(){
            if (self.didSave) {
                self.didSave(self.event);
            }
        }];
    } else {
        UIAlertController *alertController = createOkAlert(EMPTY_FIELDS_ALERT_TITLE, EMPTY_FIELDS_ALERT_MESSAGE);
        [self presentViewController:alertController animated:YES completion:nil];
    }
}

- (BOOL)isFormValid {
    return self.titleField.text.length > 0 && self.locationField.text.length > 0;
}

#pragma mark - CollectionView method

- (void)setupCollectionView {
    self.inviteesCollectionView.delegate = self;
    self.inviteesCollectionView.dataSource = self;
}

- (nonnull UICollectionViewCell *)collectionView:(nonnull UICollectionView *)collectionView cellForItemAtIndexPath:(nonnull NSIndexPath *)indexPath {
    InviteeCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:INVITEE_CELL_IDENTIFIER forIndexPath:indexPath];
    
    if (cell) {
        [cell setCell:self.invitees[indexPath.item] canRemove:self.canEdit];
        cell.removeInvitee = ^(InviteeCollectionViewCell *_Nonnull cell){
            [self removeInvitee:cell];
        };
        cell.didTapProfileImage = ^(InviteeCollectionViewCell *_Nonnull cell){
            [self performSegueWithIdentifier:NEW_EVENT_TO_PROFILE_SEGUE_IDENTIFIER sender:cell.user];
        };
    }
    
    return cell;
}

- (void)removeInvitee:(InviteeCollectionViewCell *_Nonnull)cell {
    CGFloat indexToRemove = [self.inviteesCollectionView indexPathForCell:cell].item;
    
    [self.invitees removeObjectAtIndex:indexToRemove];
    [self.inviteesCollectionView reloadData];
}

- (NSInteger)collectionView:(nonnull UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.invitees.count;
}

- (CGSize)collectionView:(UICollectionView *)collectionView
                  layout:(UICollectionViewLayout *)collectionViewLayout
  sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    return CGSizeMake(INVITEE_CELL_WIDTH, self.inviteesCollectionView.frame.size.height);
}

- (void)addInvitee:(PFUser *_Nonnull)newInvitee {
    //init set with twice capvity to avoid hashing conflicts (better time performance)
    NSMutableSet<NSString *> *setOfCurrentInviteeIds = [[NSMutableSet alloc] initWithCapacity:self.invitees.count * 2];
    
    for (PFUser *user in self.invitees) {
        [setOfCurrentInviteeIds addObject:user.username];
    }
    
    if (newInvitee && ![setOfCurrentInviteeIds containsObject:newInvitee.username]) {
        [self.invitees addObject:newInvitee];
        [self.inviteesCollectionView reloadData];
    }
}

#pragma mark - Changing Image

- (IBAction)didTapChangeImage:(UIButton *)sender {
    UIAlertController *photoAlert = [UIAlertController alertControllerWithTitle:nil
                                                                        message:nil
                                                                 preferredStyle:UIAlertControllerStyleActionSheet];
    
    UIAlertAction *chooseAction = [UIAlertAction actionWithTitle:CHOOSE_ACTION_TITLE style:UIAlertActionStyleDefault
                                                         handler:^(UIAlertAction * action) {
        //choose from photos
        [self launchImagePicker:NO];
    }];
    
    UIAlertAction *takeAction = [UIAlertAction actionWithTitle:TAKE_ACTION_TITLE style:UIAlertActionStyleDefault
                                                       handler:^(UIAlertAction * action) {
        //take a photo
        [self launchImagePicker:YES];
    }];
    
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:NSLocalizedString(CANCEL_ACTION_TITLE, nil)
                                                           style:UIAlertActionStyleCancel
                                                         handler:nil];
    [photoAlert addAction:chooseAction];
    [photoAlert addAction:takeAction];
    [photoAlert addAction:cancelAction];
    [self presentViewController:photoAlert animated:YES completion:nil];
}

- (void)launchImagePicker:(BOOL)take {
    UIImagePickerController *imagePickerVC = [UIImagePickerController new];
    imagePickerVC.delegate = self;
    imagePickerVC.allowsEditing = YES;
    
    if (take && [UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
        imagePickerVC.sourceType = UIImagePickerControllerSourceTypeCamera;
    }
    else {
        imagePickerVC.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    }
    
    [self presentViewController:imagePickerVC animated:YES completion:nil];
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info {
    
    // Get the image captured by the UIImagePickerController
    UIImage *editedImage = info[UIImagePickerControllerEditedImage];
    editedImage = resizeImage(editedImage,
                              CGSizeMake(IMAGE_STANDARD_DIMENSIONS,
                                         IMAGE_STANDARD_DIMENSIONS));
    
    self.eventPictureView.image = editedImage;
    
    // Dismiss UIImagePickerController to go back to your original view controller
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    
    if ([segue.identifier isEqualToString:NEW_EVENT_TO_ADD_INVITEE_SEGUE_TITLE]) {
        AddInviteeViewController *destinationViewController = [segue destinationViewController];
        destinationViewController.addInvitee = ^(PFUser *_Nonnull user) {
            if (user) {
                [self addInvitee:user];
            }
        };
    } else if ([segue.identifier isEqualToString:NEW_EVENT_TO_MAP_SEGUE_IDENTIFIER]) {
        EventLocationPickerViewController *destinationViewController = [segue destinationViewController];
        [destinationViewController setViewController:[self inviteesPlusOrganizerArray]
                              didSelectLocationBlock:^(FoursquareVenue *_Nullable selectedVenue){
            [self updateEventLocation:selectedVenue];
        }];
    } else if ([segue.identifier isEqualToString:NEW_EVENT_TO_PROFILE_SEGUE_IDENTIFIER]) {
        ProfileViewController *destinationViewController = [segue destinationViewController];
        PFUser *user = (PFUser *)sender;
        destinationViewController.targetUser = user;
    }
}

- (NSArray<PFUser *> *)inviteesPlusOrganizerArray {
    NSMutableArray<PFUser *> *array = [[NSMutableArray alloc] initWithArray:self.invitees];
    [array addObject:[PFUser currentUser]];
    return array;
}

#pragma mark - Location

- (void)updateEventLocation:(FoursquareVenue *_Nullable)venue {
    if (!venue) {
        self.locationField.text = @"";
    }
    if (self.event.venue) {
        [self.event.venue deleteInBackground];
    }
    
    self.venue = venue;
    self.venue.eventId = self.event.objectId;
    [self.venue saveInBackground];
    
    if (venue.name) {
        self.locationField.text = venue.name;
    } else {
        CLGeocoder *geocoder = [[CLGeocoder alloc] init];
        CLLocation *location = [[CLLocation alloc] initWithLatitude:venue.latitude longitude:venue.longitude];
        [geocoder reverseGeocodeLocation:location completionHandler:^(NSArray<CLPlacemark *> *_Nullable placemarks, NSError *_Nullable error) {
            if (placemarks && placemarks.count > 0) {
                CLPlacemark *placemark = placemarks.firstObject;
                self.locationField.text = [EventViewController getAddressStringFromPlacemark:placemark];
            }
        }];
    }
}

+ (NSString *)getAddressStringFromPlacemark:(CLPlacemark *_Nonnull)placemark {
    NSString *city = placemark.locality;
    NSString *state = placemark.administrativeArea;
    NSString *zip  = placemark.postalCode;
    NSString *streetLine1 = placemark.thoroughfare;
    NSString *streetNumber = placemark.subThoroughfare;
    
    NSString *formattedAddress = [NSString stringWithFormat:@"%@ %@, %@, %@, %@", streetNumber, streetLine1, city, state, zip];
    return formattedAddress;
}

#pragma mark - TextField delegate methods

- (BOOL)canBecomeFirstResponder {
    return YES;
}

- (void)copyTextFieldContent:(id)sender {
    UIPasteboard* pb = [UIPasteboard generalPasteboard];
    pb.string = self.titleField.text;
}

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField {
    UIMenuController* menuController = [UIMenuController sharedMenuController];
    UIMenuItem* copyItem = [[UIMenuItem alloc] initWithTitle:TEXT_FIELD_COPY_ITEM_TITLE
                                                      action:@selector(copyTextFieldContent:)];
    menuController.menuItems = @[copyItem];
    CGRect selectionRect = textField.frame;
    [menuController showMenuFromView:self.view rect:selectionRect];
    return NO;
}

@end
