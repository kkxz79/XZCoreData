//
//  ViewController.m
//  CoreDataLearn
//
//  Created by kkxz on 2018/9/25.
//  Copyright © 2018年 kkxz. All rights reserved.
//

#import "ViewController.h"
#import <CoreData/CoreData.h>
#import "Student+CoreDataClass.h"

@interface ViewController ()<UITableViewDelegate,UITableViewDataSource>
@property(nonatomic,strong)NSManagedObjectContext*context;
@property(nonatomic,strong)UIButton * buttonOne;
@property(nonatomic,strong)UIButton * buttonTwo;
@property(nonatomic,strong)UIButton * buttonThree;
@property(nonatomic,strong)UIButton * buttonFour;
@property(nonatomic,strong)UIButton * buttonFive;
@property(nonatomic,strong)UITableView * tableView;
@property(nonatomic,strong)NSMutableArray * dataArray;
@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.title = @"首页";
    self.view.backgroundColor = [UIColor whiteColor];
    [self createSubViews];
    [self createAutoLayout];
    //NSManagedObjectContext 管理对象，上下文，持久性存储模型对象，处理数据与应用的交互.
    //NSManagedObjectModel 被管理的数据模型，数据结构.
    //NSPersistentStoreCoordinator 添加数据库，设置数据存储的名字，位置，存储方式.
    //NSManagedObject 被管理的数据记录.
    //NSFetchRequest 数据请求.
    //NSEntityDescription 表格实体结构
    
    [self createSqlite];
    
    //查询所有数据的请求
    NSFetchRequest * request = [NSFetchRequest fetchRequestWithEntityName:@"Student"];
    NSArray * resArray = [self.context executeFetchRequest:request error:nil];
    self.dataArray = [NSMutableArray arrayWithArray:resArray];
    [self.tableView reloadData];
    
}

-(void)createSubViews
{
    [self.view addSubview:self.buttonOne];
    [self.view addSubview:self.buttonTwo];
    [self.view addSubview:self.buttonThree];
    [self.view addSubview:self.buttonFour];
    [self.view addSubview:self.buttonFive];
    [self.view addSubview:self.tableView];
}

-(void)createAutoLayout
{
    self.buttonOne.frame = CGRectMake(10.0f, 80.0f, 60.0f,25.0f);
    self.buttonTwo.frame = CGRectMake(80.0f, 80.0f, 60.0f, 25.0f);
    self.buttonThree.frame = CGRectMake(150.0f, 80.0f, 60.0f, 25.0f);
    self.buttonFour.frame = CGRectMake(220.0f, 80.0f, 60.0f, 25.0f);
    self.buttonFive.frame = CGRectMake(290.0f, 80.0f, 60.0f, 25.0f);
    self.tableView.frame = CGRectMake(0.0f, 120.0f, self.view.frame.size.width,self.view.frame.size.height-120.0f);
    
}

//创建数据库(需要手动生成上下文，关联数据库)
-(void)createSqlite
{
    //1.创建模型对象
    //获取模型路径
    NSURL * modelURL = [[NSBundle mainBundle] URLForResource:@"Model" withExtension:@"momd"];
    //根据模型文件创建模型对象
    NSManagedObjectModel * model = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
    
    //2.创建持久化存储助理：数据库
    //利用模型对象创建助理对象
    NSPersistentStoreCoordinator * store = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:model];
    
    //数据库名称和路径
    NSString * docStr = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
    NSString * sqlPath = [docStr stringByAppendingPathComponent:@"coreData.sqlite"];
    NSLog(@"数据库Path = %@",sqlPath);
    
    //请求自动轻量级迁移（轻量级迁移适用于添加新表，添加新的实体，添加新的实体属性等系统能自己推断出来的迁移方式）
    NSDictionary * options = [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithBool:YES],NSMigratePersistentStoresAutomaticallyOption,[NSNumber numberWithBool:YES],NSInferMappingModelAutomaticallyOption, nil];
    
    NSURL *sqlUrl = [NSURL fileURLWithPath:sqlPath];
    NSError * error = nil;
    //设置数据库相关信息 添加一个持久化存储库并设置存储类型和路径，NSSQLiteStoreType:SQLite作为存储库
    [store addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:sqlUrl options:options error:&error];
    if(error){
        NSLog(@"添加数据库失败：%@",error);
    }else{
        NSLog(@"添加数据库成功");
    }
    
    //3.创建上下文 保存信息 操作数据库
    NSManagedObjectContext * context = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSMainQueueConcurrencyType];
    
    //关联持久化助理
    context.persistentStoreCoordinator = store;
    self.context = context;
    
}

