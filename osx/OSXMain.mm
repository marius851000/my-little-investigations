/*   SDLMain.m - main entry point for our Cocoa-ized SDL app
       Initial Version: Darrell Walisser <dwaliss1@purdue.edu>
       Non-NIB-Code & other changes: Max Horn <max@quendi.de>

    Feel free to customize this file to suit your needs
*/

#include "SDL2/SDL.h"
#import "NSFileManagerDirectoryLocations.h"
#include "ApplicationSupportBridge.h"
#include <sys/param.h> /* for MAXPATHLEN */
#include <unistd.h>

string pLocalApplicationSupportPath;
string pLocalizedCommonResourcesPath;
string pCasesPath;
string pUserApplicationSupportPath;
string pDialogSeenListsPath;
string pSavesPath;

/* Main entry point to executable - should *not* be SDL_main! */
void BeginOSX(string executionPath)
{
    NSAutoreleasePool *pPool = [[NSAutoreleasePool alloc] init];
    NSFileManager *defaultManager = [NSFileManager defaultManager];

    /* Create our Application Support folders if they don't exist yet and store the paths */
    NSString *pStrUserApplicationSupportPath = [defaultManager userApplicationSupportDirectory];

    /* Next, create the folders that the executable will need during execution if they don't already exist. */
    NSString *pStrLocalGameApplicationSupportPath = nil;
    NSString *pStrLocalizedCommonResourcesPath = nil;
    NSString *pStrCasesPath = nil;
    NSString *pStrUserGameApplicationSupportPath = nil;
    NSString *pStrDialogSeenListsPath = nil;
    NSString *pStrSavesPath = nil;

#ifdef MLI_DEBUG
    executionPath = "/Applications/My Little Investigations.app/Contents/MacOS";
#else
    executionPath = executionPath.substr(0, executionPath.find_last_of("/"));
#endif

    NSString *pStrExecutionPath = [defaultManager stringWithFileSystemRepresentation:executionPath.c_str() length: executionPath.size()];

    pStrLocalGameApplicationSupportPath = [pStrExecutionPath stringByAppendingPathComponent:@"../Resources"];
    pStrLocalizedCommonResourcesPath = [pStrLocalGameApplicationSupportPath stringByAppendingPathComponent:@"Languages"];
    pStrCasesPath = [pStrLocalGameApplicationSupportPath stringByAppendingPathComponent:@"Cases"];
    pStrUserGameApplicationSupportPath = [pStrUserApplicationSupportPath stringByAppendingPathComponent:@"My Little Investigations"];
    pStrDialogSeenListsPath = [pStrUserGameApplicationSupportPath stringByAppendingPathComponent:@"DialogSeenLists"];
    pStrSavesPath = [pStrUserGameApplicationSupportPath stringByAppendingPathComponent:@"Saves"];

	NSError *error = nil;

	[defaultManager
		createDirectoryAtPath:pStrDialogSeenListsPath
		withIntermediateDirectories:YES
		attributes:nil
		error:&error];

	[defaultManager
		createDirectoryAtPath:pStrSavesPath
		withIntermediateDirectories:YES
		attributes:nil
		error:&error];

    pLocalApplicationSupportPath = [pStrLocalGameApplicationSupportPath fileSystemRepresentation];
    pLocalizedCommonResourcesPath = [pStrLocalizedCommonResourcesPath fileSystemRepresentation];
    pCasesPath = [pStrCasesPath fileSystemRepresentation];
    pUserApplicationSupportPath = [pStrUserGameApplicationSupportPath fileSystemRepresentation];
    pDialogSeenListsPath = [pStrDialogSeenListsPath fileSystemRepresentation];
    pSavesPath = [pStrSavesPath fileSystemRepresentation];

    [pPool release];
}

vector<string> GetCaseFilePathsOSX()
{
    NSAutoreleasePool *pool = [NSAutoreleasePool new];
    NSError *error = nil;
    NSFileManager *defaultManager = [NSFileManager defaultManager];

    //TODO: Save the NSString as, say, a static pointer.
    NSString *casesPath = [defaultManager stringWithFileSystemRepresentation:pCasesPath.c_str() length: pCasesPath.size()];

    NSArray *pCaseFileList =
        [defaultManager
            contentsOfDirectoryAtPath: casesPath
            error:&error];

    vector<string> ppCaseFileList;

    for (NSUInteger i = 0; i < [pCaseFileList count]; i++)
    {
        NSString *pStrCaseFileName = [pCaseFileList objectAtIndex:i];

       //Ignore UNIX hidden files, like OS X's .DS_Store
        if ([pStrCaseFileName hasPrefix:@"."])
        {
            continue;
        }

        NSString *pStrCaseFilePath = [casesPath stringByAppendingPathComponent:pStrCaseFileName];
		ppCaseFileList.push_back(string([pStrCaseFilePath fileSystemRepresentation]));
    }

    [pool drain];
    return ppCaseFileList;
}

