//
//  SBFirstViewController.m
//  Study Buddy
//
//  Created by John Clem on 8/9/13.
//  Copyright (c) 2013 Mind Diaper. All rights reserved.
//

#import "SBLectureViewController.h"
#import <socket.IO/SocketIOPacket.h>

@interface SBLectureViewController ()

@end

@implementation SBLectureViewController

// Create an enum to hold the various status types
typedef enum statusTypes
{
    kStatusTypeInitial = 0,
    kStatusTypeRed,
    kStatusTypeAmber,
    kStatusTypeGreen,
    kStatusTypeDisconnected,
    kStatusTypeUnknown
} StatusType;

- (void)viewDidLoad
{
    [super viewDidLoad];

    [self resetButtonStates];
    
    // Setup web socket connection
    self.socketIO = [[SocketIO alloc] initWithDelegate:self];
    [self.socketIO connectToHost:@"localhost" onPort:3000];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

// Action to change my current status.  Called by the three status buttons
- (IBAction)changeStatus:(id)sender
{
    NSLog(@"Changing Status To: %ld", (long)[(UIButton *)sender tag]);
    
    _currentStatus = [(UIButton *)sender tag];
    
        
    [self handleStatusChange];
}

// Called externally, resets status and displays current lecture note content
- (void)handleNewLectureNote:(NSString *)lectureNote
{
    [self resetButtonStates];
    
    [_nameField setText:lectureNote];
    
    [_nameField setNeedsDisplay];
}

// Sets up the controller for a new lecture
- (void)startLecture
{
    [self resetButtonStates];

    _currentStatus = kStatusTypeInitial;
    [self sendStatusToLectureNotesServer:kStatusTypeInitial];
}

// Ends the current lecture, resetting the view controller to it's initial state
- (void)endLecture
{
    // Set our status to it's initial state
    _currentStatus = 0;
    
    // Reset the button state
    [self resetButtonStates];

}

- (void)handleStatusChange
{
    [self resetButtonStates];
    
    switch (_currentStatus) {
        case kStatusTypeInitial:
            // The initial ready-state of the View Controller at the start of a new lecture
            break;
        case kStatusTypeGreen:
            // User tapped the Got It button
            [_greenButton setSelected:YES];
            [_greenButton setAlpha:1.f];
            [self sendStatusToLectureNotesServer:kStatusTypeGreen];
            break;
        case kStatusTypeAmber:
            // User tapped the Hang-On button
            [_amberButton setSelected:YES];
            [_amberButton setAlpha:1.f];
            [self sendStatusToLectureNotesServer:kStatusTypeAmber];
            break;
        case kStatusTypeRed:
            // User tapped the Help button
            [_redButton setSelected:YES];
            [_redButton setAlpha:1.f];
            [self sendStatusToLectureNotesServer:kStatusTypeRed];
            break;
        case kStatusTypeDisconnected:
            // The app cannot connect to a lectureNotes server
            break;
        case kStatusTypeUnknown:
            NSLog(@"Error: Cannot handle status change to unknown status");
            break;
        default:
            _currentStatus = kStatusTypeUnknown;
            [self handleStatusChange];
            break;
    }
}

- (void)resetButtonStates
{
    [_redButton setSelected:NO];
    [_amberButton setSelected:NO];
    [_greenButton setSelected:NO];

    [_redButton setAlpha:0.75];
    [_amberButton setAlpha:0.75];
    [_greenButton setAlpha:0.75];
    
    [self.view setTintColor:UIColor.whiteColor];
}

- (void)sendStatusToLectureNotesServer:(StatusType)status
{
    // Send my current status to the Lecture Notes server
    NSString *statusTypeString;
    
    switch (status) {
        case kStatusTypeGreen:
            statusTypeString = @"Green";
            [_bigImageView setImage:[UIImage imageNamed:@"green.png"]];
            break;
        case kStatusTypeRed:
            statusTypeString = @"Red";
            [_bigImageView setImage:[UIImage imageNamed:@"red.png"]];
            break;
        default:
            statusTypeString = @"Amber";
            [_bigImageView setImage:[UIImage imageNamed:@"amber.png"]];
            break;
    }
    [self.socketIO sendEvent:@"msg" withData:@{ @"msg": statusTypeString, @"name": _nameField.text } andAcknowledge:^(id argsData) {
        
    }];
}

#pragma mark - Web Sockets
#pragma mark - Private

- (void)appendMessage:(NSDictionary *)message
{
    if(!self.messages)
        self.messages = [NSMutableArray array];
    
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:0 inSection:0];
    [self.messages insertObject:message atIndex:0];
    [self.tableView insertRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationLeft];
    [self.tableView scrollRectToVisible:CGRectMake(0, 0, 1, 1) animated:YES];
}

#pragma mark - UITableViewDataSource

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    NSDictionary *dict = self.messages[indexPath.row];
    [cell.textLabel setText:dict[@"msg"]];
    [cell.detailTextLabel setText:dict[@"user"]];
    return cell;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.messages count];
}

#pragma mark - SocketIODelegate

- (void)socketIO:(SocketIO *)socket onError:(NSError *)error
{
    NSLog(@"%@", error.localizedDescription);
}

- (void)socketIO:(SocketIO *)socket didReceiveMessage:(SocketIOPacket *)packet {
    
}

- (void)socketIO:(SocketIO *)socket didReceiveEvent:(SocketIOPacket *)packet
{
    if([[packet args] count] > 0 && [packet args][0][@"msg"]) {
        [self appendMessage:[packet args][0]];
    }
}

- (void) socketIO:(SocketIO *)socket failedToConnectWithError:(NSError *)error
{
    NSLog(@"%@", error.localizedDescription);
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    [_nameField resignFirstResponder];
}

@end
