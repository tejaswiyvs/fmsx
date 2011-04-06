//
//  Person.m
//  FM10SX
//
//  Created by Amy Kettlewell on 09/10/29.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "SXFGameDB.h"
#import "DatabaseTypes.h"
#import "Person.h"
#import "Agreement.h"
#import "PlayerForm.h"
#import "Relationship.h"
#import "Database.h"
#import "Nation.h"
#import "Name.h"
#import "Team.h"
#import "Contract.h"
#import "Controller.h"
#import "ContractOffer.h"
#import "SXGraphicsController.h"

@implementation Person

@synthesize databaseClass, rowID, UID, playerData, staffData, personData, nonPlayerData, flags,
playerAndNonPlayerData, officialData, retiredPersonData, virtualPlayerData, spokespersonData,
journalistData, humanData, name, personStats, nonPlayerStats, playerStats,fileStartOffset, fileEndOffset,
unknownData1, unknownChar1, newFirstName, newSurname, newCommonName, transferID, agentData;

- (id)init
{
	[super init];
	
	name = @"---";
	
	return self;
}

- (NSString *)dobPreviewString
{
	if (personData) {
		NSCalendar *gregorian = [[NSCalendar alloc]
								 initWithCalendarIdentifier:NSGregorianCalendar];
		
		NSDateComponents *components =
		[gregorian components:(NSYearCalendarUnit | NSMonthCalendarUnit |  NSDayCalendarUnit) fromDate:[[personData dateOfBirth] date]];
		
		NSString *str = [[NSString alloc] initWithFormat:@"%d.%d.%d",[components day],[components month],[components year]];
		[gregorian release];
		return str;
	}
	return @"---";
}

- (NSString *)name {
	if (personData) {
		if ([personData commonNameID]>-1 && [personData commonNameID]<[(NSMutableArray *)[[NSApp delegate] valueForKeyPath:@"gameDB.database.commonNames"] count]) {
			return [[[[NSApp delegate] valueForKeyPath:@"gameDB.database.commonNames"] objectAtIndex:[personData commonNameID]] name];
		}
		else if ([personData firstNameID]>-1 || [personData surnameID]>-1) {
			NSMutableString *madeName = [NSMutableString string];
			NSString *firstName, *surname;
			
			if ([personData firstNameID]>-1 && [personData firstNameID]<[(NSMutableArray *)[[NSApp delegate] valueForKeyPath:@"gameDB.database.firstNames"] count]) {
				firstName = [[[[NSApp delegate] valueForKeyPath:@"gameDB.database.firstNames"] objectAtIndex:[personData firstNameID]] name];
				if (firstName!=nil && [firstName length]>0) {
					[madeName appendFormat:@"%@",firstName];
				}
			}
			if ([personData surnameID]>-1 && [personData surnameID]<[(NSMutableArray *)[[NSApp delegate] valueForKeyPath:@"gameDB.database.surnames"] count]) {
				surname = [[[[NSApp delegate] valueForKeyPath:@"gameDB.database.surnames"] objectAtIndex:[personData surnameID]] name];
				if ([madeName length]>0) { [madeName appendString:@" "]; }
				if (surname!=nil && [surname length]>0) {
					[madeName appendFormat:@"%@",surname];
				}
			}
			
			return madeName;
		}
	}
	else if (retiredPersonData) {
		return [NSString stringWithFormat:@"%@ %@",[retiredPersonData firstName], [retiredPersonData surname]];
	}
	else if (virtualPlayerData) {
		return NSLocalizedString(@"Virtual Player",nil);
	}
	
	return @"---";
}

- (NSString *)nationString {
	NSMutableString *string = [[NSMutableString alloc] init];
	if (personData && [personData nationID] > -1) {
		[string appendFormat:@"%@",[[[[[NSApp delegate] valueForKeyPath:@"gameDB.database.nations"] objectAtIndex:[personData nationID]] teamContainer] name]];
		
		for (Relationship *item in [personData relationships]) {
			if ([item relationshipType]==RT_HAS_NATIONALITY && [item associatedID] > -1)
			{
				[string appendFormat:@" / %@",[[[[[NSApp delegate] valueForKeyPath:@"gameDB.database.nations"] objectAtIndex:[item associatedID]] teamContainer] name]];
			}
		}
	}
	else { [string appendString:@"---"]; }
	
	return string;
}

- (NSString *)nationalTeamString
{
	if (staffData) {
		if ([staffData nationalTeamID]>-1) {
			[[[[[NSApp delegate] valueForKeyPath:@"gameDB.database.nations"] objectAtIndex:[[[[NSApp delegate] valueForKeyPath:@"gameDB.database.teams"] objectAtIndex:[staffData nationalTeamID]] teamContainerID]] teamContainer] name];
		}
		else if (personData && [personData nationID]>-1) { return [[[[[NSApp delegate] valueForKeyPath:@"gameDB.database.nations"] objectAtIndex:[personData nationID]] teamContainer] name]; }
	}
	return @"No Nation";
}

