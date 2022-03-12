//const fs = require('fs')
//
//const fileContents = fs.readFileSync('./Investment.json').toString()

var exampleSource = "";
var optimize = 1;
var compiler;
var jsonSolcStandard;

function getSourceCode() {
    return document.getElementById("source").value;
}

function getVersion() {
    return document.getElementById("versions").value;
}

function status(txt) {
    document.getElementById("status").innerHTML = txt;
}

function populateVersions(versions) {
    sel = document.getElementById("versions");
    sel.innerHTML = "";

    for(var i = 0; i < versions.length; i++) {
        var opt = document.createElement('option');
        opt.appendChild( document.createTextNode(versions[i]) );
        opt.value = versions[i]; 
        sel.appendChild(opt); 
    }
}

function solcCompile(compiler) {
    status("compiling");
    document.getElementById("compile-output").value = "";
    var result = compiler.compile(getSourceCode(), optimize);
    var stringResult = JSON.stringify(result);
    document.getElementById("compile-output").value = stringResult;
    status("Compile Complete.");
}

function loadSolcVersion() {
    status("Loading Solc: " + getVersion());
    BrowserSolc.loadVersion(getVersion(), function(c) {
        compiler = c;
        console.log("Solc Version Loaded: " + getVersion());
        status("Solc loaded.  Compiling...");
        solcCompile(compiler);
    });
}

window.onload = function() {
    document.getElementById("source").value = exampleSource;

    document.getElementById("versions").onchange = loadSolcVersion;

    if (typeof BrowserSolc == 'undefined') {
        console.log("You have to load browser-solc.js in the page.  We recommend using a <script> tag.");
        throw new Error();
    }

    status("Loading Compiler");
    BrowserSolc.getVersions(function(soljsonSources, soljsonReleases) {
        populateVersions(soljsonSources);

        document.getElementById("versions").value = soljsonReleases["0.7.1"];

        loadSolcVersion();
    });
};

//autoload the most recent compiler (asynchronously)
function setupCompiler(){
  var outerThis = this;
  setTimeout(function(){
    window.BrowserSolc.getVersions(function(soljsonSources, soljsonReleases) {
      var compilerVersion = soljsonReleases[_.keys(soljsonReleases)[0]];
      console.log("Browser-solc compiler version : " + compilerVersion);
      window.BrowserSolc.loadVersion(compilerVersion, function(c) {
        compiler = c;
        outerThis.setState({statusMessage:"ready!"},function(){
          console.log("Solc Version Loaded: " + compilerVersion);
        });
      });
    });
  },1000);
}


