//
//  NSObject+KLBlockKVO.h
//  KLBlockKVO
//
//  Created by 刘昌大 on 2023/6/5.
//

#import <Foundation/Foundation.h>
#import "KLBlockObservation.h"

NS_ASSUME_NONNULL_BEGIN

@interface NSObject (KLBlockKVO)

@property (nonatomic, copy, readonly) KLBlockObservation *(^kl_obs)(__kindof NSObject *target, NSString *keyPath);

@end

NS_ASSUME_NONNULL_END
