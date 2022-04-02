

#import "HookIssues.h"
#import "TestHeaders.h"
#import "TKClassHooker.h"

@implementation A

-(void)printSun{
    NSLog(@">>> sun");
}

@end

@implementation A(Hook)

+(void)load{
    [TKClassHooker exchangeOriginMethod:@selector(printSun) newMethod:@selector(a_hk_printSun) mclass:[self class]];
}

-(void)a_hk_printSun{
    [self a_hk_printSun];
    NSLog(@">>> A (Hook) do hk %@", self.class);
}

@end

@implementation A(Hook2)

+(void)load{
    [TKClassHooker exchangeOriginMethod:@selector(printSun) newMethod:@selector(a_hk2_printSun) mclass:[self class]];
}

-(void)a_hk2_printSun{
    [self a_hk2_printSun];
    NSLog(@">>> A (Hook 2) do hk %@", self.class);
}

@end

@implementation AA

-(void)printSun{
    [super printSun];
    NSLog(@">>> AA do printSun %@", self.class);
}

@end

@implementation AA(Hook)

+(void)load{
    [TKClassHooker exchangeOriginMethod:@selector(printSun) newMethod:@selector(aa_hk_printSun) mclass:[self class]];
}

-(void)aa_hk_printSun{
    [self aa_hk_printSun];
    NSLog(@">>> AA (Hook) do hk %@", self.class);
}

@end

@implementation AA(Hook2)

+(void)load{
    [TKClassHooker exchangeOriginMethod:@selector(printSun) newMethod:@selector(aa_hk2_printSun) mclass:[self class]];
}

-(void)aa_hk2_printSun{
    [self aa_hk2_printSun];
    NSLog(@">>> AA (Hook 2) do hk %@", self.class);
}

@end