- (NSString *)teamString {
	if (staffData) {
		if ([staffData clubTeamID] > -1) {
			if (![[[[[NSApp delegate] valueForKeyPath:@"gameDB.database.teams"] objectAtIndex:[staffData clubTeamID]] name] isEqualToString:@"---"])
			{
				return [[[[NSApp delegate] valueForKeyPath:@"gameDB.database.teams"] objectAtIndex:[staffData clubTeamID]] name];
			}
			else
			{
				return [[[[NSApp delegate] valueForKeyPath:@"gameDB.database.teams"] objectAtIndex:[staffData clubTeamID]] fullTeamString];
			}
		}
		else if ([staffData nationalTeamID] > -1) {
			if (![[[[[NSApp delegate] valueForKeyPath:@"gameDB.database.teams"] objectAtIndex:[staffData nationalTeamID]] name] isEqualToString:@"---"])
			{
				return [[[[NSApp delegate] valueForKeyPath:@"gameDB.database.teams"] objectAtIndex:[staffData nationalTeamID]] name];
			}
			else
			{
				return [[[[NSApp delegate] valueForKeyPath:@"gameDB.database.teams"] objectAtIndex:[staffData nationalTeamID]] fullTeamString];
			}
		}
		
	}
			 
	return @"---";
}

- (NSString *)typeString {
	if (playerData && nonPlayerData) { return NSLocalizedString(@"Player / Non-Player", @"person job"); }
	else if (playerData) { return NSLocalizedString(@"Player", @"person job"); }
	else if (nonPlayerData) { return NSLocalizedString(@"Non-Player", @"person job"); }
	else if (officialData) {
		if ([officialData assistantRefereeOnly]) { return NSLocalizedString(@"Assistant Referee", @"person job"); }
		else { return NSLocalizedString(@"Referee", @"person job"); }
	}
	else if (journalistData) { return NSLocalizedString(@"Journalist", @"person job"); }
	else if (agentData) { return NSLocalizedString(@"Agent", @"person job"); }
	else if (spokespersonData) { return NSLocalizedString(@"Spokesperson", @"person job"); }
	else if (humanData) { return NSLocalizedString(@"Human", @"person job"); }
	else if (databaseClass==DBC_VIRTUAL_PLAYER) { return NSLocalizedString(@"Virtual Player", @"person job"); }
	else if (retiredPersonData) { return NSLocalizedString(@"Retired Person", @"person job"); }
	else { return @"---"; }
}

- (NSString *)jobString {
	if (officialData) {
		if ([officialData assistantRefereeOnly]) { return NSLocalizedString(@"Assistant Referee", @"person job"); }
		else { return NSLocalizedString(@"Referee", @"person job"); }
	}
	else if (journalistData) { return NSLocalizedString(@"Journalist", @"person job"); }
	else if (agentData) { return NSLocalizedString(@"Agent", @"person job"); }
	else if (spokespersonData) { return NSLocalizedString(@"Spokesperson", @"person job"); }
	else if (staffData) {
		int job;
		if (staffData) { job = [staffData clubJob]; }
		
		if (job==JOB_PLAYER) { return NSLocalizedString(@"Player", @"person job"); }
		else if (job==JOB_COACH) { return NSLocalizedString(@"Coach", @"person job"); }
		else if (job==JOB_CHAIRMAN) { return NSLocalizedString(@"Chairman", @"person job"); }
		else if (job==JOB_DIRECTOR) { return NSLocalizedString(@"Director", @"person job"); }
		else if (job==JOB_MANAGING_DIRECTOR) { return NSLocalizedString(@"Managing Director", @"person job"); }
		else if (job==JOB_DIRECTOR_OF_FOOTBALL) { return NSLocalizedString(@"Director Of Football", @"person job"); }
		else if (job==JOB_PHYSIO) { return NSLocalizedString(@"Physio", @"person job"); }
		else if (job==JOB_SCOUT) { return NSLocalizedString(@"Scout", @"person job"); }
		else if (job==JOB_MANAGER) { return NSLocalizedString(@"Manager", @"person job"); }
		else if (job==JOB_HEAD_COACH) { return NSLocalizedString(@"Head Coach", @"person job"); }
		else if (job==JOB_ASSISTANT_MANAGER) { return NSLocalizedString(@"Assistant Manager", @"person job"); }
		else if (job==JOB_GENERAL_MANAGER) { return NSLocalizedString(@"General Manager", @"person job"); }
		else if (job==JOB_CARETAKER_COACH) { return NSLocalizedString(@"Caretaker Coach", @"person job"); }
		else if (job==JOB_PLAYER_MANAGER) { return NSLocalizedString(@"Player / Manager", @"person job"); }
		else if (job==JOB_COACH) { return NSLocalizedString(@"Coach", @"person job"); }
		else if (job==JOB_PLAYER_COACH) { return NSLocalizedString(@"Player / Coach", @"person job"); }
		else if (job==JOB_PLAYER_ASSISTANT_MANAGER) { return NSLocalizedString(@"Player / Assistant Manager", @"person job"); }
		else if (job==JOB_FITNESS_COACH) { return NSLocalizedString(@"Fitness Coach", @"person job"); }
		else if (job==JOB_PLAYER_FITNESS_COACH) { return NSLocalizedString(@"Player / Fitness Coach", @"person job"); }
		else if (job==JOB_CARETAKER_COACH) { return NSLocalizedString(@"Caretaker / Coach", @"person job"); }
		else if (job==JOB_GOALKEEPING_COACH) { return NSLocalizedString(@"Goalkeeping Coach", @"person job"); }
		else if (job==JOB_PLAYER_GOALKEEPING_COACH) { return NSLocalizedString(@"Player / Goalkeeping Coach", @"person job"); }
		else if (job==JOB_YOUTH_TEAM_COACH) { return NSLocalizedString(@"Youth Team Coach", @"person job"); }
		else if (job==JOB_PLAYER_YOUTH_TEAM_COACH) { return NSLocalizedString(@"Player / Youth Team Coach", @"person job"); }
		else if (job==JOB_FIRST_TEAM_COACH) { return NSLocalizedString(@"First Team Coach", @"person job"); }
		else if (job==JOB_PLAYER_FIRST_TEAM_COACH) { return NSLocalizedString(@"Player / First Team Coach", @"person job"); }
	}
	return @"---";
}

