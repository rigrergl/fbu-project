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
#import <Parse/Parse.h>

static int INPUT_VIEW_BORDER_WIDTH = 1;
static float INPUT_VIEW_CORNER_RADIUS = 10.0f;
static float KEYBOARD_MOVEMENT_ANIMATION_DURATION = 0.3;

@interface ChatViewController () <UICollectionViewDelegate, UICollectionViewDataSource>
@property (strong, nonatomic) IBOutlet UICollectionView *_Nonnull collectionView;
@property (strong, nonatomic) NSMutableArray *_Nullable messages;
@property (strong, nonatomic) IBOutlet UITextView *_Nonnull inputTextView;
@property (strong, nonatomic) IBOutlet UILabel *_Nonnull chatNameLabel;
@property (nonatomic, strong) NSTimer *_Nullable refreshTimer;
@property (nonatomic, assign) CGFloat originalFrameHeight;
 
@end

@implementation ChatViewController

- (void)viewDidLoad {
    [super viewDidLoad];
  
    [self setupCollectionView];
    
    [self setupGestures];
    [self styleInputTextView];
    
    [self setChatNameLabel];
    [self fetchMessages];
    
    self.originalFrameHeight = self.view.frame.size.height;
}

- (void)setupCollectionView {
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

- (void)setChatNameLabel {
    if (self.match) {
        NSArray *usersInMatch = self.match.users;
        PFUser *user1 = usersInMatch[0];
        PFUser *user2 = usersInMatch[1];
        if ([user1.objectId isEqualToString: [PFUser currentUser].objectId]) {
            self.chatNameLabel.text = user2.username;
        } else {
            self.chatNameLabel.text = user1.username;
        }
    } else if (self.event) {
        self.chatNameLabel.text = self.event.title;
    }
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
    [[MessagePoller shared] startPollingMatch:self.match];
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
    static NSString * const CHAT_CELL_IDENTIFIER = @"chatCell";
    
    MessageCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:CHAT_CELL_IDENTIFIER forIndexPath:indexPath];
    
    if (cell) {
        DirectMessage *message = (DirectMessage *) self.messages[indexPath.item];
        [cell setCellWithDirectMessage:message];
        cell.wrappingViewWidth.constant = self.view.frame.size.width;
    }
    
    return cell;
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

@end
