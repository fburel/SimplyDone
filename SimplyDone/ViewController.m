//
//  ViewController.m
//  SimplyDone
//
//  Created by Florian BUREL on 13/01/2015.
//  Copyright (c) 2015 Florian Burel. All rights reserved.
//

#import "ViewController.h"
#import "CoreDataManager.h"
#import "Todo.h"

@import CoreData;

@interface ViewController () <UITableViewDataSource>

@property (strong, nonatomic) UITableView * tableView;
@property (strong, nonatomic) NSArray * todos;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];


    [self populateDB];

    self.tableView = [[UITableView alloc]init];
    self.tableView.frame = CGRectMake(0,
                                      0,
                                      self.view.frame.size.width,
                                      self.view.frame.size.height);
    [self.view addSubview:self.tableView];
    self.tableView.dataSource = self;

    [self updateDatabaseInBackground];

}

- (void)updateDatabaseInBackground {

    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(contextDidSave)
                                                 name:NSManagedObjectContextDidSaveNotification
                                               object:nil];


    dispatch_async(dispatch_get_global_queue(2, 0), ^{

        CoreDataManager * mgr = [CoreDataManager new];
        NSManagedObjectContext * context = mgr.managedObjectContext;

        for(int i = 0 ; i < 10000; i++)
        {

            Todo * todo = [NSEntityDescription insertNewObjectForEntityForName:@"Todo"
                                                        inManagedObjectContext:context];

            todo.details = [NSString stringWithFormat:@"todo - %d", i];
            todo.done = @(i % 2 == 0);

        }

        [context save:nil];
    });

}

- (void)contextDidSave {

    self.todos = nil;
    [self.tableView reloadData];

}

- (void)populateDB {

    CoreDataManager * cmgr = [CoreDataManager sharedInstance];
    NSManagedObjectContext * context = cmgr.managedObjectContext;

    for(int i = 0 ; i < 4 ; i++)
    {
        Todo * todo = [NSEntityDescription insertNewObjectForEntityForName:@"Todo"
                                      inManagedObjectContext:context];

        todo.details = [NSString stringWithFormat:@"todo - %d", i];
        todo.done = @(i % 2 == 0);

    }

}

- (NSArray *)todos
{
   if(!_todos)
   {
       CoreDataManager * cmgr = [CoreDataManager sharedInstance];
       NSManagedObjectContext * context = cmgr.managedObjectContext;

       NSFetchRequest * request = [[NSFetchRequest alloc]initWithEntityName:@"Todo"];
       NSSortDescriptor * sd;
       sd = [NSSortDescriptor sortDescriptorWithKey:@"details"
                                          ascending:NO];
       request.sortDescriptors = @[sd];

       _todos = [context executeFetchRequest:request
                                     error:nil];
   }
    return _todos;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.todos.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    Todo * todo = self.todos[indexPath.row];
    
    static NSString * CELL_IDENTIFIER = @"cell";
    
    UITableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:CELL_IDENTIFIER];
    
    if(!cell)
    {
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CELL_IDENTIFIER];
    }
    
    cell.textLabel.text = todo.details; // nom du todo
    cell.accessoryType = todo.done.boolValue ? UITableViewCellAccessoryCheckmark : UITableViewCellAccessoryNone; // Checkmark ou None
    
    return cell;
}
@end










