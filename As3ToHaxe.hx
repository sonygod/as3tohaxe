/*
 * Copyright (c) 2011, TouchMyPixel & contributors
 * Original author : Tarwin Stroh-Spijer <tarwin@touchmypixel.com>
 * Contributors: Tony Polinelli <tonyp@touchmypixel.com>       
 *               Andras Csizmadia <andras@vpmedia.eu>
 * Reference for further improvements: 
 * http://haxe.org/doc/start/flash/as3migration/part1 
 * http://www.haxenme.org/developers/documentation/actionscript-developers/
 * http://www.haxenme.org/api/  
 * All rights reserved.
 * Redistribution and use in source and binary forms, with or without
 * modification, are permitted provided that the following conditions are met:
 *
 *   - Redistributions of source code must retain the above copyright
 *     notice, this list of conditions and the following disclaimer.
 *   - Redistributions in binary form must reproduce the above copyright
 *     notice, this list of conditions and the following disclaimer in the
 *     documentation and/or other materials provided with the distribution.
 *
 * THIS SOFTWARE IS PROVIDED BY THE TOUCH MY PIXEL & CONTRIBUTERS "AS IS"
 * AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
 * IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
 * ARE DISCLAIMED. IN NO EVENT SHALL THE TOUCH MY PIXEL & CONTRIBUTORS
 * BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
 * CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
 * SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
 * INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN
 * CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
 * ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF
 * THE POSSIBILITY OF SUCH DAMAGE.
 */

package;

import sys.FileSystem;
import neko.Lib;
//import neko.Sys;

using StringTools;
using As3ToHaxe;

/**
 * Simple Program which iterates -from folder, finds .mtt templates and compiles them to the -to folder
 */
class As3ToHaxe
{
    public static var keys = ["-from", "-to", "-remove", "-useSpaces"];
    
    var to:String;
    var from:String; 
    var useSpaces:String;
    var remove:String;
    var sysargs:Array<String>;
    
    var items:Array<String>;
    
    public static var basePackage:String = "away3d";
    
    private var nameSpaces:Map<String,Ns>;
    private var maxLoop:Int;
    
    public static function main() 
    {
        new As3ToHaxe();
    }
    
    public function new()
    {
        maxLoop = 1000;
        
        if (parseArgs())
        {
        
            // make sure that the to directory exists
            if (!FileSystem.exists(to)) FileSystem.createDirectory(to);
            
            // delete old files
            if (remove == "true")
                removeDirectory(to);
            
            items = [];
            // fill items
            recurse(from);

            // to remember namespaces
            nameSpaces = new Map();
            
            for (item in items)
            {
                // make sure we only work wtih AS fiels
                var ext = getExt(item);
                switch(ext)
                {
                    case "hx": 
                        doConversion(item);
                }
            }
            
            // build namespace files
            buildNameSpaces();
        }
    }
    
