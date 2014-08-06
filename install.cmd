/* Install PMRaw ver. 2.1
*/

nok = RxFuncAdd("SysLoadFuncs",  "RexxUtil", "SysLoadFuncs") ;rc = SysLoadFuncs();

HomePath = directory();

HomePath = strip(HomePath,"T","\");	/* sicherheitshalber (falls im Rootdir ausgefÅhrt) */

say "----------------------------"
say "Install PMRaw ver. 2.1"
say "----------------------------"
say "Creating a Desktop Folder Object and a Program Object:"
say "Install to "HomePath"? (Y/N)";

if Translate( SysGetKey('NoEcho') ) = "Y" then NOP;
else;do
   say "No installation";
   exit;
end;

ok = SysFileTree("PMRaw.exe","files.","F");
if files.0 = 1 then NOP;
else;do
   say "PMRaw.exe missing - installation abandoned";
   exit;
end;

/* --------------------------------------  */
/* Create PMRaw folder on WPS-desktop:    */
/* --------------------------------------  */

FolderID = "<PMRaw Objects>";

ok = SysCreateObject(   "WPFolder",           ,
                        "PMRaw 2.1 -" || "0D0A"x || "The GUI for dcraw",           ,
                        "<WP_DESKTOP>",       ,
                        "OBJECTID="FolderID";ICONFILE="HomePath"\Folder1.ico;",  ,
                        "Replace"             ,
                    );

if ok then
   say "Folder-object successfully created";
else;
   say "Error creating Folder-object: Code="ok;

/* --------------------------------------  */
/* Create sqlMate program-object:          */
/* --------------------------------------  */

ok = SysCreateObject(   "WpProgram",                                    ,
                        "PMRaw",         ,
                        FolderID,                                       ,
                        "EXENAME="HomePath"\PMRaw.exe;ICONFILE="HomePath"\PMRaw.ico;"|| ,
                        "STARTUPDIR="HomePath"\",                       ,
                        "Replace"                                       ,
                    );

if ok then
   say "Program-object successfully created";
else;do
   say "Error creating program-object: Code="ok;
   ok = beep(222,333);
   exit;
end;



say "PMRaw 2.0 - installation successfully completed";

exit;
