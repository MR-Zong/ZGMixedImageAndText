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
UIKIT_EXTERN NSString * const ZGTapColorAttributeStateHeightLight;

@interface ZGLabel : UILabel


@property (nonatomic, copy) NSDictionary *tapAttribute;

@end
