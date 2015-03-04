//
//  AcTableView.m
//  AcTableView-Demo
//
//  Created by Ancc on 15/2/13.
//  Copyright (c) 2015年 Ancc. All rights reserved.
//

#import "AcTableView.h"
#import <CommonCrypto/CommonHMAC.h>//md5需要

#pragma mark block存储相关
@interface AcHeadEntity:NSObject
@property (nonatomic,copy)AcHeadViewBlock viewBlock;
+(instancetype)entity:(AcHeadViewBlock)viewBlock;
@end
@implementation AcHeadEntity
+(instancetype)entity:(AcHeadViewBlock)viewBlock
{
    return ({
        AcHeadEntity *entity = [AcHeadEntity new];
        entity.viewBlock = viewBlock;
        //非空处理,传入block为空时,head显示为空
        if(entity.viewBlock==nil)
        {
            entity.viewBlock=^AcHeaderView*{
                return nil;
            };
        }
        entity;
    });
}
@end
@interface AcFootEntity:NSObject
@property (nonatomic,copy)AcFootViewBlock viewBlock;
+(instancetype)entity:(AcFootViewBlock)viewBlock;
@end
@implementation AcFootEntity
+(instancetype)entity:(AcFootViewBlock)viewBlock
{
    return ({
        AcFootEntity *entity = [AcFootEntity new];
        entity.viewBlock = viewBlock;
        if(entity.viewBlock==nil)
        {
            entity.viewBlock=^AcFooterView*{
                return nil;
            };
        }
        entity;
    });
}
@end
@interface AcContentEntity:NSObject
@property (nonatomic,copy)AcContentViewBlock viewBlock;
@property (nonatomic,copy)AcContentEventBlock eventBlock;
+(instancetype)entity:(AcContentViewBlock)viewBlock;
+(instancetype)entity:(AcContentViewBlock)viewBlock eventBlock:(AcContentEventBlock)eventBlock;
@end
@implementation AcContentEntity
+(instancetype)entity:(AcContentViewBlock)viewBlock
{
    return [self entity:viewBlock eventBlock:nil];
}
+(instancetype)entity:(AcContentViewBlock)viewBlock eventBlock:(AcContentEventBlock)eventBlock
{
    return ({
        AcContentEntity *entity = [AcContentEntity new];
        entity.viewBlock = viewBlock;
        entity.eventBlock= eventBlock;
        entity;
    });
}
@end
//主要视图管理类
@interface AcEntityModel : NSObject
@property (nonatomic,strong)AcHeadEntity *headEntity;
/**AcContentEntity数组,head对应的子cell*/
@property (nonatomic,strong)NSMutableArray *contentEntitys;
/**AcFootEntity*/
@property (nonatomic,strong)AcFootEntity *footEntity;
+(instancetype)newModel:(AcHeadViewBlock)viewBlock;
-(void)addContentEntitysObject:(AcContentEntity *)entity;
@end
@implementation AcEntityModel
+(instancetype)newModel:(AcHeadViewBlock)viewBlock
{
    return ({
        AcEntityModel *model = [AcEntityModel new];
        model.headEntity=[AcHeadEntity entity:viewBlock];
        model;
    });
}
-(void)addContentEntitysObject:(AcContentEntity *)entity
{
    if(self.contentEntitys==nil)
    {
        self.contentEntitys = [NSMutableArray new];
    }
    [self.contentEntitys addObject:entity];
}
@end

#pragma mark 视图相关实体类
@implementation AcTableViewCell
@end

@implementation AcView
-(instancetype)initWithHeight:(CGFloat)height
{
    return [super initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, height)];
}
@end

@implementation AcHeaderView
@end
@implementation AcFooterView
@end
@implementation AcContentView
@end

///////////////////////////////////////////////////////////////////////////////////////////
#pragma mark 工具类
@interface AcTool:NSObject
/**
 *  生成一段随机字符串
 *
 *  @param length 需要的长度
 */
+(NSString *)radomKey:(NSInteger)length;
/**
 *  md5处理函数
 */
+(NSString *)md5:(NSString *)inputString;
/**
 *  警告框,用户入参错误时候的提示
 */
