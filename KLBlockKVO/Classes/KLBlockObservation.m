//
//  KLBlockObservation.m
//  KLBlockKVO
//
//  Created by 刘昌大 on 2023/6/5.
//

#import "KLBlockObservation.h"

@interface KLBlockObservation ()

@property (nonatomic, weak) __kindof NSObject *target;

@property (nonatomic, copy) NSString *keyPath;

@property (nonatomic, copy) void (^changedHandler)(id newValue, id oldValue);

@property (nonatomic, weak) NSOperationQueue *queue;

@property (nonatomic, copy) void (^removeHandler)(void);

@end

@implementation KLBlockObservation

- (instancetype)initWithTarget:(__kindof NSObject *)target keyPath:(NSString *)keyPath {
    if (self = [super init]) {
        _target = target;
        _keyPath = keyPath;
    }
    return self;
}

- (void (^)(void (^ _Nonnull)(id _Nonnull, id _Nonnull)))changed {
    void (^changed)(void (^)(id, id)) = ^(void (^handler)(id, id)) {
        self.changedHandler = handler;
        if (self.changedHandler && self.target) {
            if (!self.queue) {
                self.queue = NSOperationQueue.currentQueue;
            }
            [self.target addObserver:self forKeyPath:self.keyPath options:NSKeyValueObservingOptionInitial|NSKeyValueObservingOptionNew|NSKeyValueObservingOptionOld context:nil];
        }
    };
    return changed;
}

- (void)dealloc {
    if (self.target) {
        [self.target removeObserver:self forKeyPath:self.keyPath context:nil];
    }
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context {
    if (self.changedHandler) {
        if (!self.queue) {
            self.queue = NSOperationQueue.mainQueue;
        }
        [self.queue addOperationWithBlock:^{
            id newValue = change[NSKeyValueChangeNewKey];
            id oldValue = change[NSKeyValueChangeOldKey];
            self.changedHandler(newValue, oldValue);
        }];
    }
}

- (void (^)(void))remove {
    void (^remove)(void) = ^{
        if (self.removeHandler) {
            self.removeHandler();
            self.removeHandler = nil;
        }
    };
    return remove;
}

@end
