//
//  TeamContainerLoader.m
//  FM10SX
//
//  Created by Amy Kettlewell on 09/10/25.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "TeamContainerLoader.h"
#import "ColourLoader.h"
#import "RelationshipLoader.h"
#import "AlternativeStadiumLoader.h"
#import "AlternativeKitLoader.h"
#import "Unknown1Loader.h"
#import	"FMString.h"
#import "TransferInfoLoader.h"

@implementation TeamContainerLoader

+ (id)readFromData:(NSData *)data atOffset:(unsigned int *)byteOffset
{
	char cbuffer;
	short sbuffer;
	int ibuffer;
	BOOL debug = NO;
	NSMutableArray *tempArray;
	
	unsigned int offset = *byteOffset;
	
	TeamContainer *object = [[TeamContainer alloc] init];
	
	[data getBytes:&cbuffer range:NSMakeRange(offset, 1)]; offset += 1;
	[object setTeamContainerType:cbuffer];
	[data getBytes:&cbuffer range:NSMakeRange(offset, 1)]; offset += 1;
	[object setNameGender:cbuffer];
	[data getBytes:&cbuffer range:NSMakeRange(offset, 1)]; offset += 1;
	[object setShortNameGender:cbuffer];
	[object setName:[FMString readFromData:data atOffset:&offset]];
	[object setShortName:[FMString readFromData:data atOffset:&offset]];
	
	[data getBytes:&cbuffer range:NSMakeRange(offset, 1)]; offset += 1;
	tempArray = [[NSMutableArray alloc] init];
	for (int i=0;i<cbuffer;i++) {
		id colour = [ColourLoader readColourFromData:data atOffset:&offset extended:YES];
		if ([[colour className] isEqualToString:@"Colour"]) {
			[tempArray addObject:colour];
		}
		else { return [NSString stringWithFormat:@"Kit - %@",colour]; }
	}
	[object setColours:tempArray];
	[tempArray release];
	
	[data getBytes:&cbuffer range:NSMakeRange(offset, 1)]; offset += 1;
	tempArray = [[NSMutableArray alloc] init];
	for (int i=0;i<cbuffer;i++) {
		[data getBytes:&ibuffer range:NSMakeRange(offset, 4)]; offset += 4;
		[tempArray addObject:[NSNumber numberWithInt:ibuffer]];
	}
	[object setTeams:tempArray];
	[tempArray release];
	
	[data getBytes:&cbuffer range:NSMakeRange(offset, 1)]; offset += 1;
	if (cbuffer>0 && debug) { NSLog(@"mystery count 1 > 0 at %d",offset); }
	
	tempArray = [[NSMutableArray alloc] init];
	for (int i=0;i<cbuffer;i++) {
		[data getBytes:&ibuffer range:NSMakeRange(offset, 4)]; offset += 4;
		[tempArray addObject:[NSNumber numberWithInt:ibuffer]];
	}
	[object setUnknowns1:tempArray];
	[tempArray release];
	
	[data getBytes:&cbuffer range:NSMakeRange(offset, 1)]; offset += 1;
	if (cbuffer>0 && debug) { NSLog(@"mystery count 3 > 0 at %d",offset); }
	
	tempArray = [[NSMutableArray alloc] init];
	for (int i=0;i<cbuffer;i++) {
		[data getBytes:&ibuffer range:NSMakeRange(offset, 4)]; offset += 4;
		[tempArray addObject:[NSNumber numberWithInt:ibuffer]];
	}
//	[object setUnknowns3:tempArray];
	[tempArray release];
	
	[data getBytes:&cbuffer range:NSMakeRange(offset, 1)]; offset += 1;
	if (cbuffer>0 && debug) { NSLog(@"mystery count 4 > 0 at %d",offset); }
	
	tempArray = [[NSMutableArray alloc] init];
	for (int i=0;i<cbuffer;i++) {
		[data getBytes:&ibuffer range:NSMakeRange(offset, 4)]; offset += 4;
		[tempArray addObject:[NSNumber numberWithInt:ibuffer]];
	}
//	[object setUnknowns4:tempArray];
	[tempArray release];
	
	[data getBytes:&cbuffer range:NSMakeRange(offset, 1)]; offset += 1;
	tempArray = [[NSMutableArray alloc] init];
	for (int i=0;i<cbuffer;i++) {
		[tempArray addObject:[RelationshipLoader readFromData:data atOffset:&offset]];
	}
	[object setRelationships:tempArray];
	[tempArray release];
	
	[data getBytes:&sbuffer range:NSMakeRange(offset, 2)]; offset += 2;
	tempArray = [[NSMutableArray alloc] init];
	for (int i=0;i<sbuffer;i++) {
		[tempArray addObject:[AlternativeStadiumLoader readFromData:data atOffset:&offset]];
	}
	[object setAlternativeStadiums:tempArray];
	[tempArray release];
	
	[data getBytes:&cbuffer range:NSMakeRange(offset, 1)]; offset += 1;
	if (cbuffer>0 && debug) { NSLog(@"mystery count 2 > 0 at %d",offset); }
	tempArray = [[NSMutableArray alloc] init];
	for (int i=0;i<cbuffer;i++) {
		[tempArray addObject:[Unknown1Loader readFromData:data atOffset:&offset]];
	}
	[object setUnknowns2:tempArray];
	[tempArray release];
	
	[data getBytes:&cbuffer range:NSMakeRange(offset, 1)]; offset += 1;
	[object setAttacking:cbuffer];
	[data getBytes:&cbuffer range:NSMakeRange(offset, 1)]; offset += 1;
	[object setDepth:cbuffer];
	[data getBytes:&cbuffer range:NSMakeRange(offset, 1)]; offset += 1;
	[object setDirectness:cbuffer];
	[data getBytes:&cbuffer range:NSMakeRange(offset, 1)]; offset += 1;
	[object setFlamboyancy:cbuffer];
	[data getBytes:&cbuffer range:NSMakeRange(offset, 1)]; offset += 1;
	[object setFlexibility:cbuffer];
	[data getBytes:&cbuffer range:NSMakeRange(offset, 1)]; offset += 1;
	[object setFreeRoles:cbuffer];
	[data getBytes:&cbuffer range:NSMakeRange(offset, 1)]; offset += 1;
	[object setMarking:cbuffer];
	[data getBytes:&cbuffer range:NSMakeRange(offset, 1)]; offset += 1;
	[object setOffside:cbuffer];
	[data getBytes:&cbuffer range:NSMakeRange(offset, 1)]; offset += 1;
	[object setPressing:cbuffer];
	[data getBytes:&cbuffer range:NSMakeRange(offset, 1)]; offset += 1;
	[object setSittingBack:cbuffer];
	[data getBytes:&cbuffer range:NSMakeRange(offset, 1)]; offset += 1;
	[object setTempo:cbuffer];
	[data getBytes:&cbuffer range:NSMakeRange(offset, 1)]; offset += 1;
	[object setUseOfPlaymaker:cbuffer];
	[data getBytes:&cbuffer range:NSMakeRange(offset, 1)]; offset += 1;
	[object setWidth:cbuffer];
	[data getBytes:&cbuffer range:NSMakeRange(offset, 1)]; offset += 1;
	[object setPreferredFormation:cbuffer];
	[data getBytes:&cbuffer range:NSMakeRange(offset, 1)]; offset += 1;
	[object setPreferredFormation2:cbuffer];
	[data getBytes:&cbuffer range:NSMakeRange(offset, 1)]; offset += 1;
	[object setDefensiveFormation:cbuffer];
	[data getBytes:&cbuffer range:NSMakeRange(offset, 1)]; offset += 1;
	[object setAttackingFormation:cbuffer];
	
	if (debug) { NSLog(@"before TIs at %d",offset); }
	
	[data getBytes:&sbuffer range:NSMakeRange(offset, 2)]; offset += 2;
	tempArray = [[NSMutableArray alloc] init];
	for (int i=0;i<sbuffer;i++) {
		id ti = [TransferInfoLoader readFromData:data atOffset:&offset];
		if ([[ti className] isEqualToString:@"TransferInfo"]) {
			[tempArray addObject:ti];
		}
		else { return [NSString stringWithFormat:@"Transfer Info - %@",ti]; }
	}
//	[object setTransferInfos:tempArray];
	[tempArray release];
	
//	if (debug) { NSLog(@"after TIs at %d",offset); }
	
	[tempArray release];
	
	*byteOffset = offset;
	
	return object;
}

@end
