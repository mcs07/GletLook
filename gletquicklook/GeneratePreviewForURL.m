#import <CoreFoundation/CoreFoundation.h>
#import <CoreServices/CoreServices.h>
#import <QuickLook/QuickLook.h>
#import <Cocoa/Cocoa.h>

/* -----------------------------------------------------------------------------
   Generate a preview for file

   This function's job is to create preview for designated file
   ----------------------------------------------------------------------------- */

OSStatus GeneratePreviewForURL(void *thisInterface, QLPreviewRequestRef preview, CFURLRef url, CFStringRef contentTypeUTI, CFDictionaryRef options)
{
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
	NSURL *nsUrl = (NSURL *)url;
    
    NSDictionary *fileDict = [NSDictionary dictionaryWithContentsOfFile:[nsUrl path]];
    NSString *name = [fileDict objectForKey:@"Name"];
    NSString *command = [fileDict objectForKey:@"Command"];
    NSString *escapedCommand = [(NSString *) CFXMLCreateStringByEscapingEntities(NULL, (CFStringRef) command, NULL) autorelease];
    NSString *font = [fileDict objectForKey:@"FontFamily"];
    NSNumber *fontSize = [fileDict objectForKey:@"FontSize"];
    NSString *coords = [fileDict objectForKey:@"GeekletFrame"];
    NSNumber *refresh = [fileDict objectForKey:@"RefreshInterval"];
    
	NSMutableString *html = [[[NSMutableString alloc] init] autorelease];
	[html appendString:@"<html><head><style>dl{float:left;width:520px;margin:1em 0;padding:0;} dt{clear:left;float:left;width:200px;margin:0;padding:5px;font-weight:bold;} dd{float:left;width:300px;margin:0;padding:5px;}</style><body><dl><dt>Name</dt><dd>"];
    [html appendString:name];
    [html appendString:@"</dd><dt>Command</dt><dd>"];
    [html appendString:escapedCommand];
    [html appendString:@"</dd><dt>Font</dt><dd>"];
    [html appendString:font];
    [html appendString:@"</dd><dt>Font Size</dt><dd>"];
    [html appendString:[fontSize stringValue]];
    [html appendString:@"</dd><dt>Coordinates</dt><dd>"];
    [html appendString:coords];
    [html appendString:@"</dd><dt>Refresh Rate</dt><dd>"];
    [html appendString:[refresh stringValue]];
    [html appendString:@"</dd></dl></body></html>"];
    
	CFDictionaryRef props = (CFDictionaryRef) [NSDictionary dictionary];
	QLPreviewRequestSetDataRepresentation(
                                          preview,
                                          (CFDataRef)[html dataUsingEncoding:NSUTF8StringEncoding],
                                          kUTTypeHTML, 
                                          props);
    
	[pool release];
	return noErr;
}

void CancelPreviewGeneration(void* thisInterface, QLPreviewRequestRef preview)
{
    // implement only if supported
}