vector<string> GetSaveFilePathsForCaseOSX(string pCaseUuid)
{
	NSAutoreleasePool *pool = [NSAutoreleasePool new];
	NSError *error = nil;
	NSFileManager *defaultManager = [NSFileManager defaultManager];

    //TODO: Save the NSString as, say, a static pointer.
    NSString *pStrCaseSavesFilePath = [defaultManager stringWithFileSystemRepresentation:pSavesPath.c_str() length: pSavesPath.size()];
    pStrCaseSavesFilePath = [pStrCaseSavesFilePath stringByAppendingPathComponent:[NSString stringWithUTF8String:pCaseUuid.c_str()]];

    [defaultManager
        createDirectoryAtPath:pStrCaseSavesFilePath
        withIntermediateDirectories:YES
        attributes:nil
        error:&error];

    NSArray *pSaveFileList =
        [defaultManager
            contentsOfDirectoryAtPath:pStrCaseSavesFilePath
            error:&error];

    vector<string> ppSaveFilePathList;

    for (NSUInteger i = 0; i < [pSaveFileList count]; i++)
    {
        NSString *pStrSaveFileName = [pSaveFileList objectAtIndex:i];

       //Ignore UNIX hidden files, like OS X's .DS_Store
        if ([pStrSaveFileName hasPrefix:@"."])
        {
            continue;
        }

        NSString *pStrSaveFilePath = [pStrCaseSavesFilePath stringByAppendingPathComponent:pStrSaveFileName];
		ppSaveFilePathList.push_back(string([pStrSaveFilePath fileSystemRepresentation]));
    }

    [pool drain];
    return ppSaveFilePathList;
}

vector<string> GetLocalizedCommonResourcesFilePathsOSX()
{
    NSAutoreleasePool *pool = [NSAutoreleasePool new];
    NSError *error = nil;
    NSFileManager *defaultManager = [NSFileManager defaultManager];

    //TODO: Save the NSString as, say, a static pointer.
    NSString *localizedCommonResourcesPath = [defaultManager stringWithFileSystemRepresentation:pLocalizedCommonResourcesPath.c_str() length: pLocalizedCommonResourcesPath.size()];

    NSArray *pLocalizedCommonResourcesFileList =
        [defaultManager
            contentsOfDirectoryAtPath: localizedCommonResourcesPath
            error:&error];

    vector<string> ppLocalizedCommonResourcesFileList;

    for (NSUInteger i = 0; i < [pLocalizedCommonResourcesFileList count]; i++)
    {
        NSString *pStrLocalizedCommonResouresFileName = [pLocalizedCommonResourcesFileList objectAtIndex:i];

       //Ignore UNIX hidden files, like OS X's .DS_Store
        if ([pStrLocalizedCommonResouresFileName hasPrefix:@"."])
        {
            continue;
        }

        NSString *pStrLocalizedCommonResourcesFilePath = [localizedCommonResourcesPath stringByAppendingPathComponent:pStrLocalizedCommonResouresFileName];
		ppLocalizedCommonResourcesFileList.push_back(string([pStrLocalizedCommonResourcesFilePath fileSystemRepresentation]));
    }

    [pool drain];
    return ppLocalizedCommonResourcesFileList;
}

string GetVersionStringOSX(string PropertyListFilePath)
{
    NSFileManager *defaultManager = [NSFileManager defaultManager];
    NSString *pPropertyListPath = [defaultManager stringWithFileSystemRepresentation:PropertyListFilePath.c_str() length: PropertyListFilePath.size()];

    if (![defaultManager fileExistsAtPath:pPropertyListPath])
    {
        return string();
    }

    NSDictionary *pPropertyListDictionary =
        [NSDictionary dictionaryWithContentsOfFile:pPropertyListPath];

    if (pPropertyListDictionary == NULL)
    {
        return string();
    }

    NSString *pVersionString = [pPropertyListDictionary objectForKey:@"CFBundleVersion"];
    return [pVersionString UTF8String];
}

char * GetPropertyListXMLForVersionStringOSX(string pPropertyListFilePath, string pVersionString, unsigned long *pVersionStringLength)
{
    *pVersionStringLength = 0;

    NSFileManager *defaultManager = [NSFileManager defaultManager];
    NSError *pError = nil;
    //TODO: Save the NSString as, say, a static pointer.
    NSString *pPropertyListPath = [defaultManager stringWithFileSystemRepresentation:pPropertyListFilePath.c_str() length: pPropertyListFilePath.size()];

    if (![defaultManager fileExistsAtPath:pPropertyListPath])
    {
        return NULL;
    }

    NSMutableDictionary *pPropertyListDictionaryMutable =
        [NSMutableDictionary dictionaryWithContentsOfFile:pPropertyListPath];

    if (pPropertyListDictionaryMutable == NULL)
    {
        return NULL;
    }

    [pPropertyListDictionaryMutable setObject:[NSString stringWithUTF8String:pVersionString.c_str()] forKey:@"CFBundleVersion"];
    [pPropertyListDictionaryMutable setObject:[NSString stringWithUTF8String:pVersionString.c_str()] forKey:@"CFBundleShortVersionString"];

    NSData *pData = [NSPropertyListSerialization
        dataWithPropertyList:pPropertyListDictionaryMutable
        format:NSPropertyListXMLFormat_v1_0
        options:0
        error:&pError];

    if (pData == NULL)
    {
        return NULL;
    }

    NSUInteger dataLength = [pData length];

    char *pCharData = (char *)malloc(dataLength * sizeof(char));
    [pData getBytes:(void *)pCharData length:dataLength];

    *pVersionStringLength = dataLength;
    return pCharData;
}