#pragma mark - button click
//TODO:插入数据
-(void)insertDataClick
{
    //1.根据Entity名称和NSManagedObjectContext获取一个新的继承于NSManagedObject的子类Student
    Student * student = [NSEntityDescription insertNewObjectForEntityForName:@"Student" inManagedObjectContext:self.context];
    //2.根据表Student中的键值，给NSManagedObject对象赋值
    student.name = [NSString stringWithFormat:@"Mr_%d",arc4random()%100];
    student.age = arc4random()%20;
    student.sex = arc4random()%2 == 0 ? @"美女":@"帅哥";
    student.height = arc4random()%180;
    student.number = arc4random()%100;
    student.weight = arc4random()%100;
    
    //查询所有数据的请求
    NSFetchRequest * request = [NSFetchRequest fetchRequestWithEntityName:@"Student"];
    NSArray * resArray = [self.context executeFetchRequest:request error:nil];
    self.dataArray = [NSMutableArray arrayWithArray:resArray];
    [self.tableView reloadData];
    
    //3.保存插入的数据
    NSError * error = nil;
    if([self.context save:&error]){
        [self alertViewWithMessage:@"数据成功插入数据库"];
    }
    else{
        [self alertViewWithMessage:[NSString stringWithFormat:@"数据插入数据库失败：%@",error]];
    }
    
}

//TODO:删除数据
-(void)deleteDataClick
{
    //创建删除请求
    NSFetchRequest * deleteRequest = [NSFetchRequest fetchRequestWithEntityName:@"Student"];
    //删除条件
    NSPredicate * pre = [NSPredicate predicateWithFormat:@"number < %d",50];
    deleteRequest.predicate = pre;
    //返回需要删除的对象数组
    NSArray * deleteArray = [self.context executeFetchRequest:deleteRequest error:nil];
    //从数据库中删除
    for(Student * stu in deleteArray){
        [self.context deleteObject:stu];
    }
    
    //没有任何条件就是读取所有数据
    NSFetchRequest * request = [NSFetchRequest fetchRequestWithEntityName:@"Student"];
    NSArray * resArray = [self.context executeFetchRequest:request error:nil];
    self.dataArray = [NSMutableArray arrayWithArray:resArray];
    [self.tableView reloadData];
    
    NSError *error = nil;
    if([self.context save:&error]){
        [self alertViewWithMessage:@"删除number < 50的数据成功！"];
    }
    else{
        NSLog(@"删除数据失败：%@",error);
    }
    
}

//TODO:更新、修改数据
-(void)updateDataClick
{
    //创建查询请求
    NSFetchRequest * refreshRequest = [NSFetchRequest fetchRequestWithEntityName:@"Student"];
    NSPredicate * pre = [NSPredicate predicateWithFormat:@"sex = %@",@"帅哥"];
    refreshRequest.predicate = pre;
    //发送请求，返回需要更新的数据对象
    NSArray * refreshArray = [self.context executeFetchRequest:refreshRequest error:nil];
    //更新修改
    for(Student *stu in refreshArray){
        stu.name = @"dev_iOS";
        [self.context refreshObject:stu mergeChanges:YES];
    }
    
    //获取所有数据
    NSFetchRequest * request = [NSFetchRequest fetchRequestWithEntityName:@"Student"];
    NSArray * resArray = [self.context executeFetchRequest:request error:nil];
    self.dataArray = [NSMutableArray arrayWithArray:resArray];
    [self.tableView reloadData];
    
    //保存
    NSError * error = nil;
    if([self.context save:&error]){
        [self alertViewWithMessage:@"更新所有帅哥的名字为“dev_iOS”"];
    }
    else{
        NSLog(@"更新数据失败");
    }
    
}

