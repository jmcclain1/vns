Include.jsCommonPath = "./";

// JsUnit/prototype
Include.jsUnit("jsUnitCore");
Include.thirdParty("prototype-1.5.0");
Include.thirdParty("effects-1.5.0");
Include.thirdParty("yui-0.12.2/yahoo/yahoo");
Include.thirdParty("yui-0.12.2/dragdrop/dragdrop");
Include.thirdParty("yui-0.12.2/dom/dom");
Include.thirdParty("aim");

// Utilities we have
Include.jsCommon("dombuilder");
Include.jsCommon("utils");
Include.jsCommon("string_utils");
Include.jsCommon("pivotal/pivotal");
Include.jsCommon("pivotal/placement");
Include.jsCommon("pivotal/popup");
Include.jsCommon("pivotal/roundy_corners");

// Test mocks
Include.commonTest("ajax");
Include.commonTest("assertions");
Include.commonTest("clock");
Include.commonTest("gmap");
Include.testPageFile("test_helper");
