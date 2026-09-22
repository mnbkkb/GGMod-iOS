//
//  SearchResult.h
//  GGMod
//

#import <Foundation/Foundation.h>
#import <mach/mach.h>

@interface SearchResult : NSObject

@property (nonatomic, assign) mach_vm_address_t address;
@property (nonatomic, strong) NSNumber *value;
@property (nonatomic, assign) GGSearchDataType dataType;
@property (nonatomic, assign) BOOL locked;       // 是否锁定（冻结数值）
@property (nonatomic, strong) NSNumber *lockedValue; // 锁定值

- (instancetype)initWithAddress:(mach_vm_address_t)address
                          value:(NSNumber *)value
                       dataType:(GGSearchDataType)dataType;

@end