- (NSString *)nationJobString 
{
	if (officialData) {
		if ([officialData assistantRefereeOnly]) { return NSLocalizedString(@"Assistant Referee", @"person job"); }
		else { return NSLocalizedString(@"Referee", @"person job"); }
	}
	else if (journalistData) { return NSLocalizedString(@"Journalist", @"person job"); }
	else if (agentData) { return NSLocalizedString(@"Agent", @"person job"); }
	else if (spokespersonData) { return NSLocalizedString(@"Spokesperson", @"person job"); }
	else if (staffData) {
		int job;
		if (staffData) { job = [staffData nationalJob]; }
		
		if (job==JOB_PLAYER) { return NSLocalizedString(@"Player", @"person job"); }
		else if (job==JOB_COACH) { return NSLocalizedString(@"Coach", @"person job"); }
		else if (job==JOB_CHAIRMAN) { return NSLocalizedString(@"Chairman", @"person job"); }
		else if (job==JOB_DIRECTOR) { return NSLocalizedString(@"Director", @"person job"); }
		else if (job==JOB_MANAGING_DIRECTOR) { return NSLocalizedString(@"Managing Director", @"person job"); }
		else if (job==JOB_DIRECTOR_OF_FOOTBALL) { return NSLocalizedString(@"Director Of Football", @"person job"); }
		else if (job==JOB_PHYSIO) { return NSLocalizedString(@"Physio", @"person job"); }
		else if (job==JOB_SCOUT) { return NSLocalizedString(@"Scout", @"person job"); }
		else if (job==JOB_MANAGER) { return NSLocalizedString(@"Manager", @"person job"); }
		else if (job==JOB_HEAD_COACH) { return NSLocalizedString(@"Head Coach", @"person job"); }
		else if (job==JOB_ASSISTANT_MANAGER) { return NSLocalizedString(@"Assistant Manager", @"person job"); }
		else if (job==JOB_GENERAL_MANAGER) { return NSLocalizedString(@"General Manager", @"person job"); }
		else if (job==JOB_CARETAKER_COACH) { return NSLocalizedString(@"Caretaker Coach", @"person job"); }
		else if (job==JOB_PLAYER_MANAGER) { return NSLocalizedString(@"Player / Manager", @"person job"); }
		else if (job==JOB_COACH) { return NSLocalizedString(@"Coach", @"person job"); }
		else if (job==JOB_PLAYER_COACH) { return NSLocalizedString(@"Player / Coach", @"person job"); }
		else if (job==JOB_PLAYER_ASSISTANT_MANAGER) { return NSLocalizedString(@"Player / Assistant Manager", @"person job"); }
		else if (job==JOB_FITNESS_COACH) { return NSLocalizedString(@"Fitness Coach", @"person job"); }
		else if (job==JOB_PLAYER_FITNESS_COACH) { return NSLocalizedString(@"Player / Fitness Coach", @"person job"); }
		else if (job==JOB_CARETAKER_COACH) { return NSLocalizedString(@"Caretaker / Coach", @"person job"); }
		else if (job==JOB_GOALKEEPING_COACH) { return NSLocalizedString(@"Goalkeeping Coach", @"person job"); }
		else if (job==JOB_PLAYER_GOALKEEPING_COACH) { return NSLocalizedString(@"Player / Goalkeeping Coach", @"person job"); }
		else if (job==JOB_YOUTH_TEAM_COACH) { return NSLocalizedString(@"Youth Team Coach", @"person job"); }
		else if (job==JOB_PLAYER_YOUTH_TEAM_COACH) { return NSLocalizedString(@"Player / Youth Team Coach", @"person job"); }
		else if (job==JOB_FIRST_TEAM_COACH) { return NSLocalizedString(@"First Team Coach", @"person job"); }
		else if (job==JOB_PLAYER_FIRST_TEAM_COACH) { return NSLocalizedString(@"Player / First Team Coach", @"person job"); }
	}
	return @"---";
}

