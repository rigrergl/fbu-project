//
//  ChatViewController.m
//  fbu-project
//
//  Created by Rigre Reinier Garciandia Larquin on 7/14/21.
//

#import "ChatViewController.h"
#import "MessageCollectionViewCell.h"
#import "DirectMessage.h"
#import "DictionaryConstants.h"
#import "MessagePoller.h"
#import "ProfileViewController.h"
#import "EventViewController.h"
#import <Parse/Parse.h>

@interface ChatViewController () <UICollectionViewDelegate, UICollectionViewDataSource>

@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;
@property (strong, nonatomic) NSMutableArray *_Nullable messages;
@property (weak, nonatomic) IBOutlet UITextView *inputTextView;
@property (nonatomic, assign) CGFloat originalFrameHeight;
@property (weak, nonatomic) IBOutlet UIButton *chatTitleButton;
@property (strong, nonatomic) PFUser *otherUser;

@end

static NSInteger INPUT_VIEW_BORDER_WIDTH = 1;
static CGFloat INPUT_VIEW_CORNER_RADIUS = 10.0f;
static CGFloat KEYBOARD_MOVEMENT_ANIMATION_DURATION = 0.3;
static const NSInteger MESSAGE_CELL_INITIAL_HEIGHT = 60;
static NSString * const LEFT_CHAT_CELL_IDENTIFIER = @"leftChatCell";
static NSString * const RIGHT_CHAT_CELL_IDENTIFIER = @"rightChatCell";
static NSString * const CHAT_TO_PROFILE_SEGUE_IDENTIFIER = @"chatToProfile";
static NSString * const CHAT_TO_EVENT_INFO_SEGUE_IDENTIFIER = @"chatToEventInfo";

@implementation ChatViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setupCollectionView];
    [self setupGestures];
    [self styleInputTextView];
    [self setupChatTitle];
    [self fetchMessages];
    
    self.originalFrameHeight = self.view.frame.size.height;
}

- (void)setupChatTitle {
    if (self.match) {
        NSArray *usersInMatch = self.match.users;
        PFUser *user1 = usersInMatch[0];
        PFUser *user2 = usersInMatch[1];
        if ([user1.objectId isEqualToString: [PFUser currentUser].objectId]) {
            [self.chatTitleButton setTitle:user2.username forState:UIControlStateNormal];
            self.otherUser = user2;
        } else {
            [self.chatTitleButton setTitle:user1.username forState:UIControlStateNormal];
            self.otherUser = user1;
        }
    } else if (self.event) {
        [self.chatTitleButton setTitle:self.event.title forState:UIControlStateNormal];
    }
}

- (IBAction)didTapChatTitleButton:(UIButton *)sender {
    if (self.match && self.otherUser) {
        [self performSegueWithIdentifier:CHAT_TO_PROFILE_SEGUE_IDENTIFIER sender:nil];
    } else if (self.event) {
        [self performSegueWithIdentifier:CHAT_TO_EVENT_INFO_SEGUE_IDENTIFIER sender:nil];
    }
}

- (void)setupCollectionView {
    UICollectionViewFlowLayout *layout = self.collectionView.collectionViewLayout;
    layout.estimatedItemSize = UICollectionViewFlowLayoutAutomaticSize;
    self.collectionView.delegate = self;
    self.collectionView.dataSource = self;
    [self.collectionView reloadData];
}

- (void)fetchMessages {
    if (self.match) {
        [self fetchMatchMessages];
    } else if (self.event) {
        [self fetchEventMessages];
    }
}

- (void)fetchEventMessages {
    PFQuery *messageQuery = [PFQuery queryWithClassName:[DirectMessage parseClassName]];
    [messageQuery whereKey:DIRECT_MESSAGE_EVENT_KEY equalTo:self.event];
    
    [messageQuery findObjectsInBackgroundWithBlock:^(NSArray *_Nullable messages, NSError *_Nullable error){
        if (!error) {
            self.messages = messages;
            [self reloadCollectionViewAndScrollToBottom];
        }
    }];
}

- (void)fetchMatchMessages {
    PFQuery *messageQuery = [PFQuery queryWithClassName:[DirectMessage parseClassName]];
    [messageQuery whereKey:DIRECT_MESSAGE_MATCH_KEY equalTo:self.match];
    
    [messageQuery findObjectsInBackgroundWithBlock:^(NSArray *_Nullable messages, NSError *_Nullable error){
        if (!error) {
            self.messages = messages;
            [self reloadCollectionViewAndScrollToBottom];
        }
    }];
}

-  (void)reloadCollectionViewAndScrollToBottom {
    [self.collectionView reloadData];
    [self.collectionView performBatchUpdates:^{}
                                  completion:^(BOOL finished) {
        // collection-view finished reload
        [self scrollToBottomOfCollectionView];
    }];
}

- (void)styleInputTextView {
    self.inputTextView.layer.borderColor = [UIColor lightGrayColor].CGColor;
    self.inputTextView.layer.borderWidth = INPUT_VIEW_BORDER_WIDTH;
    self.inputTextView.layer.cornerRadius = INPUT_VIEW_CORNER_RADIUS;
}

