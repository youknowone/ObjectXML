//
//  ObjectXML.h
//  IdealCocoa
//
//  Created by youknowone on 10. 1. 31..
//  Copyright 2010 youknowone.org All rights reserved.
//

@interface OXAttributeDictionary: NSDictionary {
    NSDictionary *impl;
}

@end

@interface OXElementArray : NSMutableArray  {
    NSMutableArray *impl;

    NSMutableArray *_childrenNames;
    NSMutableDictionary *_childrenDictionary;
}

/*!
 *  @brief Name set of children
 */
- (NSArray *)childrenNames;
/*!
 *  @brief Returns childrens by given names
 *  @details Results are cached
 */
- (NSArray *)childrenByName:(NSString *)name;
/*!
 *  @brief Returns childrens by given names
 *  @details Results are cached
 */
- (NSArray *)childrenByNames:(NSString *)name, ... NS_REQUIRES_NIL_TERMINATION;
/*!
 *  @brief Shortcut for childrenByName:
 */
- (NSArray *)byName:(NSString *)name;
/*!
 *  @brief Shortcut for childrenByNames:
 */
- (NSArray *)byNames:(NSString *)name, ... NS_REQUIRES_NIL_TERMINATION;
/*!
 *  @brief First object of childrenByName:
 */
- (id)firstChildByName:(NSString *)name;
//- (id)firstChildByNames:(NSString *)name, ...;

/*!
 *  @brief Returns text childrens
 */
- (NSArray *)textChildren;
/*!
 *  @brief First object of textChildren
 */
- (id)firstTextChild;

@end


@class OXNode;

@protocol OXElement<NSObject, NSCopying>

@property(readonly) NSString *space, *name;
@property(readonly) OXElementArray *children;
@property(readonly) OXElementArray *elements __deprecated;
@property(readonly) OXAttributeDictionary *attributes;
- (void)setAttributes:(OXAttributeDictionary *)attributes __deprecated;
@property(assign) NSObject<OXElement> *parent;
@property(readonly) NSObject<OXElement> *root;
@property(readonly) NSString *text;
@property(readonly) NSString *strippedText;
@property(readonly) NSString *innerText;
@property(readonly) NSString *strippedInnerText;

- (NSString *)descriptionWithIndent:(NSString *)indent;

@end


/*!
 *  @brief Fake interface object. Use for iteration only.
 */
@interface OXElement: NSObject<OXElement>

@end


@interface OXNode: NSObject<OXElement> {
    NSObject<OXElement> *_parent;
    NSString *_name;
    OXElementArray *_children;
    OXAttributeDictionary * _attributes;

    NSObject<OXElement> *_root;
}

- (id)initWithName:(NSString *)name attributes:(NSDictionary *)attributes children:(NSArray *)elements;
+ (id)nodeWithName:(NSString*)name attributes:(NSDictionary *)attributes children:(NSArray *)elements;

@end

@interface OXNode (creation)

+ (id)nodeWithData:(NSData *)data;
+ (id)nodeWithContentOfURL:(NSURL *)url;
+ (id)nodeWithString:(NSString *)dataString;

@end


@interface OXText: NSObject<OXElement> {
@protected
    NSObject<OXElement> *_parent;
    NSString *_value;
    NSString *_strippedValue;
}

- (id)initWithString:(NSString *)string parent:(NSObject<OXElement> *)parent;
+ (id)textWithString:(NSString *)string parent:(NSObject<OXElement> *)parent;

@end


@interface OXTextBuilder: OXText {
    NSMutableArray *_resources;
}

@property(nonatomic, readonly) NSMutableArray *resources;

@end


@protocol OXXMLSimpleParserErrorDelegate;
@interface OXXMLSimpleParser : NSXMLParser
#if __MAC_OS_X_VERSION_MAX_ALLOWED > __MAC_10_5 || __IPHONE_OS_VERSION_MAX_ALLOWED > __IPHONE_3_2
<NSXMLParserDelegate>
#endif
{
    id errorDelegate;
@protected
    NSObject<OXElement> *rootElement;
    NSObject<OXElement> *currentElement;
}

+ (void)setSharedErrorDelegate:(id<OXXMLSimpleParserErrorDelegate>)delegate;
+ (id<OXXMLSimpleParserErrorDelegate>)sharedErrorDelegate;

@property(readonly) OXNode *document;
@property(retain) id<OXXMLSimpleParserErrorDelegate> errorDelegate;

@end

@protocol OXXMLSimpleParserErrorDelegate
-(void)simpleParser:(OXXMLSimpleParser *)parser parseErrorOccurred:(NSError *)parseError;
@end

