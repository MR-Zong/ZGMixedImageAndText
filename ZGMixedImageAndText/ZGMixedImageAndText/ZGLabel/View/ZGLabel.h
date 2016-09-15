//
//  ZGLabel.h
//  ZGTestFontLabel
//
//  Created by Zong on 16/9/6.
//  Copyright © 2016年 Zong. All rights reserved.
//

#import <UIKit/UIKit.h>


UIKIT_EXTERN NSString * const ZGTapAttributeName;

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

@property (nonatomic, copy) NSDictionary *tapAttribute;
@property (nonatomic, assign) BOOL highLightedColorEnable;
@property (nonatomic, weak) id <ZGLabelDelegate> delegate;

@end
