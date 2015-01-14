//
// Created by Florian BUREL on 13/01/15.
// Copyright (c) 2015 Florian Burel. All rights reserved.
//

#import <Foundation/Foundation.h>

@class Todo;


typedef void(^AllTodoCompletion)(NSArray * todos, NSError * error);
typedef void(^TodoCompletion)(Todo * todo, NSError * error);

@interface TodoRepository : NSObject

/// Ajoute un item a la liste
- (void) addTodo:(Todo *)todo completion:(TodoCompletion)block;

/// Return all Todos (async)
//- (void) allTodos:(AllTodoCompletion)completion;

/// Change the status of the given item
- (void) changeStatus:(Todo *)todo completion:(TodoCompletion)block;

/// Supprime un element de la liste
- (void) deleteTodo:(Todo *)todo completion:(TodoCompletion)block;

@end