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
	NSDictionary *fileDict = [NSDictionary dictionaryWithContentsOfFile:[(NSURL *)url path]];
	NSString *name = [fileDict objectForKey:@"Name"];
	NSString *command = [(NSString *) CFXMLCreateStringByEscapingEntities(NULL, (CFStringRef) [fileDict objectForKey:@"Command"], NULL) autorelease];
	NSString *font = [fileDict objectForKey:@"FontFamily"];
	NSNumber *fontSize = [fileDict objectForKey:@"FontSize"];
	NSString *coords = [fileDict objectForKey:@"GeekletFrame"];
	NSNumber *refresh = [fileDict objectForKey:@"RefreshInterval"];
	NSMutableString *html = [[[NSMutableString alloc] init] autorelease];
	[html appendString:@"<html><head><style>body{background:#f1f1f1} dl{font:14px 'Lucida Grande';margin-left:140px;} dt{clear:left;float:left;margin:0 0 0 -130px;padding:5px 0;font-weight:bold;color:#808080;text-align:right;width:120px} dd{margin:0;padding:5px;} pre{margin: 0px;white-space:pre-wrap;word-wrap:break-word;}</style><body><dl>"];
	if (name) {
		[html appendString:@"<dt>Name</dt><dd>"];
		[html appendString:name];
	}
	if (command) {
		[html appendString:@"</dd><dt>Command</dt><dd><pre>"];
		[html appendString:command];
	}
	if (font) {
        [html appendString:@"</pre></dd><dt>Font</dt><dd>"];
        [html appendString:font];
    }
	if (fontSize) {
        [html appendString:@"</dd><dt>Font Size</dt><dd>"];
        [html appendString:[fontSize stringValue]];
    }
	if (coords) {
        [html appendString:@"</dd><dt>Coordinates</dt><dd>"];
        [html appendString:coords];
    }
	if (refresh) {
        [html appendString:@"</dd><dt>Refresh Rate</dt><dd>"];
        [html appendString:[refresh stringValue]];
    }
    [html appendString:@"</dd></dl></body></html>"];
	
	CFDictionaryRef props = (CFDictionaryRef) [NSDictionary dictionary];
	QLPreviewRequestSetDataRepresentation(preview, (CFDataRef)[html dataUsingEncoding:NSUTF8StringEncoding], kUTTypeHTML, props);
	
	[pool release];
	return noErr;
}

void CancelPreviewGeneration(void* thisInterface, QLPreviewRequestRef preview)
{
	// implement only if supported
}
