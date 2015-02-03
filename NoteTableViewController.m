//
//  SearchTableViewController.m
//  NoteApp
//
//  Created by Matt Maher on 1/15/15.
//  Copyright (c) 2015 Matt Maher. All rights reserved.
//

#import "NoteTableViewController.h"
#import "AppDelegate.h"
#import "Note.h"
#import "AddNoteViewController.h"
#import "ReadNoteViewController.h"
#import "DataSource.h"
#import <CoreData/CoreData.h>

@interface NoteTableViewController () <NSFetchedResultsControllerDelegate, UISearchDisplayDelegate, UISearchBarDelegate>

@property (nonatomic, strong)Note *note;
@property (nonatomic, retain) NSMutableArray *searchResults;
@property (nonatomic, retain) NSMutableArray *fixedResults;

@property (nonatomic, strong)NSManagedObjectContext *managedObjectContext;
@property (nonatomic, strong)NSFetchedResultsController *fetchedResultsController;

@property (nonatomic, strong) Note *selectedFilteredNote;
@property (nonatomic, strong) Note *selectedNote;

@end

@implementation NoteTableViewController

@synthesize searchResults;
@synthesize fixedResults;
@synthesize noteList;

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (NSManagedObjectContext*)managedObjectContext {
    return [(AppDelegate*)[[UIApplication sharedApplication]delegate]managedObjectContext];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    NSError *error = nil;
    
    if (![[self fetchedResultsController]performFetch:&error]) {
        NSLog(@"Error! %@", error);
        abort();
    }
    
    self.searchResults = [NSMutableArray arrayWithCapacity:[[self.fetchedResultsController fetchedObjects] count]];
    fixedResults = [NSMutableArray arrayWithCapacity:[[self.fetchedResultsController fetchedObjects] count]];
    
    [self.navigationController.navigationBar setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys: [UIFont fontWithName:@"Snell Roundhand" size:30],NSFontAttributeName, nil]];
    self.navigationItem.title = @"The Ideamator";
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reloadTableView:) name:@"reloadTable" object:nil];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)viewDidUnload
{
    self.searchResults = nil;
    self.fixedResults = nil;
}

- (void) dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"reloadTable" object:nil];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    //[self.tableView reloadData];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    //[self.tableView reloadData];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)reloadTableView:(NSNotification*)notification {
    {
        if ([[notification name] isEqualToString:@"reloadTable"])
        {
            NSLog(@"Reloading");
            /*
            NSError *error = nil;
            
            //[NSFetchedResultsController deleteCacheWithName:nil];
            
            [self.fetchedResultsController performFetch:&error];
            
            if (error) {
                NSLog(@"Error! %@", error);
                abort();
            }*/
            
            //[self.tableView reloadData];
            // The contents of the first cell are printed on all new cells w/o reloadData.
        }
    }
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return [[self.fetchedResultsController sections]count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (tableView == self.searchDisplayController.searchResultsTableView)
    {
        return [self.searchResults count];
    }
    else
    {
        id<NSFetchedResultsSectionInfo> sectionInfo = [[self.fetchedResultsController sections]objectAtIndex:section];
        
        return [sectionInfo numberOfObjects];
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
    // Configure the cell...
    
    Note *note = nil;
    
    if (tableView == self.searchDisplayController.searchResultsTableView)
    {
        note = [self.searchResults objectAtIndex:indexPath.row];
        [fixedResults addObject:note.noteTitle];
    }
    else
    {
        note = [self.fetchedResultsController objectAtIndexPath:indexPath];
    }
    
    cell.textLabel.text = note.noteTitle;
    cell.detailTextLabel.text = note.noteTag;
    
    //[cell setSelected:YES];
    //NSLog(@"Selected");
    //[cell setSelected:NO];
    
    //UILabel *noteTitleLabel = (UILabel *)[cell viewWithTag:101];
    //noteTitleLabel.text = note.noteTitle;
    
    //UILabel *noteStatusLabel = (UILabel *)[cell viewWithTag:102];
    //noteStatusLabel.text = note.noteTag;
    
    return cell;
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    
    if ([[segue identifier]isEqualToString:@"addNote"]) {
        /*
        if (isPhone) {
            UINavigationController *navigationController = segue.destinationViewController;
            AddNoteViewController *addNoteViewController = (AddNoteViewController*) navigationController.topViewController;
            Note *addNote = [NSEntityDescription insertNewObjectForEntityForName:@"Note" inManagedObjectContext:[self managedObjectContext]];
            addNoteViewController.addNote = addNote;
        } else {
            UIViewController *destinationVC = segue.destinationViewController;
            AddNoteViewController *addNoteViewController = (AddNoteViewController*) destinationVC;
            Note *addNote = [NSEntityDescription insertNewObjectForEntityForName:@"Note" inManagedObjectContext:[self managedObjectContext]];
            addNoteViewController.addNote = addNote;
        }*/
    }
    
    if ([[segue identifier]isEqualToString:@"readNote"]) {
        
        ReadNoteViewController *readNoteViewController = segue.destinationViewController;
        
        if (self.searchResults.count != 0) {
            NSIndexPath *indexFilteredPath = [self.searchDisplayController.searchResultsTableView indexPathForSelectedRow];
            self.selectedFilteredNote = [self.searchResults objectAtIndex:indexFilteredPath.row];
            readNoteViewController.selectedNote = _selectedFilteredNote;
        }
        else
        {
            NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
            self.selectedNote = [self.fetchedResultsController objectAtIndexPath:indexPath];
            readNoteViewController.selectedNote = _selectedNote;
        }
    }
}

// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    //Return NO if you do not want the specified item to be editable.
    
    return YES;
}

// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        NSManagedObjectContext *context = [self managedObjectContext];
        
        Note *noteToDelete = [self.fetchedResultsController objectAtIndexPath:indexPath];
        
        [context deleteObject:noteToDelete];
        
        NSError *error = nil;
        
        if (![context save:&error]) {
            NSLog(@"Error! %@", error);
        }
    }
    
}
/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
}

// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/
#pragma mark - Fetched Results Controller Section

- (NSFetchedResultsController*)fetchedResultsController {
    if (_fetchedResultsController != nil) {
        return _fetchedResultsController;
    }
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc]init];
    
    NSManagedObjectContext *context = [self managedObjectContext];
    
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Note" inManagedObjectContext:context];
    
    [fetchRequest setEntity:entity];
    
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc]initWithKey:@"noteTitle" ascending:YES];
    
    NSArray *sortDescriptors = [[NSArray alloc]initWithObjects:sortDescriptor, nil];
    
    fetchRequest.sortDescriptors = sortDescriptors;
    
    _fetchedResultsController = [[NSFetchedResultsController alloc]initWithFetchRequest:fetchRequest managedObjectContext:context sectionNameKeyPath:nil cacheName:nil];
    
    _fetchedResultsController.delegate = self;
    
    return _fetchedResultsController;
}

#pragma mark - Fetched Results Controller Delegates

- (void)controllerWillChangeContent:(NSFetchedResultsController *)controller {
    [self.tableView beginUpdates];
}

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller {
    [self.tableView endUpdates];
}

- (void)controller:(NSFetchedResultsController *)controller didChangeObject:(id)anObject atIndexPath:(NSIndexPath *)indexPath forChangeType:(NSFetchedResultsChangeType)type newIndexPath:(NSIndexPath *)newIndexPath {
    UITableView *tableView = self.tableView;
    switch (type) {
        case NSFetchedResultsChangeInsert:
            [tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:newIndexPath] withRowAnimation:UITableViewRowAnimationFade];
            break;
        case NSFetchedResultsChangeDelete:
            [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
            break;
        case NSFetchedResultsChangeUpdate: {
            Note *changeNote = [self.fetchedResultsController objectAtIndexPath:indexPath];
            UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
            
            cell.textLabel.text = changeNote.noteTitle;
            cell.detailTextLabel.text = changeNote.noteTag;
            //UILabel *noteTitleLabel = (UILabel *)[cell viewWithTag:101];
            //noteTitleLabel.text = changeNote.noteTitle;
            
            //UILabel *noteStatusLabel = (UILabel *)[cell viewWithTag:102];
            //noteStatusLabel.text = changeNote.noteTag;
            }
            break;
            
        case NSFetchedResultsChangeMove:
            [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
            [tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
            break;
            
    }
}

#pragma mark - Content Filtering

- (void)filterContentForSearchText:(NSString*)searchText scope:(NSString*)scope
{
    [self.searchResults removeAllObjects];
    noteList = [self.fetchedResultsController fetchedObjects].mutableCopy;
    self.searchResults = [[DataSource sharedInstance] searchNotes:(NSString*)searchText scope:(NSString*)scope notes:(NSMutableArray*)noteList].mutableCopy;
}

#pragma mark - UISearchDisplayController Delegate Methods

- (BOOL)searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchString:(NSString *)searchString
{
    [self filterContentForSearchText:searchString scope:@"All"];
    return YES;
}

- (BOOL)searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchScope:(NSInteger)searchOption
{
    [self filterContentForSearchText:[self.searchDisplayController.searchBar text] scope:@"All"];
    return YES;
}

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar
{
    [self viewDidLoad];
}

@end
