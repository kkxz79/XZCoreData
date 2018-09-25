//
//  Student+CoreDataProperties.m
//  CoreDataLearn
//
//  Created by kkxz on 2018/9/25.
//  Copyright © 2018年 kkxz. All rights reserved.
//
//

#import "Student+CoreDataProperties.h"

@implementation Student (CoreDataProperties)

+ (NSFetchRequest<Student *> *)fetchRequest {
	return [NSFetchRequest fetchRequestWithEntityName:@"Student"];
}

@dynamic age;
@dynamic height;
@dynamic name;
@dynamic number;
@dynamic sex;
@dynamic weight;

@end
