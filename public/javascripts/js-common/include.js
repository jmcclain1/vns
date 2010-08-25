//convenience functions for including groups of js files (dependency trees, etc)

Include = {
  javascriptPath: "../",
  jsCommonPath: "js-common/",
  cacheBuster: parseInt(new Date().getTime()/(1*1000)),

  projectFile: function(fileName) {
    Include._include(fileName);
  },

  jsCommon: function(fileName) {
    Include._include(this.jsCommonPath + fileName);
  },

  jsUnit: function(fileName) {
    Include._include(this.jsCommonPath + "jsunit/app/" + fileName);
  },

  commonTest: function(fileName) {
    Include._include(this.jsCommonPath + "test/" + fileName);
  },

  thirdParty: function(fileName) {
    Include._include(this.jsCommonPath + "third-party/" + fileName);
  },

  testPageFile: function(fileName) {
    Include._include("test-pages/" + fileName);
  },

  jsUnitCore: function() {
    Include.jsUnit("jsUnitCore");
  },

  _include: function(relativePath) {
    document.write("<script src='" + this.javascriptPath + relativePath + ".js" +
                   (Include.cacheBuster ? ("?" + Include.cacheBuster) : "") +
                   "' type='text/javascript'></script>");
  }
}
