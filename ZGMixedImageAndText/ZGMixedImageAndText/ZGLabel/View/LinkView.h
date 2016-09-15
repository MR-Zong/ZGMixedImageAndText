//
//  LinkView.h
//  ZGMixedImageAndText
//
//  Created by 徐宗根 on 16/9/10.
//  Copyright © 2016年 Zong. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreText/CoreText.h>


typedef enum{
    CLICK_TYPE_NONE = 0,
    CLICK_TYPE_LINK ,
    CLICK_TYPE_PHONE,
}CLICK_TYPE;

@interface LinkView : UIView

{
    CTFrameRef _frame;
    NSInteger clickNum;
    BOOL isClick;
    CLICK_TYPE clickType;
}

@property (assign, nonatomic) CLICK_TYPE clickType;
@property (assign, nonatomic) BOOL isClick;
@property (assign, nonatomic) NSInteger clickNum;//点击的位置
@property (retain, nonatomic) NSString *text;
@property (retain, nonatomic) NSArray *linkArray;//存链接的Range数组
@property (retain, nonatomic) NSArray *phoneArray;//存电话号码的Range数组

@end