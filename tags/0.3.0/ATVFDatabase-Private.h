#import "ATVFDatabase.h"

@interface ATVFDatabase (Private)

-(BOOL)upgradeSchema;
-(BOOL)installSchemaVersion:(long)version;

@end