- (NSString *)positionString
{
	if (!playerStats) { return @""; }
	
	NSMutableString *position = [[NSMutableString alloc] init];
	
	if ([playerStats goalkeeper]>=15) { return @"GK"; }
	if ([playerStats sweeper]>=15) { 
		[position appendString:@"SW"];
	}
	if ([playerStats leftDefender]>=15 ||
		[playerStats rightDefender]>=15 ||
		[playerStats centralDefender]>=15) {
		if ([position length]>0) { [position appendString:@", "]; }
		[position appendString:@"D "];
		if ([playerStats rightDefender]>=15) { [position appendString:@"R"]; }
		if ([playerStats leftDefender]>=15) { [position appendString:@"L"]; }
		if ([playerStats centralDefender]>=15) { [position appendString:@"C"]; }
	}
	if ([playerStats leftWingBack]>=15 ||
		[playerStats rightWingBack]>=15) {
		if ([position length]>0) { [position appendString:@", "]; }
		[position appendString:@"WB "];
		if ([playerStats rightWingBack]>=15) { [position appendString:@"R"]; }
		if ([playerStats leftWingBack]>=15) { [position appendString:@"L"]; }
	}
	if ([playerStats centralDefensiveMidfielder]>=15) {
		if ([position length]>0) { [position appendString:@", "]; }
		[position appendString:@"DM"];
	}
	
	if ([playerStats leftAttackingMidfielder]>=15 ||
		[playerStats rightAttackingMidfielder]>=15 ||
		[playerStats centralAttackingMidfielder]>=15) {
		if ([position length]>0) { [position appendString:@", "]; }
		[position appendString:@"AM "];
	}
	else if ([playerStats leftMidfielder]>=15 ||
			 [playerStats rightMidfielder]>=15 ||
			 [playerStats centralMidfielder]>=15) {
		if ([position length]>0) { [position appendString:@", "]; }
		[position appendString:@"M "];
	}
	
	if ([playerStats leftAttackingMidfielder]>=15 || [playerStats rightAttackingMidfielder]>=15 ||
		[playerStats centralAttackingMidfielder]>=15 || [playerStats leftMidfielder]>=15 ||
		[playerStats rightMidfielder]>=15 || [playerStats centralMidfielder]>=15) {
		if ([playerStats rightMidfielder]>=15 || [playerStats rightAttackingMidfielder]>=15) {
			[position appendString:@"R"];
		}
		if ([playerStats leftMidfielder]>=15 || [playerStats leftAttackingMidfielder]>=15) {
			[position appendString:@"L"];
		}
		if ([playerStats centralMidfielder]>=15 || [playerStats centralAttackingMidfielder]>=15) {
			[position appendString:@"C"];
		}
	}
	
	if ([playerStats centreForward]>=15) {
		if ([position length]>0) { [position appendString:@", "]; }
		[position appendString:@"F C"];
	}
	
	if ([position length]>0) { return position; }
	
	return @"";
}

- (int)age
{
	if (personData) {
		short dobYear = [[personData dateOfBirth] year];
		short currentYear = [[[[NSApp delegate] gameDB] currentDate] year];
		short dobMonth = [[[[[[NSApp delegate] gameDB] currentDate] date] descriptionWithCalendarFormat:@"%m" timeZone:nil locale:nil] intValue]; 
		short currentMonth = [[[[personData dateOfBirth] date] descriptionWithCalendarFormat:@"%m" timeZone:nil locale:nil] intValue]; 
		short dobDay = [[[[[[NSApp delegate] gameDB] currentDate] date] descriptionWithCalendarFormat:@"%d" timeZone:nil locale:nil] intValue]; 
		short currentDay = [[[[personData dateOfBirth] date] descriptionWithCalendarFormat:@"%d" timeZone:nil locale:nil] intValue]; 
		
		short monthDiff = currentMonth - dobMonth;
		short dayDiff = currentDay - dobDay;
		
		int age = currentYear - dobYear;
		
		if (monthDiff <= 0 && dayDiff < 0) { age--; }
		
		return age;
	}
	
	return 0;
}

