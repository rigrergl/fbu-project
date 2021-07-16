//
//  ChatViewController.m
//  fbu-project
//
//  Created by Rigre Reinier Garciandia Larquin on 7/14/21.
//

#import "ChatViewController.h"
#import "MessageCollectionViewCell.h"
#import <LoremIpsum/LoremIpsum.h>
#import "DirectMessage.h"
#import <Parse/Parse.h>

@interface ChatViewController () <UICollectionViewDelegate, UICollectionViewDataSource>
@property (strong, nonatomic) IBOutlet UICollectionView *_Nonnull collectionView;
@property (strong, nonatomic) NSMutableArray *_Nullable messages;
@property (strong, nonatomic) IBOutlet UITextView *_Nonnull inputTextView;
@property (strong, nonatomic) IBOutlet UILabel *_Nonnull chatNameLabel;
@property (nonatomic, strong) NSTimer *_Nullable refreshTimer;

@end

@implementation ChatViewController

- (void)viewDidLoad {
    [super viewDidLoad];
  
    [self setupCollectionView];
    
    [self setupGestures];
    [self styleInputTextView];
    
    [self setChatNameLabel];
    [self fetchMessages];
}

- (void)setupCollectionView {
    self.collectionView.delegate = self;
    self.collectionView.dataSource = self;
    [self.collectionView reloadData];
}

- (void)fetchMessages {
    if (self.match) {
        [self fetchMatchMessages];
    }
    //TODO: ELSE FETCH EVENT MESSAGES
}

- (void)fetchMatchMessages {
    PFQuery *messageQuery = [PFQuery queryWithClassName:@"DirectMessage"];
    [messageQuery whereKey:@"match" equalTo:self.match];
    
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
    }
}

- (void)styleInputTextView {
    self.inputTextView.layer.borderColor = [UIColor lightGrayColor].CGColor;
    self.inputTextView.layer.borderWidth = 1;
    self.inputTextView.layer.cornerRadius = 10.0f;
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
    if (self.match) {
        [DirectMessage postMessageWithContent:self.inputTextView.text
                                      inMatch:self.match
                               withCompletion:^(BOOL succeeded, DirectMessage *_Nullable newMessage, NSError *_Nullable error){
           if (newMessage) {
                [self.messages addObject:newMessage];
                [self reloadCollectionViewAndScrollToBottom];
            }
        }];
    }
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
    
    self.tabBarController.tabBar.hidden = true;
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];
    
    self.tabBarController.tabBar.hidden = false;
}

#pragma mark - Collection View methods

- (nonnull UICollectionViewCell *)collectionView:(nonnull UICollectionView *)collectionView
                          cellForItemAtIndexPath:(nonnull NSIndexPath *)indexPath {
    MessageCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"chatCell" forIndexPath:indexPath];
    
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
    } else {
        return 0;
    }
}

#pragma mark - keyboard movements

- (void)endTyping {
    [self.inputTextView resignFirstResponder];
}

- (void)keyboardWillShow:(NSNotification *)notification {
    CGSize keyboardSize = [[[notification userInfo] objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue].size;

    [UIView animateWithDuration:0.3 animations:^{
        CGRect f = self.view.frame;
        f.origin.y = -keyboardSize.height;
        self.view.frame = f;
    }];
}

- (void)keyboardWillHide:(NSNotification *)notification {
    [UIView animateWithDuration:0.3 animations:^{
        CGRect f = self.view.frame;
        f.origin.y = 0.0f;
        self.view.frame = f;
    }];
}

- (void)scrollToBottomOfCollectionView {
    NSInteger item = [self.collectionView numberOfItemsInSection:0] - 1;
    NSIndexPath *lastIndex = [NSIndexPath indexPathForItem:item inSection:0];
    [self.collectionView scrollToItemAtIndexPath:lastIndex atScrollPosition:UICollectionViewScrollPositionBottom animated:NO];
}

@end
