//
//  NSObject+KLBlockKVO.m
//  KLBlockKVO
//
//  Created by 刘昌大 on 2023/6/5.
//

#import "NSObject+KLBlockKVO.h"
#import <objc/runtime.h>

@interface KLBlockObservation ()

@property (nonatomic, copy) void (^removeHandler)(void);

@end

@interface NSObject ()

@property (nonatomic, strong, readonly) NSMutableArray<KLBlockObservation *> *kl_observations;

@end

@implementation NSObject (KLBlockKVO)

- (NSMutableArray<KLBlockObservation *> *)kl_observations {
    @synchronized (self) {
        NSMutableArray<KLBlockObservation *> *observations = objc_getAssociatedObject(self, @selector(kl_observations));
        if (!observations) {
            observations = [NSMutableArray array];
            objc_setAssociatedObject(self, @selector(kl_observations), observations, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
        }
        return observations;
    }
}

- (KLBlockObservation * _Nonnull (^)(__kindof NSObject * _Nonnull, NSString * _Nonnull))kl_obs {
    KLBlockObservation *(^obs)(__kindof NSObject *, NSString *) = ^(__kindof NSObject *target, NSString *keyPath) {
        @synchronized (self) {
            __block KLBlockObservation *observation = nil;
            [self.kl_observations enumerateObjectsUsingBlock:^(KLBlockObservation * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                if ([obj.target isEqual:target] && [obj.keyPath isEqualToString:keyPath]) {
                    observation = obj;
                }
            }];
            if (observation) {
                [self.kl_observations removeObject:observation];
            }
            observation = [[KLBlockObservation alloc] initWithTarget:target keyPath:keyPath];
            [self.kl_observations addObject:observation];
            __weak typeof(self) weakSelf = self;
            __weak typeof(observation) weakObservation = observation;
            observation.removeHandler = ^{
                NSMutableArray *removeObservations = [NSMutableArray array];
                [weakSelf.kl_observations enumerateObjectsUsingBlock:^(KLBlockObservation * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                    if ([obj.target isEqual:target] && [obj.keyPath isEqualToString:keyPath]) {
                        [removeObservations addObject:obj];
                    }
                }];
                [weakSelf.kl_observations removeObjectsInArray:removeObservations];
            };
            return observation;
        }
    };
    return obs;
}

@end
