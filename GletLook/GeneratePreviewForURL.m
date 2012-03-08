#import <CoreFoundation/CoreFoundation.h>
#import <CoreServices/CoreServices.h>
#import <QuickLook/QuickLook.h>
#import <Cocoa/Cocoa.h>

OSStatus GeneratePreviewForURL(void *thisInterface, QLPreviewRequestRef preview, CFURLRef url, CFStringRef contentTypeUTI, CFDictionaryRef options)
{
	if (QLPreviewRequestIsCancelled(preview))
		return noErr;
	
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
	NSError *error;
	
	// Set the properties of the view
	NSMutableDictionary *props = [[[NSMutableDictionary alloc] init] autorelease];
	[props setObject:@"UTF-8" forKey:(NSString *)kQLPreviewPropertyTextEncodingNameKey];
	[props setObject:@"text/html" forKey:(NSString *)kQLPreviewPropertyMIMETypeKey];
	
	// Get icon from bundle and add as attachment
	CFBundleRef bundle = QLPreviewRequestGetGeneratorBundle(preview);
	CFURLRef iconUrl = CFBundleCopyResourceURL(bundle, CFSTR("icon.png"), NULL, NULL);
	NSString *iconUrlString = [(NSURL *)iconUrl path];
	NSData *image=[NSData dataWithContentsOfFile:iconUrlString];
	NSMutableDictionary *imgProps=[[[NSMutableDictionary alloc] init] autorelease];
	[imgProps setObject:@"image/png" forKey:(NSString *)kQLPreviewPropertyMIMETypeKey];
	[imgProps setObject:image forKey:(NSString *)kQLPreviewPropertyAttachmentDataKey];
	[props setObject:[NSDictionary dictionaryWithObject:imgProps forKey:@"icon.png"] forKey:(NSString *)kQLPreviewPropertyAttachmentsKey];
	
	// Get html template from bundle
	CFURLRef htmlUrl = CFBundleCopyResourceURL(bundle, CFSTR("gletlook.html"), NULL, NULL);
	NSString *htmlString = [NSString stringWithContentsOfURL:(NSURL*)htmlUrl encoding:NSUTF8StringEncoding error:&error];
	
	// Parse contents of selected glet file
	NSDictionary *fileDict = [NSDictionary dictionaryWithContentsOfFile:[(NSURL *)url path]];
	NSString *command = [(NSString *)CFXMLCreateStringByEscapingEntities(NULL, (CFStringRef) [fileDict objectForKey:@"Command"], NULL) autorelease];
	NSString *font = [fileDict objectForKey:@"FontFamily"];
	NSNumber *fontSize = [fileDict objectForKey:@"FontSize"];
	NSString *coords = [fileDict objectForKey:@"GeekletFrame"];
	
	// Generate html for properties
	NSMutableString *dl = [[[NSMutableString alloc] init] autorelease];
    
	
	if (font && fontSize)
		[dl appendString:[NSString stringWithFormat:@"<p>%@pt %@</p>", fontSize, font]];
	if (coords)
		[dl appendString:[NSString stringWithFormat:@"<p>%@</p>", coords]];
    [dl appendString:[NSString stringWithFormat:@"</div>"]];
    if (command)
		[dl appendString:[NSString stringWithFormat:@"<pre>%@</pre>", command]];
	
	// Combine html
	NSString *outputHTML = [NSString stringWithFormat:htmlString, [(NSURL *)url lastPathComponent], dl, nil];
	
    // Send to quicklook
	QLPreviewRequestSetDataRepresentation(preview, (CFDataRef)[outputHTML dataUsingEncoding:NSUTF8StringEncoding], kUTTypeHTML, (CFDictionaryRef)props);
	[pool release];
	return noErr;
}

void CancelPreviewGeneration(void* thisInterface, QLPreviewRequestRef preview)
{
	// implement only if supported
}