//TODO:读取查询
-(void)readDataClick
{
    /* 谓词的条件指令
     1.比较运算符 > 、< 、== 、>= 、<= 、!=
     例：@"number >= 99"
     
     2.范围运算符：IN 、BETWEEN
     例：@"number BETWEEN {1,5}"
     @"address IN {'shanghai','nanjing'}"
     
     3.字符串本身:SELF
     例：@"SELF == 'APPLE'"
     
     4.字符串相关：BEGINSWITH、ENDSWITH、CONTAINS
     例：  @"name CONTAIN[cd] 'ang'"  //包含某个字符串
     @"name BEGINSWITH[c] 'sh'"    //以某个字符串开头
     @"name ENDSWITH[d] 'ang'"    //以某个字符串结束
     
     5.通配符：LIKE
     例：@"name LIKE[cd] '*er*'"   // *代表通配符,Like也接受[cd].
     @"name LIKE[cd] '???er*'"
     
     *注*: 星号 "*" : 代表0个或多个字符
     问号 "?" : 代表一个字符
     
     6.正则表达式：MATCHES
     例：NSString *regex = @"^A.+e$"; //以A开头，e结尾
     @"name MATCHES %@",regex
     
     注:[c]*不区分大小写 , [d]不区分发音符号即没有重音符号, [cd]既不区分大小写，也不区分发音符号。
     
     7. 合计操作
     ANY，SOME：指定下列表达式中的任意元素。比如，ANY children.age < 18。
     ALL：指定下列表达式中的所有元素。比如，ALL children.age < 18。
     NONE：指定下列表达式中没有的元素。比如，NONE children.age < 18。它在逻辑上等于NOT (ANY ...)。
     IN：等于SQL的IN操作，左边的表达必须出现在右边指定的集合中。比如，name IN { 'Ben', 'Melissa', 'Nick' }。
     
     提示:
     1. 谓词中的匹配指令关键字通常使用大写字母
     2. 谓词中可以使用格式字符串
     3. 如果通过对象的key
     path指定匹配条件，需要使用%K
     */
    
    //创造查询条件
    NSFetchRequest * request = [NSFetchRequest fetchRequestWithEntityName:@"Student"];
    //查询条件
    NSPredicate * pre = [NSPredicate predicateWithFormat:@"sex = %@",@"美女"];
    request.predicate = pre;
    // 从第几页开始显示
    // 通过这个属性实现分页
    //request.fetchOffset = 0;
    // 每页显示多少条数据
    //request.fetchLimit = 6;
    
    //发送查询请求，并返回结果
    NSArray * resArray = [self.context executeFetchRequest:request error:nil];
    self.dataArray = [NSMutableArray arrayWithArray:resArray];
    [self.tableView reloadData];
    
    [self alertViewWithMessage:@"查询所有的美女"];
    
}

//TODO:排序
-(void)sortClick
{
    //创建排序请求
    NSFetchRequest * request = [NSFetchRequest fetchRequestWithEntityName:@"Student"];
    //实例化排序对象
    NSSortDescriptor * ageSort = [NSSortDescriptor sortDescriptorWithKey:@"age" ascending:YES];
    NSSortDescriptor * numberSort = [NSSortDescriptor sortDescriptorWithKey:@"number" ascending:YES];
    request.sortDescriptors = @[ageSort,numberSort];
    
    //发送请求
    NSError * error = nil;
    NSArray * resArray = [self.context executeFetchRequest:request error:&error];
    
    self.dataArray = [NSMutableArray arrayWithArray:resArray];
    [self.tableView reloadData];
    
    if(error ==nil){
        [self alertViewWithMessage:@"按照age和number排序"];
    }
    else{
        NSLog(@"排序失败，%@",error);
    }
    
}

- (void)alertViewWithMessage:(NSString *)message{
    
    UIAlertController * alert = [UIAlertController alertControllerWithTitle:@"提示" message:message preferredStyle:UIAlertControllerStyleAlert];
    [self presentViewController:alert animated:YES completion:^{
        [NSThread sleepForTimeInterval:0.5];
        [alert dismissViewControllerAnimated:YES completion:nil];
    }];
}

