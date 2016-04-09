//
//  ObjectXML.h
//  IdealCocoa
//
//  Created by youknowone on 10. 1. 31..
//  Copyright 2010 youknowone.org All rights reserved.
//

@class OXAttributeDictionary, OXElementArray;
@class OXNode;

/*!
 *  @brief Common interface of XML element;
 *
 */
@protocol OXElement<NSObject, NSCopying>

//! @brief Namespace. Not impelented yet.
@property(readonly) NSString *space;
//! @brief Node name.
@property(readonly) NSString *name;
//! @brief Node chiledren.
@property(readonly) OXElementArray *children;
//! @brief Node attributes.
@property(readonly) OXAttributeDictionary *attributes;
//! @brief Node parents.
@property(assign) NSObject<OXElement> *parent;
//! @brief Node root.
@property(readonly) NSObject<OXElement> *root;
//! @brief Text value. (If element is text)
@property(readonly) NSString *text;
/*!
 *  @brief text value trimming whitespaces from head and tail.
 *  @see text
 */
@property(readonly) NSString *strippedText;
//! @brief Text content of node as like Javascript innerHTML.
@property(readonly) NSString *innerText;
/*!
 *  @brief innerText value trimming whitespaces from head and tail.
 *  @see innerText
 */
@property(readonly) NSString *strippedInnerText;

//! @brief description text with indent depth.
- (NSString *)descriptionWithIndent:(NSString *)indent;

//! @deprecated Use children
@property(readonly) OXElementArray *elements __deprecated;
//! @deprecated Setter is not available
- (void)setAttributes:(OXAttributeDictionary *)attributes __deprecated;

@end


/*!
 *  @brief Fake interface object. Use for iteration only.
 */
@interface OXElement: NSObject<OXElement>

@end


/*!
 *  @brief Node element
 *  @details This is common, basic XML element type. Node has name, attribute, children and innerText
 */
@interface OXNode: NSObject<OXElement> {
    NSObject<OXElement> *_parent;
    NSString *_name;
    OXElementArray *_children;
    OXAttributeDictionary * _attributes;

    NSObject<OXElement> *_root;
}

/*!
 *  @brief Initialize a node element.
 *  @param name
 *      node name. This should not be nil.
 *  @param attributes
 *      node attributes. nil for no attribute.
 *  @param children
 *      node children. nil for no children.
 *  @return An initialized node element from given parameters
 */
- (instancetype)initWithName:(NSString *)name attributes:(NSDictionary *)attributes children:(NSArray *)children NS_DESIGNATED_INITIALIZER;
/*!
 *  @brief Creates and returns a node element.
 *  @see initWithName:attributes:children:
 */
+ (instancetype)nodeWithName:(NSString*)name attributes:(NSDictionary *)attributes children:(NSArray *)children;

@end

/*!
 *  @brief OXNode creations from parser shortcuts
 */
@interface OXNode (creation)

//! @brief Parse a node from data (Containing string)
+ (instancetype)nodeWithData:(NSData *)data;
/*!
 *  @brief Parse a node from contents of URL.
 *  @details About local files, use NSURL -filrURLWithPath:. This can be shorten with FoundationExtension from https://github.com/youknowone/FoundationExtension
 */
+ (instancetype)nodeWithContentOfURL:(NSURL *)URL;
//! @brief Parse a node from data string
+ (instancetype)nodeWithString:(NSString *)dataString;

@end

/*!
 *  @brief Text element
 *  @details This is text element between XML element type. Text has text.
 */
@interface OXText: NSObject<OXElement> {
@protected
    NSObject<OXElement> *_parent;
    NSString *_value;
    NSString *_strippedValue;
}

/*!
 *  @brief Initialize a text element.
 *  @param string
 *      text element data string.
 *  @param parent
 *      Parent of element. Text element is assumed that has a parent always.
 *  @return An initialized text element from given parameters
 */
- (instancetype)initWithString:(NSString *)string parent:(NSObject<OXElement> *)parent NS_DESIGNATED_INITIALIZER;
/*!
 *  @brief Creates and returns a text element.
 *  @see initWithString:parent:
 */
+ (instancetype)textWithString:(NSString *)string parent:(NSObject<OXElement> *)parent;

@end


/*!
 *  @brief Text element builder for parser
 *  @details This class is used for parser internal implementation
 */
@interface OXTextBuilder: OXText {
    NSMutableArray *_resources;
}

/*!
 *  @brief Resources to be combined to text element.
 */
@property(nonatomic, readonly) NSMutableArray *resources;

@end


/*!
 *  @brief Attributes with dictionary interface.
 *  @details No additional functions yet. Component of OXNode.
 */
@interface OXAttributeDictionary: NSDictionary {
    NSDictionary *impl;
}

@end


/*!
 *  @brief Children with array interface.
 *  @details Component of OXNode.
 */
@interface OXElementArray : NSMutableArray  {
    NSMutableArray *impl;

    NSMutableArray *_childrenNames;
    NSMutableDictionary *_childrenDictionary;
}

/*!
 *  @brief Name set of children
 */
@property (NS_NONATOMIC_IOSONLY, readonly, copy) NSArray *childrenNames;
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
@property (NS_NONATOMIC_IOSONLY, readonly, copy) NSArray *textChildren;
/*!
 *  @brief First object of textChildren
 */
@property (NS_NONATOMIC_IOSONLY, readonly, strong) id firstTextChild;

@end


@protocol OXXMLSimpleParserErrorDelegate;

/*!
 *  @interface OXXMLSimpleParser
 *  @brief ObjectXML parser from NSXMLParser
 *  @details Use OXNode creation methods for easy usage. This is not cleaned up in best form yet.
 */
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

@property(weak, readonly) OXNode *document;
@property(strong) id<OXXMLSimpleParserErrorDelegate> errorDelegate;

@end

@protocol OXXMLSimpleParserErrorDelegate
-(void)simpleParser:(OXXMLSimpleParser *)parser parseErrorOccurred:(NSError *)parseError;
@end

