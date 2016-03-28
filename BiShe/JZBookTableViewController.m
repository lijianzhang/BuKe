//
//  JZBookTableViewController.m
//  BiShe
//
//  Created by Jz on 15/12/22.
//  Copyright © 2015年 Jz. All rights reserved.
//

#import "JZBookTableViewController.h"
#import "JZNewWorkTool.h"
#import "JZBooksStore.h"
#import "MJExtension.h"
#import "JZTopBookTableViewCell.h"
#import "JZBooksStore.h"
#import "MJRefresh.h"
#import "JZBookCollectionViewController.h"
#import "JZBasicBookViewController.h"
#import "JZPromptView.h"
#import "JZHUD.h"
#define file [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES).firstObject stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.data",self.name]]

@interface JZBookTableViewController ()

@property (nonatomic, strong)NSMutableArray<JZBooksStore *> *section;
@property(nonatomic,strong)JZPromptView *promptView;/**<<#text#> */
@end

@implementation JZBookTableViewController

#pragma mark -懒加载
-(NSMutableArray<JZBooksStore *> *)section{
    if (!_section) {
        
        _section = [NSMutableArray array];
        for (int i=0; i<self.Category.count; i++) {
            [_section addObject:[JZBooksStore new]];
        }
    }
    return _section;
}
- (JZPromptView *)promptView{
    if (!_promptView) {
        _promptView = [JZPromptView prompt];
    }
    return _promptView;
}
#pragma mark -生命周期
- (void)viewDidLoad {
    [super viewDidLoad];
    MJRefreshNormalHeader *refresh = [MJRefreshNormalHeader headerWithRefreshingBlock:^{
        [self LoadData];
    }];
    refresh.lastUpdatedTimeLabel.hidden = YES;
    self.tableView.mj_header = refresh;
    
}
- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    if([NSKeyedUnarchiver unarchiveObjectWithFile:file] == nil){
        //    [self.tableView.mj_header beginRefreshing];
        [JZHUD showHUDandTitle:@""];
        [self LoadData];
    }else{
        self.section = [NSKeyedUnarchiver unarchiveObjectWithFile:file];
        [self.tableView reloadData];
    }
}


- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];

}


#pragma mark -其他
/**
 *  加载数据
 *
 */
- (void) LoadData{

    JZNewWorkTool *tool = [JZNewWorkTool workTool];

    
    dispatch_group_t group = dispatch_group_create();
    for (int i=0; i<self.Category.count;i++) {
        dispatch_group_enter(group);



        [tool dataWithCategory:self.Category[i][@"id"] start:@0 end:@3 success:^(id obj) {
            dispatch_group_leave(group);
                self.section[i] = obj;
        } fail:^(NSError *error) {
        }];
    }

    dispatch_group_notify(group, dispatch_get_main_queue(), ^{
        [self.tableView reloadData];
        [self.tableView.mj_header endRefreshing];
        [NSKeyedArchiver archiveRootObject:self.section toFile:file];
        [JZHUD showSuccessandTitle:@""];
    });

}



#pragma mark - Table view data source



- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    self.tableView.hidden = self.section.count == 0?YES:NO;
    return self.section.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    JZTopBookTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
    if (self.section[indexPath.row]) {
        cell.bookViewModels = self.section[indexPath.row].books;
        cell.category.text = self.Category[indexPath.row][@"name"];
        cell.tagWithButton = indexPath.row;
        __weak JZBookTableViewController * wself = self;
        cell.clickBlock = ^(NSInteger index){
            JZBasicBookViewController *vc = [[UIStoryboard storyboardWithName:@"Main" bundle:[NSBundle mainBundle]]instantiateViewControllerWithIdentifier:@"JZBasicBookViewController"];
            BookData *data = (BookData *)wself.section[indexPath.row].books[index];
            vc.idUrl = data.bookid;
            vc.imageUrl = data.book.image;
            [self.navigationController pushViewController:vc animated:YES];
        };
    }


    return cell;
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    
    if ([segue.identifier isEqualToString:@"bookTable2bookCollection"]) {
        UIButton *button = (UIButton*)sender;
        NSInteger number = button.tag - 100;
        JZBookCollectionViewController *vc = segue.destinationViewController;
        vc.contentData = self.Category[number];
        
    }
}

- (void)dealloc{
    NSLog(@"已销毁");
}


/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
