//
//  ObjectXML.m
//  IdealCocoa
//
//  Created by youknowone on 10. 1. 31..
//  Copyright 2010 youknowone.org All rights reserved.
//

#define XML_DEBUG FALSE

#import "ObjectXML.h"
#import "debug.h"

@implementation OXElement
@dynamic space, name, elements, children, attributes, parent, root, text, innerText, strippedText, strippedInnerText;

+ (id)alloc {
    assert(NO);
}

- (id)init {
    assert(NO);
}

- (id)copyWithZone:(NSZone *)zone {
    assert(NO);
}

- (NSString *)descriptionWithIndent:(NSString *)indent {
    return nil;
}

- (void)setAttributes:(OXAttributeDictionary *)attributes {
    assert(NO);
}

@end


@implementation OXAttributeDictionary

- (id)initWithObjects:(const id [])objects forKeys:(const id<NSCopying> [])keys count:(NSUInteger)cnt {
    self = [self init];
    if (self != nil) {
        self->impl = [[NSDictionary alloc] initWithObjects:objects forKeys:keys count:cnt];
    }
    return self;
}

- (NSEnumerator *)keyEnumerator {
    dassert(self->impl);
    return [self->impl keyEnumerator];
}

- (id)objectForKey:(id)aKey {
    dassert(self->impl);
    return [self->impl objectForKey:aKey];
}

- (NSUInteger)count {
    dassert(self->impl);
    return [self->impl count];
}

- (NSString *)description {
    return [self->impl description];
}


@end


@implementation OXElementArray

- (void)initAsXMLElementArray {
    self->_childrenDictionary = [[NSMutableDictionary alloc] init];
}

- (id)init {
    self = [super init];
    if (self != nil) {
        self->impl = [[NSMutableArray alloc] init];
        [self initAsXMLElementArray];
    }
    return self;
}

- (id)initWithObjects:(const id [])objects count:(NSUInteger)cnt {
    self = [super init];
    if (self != nil) {
        self->impl = [[NSMutableArray alloc] initWithObjects:objects count:cnt];
        [self initAsXMLElementArray];
    }
    return self;
}

- (id)initWithCapacity:(NSUInteger)numItems {
    self = [super init];
    if (self != nil) {
        self->impl = [[NSMutableArray alloc] initWithCapacity:numItems];
        [self initAsXMLElementArray];
    }
    return self;
}

- (void)dealloc {
    [self->_childrenDictionary release];
    [self->_childrenNames release];
    [self->impl release];
    [super dealloc];
}


- (NSUInteger)count {
    dassert(self->impl);
    return [self->impl count];
}

- (void)addObject:(id)anObject {
    dassert(self->impl);
    [self->impl addObject:anObject];
}

- (id)objectAtIndex:(NSUInteger)index {
    dassert(self->impl);
    return [self->impl objectAtIndex:index];
}

- (void)removeObjectAtIndex:(NSUInteger)index {
    dassert(self->impl);
    return [self->impl removeObjectAtIndex:index];
}

- (NSString *)description {
    return [self->impl description];
}

- (NSArray *)childrenNames {
    if (self->_childrenNames == nil) {
        self->_childrenNames = [[NSMutableArray alloc] init];

        for (NSObject<OXElement> *elem in self) {
            id key = elem.name;
            if (key == nil) {
                key = [NSNull null];
            }
            if ([self->_childrenNames indexOfObject:key] == NSNotFound) {
                [self->_childrenNames addObject:key];
            }
        }
    }
    return self->_childrenNames;
}

- (NSArray *)childrenByName:(NSString *)name {
    return [self childrenByNames:name, nil];
}

- (NSArray *)byName:(NSString *)name {
    return [self childrenByNames:name, nil];
}

