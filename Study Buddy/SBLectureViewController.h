//
//  SBFirstViewController.h
//  Study Buddy
//
//  Created by John Clem on 8/9/13.
//  Copyright (c) 2013 Mind Diaper. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <socket.IO/SocketIO.h>

@interface SBLectureViewController : UIViewController <SocketIODelegate, UITableViewDataSource, UITableViewDelegate>

// Status buttons
@property (nonatomic, weak) IBOutlet UIButton *redButton, *amberButton, *greenButton;

// Big Image
@property (nonatomic, weak) IBOutlet UIImageView *bigImageView;

// Lecture notes for current task
@property (nonatomic, weak) IBOutlet UITextField *nameField;

// Reference to my current status
@property (nonatomic, readonly) NSInteger currentStatus;


// Action to change my current status.  Called by the three status buttons
- (IBAction)changeStatus:(id)sender;

// Called externally, resets status and displays current lecture note content
- (void)handleNewLectureNote:(NSString *)lectureNote;

// Sets up the controller for a new lecture
- (void)startLecture;

// Ends the current lecture, resetting the view controller to it's initial state
- (void)endLecture;


// Socket.IO
@property (nonatomic, strong) NSMutableArray *messages;
@property (nonatomic, strong) SocketIO *socketIO;
@property (nonatomic, weak) IBOutlet UITableView *tableView;

@end