#pragma mark - UITableViewDelegate&UITableViewDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.dataArray.count;
}
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *identifier = @"StudentCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    if(cell==nil){
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
    }
    if(self.dataArray.count>0){
        Student * student = self.dataArray[indexPath.row];
        cell.imageView.image = [UIImage imageNamed:([student.sex isEqualToString:@"美女"]?@"mei.jpeg":@"luo.jpg")];
        cell.textLabel.text = [NSString stringWithFormat:@" age = %d \n number = %d \n name = %@ \n sex = %@ \n weight = %d",student.age,student.number,student.name,student.sex,student.weight];
        cell.textLabel.numberOfLines = 0;
    }
    return cell;
}

#pragma mark - lazy init
@synthesize context = _context;

@synthesize buttonOne = _buttonOne;
-(UIButton *)buttonOne
{
    if(_buttonOne == nil){
        _buttonOne = [UIButton buttonWithType:UIButtonTypeSystem];
        [_buttonOne setTitle:@"插入" forState:UIControlStateNormal];
        [_buttonOne.titleLabel setFont:[UIFont systemFontOfSize:14.0f]];
        [_buttonOne setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
        [_buttonOne addTarget:self action:@selector(insertDataClick) forControlEvents:UIControlEventTouchUpInside];
    }
    return _buttonOne;
}

@synthesize buttonTwo = _buttonTwo;
-(UIButton *)buttonTwo
{
    if(_buttonTwo == nil){
        _buttonTwo = [UIButton buttonWithType:UIButtonTypeSystem];
        [_buttonTwo setTitle:@"删除" forState:UIControlStateNormal];
        [_buttonTwo.titleLabel setFont:[UIFont systemFontOfSize:14.0f]];
        [_buttonTwo setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
        [_buttonTwo addTarget:self action:@selector(deleteDataClick) forControlEvents:UIControlEventTouchUpInside];
    }
    return _buttonTwo;
}

@synthesize buttonThree = _buttonThree;
-(UIButton *)buttonThree
{
    if(_buttonThree == nil){
        _buttonThree = [UIButton buttonWithType:UIButtonTypeSystem];
        [_buttonThree setTitle:@"更新" forState:UIControlStateNormal];
        [_buttonThree.titleLabel setFont:[UIFont systemFontOfSize:14.0f]];
        [_buttonThree setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
        [_buttonThree addTarget:self action:@selector(updateDataClick) forControlEvents:UIControlEventTouchUpInside];
    }
    return _buttonThree;
}
@synthesize buttonFour = _buttonFour;
-(UIButton *)buttonFour
{
    if(!_buttonFour){
        _buttonFour = [UIButton buttonWithType:UIButtonTypeSystem];
        [_buttonFour setTitle:@"查询" forState:UIControlStateNormal];
        [_buttonFour.titleLabel setFont:[UIFont systemFontOfSize:14.0f]];
        [_buttonFour setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
        [_buttonFour addTarget:self action:@selector(readDataClick) forControlEvents:UIControlEventTouchUpInside];
    }
    return _buttonFour;
}
@synthesize buttonFive = _buttonFive;
-(UIButton *)buttonFive
{
    if(!_buttonFive){
        _buttonFive = [UIButton buttonWithType:UIButtonTypeSystem];
        [_buttonFive setTitle:@"排序" forState:UIControlStateNormal];
        [_buttonFive.titleLabel setFont:[UIFont systemFontOfSize:14.0f]];
        [_buttonFive setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
        [_buttonFive addTarget:self action:@selector(sortClick) forControlEvents:UIControlEventTouchUpInside];
    }
    return _buttonFive;
}
@synthesize tableView = _tableView;
-(UITableView *)tableView
{
    if (!_tableView) {
        _tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
        _tableView.backgroundColor = [UIColor whiteColor];
        _tableView.delegate = self;
        _tableView.dataSource = self;
        _tableView.rowHeight = 120.0f;
    }
    return _tableView;
}
@synthesize dataArray = _dataArray;
-(NSMutableArray *)dataArray
{
    if(!_dataArray){
        _dataArray = [[NSMutableArray alloc] initWithCapacity:0];
    }
    return _dataArray;
}

@end