- (NSArray *)childrenByNames:(NSString *)name, ... {
    va_list args;
	va_start(args, name);

    NSMutableArray *names = [NSMutableArray array];
	for (NSString *arg = name; arg != nil; arg = va_arg(args, NSString*))
	{
		[names addObject:arg];
	}
	va_end(args);

    NSString *uniqueKey = [names componentsJoinedByString:@"&"];

    NSArray *result = [self->_childrenDictionary objectForKey:uniqueKey];
    if (result == nil) {
        NSMutableArray *tempResult = [NSMutableArray array];
        for (NSObject<OXElement> *elem in self) {
            id key = elem.name;
            if (key == nil) {
                key = [NSNull null];
            }
            if ([names indexOfObject:key] != NSNotFound) {
                [tempResult addObject:elem];
            }
        }
        result = [NSArray arrayWithArray:tempResult];
        [self->_childrenDictionary setObject:result forKey:uniqueKey];
    }
    return result;
}

- (NSArray *)byNames:(NSString *)name, ... {
    // FIXME: hard copy...
    va_list args;
	va_start(args, name);

    NSMutableArray *names = [NSMutableArray array];
	for (NSString *arg = name; arg != nil; arg = va_arg(args, NSString*))
	{
		[names addObject:arg];
	}
	va_end(args);

    NSString *uniqueKey = [names componentsJoinedByString:@"&"];

    NSArray *result = [self->_childrenDictionary objectForKey:uniqueKey];
    if (result == nil) {
        NSMutableArray *tempResult = [NSMutableArray array];
        for (NSObject<OXElement> *elem in self) {
            id key = elem.name;
            if (key == nil) {
                key = [NSNull null];
            }
            if ([names indexOfObject:key] != NSNotFound) {
                [tempResult addObject:elem];
            }
        }
        result = [NSArray arrayWithArray:tempResult];
        [self->_childrenDictionary setObject:result forKey:uniqueKey];
    }
    return result;
}

- (id)firstChildByName:(NSString *)name {
    return [[self childrenByNames:name, nil] objectAtIndex:0];
}

//- (id)firstChildByNames:(NSString *)name, ... {
//    return [[self childrenByNames:name, ...] objectAtIndex:0];
//}

- (NSArray *)textChildren {
    return [self childrenByName:(id)[NSNull null]];
}

- (id)firstTextChild {
    return [self.textChildren objectAtIndex:0];
}


@end


@implementation OXText

- (id)initWithString:(NSString *)string parent:(NSObject<OXElement> *)parent {
    self = [super init];
    if (self != nil) {
        self->_value = [string copy];
        self->_parent = parent;
    }
    return self;
}

+ (id)textWithString:(NSString*)string parent:(NSObject<OXElement> *)parent {
    return [[[self alloc] initWithString:string parent:parent] autorelease];
}

- (void)dealloc {
    [self->_value release];
    [self->_strippedValue release];
    [super dealloc];
}

- (id)copyWithZone:(NSZone *)zone {
    return [[[self class] alloc] initWithString:self->_value parent:self->_parent];
}

- (void)setParent:(NSObject<OXElement> *)parent {
    self->_parent = parent;
}

- (NSObject<OXElement> *)parent {
    return self->_parent;
}

- (NSString *)space {
    return nil;
}

- (NSString *)name {
    return nil;
}

- (NSString *)text {
    return self->_value;
}

- (NSString *)strippedText {
    if (self->_strippedValue == nil) {
        self->_strippedValue = [[self->_value stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] retain];
    }
    return self->_strippedValue;
}

- (NSString *)innerText {
    return nil;
}

- (NSString *)strippedInnerText {
    return nil;
}

- (NSString *)childText {
    return nil;
}

- (NSString *)description {
    return self->_value;
}

- (OXAttributeDictionary *)attributes {
    return nil;
}

-(void)setAttributes:(OXAttributeDictionary *)attributes {
    dassert(NO);
}

- (OXElementArray *)children {
    return nil;
}

- (OXElementArray *)elements {
    return nil;
}

- (NSObject<OXElement> *)root {
    return self.parent.root;
}

- (NSString *)descriptionWithIndent:(NSString *)indent {
    NSString *desc = [NSString stringWithFormat:@"%@%@", indent, self.strippedText];
    return desc;
}

@end


@implementation OXNode

- (id)initWithName:(NSString *)aName attributes:(NSDictionary *)attributeDict children:(NSArray *)elementsArray {
    self = [super init];
    if (self != nil) {
        self->_name = [aName copy];
        self->_attributes = [[OXAttributeDictionary alloc] initWithDictionary:attributeDict];
        if (elementsArray) {
            self->_children = [[OXElementArray alloc] initWithArray:elementsArray];
        } else {
            self->_children = [[OXElementArray alloc] init];
        }
    }
    return self;
}

