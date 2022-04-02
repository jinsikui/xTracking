

#import "TestLogger.h"
#import "TestHeaders.h"


@interface TestLogger()
@property(nonatomic, copy) NSString *logFilePath;
@end

@implementation TestLogger

+(instancetype)shared{
    static TestLogger *instance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[TestLogger alloc] init];
    });
    return instance;
}

-(instancetype)init{
    self = [super init];
    if(self){
        _logFilePath = [xFile documentPath:@"LOG.txt"];
    }
    return self;
}

-(void)log:(NSString*)str{
    [xFile createFileIfNotExistsAtPath:_logFilePath];
    NSString *logStr = [str stringByAppendingString:@"\n"];
    [xFile appendText:logStr toFile:_logFilePath];
}

-(void)clearLog{
    if(![xFile fileExistsAtPath:_logFilePath]){
        return;
    }
    [xFile deleteFileOfPath:_logFilePath];
    [xFile createFileIfNotExistsAtPath:_logFilePath];
}

-(NSString*)readAllLog{
    if(![xFile fileExistsAtPath:_logFilePath]){
        return @"";
    }
    NSString *log = [[NSString alloc] initWithData:[xFile getDataFromFileOfPath:_logFilePath] encoding:NSUTF8StringEncoding];
    return log;
}

@end
