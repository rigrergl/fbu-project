//
//  EventCollectionViewCell.m
//  fbu-project
//
//  Created by Rigre Reinier Garciandia Larquin on 7/21/21.
//

#import "EventCollectionViewCell.h"
#import "CommonFunctions.h"
#import "DictionaryConstants.h"
#import "CalendarManager.h"

@interface EventCollectionViewCell ()

@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UILabel *dateLabel;
@property (weak, nonatomic) IBOutlet UIButton *chatButton;
@property (weak, nonatomic) IBOutlet UIButton *acceptButton;
@property (weak, nonatomic) IBOutlet UIButton *declineButton;
@property (weak, nonatomic) IBOutlet UIImageView *eventImageView;

@end

static const CGFloat CELL_CORNER_RADIUS = 14;
static NSString * const DATE_FORMAT = @"yyyy-MMM-dd";
static NSString * const OK_ALERT_ACTION_TITLE = @"OK";
static NSString * const SUCCESS_ALERT_TITLE = @"Success";
static NSString * const EVENT_ADDED_MESSAGE = @"Event added to calendar";
static NSString * const ERROR_ALERT_TITLE = @"Error";
static NSString * const ERROR_ADDING_EVENT_MESSAGE = @"Could not add event to calendar";

@implementation EventCollectionViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    [self setRoundedCorners];
}

- (void)setCellForAttending:(Event *_Nonnull)event
                segueToChat:(EventCellBlock _Nonnull)segueToChat {
    [self setCell:event];
    
    self.segueToChat = segueToChat;
    self.acceptInvite = nil;
    
    disableButton(self.acceptButton);
    disableButton(self.declineButton);
    enableButton(self.chatButton);
}

- (void)setCellForInvited:(Event *_Nonnull)event
             acceptInvite:(EventCellBlock _Nonnull)acceptInvite {
    [self setCell:event];
    
    self.acceptInvite = acceptInvite;
    self.segueToChat = nil;
    
    enableButton(self.acceptButton);
    enableButton(self.declineButton);
    disableButton(self.chatButton);
}

- (void)setCell:(Event *_Nonnull)event {
    self.event = event;
    self.titleLabel.text = event.title;
    self.dateLabel.text = [EventCollectionViewCell getDateString:event.date];
    
    [event[EVENT_IMAGE_KEY] getDataInBackgroundWithBlock:^(NSData *_Nullable data, NSError *_Nullable error){
        if (data) {
            self.eventImageView.image = [UIImage imageWithData:data];
        }
    }];
}

+ (NSString *)getDateString:(NSDate *_Nonnull)date {
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:DATE_FORMAT];
    
    return [dateFormatter stringFromDate:date];
}

-  (void)setRoundedCorners {
    self.layer.cornerRadius = CELL_CORNER_RADIUS;
    self.layer.masksToBounds = YES;
}

- (IBAction)didTapInfoButton:(UIButton *)sender {
    if (self.segueToInfo) {
        self.segueToInfo(self);
    }
}

- (IBAction)didTapChatButton:(UIButton *)sender {
    if (self.segueToChat) {
        self.segueToChat(self);
    }
}

- (IBAction)didTapAccept:(UIButton *)sender {
    if (self.acceptInvite) {
        self.acceptInvite(self);
    }
}

- (IBAction)didTapAddToCalendar:(UIButton *)sender {
    [[CalendarManager shared] addEvent:self.event completion:^(BOOL eventAdded){
        if (eventAdded) {
            //TODO: update calendarButton image to be remove event
            [self presentAlertWithTitle:SUCCESS_ALERT_TITLE message:EVENT_ADDED_MESSAGE];
        }  else {
            [self presentAlertWithTitle:ERROR_ALERT_TITLE message:ERROR_ADDING_EVENT_MESSAGE];
        }
    }];
}

- (UIAlertController *)createAlert {
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@""
                                                                   message:@""
                                                            preferredStyle:(UIAlertControllerStyleAlert)];
    // create an OK action
    UIAlertAction *okAction = [UIAlertAction actionWithTitle:OK_ALERT_ACTION_TITLE
                                                       style:UIAlertActionStyleDefault
                                                     handler:nil];
    // add the OK action to the alert controller
    [alert addAction:okAction];
    
    return alert;
}

- (void)presentAlertWithTitle:(NSString *)title
                      message:(NSString *)message {
    UIAlertController *alert = [self createAlert];
    alert.title = title;
    alert.message = message;
    
    if (self.presentAlert) {
        dispatch_async(dispatch_get_main_queue(), ^() {
            self.presentAlert(alert);
        });
    }
}

@end
