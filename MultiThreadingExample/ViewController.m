//
//  ViewController.m
//  MultiThreadingExample
//
//  Created by Benjamin Encz on 10/09/14.
//  Copyright (c) 2014 MakeSchool. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()

@property (weak, nonatomic) IBOutlet UILabel *downloadStatusLabel;
@property (strong, nonatomic) NSArray *strings;
@property (weak, nonatomic) IBOutlet UILabel *displayedStringLabel;
@property (assign, nonatomic) NSInteger currentStringIndex;
@property (assign, nonatomic) NSInteger completedDownloads;
@property (strong, nonatomic) dispatch_group_t dispatchGroup;

@end

static const NSInteger kTotalOperations = 1000;

@implementation ViewController

#pragma mark - Init

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    
    if (self) {
        self.strings = @[@"Test1", @"Test2", @"Test3"];
    }
    
    return self;
}

#pragma mark - View Lifecycle

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    self.displayedStringLabel.text = self.strings[self.currentStringIndex];
    self.downloadStatusLabel.text = [NSString stringWithFormat:@"%ld/%ld", self.completedDownloads, kTotalOperations];
    
    self.dispatchGroup = dispatch_group_create();
    
    for (int i = 0; i < kTotalOperations; i++) {
        dispatch_group_async(self.dispatchGroup, dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            [self downloadBlock];
        });
    }
    
    dispatch_group_notify(self.dispatchGroup, dispatch_get_main_queue(), ^{
        self.downloadStatusLabel.text = @"Completed";
    });
}

#pragma mark - Button Callbacks

- (IBAction)showRandomTextPressed:(id)sender {
    self.currentStringIndex++;
    self.currentStringIndex = self.currentStringIndex >= [self.strings count] ? 0 : self.currentStringIndex;
    self.displayedStringLabel.text = self.strings[self.currentStringIndex];
}

#pragma mark - Download Management

- (void)downloadBlock {
    sleep(1);
    
    dispatch_async(dispatch_get_main_queue(), ^{
        self.completedDownloads++;
        self.downloadStatusLabel.text = [NSString stringWithFormat:@"%ld/%ld", self.completedDownloads, kTotalOperations];
    });
}

@end