- (BOOL)contractIsExpiring
{
	if ([[staffData contracts] count]>0) {
		if ([[[[[staffData contracts] objectAtIndex:0] endDate] date] timeIntervalSinceDate:[[[[NSApp delegate] gameDB] currentDate] date]] < (60*60*24*30*6)) {
			return TRUE;
		}
	}
	return FALSE;
}
- (BOOL)contractIsExpired
{
	if ([[staffData contracts] count]>0) {
		if ([[[[[NSApp delegate] gameDB] currentDate] date] laterDate:[[[[staffData contracts] objectAtIndex:0] endDate] date]]==[[[[NSApp delegate] gameDB] currentDate] date])
		{
			return TRUE;
		}

	}
	return FALSE;
}

- (BOOL)isECNational
{
	if (personData) {
		if ([[[[[NSApp delegate] valueForKeyPath:@"gameDB.database.nations"] objectAtIndex:[personData nationID]] agreements] containsObject:[NSNumber numberWithInt:EU]] ||
			[[[[[NSApp delegate] valueForKeyPath:@"gameDB.database.nations"] objectAtIndex:[personData nationID]] agreements] containsObject:[NSNumber numberWithInt:EEA]])
		{
			return TRUE;
		}
		
		for (Relationship *item in [personData relationships]) {
			if ([item relationshipType]==RT_HAS_NATIONALITY)
			{
				if ([[[[[NSApp delegate] valueForKeyPath:@"gameDB.database.nations"] objectAtIndex:[item associatedID]] agreements] containsObject:[NSNumber numberWithInt:EU]] ||
					[[[[[NSApp delegate] valueForKeyPath:@"gameDB.database.nations"] objectAtIndex:[item associatedID]] agreements] containsObject:[NSNumber numberWithInt:EEA]])
				{
					return TRUE;
				}
			}
		}
	}
	
	return FALSE;
}

- (BOOL)acceptedContractOffer
{
	if ([[staffData contractOffers] count]>0) {
		for (ContractOffer *item in [staffData contractOffers]) {
			if ([item decision]==COD_ACCEPTED) { return TRUE; }
		}
	}
	
	return FALSE;
}

- (BOOL)isTransferListed
{
	if ([[staffData contracts] count] > 0) {
		if ([[[staffData contracts] objectAtIndex:0] transferListedByRequest] ||
			[[[staffData contracts] objectAtIndex:0] transferListedByClub]) { return TRUE; }
	}
	
	return FALSE;
}

- (BOOL)isListedForLoan
{
	if ([[staffData contracts] count] > 0) {
		if ([[[staffData contracts] objectAtIndex:0] listedForLoan]) { return TRUE; }
	}
	
	return FALSE;
}

- (NSImage *)playerGrowthPotential
{
	if (playerStats && personStats) {
		if ([self playerGrowthPotentialVal]<0.5) { return [NSImage imageNamed:@"0star.png"]; }
		else if ([self playerGrowthPotentialVal]<1) { return [NSImage imageNamed:@"1star.png"]; }
		else if ([self playerGrowthPotentialVal]<1.5) { return [NSImage imageNamed:@"2star.png"]; }
		else if ([self playerGrowthPotentialVal]<2) { return [NSImage imageNamed:@"3star.png"]; }
		else if ([self playerGrowthPotentialVal]<2.5) { return [NSImage imageNamed:@"4star.png"]; }
		else if ([self playerGrowthPotentialVal]<3) { return [NSImage imageNamed:@"5star.png"]; }
		else if ([self playerGrowthPotentialVal]<3.5) { return [NSImage imageNamed:@"6star.png"]; }
		else if ([self playerGrowthPotentialVal]<4) { return [NSImage imageNamed:@"7star.png"]; }
		else if ([self playerGrowthPotentialVal]<4.5) { return [NSImage imageNamed:@"8star.png"]; }
		else if ([self playerGrowthPotentialVal]<5) { return [NSImage imageNamed:@"9star.png"]; }
		else { return [NSImage imageNamed:@"10star.png"]; }
	}
	return [NSImage imageNamed:@"0star.png"];
}

