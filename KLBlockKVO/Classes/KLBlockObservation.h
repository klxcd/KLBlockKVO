//
//  KLBlockObservation.h
//  KLBlockKVO
//
//  Created by 刘昌大 on 2023/6/5.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface KLBlockObservation : NSObject

@property (nonatomic, weak, readonly) __kindof NSObject *target;

@property (nonatomic, copy, readonly) NSString *keyPath;

@property (nonnull, copy, readonly) void (^changed)(void (^)(id newValue, id oldValue));

@property (nonatomic, copy, readonly) void (^remove)(void);

- (instancetype)initWithTarget:(__kindof NSObject *)target keyPath:(NSString *)keyPath;

- (instancetype)init NS_UNAVAILABLE;

@end

NS_ASSUME_NONNULL_END
