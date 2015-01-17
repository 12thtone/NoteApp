//
//  DataSource.m
//  NoteApp
//
//  Created by Matt Maher on 1/12/15.
//  Copyright (c) 2015 Matt Maher. All rights reserved.
//

#import "DataSource.h"
#import "AppDelegate.h"
#import <CoreData/CoreData.h>
#import "Note.h"
#import "NoteTableViewController.h"

@interface DataSource ()

@property (nonatomic, strong)NSManagedObjectContext *managerObjectContext;

@property (nonatomic, strong) NoteTableViewController *reference;

@end

@implementation DataSource

@synthesize searchResults;
@synthesize reference;

+ (instancetype) sharedInstance {
    static dispatch_once_t once;
    static id sharedInstance;
    dispatch_once(&once, ^{
        sharedInstance = [[self alloc] init];
    });
    return sharedInstance;
}

- (NSManagedObjectContext*)managerObjectContext {
    return [(AppDelegate*)[[UIApplication sharedApplication]delegate]managedObjectContext];
}

- (void) cancelAndDismiss {
    [self.managerObjectContext rollback];
}

- (void) saveAndDismiss {
    NSError *error = nil;
    if ([self.managerObjectContext hasChanges]) {
        if (![self.managerObjectContext save:&error]) {
            NSLog(@"Save Failed: %@", [error localizedDescription]);
        } else {
            NSLog(@"Save Succeeded");
        }
    }
}

- (NSArray *) searchNotes:(NSString*)searchText scope:(NSString*)scope notes:(NSMutableArray*)noteList {
    searchResults = [[NSMutableArray alloc] init];
    for (Note *note in noteList) {
        if ([scope isEqualToString:@"All"] || [note.noteTitle isEqualToString:scope])
        {
            NSComparisonResult result = [note.noteTitle compare:searchText
                                                        options:(NSCaseInsensitiveSearch|NSDiacriticInsensitiveSearch)
                                                          range:NSMakeRange(0, [searchText length])];
            
            if (result == NSOrderedSame)
            {
                [searchResults addObject:note];
            }
        }
    }
    
    return searchResults;
}

@end