- (float)playerGrowthPotentialVal
{
	if (playerStats && personStats) {
		float DAP = (([playerStats determination] / 5) * 0.05) + ([personStats ambition] * 0.09) + ([personStats professionalism] * 0.115);
		if ([self age]<24) {
			if ([playerData potentialAbility] <= ([playerData currentAbility]+10)) { DAP = DAP - 0.5; }
		}
		else if ([self age] >= 24 && [self age] < 29) {
			DAP = DAP - 0.5;
			if ([playerData potentialAbility] <= ([playerData currentAbility]+10)) { DAP = DAP - 0.5; }
		}
		else if ([self age] >= 29 && [self age] < 34) {
			DAP = DAP - 1;
			if ([playerData potentialAbility] <= ([playerData currentAbility]+10)) { DAP = DAP - 0.5; }
		}
		else if ([self age] >= 34) {
			if ([playerData potentialAbility] <= ([playerData currentAbility]+10) && [playerStats goalkeeper] >= 15) { DAP = 0.5; }
			else { DAP = 0; }
		}
		
		NSNumberFormatter *formatter = [[NSNumberFormatter alloc] init];
		[formatter setNumberStyle:NSNumberFormatterDecimalStyle];
		[formatter setMinimumFractionDigits:2];
		[formatter setMaximumFractionDigits:2];
		[formatter setMaximum:[NSNumber numberWithInt:5]];
		[formatter setMinimum:[NSNumber numberWithInt:0]];
		NSString *str = [formatter stringFromNumber:[NSNumber numberWithFloat:DAP]];
		float rating = [str floatValue];
		
		NSLog(@"DAP:%f  R:%f",DAP,rating);
		
		return rating;
	}
	return 0.0;
}

- (void)changeName
{
	// check if the type is ok
	if (databaseClass != DBC_NON_PLAYER && databaseClass != DBC_PLAYER &&
		databaseClass != DBC_OFFICIAL && databaseClass != DBC_PLAYER_AND_NON_PLAYER &&
		databaseClass != DBC_HUMAN && databaseClass != DBC_SPOKESPERSON &&
		databaseClass != DBC_JOURNALIST)
	{ return; }
	
	NSMutableString *expression;
	NSPredicate *predicate;
	NSMutableArray *tempArray;
	
	// first name
	if ([newFirstName length]>0) {
		// search for an existing name & nation
		expression = [NSMutableString stringWithFormat:@"(name == '%@')",newFirstName];
		[expression appendFormat:@" AND (nationID == %d)",[personData nationID]];
		predicate = [NSPredicate predicateWithFormat:expression];
		tempArray = [[NSMutableArray alloc] init];
		[tempArray addObjectsFromArray:[[[NSApp delegate] valueForKeyPath:@"gameDB.database.firstNames"] filteredArrayUsingPredicate:predicate]];
		
		if ([tempArray count]==0) {
			Name *name1 = [[Name alloc] init];
			[name1 setNationID:[personData nationID]];
			[name1 setName:newFirstName];
			[name1 setRowID:[(NSMutableArray *)[[NSApp delegate] valueForKeyPath:@"gameDB.database.firstNames"] count]];
			[name1 setUID:UID];
			[name1 setCount:1];
			[[[NSApp delegate] valueForKeyPath:@"gameDB.database.firstNames"] addObject:name1];
			[personData setFirstNameID:[name1 rowID]];
			[name1 release];
		}
		else {
			[personData setFirstNameID:[[tempArray objectAtIndex:0] rowID]];
			short newCount = [(Name *)[tempArray objectAtIndex:0] count] + 1;
			[(Name *)[(NSMutableArray *)[[NSApp delegate] valueForKeyPath:@"gameDB.database.firstNames"] objectAtIndex:[[tempArray objectAtIndex:0] rowID]] setCount:newCount];
		}
		
		[tempArray release];
	}
	
	// surname
	if ([newSurname length]>0) {
		// search for an existing name & nation
		expression = [NSMutableString stringWithFormat:@"(name == '%@')",newSurname];
		[expression appendFormat:@" AND (nationID == %d)",[personData nationID]];
		predicate = [NSPredicate predicateWithFormat:expression];
		tempArray = [[NSMutableArray alloc] init];
		[tempArray addObjectsFromArray:[[[NSApp delegate] valueForKeyPath:@"gameDB.database.surnames"] filteredArrayUsingPredicate:predicate]];
		
		if ([tempArray count]==0) {
			Name *name1 = [[Name alloc] init];
			[name1 setNationID:[personData nationID]];
			[name1 setName:newSurname];
			[name1 setRowID:[(NSMutableArray *)[[NSApp delegate] valueForKeyPath:@"gameDB.database.surnames"] count]];
			[name1 setUID:UID];
			[name1 setCount:1];
			[[[NSApp delegate] valueForKeyPath:@"gameDB.database.surnames"] addObject:name1];
			[personData setSurnameID:[name1 rowID]];
			[name1 release];
		}
		else {
			[personData setSurnameID:[[tempArray objectAtIndex:0] rowID]];
			short newCount = [(Name *)[tempArray objectAtIndex:0] count] + 1;
			[(Name *)[(NSMutableArray *)[[NSApp delegate] valueForKeyPath:@"gameDB.database.surnames"] objectAtIndex:[[tempArray objectAtIndex:0] rowID]] setCount:newCount];
		}
		
		[tempArray release];
	}
	
	// common name
	if ([newCommonName length]>0) {
		// search for an existing name & nation
		expression = [NSMutableString stringWithFormat:@"(name == '%@')",newCommonName];
		[expression appendFormat:@" AND (nationID == %d)",[personData nationID]];
		predicate = [NSPredicate predicateWithFormat:expression];
		tempArray = [[NSMutableArray alloc] init];
		[tempArray addObjectsFromArray:[[[NSApp delegate] valueForKeyPath:@"gameDB.database.commonNames"] filteredArrayUsingPredicate:predicate]];
		
		if ([tempArray count]==0) {
			Name *name1 = [[Name alloc] init];
			[name1 setNationID:[personData nationID]];
			[name1 setName:newCommonName];
			[name1 setRowID:[(NSMutableArray *)[[NSApp delegate] valueForKeyPath:@"gameDB.database.commonNames"] count]];
			[name1 setUID:UID];
			[name1 setCount:1];
			[[[NSApp delegate] valueForKeyPath:@"gameDB.database.commonNames"] addObject:name1];
			[personData setCommonNameID:[name1 rowID]];
			[name1 release];
		}
		else {
			[personData setCommonNameID:[[tempArray objectAtIndex:0] rowID]];
			short newCount = [(Name *)[tempArray objectAtIndex:0] count] + 1;
			[(Name *)[(NSMutableArray *)[[NSApp delegate] valueForKeyPath:@"gameDB.database.commonNames"] objectAtIndex:[[tempArray objectAtIndex:0] rowID]] setCount:newCount];
		}
		
		[tempArray release];
	}
}

