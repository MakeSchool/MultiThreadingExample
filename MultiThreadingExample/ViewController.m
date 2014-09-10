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
@property (strong, nonatomic) NSOperationQueue *operationQueue;

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
}

#pragma mark - Button Callbacks

- (IBAction)startButtonPressed:(id)sender {
    if (self.operationQueue.operationCount > 0) {
        return;
    }
    
    self.completedDownloads = 0;
    self.downloadStatusLabel.text = [NSString stringWithFormat:@"%ld/%ld", self.completedDownloads, kTotalOperations];
    
    self.operationQueue = [NSOperationQueue new];
    self.operationQueue.maxConcurrentOperationCount = 50;
    
    NSOperation *completionBlock = [NSBlockOperation blockOperationWithBlock:^{
        dispatch_async(dispatch_get_main_queue(), ^{
            self.downloadStatusLabel.text = @"Completed";
        });
    }];
    
    for (int i = 0; i < kTotalOperations; i++) {
        NSOperation *downloadOperation = [NSBlockOperation blockOperationWithBlock:^{
            [self downloadBlock];
        }];
        
        __weak NSOperation *weakDownloadOperation = downloadOperation;
        
        [downloadOperation setCompletionBlock:^{
            if (weakDownloadOperation.cancelled) {
                return;
            }
            
            dispatch_async(dispatch_get_main_queue(), ^{
                self.completedDownloads++;
                self.downloadStatusLabel.text = [NSString stringWithFormat:@"%ld/%ld", self.completedDownloads, kTotalOperations];
            });
        }];
        
        [completionBlock addDependency:downloadOperation];
        
        [self.operationQueue addOperation:downloadOperation];
    }
    
    [self.operationQueue addOperation:completionBlock];
}

- (IBAction)cancelButtonPressed:(id)sender {
    [self.operationQueue cancelAllOperations];
}

- (IBAction)showRandomTextPressed:(id)sender {
    self.currentStringIndex++;
    self.currentStringIndex = self.currentStringIndex >= [self.strings count] ? 0 : self.currentStringIndex;
    self.displayedStringLabel.text = self.strings[self.currentStringIndex];
}

#pragma mark - Download Management

- (void)downloadBlock {
    sleep(1);
}

@end
