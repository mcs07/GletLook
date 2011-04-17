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
    CFBundleRef bundle = QLPreviewRequestGetGeneratorBundle(preview);
    CFURLRef iconUrl = CFBundleCopyResourceURL(bundle, CFSTR("icon.png"), NULL, NULL);
    NSString *iconUrlString = [(NSURL *)iconUrl path];
	NSDictionary *fileDict = [NSDictionary dictionaryWithContentsOfFile:[(NSURL *)url path]];
	NSString *name = [fileDict objectForKey:@"Name"];
	NSString *command = [(NSString *)CFXMLCreateStringByEscapingEntities(NULL, (CFStringRef) [fileDict objectForKey:@"Command"], NULL) autorelease];
	NSString *font = [fileDict objectForKey:@"FontFamily"];
	NSNumber *fontSize = [fileDict objectForKey:@"FontSize"];
	NSString *coords = [fileDict objectForKey:@"GeekletFrame"];
	NSNumber *refresh = [fileDict objectForKey:@"RefreshInterval"];
	NSMutableString *html = [[[NSMutableString alloc] init] autorelease];
	[html appendString:@"<html><head><style>body{font:14px 'Lucida Grande';background: -webkit-gradient(linear, left top, left bottom, from(#333), to(#222));margin:15px;} dl{padding: 10px 5px 10px 140px;border-radius:6px;background: -webkit-gradient(linear, left top, left bottom, from(#f1f1f1), to(#d1d1d1));-webkit-box-shadow:inset 0 1px 3px #fff, 0 0 20px #000;} dt{clear:left;float:left;margin:0 0 0 -130px;padding:5px 0;font-weight:bold;color:#808080;text-align:right;width:120px;text-shadow: #fff 0px 1px 0px;} dd{margin:0;padding:5px;} pre{margin: 0px;white-space:pre-wrap;word-wrap:break-word;} h1{display:inline-block;margin: 50px 0 0;vertical-align:top;color:#dddddd}</style><body><img src='cid:icon.png' /><h1>"];
    [html appendString:[(NSURL *)url lastPathComponent]];
    [html appendString:@"</h1><dl>"];
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
    NSLog(@"%@", html);
    NSMutableDictionary *props = [[[NSMutableDictionary alloc] init] autorelease];
    [props setObject:@"UTF-8" forKey:(NSString *)kQLPreviewPropertyTextEncodingNameKey];
    [props setObject:@"text/html" forKey:(NSString *)kQLPreviewPropertyMIMETypeKey];
    NSData *image=[NSData dataWithContentsOfFile:iconUrlString];
    NSMutableDictionary *imgProps=[[[NSMutableDictionary alloc] init] autorelease];
    [imgProps setObject:@"image/png" forKey:(NSString *)kQLPreviewPropertyMIMETypeKey];
    [imgProps setObject:image forKey:(NSString *)kQLPreviewPropertyAttachmentDataKey];
    [props setObject:[NSDictionary dictionaryWithObject:imgProps forKey:@"icon.png"] forKey:(NSString *)kQLPreviewPropertyAttachmentsKey];
	QLPreviewRequestSetDataRepresentation(preview, (CFDataRef)[html dataUsingEncoding:NSUTF8StringEncoding], kUTTypeHTML, (CFDictionaryRef)props);
	[pool release];
	return noErr;
}

void CancelPreviewGeneration(void* thisInterface, QLPreviewRequestRef preview)
{
	// implement only if supported
}
