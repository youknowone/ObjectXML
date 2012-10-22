# Abstract
ObjectXML is objective-c object model wrapper for NSXMLParser.

# Quick tutorial

    #import <ObjectXML/ObjectXML.h>
	OXNode *node = [OXNode nodeWithContentOfString:@"<aml><title>App Title</title><data id="1">OK1</data><data id="2">OK2</data></aml>"
	NSLog(@"node name: %@", node.name); // aml

	for (OXElement *e in node.children) {
		NSLog(@"nodes: %@", e);
		// 1: nodes: <title>App Title</title>
		// 2: nodes: <data id="1">OK1</data>
		// 3: nodes: <data id="2">OK2</data>
	}

	for (OXElement *e in [node.children byName:@"data"]) {
		NSLog(@"name: %@ / id: %@ / text: %@", e.name, [e.attributes objectForKey:@"id"], e.firstTextChild);
		// 1: name: data / id: 1 / text: OK1
		// 2: name: data / id: 2 / text: OK2
	}