- (BOOL)canTransfer
{
	if (playerData) { return TRUE; }
	return FALSE;
}

- (void)transfer
{
	Club *newClub = [[[NSApp delegate] valueForKeyPath:@"gameDB.database.clubs"] objectAtIndex:transferID];
	
	NSLog(@"Transferring to %@...",[[newClub teamContainer] name]);
	
	if (![self canTransfer] || [[[newClub teamContainer] teams] count]==0) { return; }
	
	Team *currentTeam;
	Club *currentClub;
	
	if ([staffData clubTeamID]>-1) {
		currentTeam = [[[NSApp delegate] valueForKeyPath:@"gameDB.database.teams"] objectAtIndex:[staffData clubTeamID]];
		currentClub = [[[NSApp delegate] valueForKeyPath:@"gameDB.database.clubs"] objectAtIndex:[currentTeam teamContainerID]];
	}
	
	// remove from old teams list
	if (playerData && [staffData clubTeamID]>-1 && [[currentTeam players] containsObject:[NSNumber numberWithInt:rowID]]) {
		[[currentTeam mutableArrayValueForKey:@"players"] removeObject:[NSNumber numberWithInt:rowID]];
	}

	// add to new teams list
	int newTeamID = [[[[newClub teamContainer] teams] objectAtIndex:0] intValue];
	
	[[[[[NSApp delegate] valueForKeyPath:@"gameDB.database.teams"] objectAtIndex:newTeamID] mutableArrayValueForKey:@"players"] addObject:[NSNumber numberWithInt:rowID]];
	
	// change club in players contract
	if ([[staffData contracts] count]>0) {
		[[[staffData contracts] objectAtIndex:0] setStartDate:[[[NSApp delegate] gameDB] currentDate]];
		[[[staffData contracts] objectAtIndex:0] setClubID:[newClub rowID]];
	}
	
	// set join details
	[staffData setClubTeamID:newTeamID];
	[staffData setClubTeamJoinDate:[[[NSApp delegate] gameDB] currentDate]];
	[staffData setLastClubID:[currentClub rowID]];
}

- (NSImage *)photo
{
	if ([[[[NSApp delegate] graphics] personPhotos] objectForKey:[NSNumber numberWithInt:UID]]!=nil)
	{
		NSImage *image = [[[NSImage alloc] initWithContentsOfFile:[[[[NSApp delegate] graphics] personPhotos] objectForKey:[NSNumber numberWithInt:UID]]] autorelease];
		return image;
	}
	else {
		if ([personData female]) { return [NSImage imageNamed:@"defaultperson_female"]; }
		else { return [NSImage imageNamed:@"defaultperson_male"]; }
	}
}