- (void)dealloc {
    self->_name = nil;
    self->_children = nil;
    self->_attributes = nil;
    [super dealloc];
}

- (NSObject<OXElement> *)root {
    if (_root == nil) {
        if (self.parent == nil) {
            _root = self;
        } else {
            _root = self.parent.root;
        }
    }
    return _root;
}

+ (id)nodeWithName:(NSString *)name attributes:(NSDictionary *)attributes children:(NSArray *)elements {
    return [[[self alloc] initWithName:name attributes:attributes children:elements] autorelease];
}

- (NSString *)description {
    return [self descriptionWithIndent:@""];
}

- (id) copyWithZone:(NSZone *)zone {
    return [[[self class] alloc] initWithName:self.name attributes:self.attributes children:self.children];
}

- (void)setParent:(NSObject<OXElement> *)parent {
    self->_parent = parent;
}

- (NSObject<OXElement> *)parent {
    return self->_parent;
}

- (NSString *)space {
    return nil;
}

- (NSString *)name {
    return _name;
}

- (OXElementArray *)children {
    return _children;
}

- (OXElementArray *)elements {
    return self.children;
}

- (OXAttributeDictionary *)attributes {
    return _attributes;
}

- (void)setAttributes:(OXAttributeDictionary *)attributes {
    [self->_attributes autorelease];
    self->_attributes = [attributes retain];
}

- (NSString *)text {
    return nil;
}

- (NSString *)strippedText {
    return nil;
}

- (NSString *)innerText {
    NSMutableString *text = [[NSMutableString alloc] init];
    for (NSObject<OXElement> *elem in self.children) {
        [text appendString:elem.description];
    }
    return [text autorelease];
}

