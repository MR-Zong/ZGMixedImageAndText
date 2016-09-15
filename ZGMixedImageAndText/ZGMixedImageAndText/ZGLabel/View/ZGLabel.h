//
//  ZGLabel.h
//  ZGTestFontLabel
//
//  Created by Zong on 16/9/6.
//  Copyright © 2016年 Zong. All rights reserved.
//

#import <UIKit/UIKit.h>


UIKIT_EXTERN NSString * const ZGTapAttributeName;

/**
 * tapAttribute 里可以设置的属性
 **/
UIKIT_EXTERN NSString * const ZGTapColorAttributeStateNormal;
UIKIT_EXTERN NSString * const ZGTapColorAttributeStateHighLighted;


@class ZGAttributeModel;
@class ZGLabel;


@protocol ZGLabelDelegate <NSObject>

- (void)label:(ZGLabel *)label didTapWithModel:(ZGAttributeModel *)model;
- (void)label:(ZGLabel *)label didLongPressWithModel:(ZGAttributeModel *)model;

@end

@interface ZGAttributeModel : NSObject

@property (nonatomic, strong) id value;
@property (nonatomic, assign) NSRange range;
+ (instancetype)attributeModelWithValue:(id)value range:(NSRange)range;

@end





@interface ZGLabel : UILabel

/**
 * 设置一些属性，例如：可以点击文字颜色，长按背景颜色
 **/
@property (nonatomic, copy) NSDictionary *tapAttribute;

/**
 * 长按背景颜色是否开启
 **/
@property (nonatomic, assign) BOOL highLightedColorEnable;

/**
 * 代理：点击文字，长按文字后，会回调代理
 **/
@property (nonatomic, weak) id <ZGLabelDelegate> delegate;

@end
