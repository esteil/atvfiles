@interface ATVFMediaAsset (Private)
-(void)_loadMetadata;
-(void)_saveMetadata;
-(void)_populateMetadata:(BOOL)isNew;
-(NSString *)_metadataXmlPath;
-(NSString *)_coverArtPath;
@end

