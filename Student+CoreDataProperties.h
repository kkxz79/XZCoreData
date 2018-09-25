//
//  Student+CoreDataProperties.h
//  CoreDataLearn
//
//  Created by kkxz on 2018/9/25.
//  Copyright © 2018年 kkxz. All rights reserved.
//
//

#import "Student+CoreDataClass.h"


NS_ASSUME_NONNULL_BEGIN

@interface Student (CoreDataProperties)

+ (NSFetchRequest<Student *> *)fetchRequest;

@property (nonatomic) int16_t age;
@property (nonatomic) int16_t height;
@property (nullable, nonatomic, copy) NSString *name;
@property (nonatomic) int16_t number;
@property (nullable, nonatomic, copy) NSString *sex;
@property (nonatomic) int16_t weight;

@end

NS_ASSUME_NONNULL_END