+(void)showAlertView:(NSString *)message;
@end
@implementation AcTool
+(NSString *)radomKey:(NSInteger)length
{
    //密钥获取源,在每取走一个字符后将字符串对应字符删除,确保密钥不会重复
    NSString *basicsKey=@"ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+-*/,.`~!@$^&()=";
    //密钥
    NSMutableString *key=[NSMutableString new];
    //根据入参获取对应长度的字符串密钥
    for(int i=0;i<length&&basicsKey.length>0;i++)
    {
        //初始化随机数
        srand((unsigned)time(0));
        //获取随机数
        int randInt=(arc4random());
        //下标
        randInt%= basicsKey.length;
        //获取对应的密钥字符
        NSString *nKey=[basicsKey substringWithRange:NSMakeRange(randInt, 1)];
        //密钥拼接
        [key appendString:nKey];
        //密钥源处理,删除可能重复的字符
        NSMutableString *tempbasicsKey=basicsKey.mutableCopy;
        [tempbasicsKey deleteCharactersInRange:NSMakeRange(randInt, 1)];
        basicsKey=tempbasicsKey.copy;
        
    }
    return key?key:@"";
}
+(NSString *)md5:(NSString *)inputString
{
    const char *cStr = [inputString UTF8String];
    unsigned char digest[16];
    CC_MD5( cStr, strlen(cStr), digest ); // This is the md5 call
    NSMutableString *output = [NSMutableString stringWithCapacity:16 * 2];
    for(int i = 0; i < 16; i++)
    {
        [output appendFormat:@"%02x", digest[i]];
    }
    return output;
}
/**
 *  警告框
 */
+(void)showAlertView:(NSString *)message
{
    UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:@"警告"
                                                       message:message?message:@"message"
                                                      delegate:nil
                                             cancelButtonTitle:@"确定"
                                             otherButtonTitles:nil, nil];
    [alertView show];
}
@end


///////////////////////////////////////////////////////////////////////////////////////////
#pragma mark 主要视图类
@interface AcTableView()<UITableViewDataSource,UITableViewDelegate>
/**cell重用标识符*/
@property (nonatomic,strong)NSString *cellIdentifier;
/**head视图数据实体数组*/
@property (nonatomic,strong)NSMutableArray *entityModelList;
///**内容视图数据实体数组*/
//@property (nonatomic,strong)NSArray *contentEntityList;
@end
@implementation AcTableView
#pragma mark -- 构造tableview
-(instancetype)init
{
    self = [super initWithFrame:CGRectZero style:UITableViewStylePlain];
    [self resetIdentifier];
    self.delegate=self;
    self.dataSource=self;
    self.backgroundColor=[UIColor clearColor];
    self.tableFooterView=[UIView new];
    return self;
}
/**
 * 初始化化方式,暂时不支持自定义UITableViewStyle
 *
 *  @author Anccccccc, 15-02-13 14:02:17
 *
 *  @param frame    显示范围
 */
-(instancetype)initWithFrame:(CGRect)frame
{
    return ({
        self = [self init];
        self.frame=frame;
        self;
    });
}
/**
 *  增加一个head视图,之后添加的cell都划分为该head视图下
 */
-(void)addHeadView:(AcHeadViewBlock)headViewBlock
{
    AcEntityModel *entity = [AcEntityModel newModel:headViewBlock];
    if(self.entityModelList==nil)
    {
        self.entityModelList = [NSMutableArray new];
    }
    [self.entityModelList addObject:entity];
}
/**
 *  添加一个foot视图,只添加在当前的head对应的视图上面,重复添加会重置原来的foot视图block
 */
-(void)addFootView:(AcFootViewBlock)footViewBlock
{
    if(self.entityModelList.count==0)
    {
        [self addHeadView:nil];
    }
    AcEntityModel *headEntity = self.entityModelList.lastObject;
    headEntity.footEntity=[AcFootEntity entity:footViewBlock];
}

/**
 *  添加一个视图到cell上面,具体加载在内部控制
 *      注意所有block使用外部变量都需要使用弱引用
 */
-(void)addCellView:(AcContentViewBlock)contentViewBlock
{
    [self addCellView:contentViewBlock touchEvent:nil];
}
/**
 *  添加一个视图到cell上面,具体加载在内部控制
 *  添加视图对应的点击回调函数,回调函数使用不同存储方式
 *      注意所有block使用外部变量都需要使用弱引用
 */
