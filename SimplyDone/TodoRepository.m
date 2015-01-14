//
// Created by Florian BUREL on 13/01/15.
// Copyright (c) 2015 Florian Burel. All rights reserved.
//

#import "TodoRepository.h"
#import "Todo.h"
#import <AFNetworking/AFNetworking.h>

#define BASE_URL        @"http://127.0.0.1:7020"


@interface TodoRepository ()

@property (strong, nonatomic) NSOperationQueue * backgroundQueue;

@property (strong, nonatomic) NSArray * list;

@end


@implementation TodoRepository

- (void)addTodo:(Todo *)todo completion:(TodoCompletion)block
{


    NSDictionary * item = @
    {
            @"details" : todo.details,
            @"done" : todo.done
    };

    NSData * jsonRep = [NSJSONSerialization dataWithJSONObject:item
                                                       options:0
                                                         error:nil];

    AFHTTPRequestOperation * request = [self launchOperationWithURL:BASE_URL
                                                             method:@"POST"
                                                               body:jsonRep];

    if(block)
    {
        NSOperation * completionOperation = [NSBlockOperation blockOperationWithBlock:^{

            block(todo, request.error);

        }];

        [completionOperation addDependency:request];
        [[NSOperationQueue mainQueue] addOperation:completionOperation];
    }


}

- (void)allTodos:(AllTodoCompletion)completion {

    // NSOperation de telechargement
    AFHTTPRequestOperation * requestOperation = [self launchOperationWithURL:BASE_URL
                                                                      method:@"GET"
                                                                        body:nil];

    // Completion
    if(completion)
    {
        NSOperation * completionOperation = [NSBlockOperation blockOperationWithBlock:^{

            NSMutableArray * todos = [NSMutableArray new];

            if(!requestOperation.error)
            {
                for(NSDictionary * item in requestOperation.responseObject)
                {
                    [todos addObject:[self parseTodoItem:item]];
                }
            }

            self.list = todos;

            completion(todos, requestOperation.error);

        }];

        [completionOperation addDependency:requestOperation];
        [[NSOperationQueue mainQueue] addOperation:completionOperation];

    }


}

- (void)changeStatus:(Todo *)todo completion:(TodoCompletion)block
{
    int idx = [self.list indexOfObject:todo];

    NSString * url = [NSString stringWithFormat:@"%@?index=%d", BASE_URL, idx];

    AFHTTPRequestOperation * request = [self launchOperationWithURL:BASE_URL
                                                             method:@"PUT"
                                                               body:nil];

    if(block)
    {
        NSOperation * completionOperation = [NSBlockOperation blockOperationWithBlock:^{

            block(todo, request.error);

        }];

        [completionOperation addDependency:request];
        [[NSOperationQueue mainQueue] addOperation:completionOperation];
    }


}

- (void)deleteTodo:(Todo *)todo completion:(TodoCompletion)block
{
    int idx = [self.list indexOfObject:todo];

    NSString * url = [NSString stringWithFormat:@"%@?index=%d", BASE_URL, idx];

    AFHTTPRequestOperation * request = [self launchOperationWithURL:BASE_URL
                                                             method:@"DELETE"
                                                               body:nil];

    if(block)
    {
        NSOperation * completionOperation = [NSBlockOperation blockOperationWithBlock:^{

            block(todo, request.error);

        }];

        [completionOperation addDependency:request];
        [[NSOperationQueue mainQueue] addOperation:completionOperation];
    }


}


- (NSOperationQueue *)backgroundQueue
{
    if(!_backgroundQueue)
    {
        _backgroundQueue = [NSOperationQueue new];
    }
    return _backgroundQueue;
}

- (Todo *)parseTodoItem:(NSDictionary *)dictionary
{

    Todo * todo = [Todo new];
    todo.details = dictionary[@"details"];
    todo.done = dictionary[@"done"];

    return todo;
}


- (AFHTTPRequestOperation *) launchOperationWithURL:(NSString *)url method:(NSString *)method body:(NSData *)body
{


    NSMutableURLRequest * request = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:url]];
    request.HTTPMethod = method;

    if(body)
    {
        [request setHTTPBody:body];
    }
    return [self launchOperationWithRequest:request];

}

- (AFHTTPRequestOperation *) launchOperationWithRequest:(NSURLRequest *)request
{
    AFHTTPRequestOperation * requestOperation;
    requestOperation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
    requestOperation.responseSerializer = [AFJSONResponseSerializer new];

    // Demarrage de l'operation
    [self.backgroundQueue addOperation:requestOperation];

    return requestOperation;
}

@end