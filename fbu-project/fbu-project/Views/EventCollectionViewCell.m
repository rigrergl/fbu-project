//
//  EventCollectionViewCell.m
//  fbu-project
//
//  Created by Rigre Reinier Garciandia Larquin on 7/21/21.
//

#import "EventCollectionViewCell.h"

@interface EventCollectionViewCell ()

@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UILabel *dateLabel;
@property (weak, nonatomic) IBOutlet UIButton *chatButton;
@property (weak, nonatomic) IBOutlet UIButton *acceptButton;
@property (weak, nonatomic) IBOutlet UIButton *declineButton;

@end

static const CGFloat CELL_CORNER_RADIUS = 14;
static NSString * const DATE_FORMAT = @"yyyy-MMM-dd";

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
    
    self.acceptButton.enabled = NO;
    self.acceptButton.alpha = 0;
    self.declineButton.enabled = NO;
    self.declineButton.alpha = 0;
    self.chatButton.enabled = YES;
    self.chatButton.alpha = 1;
}

- (void)setCellForInvited:(Event *_Nonnull)event
             acceptInvite:(EventCellBlock _Nonnull)acceptInvite {
    [self setCell:event];
    
    self.acceptInvite = acceptInvite;
    self.segueToChat = nil;
    
    self.acceptButton.enabled = YES;
    self.acceptButton.alpha = 1;
    self.declineButton.enabled = YES;
    self.declineButton.alpha = 1;
    self.chatButton.enabled = NO;
    self.chatButton.alpha = 0;
}

- (void)setCell:(Event *_Nonnull)event {
    self.event = event;
    self.titleLabel.text = event.title;
    self.dateLabel.text = [EventCollectionViewCell getDateString:event.date];
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

@end