- (NSString *)strippedInnerText {
    return [self.innerText stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
}

- (NSString *)descriptionWithIndent:(NSString *)indent {
    NSMutableString *attrs = [[NSMutableString alloc] init];
    for (NSString *key in [self.attributes keyEnumerator]) {
        [attrs appendFormat:@" %@=\"%@\"", key, [self->_attributes objectForKey:key]];
    }
    NSMutableString *elems = [[NSMutableString alloc] init];

    NSString *deeperIndent = [indent stringByAppendingString:@"\t"];
    for (NSObject<OXElement> *e in self->_children) {
        [elems appendFormat:@"\n%@", [e descriptionWithIndent:deeperIndent]];
    }

    if ([elems length] > 0) {
        [elems appendFormat:@"\n%@", indent];
    }
    NSString *desc = [NSString stringWithFormat:@"%@<%@%@>%@</%@>", indent, _name, attrs, elems, _name];
    [attrs release];
    [elems release];
    return desc;
}

@end

@implementation OXNode (creation)

+ (id)nodeWithData:(NSData *)data {
    OXXMLSimpleParser *parser = [[[OXXMLSimpleParser alloc] initWithData:data] autorelease];
    return parser.document;
}

+ (id)nodeWithContentOfURL:(NSURL *)url {
    OXXMLSimpleParser *parser = [[[OXXMLSimpleParser alloc] initWithContentsOfURL:url] autorelease];
    return parser.document;
}

+ (id)nodeWithString:(NSString *)dataString {
    return [self nodeWithData:[dataString dataUsingEncoding:NSUTF8StringEncoding]];
}

@end


@implementation OXTextBuilder
@synthesize resources=_resources;

- (id)init {
    self = [super init];
    if (self != nil) {
        self->_resources = [[NSMutableArray alloc] init];
    }
    return self;
}

- (void)dealloc {
    [self->_resources release];
    [super dealloc];
}

- (NSString *)text {
    if (self->_value == nil) {
        self->_value = [[self->_resources componentsJoinedByString:@""] retain];
        [self->_resources release];
        self->_resources = nil;
    }
    return self->_value;
}

- (NSString *)strippedText {
    if (self->_strippedValue == nil) {
        [self text]; // build
        return [super strippedText];
    }
    return self->_strippedValue;
}

@end


@implementation OXXMLSimpleParser

@synthesize errorDelegate;

- (OXNode *)document {
    if (rootElement.children.count == 0) {
        dlog(1, @"ERROR: root document is blank at %p / %@", rootElement, rootElement);
        return nil;
    }
    return [rootElement.children objectAtIndex:0];
}

id ObjectXMLSharedErrorDelegate;
+ (void)setSharedErrorDelegate:(id)delegate {
    ObjectXMLSharedErrorDelegate = delegate;
}

+ (id)sharedErrorDelegate {
    return ObjectXMLSharedErrorDelegate;
}

#pragma mark -
#pragma mark inherited methods

- (id)initWithContentsOfURL:(NSURL *)url {
    dlog(XML_DEBUG, @"XML from URL: %@", url);
    if ((self = [super initWithContentsOfURL:url]) != nil) {
        [self parse];
    }
    return self;
}

- (id)initWithData:(NSData *)data {
    if ((self = [super initWithData:data]) != nil) {
        [self parse];
    }
    return self;
}

- (void)dealloc {
    [rootElement release];
    self.errorDelegate = nil;
    [super dealloc];
}

- (BOOL) parse {
    [self setDelegate:self];
    [self setShouldProcessNamespaces:NO]; //
    [self setShouldReportNamespacePrefixes:NO];
    [self setShouldResolveExternalEntities:NO];
    return [super parse];
}

- (NSString *)description {
    return [NSString stringWithFormat:@"{%p, document=%@\n}", self, self.document];
}

#pragma mark -
#pragma mark parser delegate;

- (void)parser:(NSXMLParser *)parser parseErrorOccurred:(NSError *)parseError {
    dlog(XML_DEBUG, @"error occured: %@", parseError);
    id<OXXMLSimpleParserErrorDelegate> delegate = self.errorDelegate;
    if ( delegate == nil ) delegate = [OXXMLSimpleParser sharedErrorDelegate];
    [delegate simpleParser:self parseErrorOccurred:parseError];
}

- (void)parserDidStartDocument:(NSXMLParser *)parser {
    dlog(XML_DEBUG, @"parsing started");
    [rootElement release];
    rootElement = [[OXNode alloc] initWithName:nil attributes:nil children:nil];
    currentElement = rootElement;
}

- (void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName attributes:(NSDictionary *)attributeDict{
    dlog(XML_DEBUG, @"<%@> start with attributes: %@", elementName, attributeDict);
    OXNode* childElement = [[OXNode alloc] initWithName:elementName attributes:attributeDict children:nil];
    [(NSMutableArray *)currentElement.children addObject:childElement];
    childElement.parent = currentElement;
    [childElement release];
    currentElement = childElement;
}

- (void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName {
    dlog(XML_DEBUG, @"</%@> end", elementName);
    //currentElement.elements = [NSArray arrayWithArray:currentElement.elements];

    for (NSInteger i = currentElement.children.count - 1; i >= 0; i--) {
        NSObject<OXElement> *elem = [currentElement.children objectAtIndex:i];
        if (elem.name == nil) {
            if (elem.strippedText.length == 0) {
                [(NSMutableArray *)currentElement.children removeObjectAtIndex:i];
                continue;
            }
        }
    }
    currentElement = currentElement.parent;
}

- (void)parser:(NSXMLParser *)parser foundCharacters:(NSString *)string {
    dlog(XML_DEBUG, @"characters found: %@", string);
    NSObject<OXElement> *lastChild = currentElement.children.lastObject;
    if (currentElement.children.count > 0 && [lastChild isKindOfClass:[OXTextBuilder class]]) {
        OXTextBuilder *builder = (id)lastChild;
        [builder.resources addObject:string];
    } else {
        OXTextBuilder *builder = [[OXTextBuilder alloc] init];
        builder.parent = currentElement;

        OXText *newText = [OXText textWithString:string parent:currentElement];
        [builder.resources addObject:newText];
        [currentElement.children addObject:builder];

        [builder release];
    }
}

- (void)parserDidEndDocument:(NSXMLParser *)parser {
    dlog(XML_DEBUG, @"XML finished");
    self.document.parent = nil;
}

@end