- (void)setupGestures {
    UITapGestureRecognizer *screenTapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(didTapScreen:)];
    [self.view addGestureRecognizer:screenTapGestureRecognizer];
    [self.view setUserInteractionEnabled:YES];
}

- (void)didTapScreen:(UIGestureRecognizer *)sender {
    [self endTyping];
}

- (IBAction)didTapSend:(UIButton *)sender {
    [DirectMessage postMessageWithContent:self.inputTextView.text
                                    match:self.match
                                    event: self.event
                               completion:^(BOOL succeeded, DirectMessage *_Nullable newMessage, NSError *_Nullable error){
        if (newMessage) {
            [self.messages addObject:newMessage];
            [self reloadCollectionViewAndScrollToBottom];
        }
    }];
    self.inputTextView.text = @"";
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
    
    self.tabBarController.tabBar.hidden = true;
    
    [self startPollingMessages];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    self.tabBarController.tabBar.hidden = false;
    
    [self stopPollingMessages];
}

#pragma mark - Message Notifications (Polling)

- (void)startPollingMessages {
    if (self.match) {
        [[MessagePoller shared] startPollingMatch:self.match];
    } else if (self.event) {
        [[MessagePoller shared] startPollingEvent:self.event];
    } else {
        return;
    }
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(receiveNewMessageNotification:)
                                                 name:NEW_MESSAGE_NOTIFICATION_NAME
                                               object:nil];
}

- (void)receiveNewMessageNotification:(NSNotification *)notification {
    if ([[notification name] isEqualToString:NEW_MESSAGE_NOTIFICATION_NAME]) {
        self.messages = notification.object;
        [self reloadCollectionViewAndScrollToBottom];
    }
}

- (void)stopPollingMessages {
    [[MessagePoller shared] stopPolling];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - Collection View methods

- (nonnull UICollectionViewCell *)collectionView:(nonnull UICollectionView *)collectionView
                          cellForItemAtIndexPath:(nonnull NSIndexPath *)indexPath {
    MessageCollectionViewCell *cell;
    
    DirectMessage *message = (DirectMessage *) self.messages[indexPath.item];
    if (!message) {
        return nil;
    }
    
    NSString *authorId = message.author.objectId;
    if ([authorId isEqualToString:[PFUser currentUser].objectId]) {
        cell = [collectionView dequeueReusableCellWithReuseIdentifier:RIGHT_CHAT_CELL_IDENTIFIER forIndexPath:indexPath];
    } else {
        cell = [collectionView dequeueReusableCellWithReuseIdentifier:LEFT_CHAT_CELL_IDENTIFIER forIndexPath:indexPath];
    }
    
    if (cell) {
        [cell setCellWithDirectMessage:message];
    }
    
    return cell;
}

- (CGSize)collectionView:(UICollectionView *)collectionView
                  layout:(UICollectionViewLayout *)collectionViewLayout
  sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    return CGSizeMake(self.collectionView.frame.size.width, MESSAGE_CELL_INITIAL_HEIGHT);
}

- (NSInteger)collectionView:(nonnull UICollectionView *)collectionView
     numberOfItemsInSection:(NSInteger)section {
    if (self.messages) {
        return self.messages.count;
    }
    
    return 0;
}

#pragma mark - keyboard movements

- (void)endTyping {
    [self.inputTextView resignFirstResponder];
}

- (void)keyboardWillShow:(NSNotification *)notification {
    CGSize keyboardSize = [[[notification userInfo] objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue].size;
    
    [UIView animateWithDuration:KEYBOARD_MOVEMENT_ANIMATION_DURATION
                     animations:^{
        CGRect f = self.view.frame;
        f.size.height -= keyboardSize.height;
        self.view.frame = f;
        [self scrollToBottomOfCollectionView];
    }];
}

- (void)keyboardWillHide:(NSNotification *)notification {
    [UIView animateWithDuration:KEYBOARD_MOVEMENT_ANIMATION_DURATION
                     animations:^{
        CGRect f = self.view.frame;
        f.size.height = self.originalFrameHeight;
        self.view.frame = f;
        [self scrollToBottomOfCollectionView];
    }];
}

- (void)scrollToBottomOfCollectionView {
    NSInteger item = [self.collectionView numberOfItemsInSection:0] - 1;
    NSIndexPath *lastIndex = [NSIndexPath indexPathForItem:item inSection:0];
    [self.collectionView scrollToItemAtIndexPath:lastIndex atScrollPosition:UICollectionViewScrollPositionBottom animated:NO];
}

#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:CHAT_TO_PROFILE_SEGUE_IDENTIFIER]) {
        ProfileViewController *destinationViewController = [segue destinationViewController];
        destinationViewController.targetUser = self.otherUser;
    } else if ([segue.identifier isEqualToString:CHAT_TO_EVENT_INFO_SEGUE_IDENTIFIER]) {
        EventViewController *destinationViewController = [segue destinationViewController];
        [destinationViewController setEvent:self.event];
    }
}

@end
