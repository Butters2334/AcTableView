//
//  AcTableView.h
//  AcTableView-Demo
//
//  Created by Ancc on 15/2/13.
//  Copyright (c) 2015年 Ancc. All rights reserved.
//

#import <UIKit/UIKit.h>

/**
    传出视图实体
 */
@interface AcTableViewCell:UITableViewCell
@end

/**
 *   外部传入视图实体
 */
@interface AcView:UIView
-(instancetype)initWithHeight:(CGFloat)height;
@end
/**
    头部视图实体
 */
@interface AcHeaderView : AcView
@end
/**
    内容视图实体
 */
@interface AcContentView :AcView
@end

///////////////////////////////////////////////////////////////////////////////////////////

//头部视图构成block
typedef AcHeaderView*(^AcHeadViewBlock)(void);
//内容视图构成block
typedef AcContentView*(^AcContentViewBlock)(void);
//typedef AcContentView*(^AcContentViewBlock)(UITableViewCell *cell);
//内容视图点击block
typedef void(^AcContentEventBlock)(void);
//typedef void(^AcContentEventBlock)(UITableViewCell *cell);

/**
 * 通过调用函数添加子cell块,可添加head块或者cell块,根据顺序
 */
@interface AcTableView : UITableView
/**
 * 初始化化方式,暂时不支持自定义UITableViewStyle
 */
-(instancetype)initWithFrame:(CGRect)frame;
/**
 *  增加一个head视图,之后添加的cell都划分为该head视图下
 */
-(void)addHeadView:(AcHeadViewBlock)headViewBlock;
/**
 *  添加一个视图到cell上面,具体加载在内部控制
 *      注意所有block使用外部变量都需要使用弱引用
 */
-(void)addCellView:(AcContentViewBlock)contentViewBlock;
/**
 *  添加一个视图到cell上面,具体加载在内部控制
 *  添加视图对应的点击回调函数,回调函数使用不同存储方式
 *      注意所有block使用外部变量都需要使用弱引用
 */
-(void)addCellView:(AcContentViewBlock)contentViewBlock
        touchEvent:(AcContentEventBlock)eventBlock;
/**
 *  重置cell重用标识符-视图添加成功后,二次调用都
 */
-(void)resetIdentifier;
/**
 *  刷新tableView视图
 *      初始化之外的所有视图更新操作,都需要刷新tableView视图才能重载;
 *      调用该函数前,自行判断是否需要使用重置identifier标识符
 */
-(void)reloadData;
@end