    private function doConversion(file:String):Void
    {        
        var fromFile = file;
        var toFile = to + "/" + file.substr(from.length + 1, file.lastIndexOf(".") - (from.length)) + "hx";
        
        var rF = "";
        var rC = "";
        
        var b = 0;
        
        /* -----------------------------------------------------------*/
        // create the folder if it doesn''t exist
        var dir = toFile.substr(0, toFile.lastIndexOf("/"));
        createFolder(dir);
        
        var s = sys.io.File.getContent(fromFile);
        
        /* -----------------------------------------------------------*/
        // space to tabs      
        s = quickRegR(s, "    ", "\t");
        
       
       
      
        s = quickRegR(s,"for\\(var ([a-zA-Z0-9]+) \\: ([a-zA-Z0-9]+) in", "for($1 in ");
       
        s = quickRegR(s, "\\*\\/;", "*/");
		//s = quickRegR(s, "\\bp\\.x\\b", "int(p.x)");
		//s = quickRegR(s, "\\bp\\.y\\b", "int(p.y)");
		//s = quickRegR(s, "new BitmapData\\(rect.width, rect.height, true, 0\\)", "new BitmapData(int(rect.width), int(rect.height), true, 0)");
		s = quickRegR(s, "import msignal.Signal1;", "import msignal.Signal;");
		s = quickRegR(s, ": EventSignal", ": EventSignal<Dynamic,Dynamic>");
		s = quickRegR(s, ": Signal1", ": Signal1<Dynamic>");
		s = quickRegR(s, "import msignal.Signal0", "import msignal.Signal");
        s = quickRegR(s, "sex1", "set");
		s = quickRegR(s, "gex1", "get");
		s = quickRegR(s, "int\\(([a-zA-Z0-9\\+\\- \\*\\/\\.\\_]+)\\)", "Std.int($1)");
		s = quickRegR(s, "static @:isVar", " @:isVar static");
		s = quickRegR(s, "import flash.net.NavigateToURL;", "");
		s = quickRegR(s, ": Function", ": Dynamic");
		s = quickRegR(s, "getTimer\\(\\)", "flash.Lib.getTimer()");
		s = quickRegR(s, "import flash.utils.GetTimer;", "");
		s = quickRegR(s, "([a-zA-Z0-9]+)\\.toString\\(\\)", "Std.string($1)");
		
		s = quickRegR(s, "new Error", "new flash.errors.Error");
		s = quickRegR(s, "/\\*\\* WARNING ", ";/** WARNING ");
		s = quickRegR(s, "name : aKeyName", "name : aKeyName,");
		s = quickRegR(s, "import Lambda;", "using Lambda;");
		s = quickRegR(s, "catch\\(e : Error\\)", "catch(e:flash.errors.Error)");
		
		  // s = quickRegR(s, "static public var", "static inline var");
		  trace("path"+toFile);
        var o = sys.io.File.write(toFile, true);
        o.writeString(s);
        o.close();
        
        /* -----------------------------------------------------------*/
        
        // use for testing on a single file
        //Sys.exit(1);
    }
    
    private function logLoopError(type:String, file:String)
    {
        trace("ERROR: " + type + " - " + file);
    }
    
    private function buildNameSpaces()
    {
        // build friend namespaces!
        trace(nameSpaces);
    }
    
    public static function quickRegR(str:String, reg:String, rep:String, ?regOpt:String = "g"):String
    {
        return new EReg(reg, regOpt).replace(str, rep);
    }
    
    public static function quickRegM(str:String, reg:String, ?numMatches:Int = 1, ?regOpt:String = "g"):Array<String>
    {
        var r = new EReg(reg, regOpt);
        var m = r.match(str);
        if (m) {
            var a = [];
            var i = 1;
            while (i <= numMatches) {
                a.push(r.matched(i));
                i++;
            }
            return a;
        }
        return [];
    }
    
    private function createFolder(path:String):Void
    {
        var parts = path.split("/");
        var folder = "";
        for (part in parts)
        {
            if (folder == "") folder += part;
            else folder += "/" + part;
            if (!FileSystem.exists(folder)) FileSystem.createDirectory(folder);
        }
    }
    
    private function parseArgs():Bool
    {
        // Parse args
        var args = Sys.args();
        for (i in 0...args.length)
            if (Lambda.has(keys, args[i]))
                Reflect.setField(this, args[i].substr(1), args[i + 1]);
            
        // Check to see if argument is missing
        if (to == null) { Lib.println("Missing argument '-to'"); return false; }
        if (from == null) { Lib.println("Missing argument '-from'"); return false; }
        
        return true;
    }
    
    public function recurse(path:String)
    {
		trace("path"+path);
        var dir = FileSystem.readDirectory(path);
        
        for (item in dir)
        {
            var s = path + "/" + item;
            if (FileSystem.isDirectory(s))
            {
                recurse(s);
            }
            else
            {
                var exts = ["hx"];
                if(Lambda.has(exts, getExt(item)))
                    items.push(s);
            }
        }
    }
    
    public function getExt(s:String)
    {
        return s.substr(s.lastIndexOf(".") + 1).toLowerCase();
    }
    
    public function removeDirectory(d, p = null)
    {
        if (p == null) p = d;
        var dir = FileSystem.readDirectory(d);

        for (item in dir)
        {
            item = p + "/" + item;
            if (FileSystem.isDirectory(item)) {
                removeDirectory(item);
            }else{
                FileSystem.deleteFile(item);
            }
        }
        
        FileSystem.deleteDirectory(d);
    }
    
    public static function fUpper(s:String)
    {
        return s.charAt(0).toUpperCase() + s.substr(1);
    }
}

typedef Ns = {
    var name:String;
    var classDefs:Map<String,String>;
}