- (NSMutableArray *)sections:(SXEditorEntityViewController *)entityController
{
	NSMutableArray *sections = [[NSMutableArray alloc] init];
	
	if (personData) { 
		[sections addObject:[NSDictionary dictionaryWithObjectsAndKeys:@"Person Data",@"title",[entityController personActualPersonView],@"view",nil]]; 
		if ([personData personStatsID]>-1) {
			[sections addObject:[NSDictionary dictionaryWithObjectsAndKeys:@"Person Stats",@"title",[entityController personStatsView],@"view",nil]]; 
		}
		if ([personData hasRelationships]) {
			[sections addObject:[NSDictionary dictionaryWithObjectsAndKeys:@"Relationships",@"title",[entityController personRelationshipsView],@"view",nil]];
		}
	}
	if (spokespersonData) {
		[sections addObject:[NSDictionary dictionaryWithObjectsAndKeys:@"Spokesperson Data",@"title",[entityController personSpokespersonView],@"view",nil]];
	}
	if (agentData) {
		[sections addObject:[NSDictionary dictionaryWithObjectsAndKeys:@"Agent Data",@"title",[entityController personAgentView],@"view",nil]];
	}
	if (journalistData) {
		[sections addObject:[NSDictionary dictionaryWithObjectsAndKeys:@"Journalist Data",@"title",[entityController personJournalistView],@"view",nil]];
	}
	if (officialData) {
		[sections addObject:[NSDictionary dictionaryWithObjectsAndKeys:@"Official Data",@"title",[entityController personOfficialView],@"view",nil]];
		[sections addObject:[NSDictionary dictionaryWithObjectsAndKeys:@"Official Past Games",@"title",[entityController personOfficialPastGamesView],@"view",nil]];
	}
	if (playerData) {
		[sections addObject:[NSDictionary dictionaryWithObjectsAndKeys:@"Player Data",@"title",[entityController personPlayerView],@"view",nil]]; 
		if ([playerData playerStatsID]>-1) {
			[sections addObject:[NSDictionary dictionaryWithObjectsAndKeys:@"Player Stats",@"title",[entityController personPlayerStatsView],@"view",nil]]; 
		}
		[sections addObject:[NSDictionary dictionaryWithObjectsAndKeys:@"Preferred Moves",@"title",[entityController personPreferredMovesView],@"view",nil]]; 
		[sections addObject:[NSDictionary dictionaryWithObjectsAndKeys:@"Bans",@"title",[entityController personBansView],@"view",nil]]; 
		[sections addObject:[NSDictionary dictionaryWithObjectsAndKeys:@"Injuries",@"title",[entityController personInjuriesView],@"view",nil]]; 
		[sections addObject:[NSDictionary dictionaryWithObjectsAndKeys:@"Forms",@"title",[entityController personPlayerFormsView],@"view",nil]]; 
	}
	if (nonPlayerData) {
		[sections addObject:[NSDictionary dictionaryWithObjectsAndKeys:@"Non-Player Data",@"title",[entityController personNonPlayerView],@"view",nil]]; 
		if ([nonPlayerData nonPlayingStatsID]>-1) {
			[sections addObject:[NSDictionary dictionaryWithObjectsAndKeys:@"Non-Player Stats",@"title",[entityController personNonPlayerStatsView],@"view",nil]]; 
		}
	}
	if (staffData) {
		[sections addObject:[NSDictionary dictionaryWithObjectsAndKeys:@"Staff Data",@"title",[entityController personActualStaffView],@"view",nil]];
		[sections addObject:[NSDictionary dictionaryWithObjectsAndKeys:@"Contracts",@"title",[entityController personContractsView],@"view",nil]];
	}
	if (humanData) {
		[sections addObject:[NSDictionary dictionaryWithObjectsAndKeys:@"Human Data",@"title",[entityController personHumanView],@"view",nil]];
	}
	if (retiredPersonData) {
		[sections addObject:[NSDictionary dictionaryWithObjectsAndKeys:@"Retired Person Data",@"title",[entityController personRetiredPersonView],@"view",nil]];
	}
	[sections addObject:[NSDictionary dictionaryWithObjectsAndKeys:@"Tools",@"title",[entityController personToolsView],@"view",nil]];
	if ([[NSUserDefaults standardUserDefaults] boolForKey:@"debugMode"]) {
	//	[sections addObject:[NSDictionary dictionaryWithObjectsAndKeys:@"Debug - Person",@"title",[entityController personDebugPersonView],@"view",nil]];
	}
	
	
	return [sections autorelease];
}

@end
