//
//  NSData+SDTData.m
//  Sound Tweak 2
//
//  Created by Skylar Schipper on 11/8/13.
//  Copyright (c) 2013 OpenSky, LLC. All rights reserved.
//

#import "NSData+SDTData.h"

@implementation NSData (SDTData)

+ (NSData *)dataWithMediaItem:(MPMediaItem *)item {
    @autoreleasepool {
        // Get raw PCM data from the track
        NSURL *assetURL = [item valueForProperty:MPMediaItemPropertyAssetURL];
        NSMutableData *data = [[NSMutableData alloc] init];
        
        const uint32_t sampleRate = 16000; // 16k sample/sec
        const uint16_t bitDepth = 16; // 16 bit/sample/channel
        
        NSDictionary *opts = [NSDictionary dictionary];
        AVURLAsset *asset = [[AVURLAsset alloc] initWithURL:assetURL options:opts];
        AVAssetReader *reader = [[AVAssetReader alloc] initWithAsset:asset error:NULL];
        NSDictionary *settings = @{
                                   AVFormatIDKey: @(kAudioFormatLinearPCM),
                                   AVSampleRateKey: @(sampleRate),
                                   AVLinearPCMBitDepthKey: @(bitDepth),
                                   AVLinearPCMIsNonInterleaved: @NO,
                                   AVLinearPCMIsFloatKey: @NO,
                                   AVLinearPCMIsBigEndianKey: @NO
                                   };
        
        AVAssetReaderTrackOutput *output = [[AVAssetReaderTrackOutput alloc] initWithTrack:[asset.tracks firstObject] outputSettings:settings];
        [reader addOutput:output];
        [reader startReading];
        
        while ([reader status] != AVAssetReaderStatusCompleted) {
            CMSampleBufferRef buffer = [output copyNextSampleBuffer];
            if (buffer == NULL) continue;
            
            CMBlockBufferRef blockBuffer = CMSampleBufferGetDataBuffer(buffer);
            size_t size = CMBlockBufferGetDataLength(blockBuffer);
            uint8_t *outBytes = malloc(size);
            CMBlockBufferCopyDataBytes(blockBuffer, 0, size, outBytes);
            CMSampleBufferInvalidate(buffer);
            CFRelease(buffer);
            [data appendBytes:outBytes length:size];
            free(outBytes);
        }
        
        return [NSData dataWithData:data];
    }
}

@end