-(void)addCellView:(AcContentViewBlock)contentViewBlock
        touchEvent:(AcContentEventBlock)eventBlock;
{
    if(contentViewBlock == nil)
    {
        [AcTool showAlertView:@"contentViewBlock == nil"];
        return;
    }
    if(self.entityModelList.count==0)
    {
        [self addHeadView:nil];
    }
    AcEntityModel *headEntity = self.entityModelList.lastObject;
    AcContentEntity *entity = [AcContentEntity entity:contentViewBlock eventBlock:eventBlock];
    [headEntity addContentEntitysObject:entity];
}

/**
 *  重置cell重用标识符
 */
-(void)resetIdentifier
{
    self.cellIdentifier = [AcTool radomKey:16];
}
/**
 *  刷新tableView视图
 */
-(void)reloadData
{
    [super reloadData];
}
#pragma mark -- tableview-delegate
-(AcEntityModel *)entityModelWithIndex:(NSInteger)index
{
    if(self.entityModelList.count>index)
    {
        AcEntityModel *headEntity = self.entityModelList[index];
        return headEntity;
    }else{
        [AcTool showAlertView:@"entityModelList 长度错误"];
        return nil;
    }
}
-(UIView *)headView:(NSInteger)section
{
    AcHeadEntity *headEntity = [self entityModelWithIndex:section].headEntity;
    if(headEntity.viewBlock==nil)
    {
        [AcTool showAlertView:@"headEntity viewBlock == nil"];
        return nil;
    }else{
        return headEntity.viewBlock();
    }
}
-(UIView *)footView:(NSInteger)section
{
    AcFootEntity *footEntity = [self entityModelWithIndex:section].footEntity;
    if(footEntity==nil)
    {
        return nil;//[UIView new];//[[UIView alloc]initWithFrame:CGRectZero];
    }else   if(footEntity.viewBlock==nil){
        [AcTool showAlertView:@"footEntity viewBlock == nil"];
        return nil;
    }else{
        return footEntity.viewBlock();
    }
}
-(AcContentEntity *)contentEntityWithIndex:(NSIndexPath *)indexPath
{
    if(self.entityModelList.count<=indexPath.section)
    {
        [AcTool showAlertView:@"entityModelList 长度错误"];
        return nil;
    }
    AcEntityModel *headEntity = self.entityModelList[indexPath.section];
    if(headEntity.contentEntitys.count<=indexPath.row)
    {
        [AcTool showAlertView:@"headEntity.contentEntitys 长度错误"];
        return nil;
    }
    return headEntity.contentEntitys[indexPath.row];
}
-(UIView *)contentView:(NSIndexPath *)indexPath
{
    return [self contentView:indexPath paramCell:nil];
}
-(UIView *)contentView:(NSIndexPath *)indexPath paramCell:(UITableViewCell *)cell
{
    AcContentEntity *contentEntity = [self contentEntityWithIndex:indexPath];
    if(contentEntity.viewBlock==nil)
    {
        [AcTool showAlertView:@"contentEntity viewBlock == nil"];
        return nil;
    }else{
        return contentEntity.viewBlock(cell);
    }
}

-(AcContentEventBlock)contentEvent:(NSIndexPath *)indexPath
{
    AcContentEntity *contentEntity = [self contentEntityWithIndex:indexPath];
    return contentEntity.eventBlock;
}
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if(self.entityModelList.count>section)
    {
        AcEntityModel *headEntity = self.entityModelList[section];
        return headEntity.contentEntitys.count;
    }else{
        [AcTool showAlertView:@"entityModelList 长度错误"];
        return 0;
    }
}
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return self.entityModelList.count;
}
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *indentifier = [NSString stringWithFormat:@"%@_%zd_%zd_%zd",NSStringFromClass(self.class),indexPath.section,indexPath.row,self.cellIdentifier];
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:indentifier];
    if(!cell)
    {
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:indentifier];
        cell.backgroundColor=[UIColor clearColor];
        [cell addSubview:[self contentView:indexPath paramCell:cell]];
    }
    return cell;
}
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    AcContentEventBlock eventBlock = [self contentEvent:indexPath];
    if(eventBlock)
    {
        eventBlock(tableView);
    }
}
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return [self contentView:indexPath].frame.size.height;
}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return [self headView:section].frame.size.height;
}
-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    return [self headView:section];
}
-(CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return [self footView:section].frame.size.height;
}
-(UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section
{
    return [self footView:section];
}
@end


///////////////////////////////////////////////////////////////////////////////////////////


