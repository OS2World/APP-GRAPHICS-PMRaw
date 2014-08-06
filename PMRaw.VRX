/*:VRX         Main
*/
/*  Main
*/
Main:
/*  Process the arguments.
    Get the parent window.
*/
    parse source . calledAs .
    parent = ""
    argCount = arg()
    argOff = 0
    if( calledAs \= "COMMAND" )then do
        if argCount >= 1 then do
            parent = arg(1)
            argCount = argCount - 1
            argOff = 1
        end
    end; else do
        call VROptions 'ImplicitNames'
    end
    InitArgs.0 = argCount
    if( argCount > 0 )then do i = 1 to argCount
        InitArgs.i = arg( i + argOff )
    end
    drop calledAs argCount argOff

/*  Load the windows
*/
    call VRInit
    parse source . . spec
    _VREPrimaryWindowPath = ,
        VRParseFileName( spec, "dpn" ) || ".VRW"
    _VREPrimaryWindow = ,
        VRLoad( parent, _VREPrimaryWindowPath )
    drop parent spec
    if( _VREPrimaryWindow == "" )then do
        call VRMessage "", "Cannot load window:" VRError(), ,
            "Error!"
        _VREReturnValue = 32000
        signal _VRELeaveMain
    end

/*  Process events
*/
    call Init
    signal on halt
    do while( \ VRGet( _VREPrimaryWindow, "Shutdown" ) )
        _VREEvent = VREvent()
        interpret _VREEvent
    end
_VREHalt:
    _VREReturnValue = Fini()
    call VRDestroy _VREPrimaryWindow
_VRELeaveMain:
    call VRFini
exit _VREReturnValue

VRLoadSecondary:
    __vrlsWait = abbrev( 'WAIT', translate(arg(2)), 1 )
    if __vrlsWait then do
        call VRFlush
    end
    __vrlsHWnd = VRLoad( VRWindow(), VRWindowPath(), arg(1) )
    if __vrlsHWnd = '' then signal __vrlsDone
    if __vrlsWait \= 1 then signal __vrlsDone
    call VRSet __vrlsHWnd, 'WindowMode', 'Modal' 
    __vrlsTmp = __vrlsWindows.0
    if( DataType(__vrlsTmp) \= 'NUM' ) then do
        __vrlsTmp = 1
    end
    else do
        __vrlsTmp = __vrlsTmp + 1
    end
    __vrlsWindows.__vrlsTmp = VRWindow( __vrlsHWnd )
    __vrlsWindows.0 = __vrlsTmp
    do while( VRIsValidObject( VRWindow() ) = 1 )
        __vrlsEvent = VREvent()
        interpret __vrlsEvent
    end
    __vrlsTmp = __vrlsWindows.0
    __vrlsWindows.0 = __vrlsTmp - 1
    call VRWindow __vrlsWindows.__vrlsTmp 
    __vrlsHWnd = ''
__vrlsDone:
return __vrlsHWnd

/*:VRX         CB_BatchJPG_Click
*/
CB_BatchJPG_Click: 

if VRGet("CB_BatchJPG","Set") then Ena = 1; else; Ena = 0;

ok = VRSet("DT_39",         "Enabled", Ena );
ok = VRSet("DT_40",         "Enabled", Ena );
ok = VRSet("SPIN_JpgQual",  "Enabled", Ena );
ok = VRSet("CB_BatchRes",   "Enabled", Ena );
ok = VRSet("CB_BatchNoTif", "Enabled", Ena );

ok = VRSet("CB_BatchNoTif","Set", Ena );    /* Wenn kein JPG, dann darf auch nicht TIFF deleted werden  */


return

/*:VRX         CB_BatchRes_Click
*/
CB_BatchRes_Click: 

if VRGet("CB_BatchRes","Set") then Ena = 1; else; Ena = 0;

ok = VRSet("SPIN_ResRatio", "Enabled", Ena );

return 0;

/*:VRX         CB_BatchTargetDir_Click
*/
CB_BatchTargetDir_Click: 

ok = VRSet("PB_BatchBrowse",    "Enabled", VRGet("CB_BatchTargetDir","Set") );
ok = VRSet("EF_BatchTargetDir", "Enabled", VRGet("CB_BatchTargetDir","Set") );

return

/*:VRX         CB_WhiteBal_Click
*/
CB_WhiteBal_Click: 

Enabled = VRGet("CB_WhiteBal","Set");

ok = VRSet("GB_WhiteBal","Enabled",Enabled);
ok = VRSet("DT_22","Enabled",Enabled);
ok = VRSet("DT_23","Enabled",Enabled);
ok = VRSet("DT_24","Enabled",Enabled);

ok = VRSet("SL_Redmult",  "Enabled",Enabled);
ok = VRSet("SL_Greenmult","Enabled",Enabled);
ok = VRSet("SL_Bluemult", "Enabled",Enabled);

if (Enabled) then do

   ok = VRSet("SL_Redmult",  "RibbonColor", "Red");
   ok = VRSet("SL_Greenmult","RibbonColor", "Green");
   ok = VRSet("SL_Bluemult", "RibbonColor", "Blue");

   ok = VRSet("EF_Redmult",  "BackColor", "Red");
   ok = VRSet("EF_Greenmult","BackColor", "Green");
   ok = VRSet("EF_Bluemult", "BackColor", "Blue");
   ok = VRSet("EF_Bluemult", "ForeColor", "White");

end;
else;do
   ok = VRSet("SL_Redmult",  "RibbonColor", "Palegray");
   ok = VRSet("SL_Greenmult","RibbonColor", "Palegray");
   ok = VRSet("SL_Bluemult", "RibbonColor", "Palegray");

   ok = VRSet("EF_Redmult",  "BackColor", "Palegray");
   ok = VRSet("EF_Greenmult","BackColor", "Palegray");
   ok = VRSet("EF_Bluemult", "BackColor", "Palegray");
   ok = VRSet("EF_Bluemult", "ForeColor", "Black");

end;

return

/*:VRX         CN_CamFiles_Click
*/
CN_CamFiles_Click: 

Call ZCount_Selected;

Call ZSet_Counter "NumFile_Sel";
Call ZSet_Counter "FileSiz_Sel"; 

return;

/*:VRX         CN_CamFiles_ContextMenu
*/
CN_CamFiles_ContextMenu: 

ImpoDir = VRGet("EF_Cam_ImpDir", "Value");
if ImpoDir = "" then do
   ok = VRMessage( VRWindow(), "You must first specify a directory for the image-files to copy/move to","","E");
   RETURN -1;
end;

!CurRec = VRInfo("Record");

if !CurRec = "" then Ena = 0; else; Ena = 1;

ok = VRSet("MMCam_Copy", "Enabled", Ena );
ok = VRSet("MMCam_Move", "Enabled", Ena );
ok = VRSet("MMCam_Load", "Enabled", Ena );

ok = VRMethod("MMCam", "Popup");

return

/*:VRX         CN_CamFiles_DoubleClick
*/
CN_CamFiles_DoubleClick: 

!CurRec = VRInfo("Record");

Call MMCam_Load_Click;

return 0;

/*:VRX         EF_z_ContextMenu
*/
EF_z_ContextMenu:

EF_1_ContextMenu: 
EF_2_ContextMenu: 
EF_3_ContextMenu: 
EF_4_ContextMenu: 
EF_5_ContextMenu: 

!Obj = VRInfo("Object");
ok = VRMethod("MM_Ack", "Popup" );

return;

/*:VRX         Fini
*/
Fini:
    window = VRWindow()
    call VRSet window, "Visible", 0
    drop window
return 0

/*:VRX         Halt
*/
Halt:
    signal _VREHalt
return

/*:VRX         Init
*/
Init:

nok = RxFuncAdd("SysLoadFuncs",  "RexxUtil", "SysLoadFuncs") ;rc = SysLoadFuncs();
nok = RxFuncAdd("RxExtra",       "RxExtras", "RxExtra")      ;rc = RxExtra("LOAD");
nok = RxFuncAdd("FileLoadFuncs", "FILEREXX", "FileLoadFuncs");rc = FileLoadFuncs();

INIFile = "PMRaw.ini";

Def_PrfName = "default.prf";   /* enthÑlt auch dcraw.exe-Name !!   */

YGlob.YVers      = "2.4";      /* auch in WIN_Ack                  */
YGlob.YProg      = "PMRaw";
YGlob.YHomeDir   = directory() || "\";
YGlob.Ydcraw.exe = SysINI( Def_PrfName, "Settings", "dcraw.exe" );

YGlob.YPrfName = SysINI( INIFile, "Settings", "PrfName" );
if YGlob.YPrfName = "ERROR:" then
   YGlob.YPrfName = Def_PrfName;

ok = VRSet("EF_PrfName","Value", YGlob.YPrfName );

if 1 then ok = VRRedirectStdIO("OFF"); /* Makes console invisible   */

say "Home="YGlob.YHomeDir"!";

/* Check for valid dcraw.exe-name:      */
if \VRFileExists( YGlob.Ydcraw.exe ) then do
   Call XSay "Severe error! no valid dcraw.exe found (looking for "YGlob.Ydcraw.exe")!";
   ok = beep(333,496);
end;


PPM_File = "";

But_OC.1 = "OK";
But_OC.2 = "Cancel";
But_OC.0 = 2;

/* ----------------------           */
/* Preloading of windows:           */
/* ----------------------           */
ok = VRLoadSecondary("WIN_Wait");   /* please wait...   */
ok = VRLoadSecondary("WIN_Verbos"); /* dcraw-messages   */
ok = VRLoadSecondary("WIN_Camdata");

ok = VRSet("Window1", "Userdata", VRGet("Window1","Caption") );    /* save for later use        */

ok = VRSet("DT_Laengenberechnung","Font", VRGet("DT_Filename","Font") );    /* angleichen Font  */

ok = VRSet("GB_ChromAberr", "Userdata", VRGet("GB_ChromAberr", "Caption") );

ok = VRSet("RB_WB_Auto",   "Userdata", "-a" );
ok = VRSet("RB_WB_Camera", "Userdata", "-w" );

ok = VRSet("RB_PPM",  "Userdata", "" );
ok = VRSet("RB_TIFF", "Userdata", "-T" );

ok = VRSet("RB_Out8Bit",   "Userdata", "" );    /* neu: 8Bit = default  */
ok = VRSet("RB_Out16Bit",  "Userdata", "-4" );

ok = VRSet("RB_ColSpc_raw",   "Userdata", "-o 0" );
ok = VRSet("RB_ColSpc_RGB",   "Userdata", "-o 1" );
ok = VRSet("RB_ColSpc_Adobe", "Userdata", "-o 2" );
ok = VRSet("RB_ColSpc_Wide",  "Userdata", "-o 3" );
ok = VRSet("RB_ColSpc_Kodak", "Userdata", "-o 4" );

ok = VRSet("SL_Brightness","Userdata", "-b" );
ok = VRSet("SL_Redmult",   "Userdata", "-r" );
ok = VRSet("SL_Bluemult",  "Userdata", "-l" );

ok = VRSet("CB_RGGB",       "Userdata", "-f" );

ok = VRSet("CB_AutoBright", "Userdata", "-W" ); /* umgekehrt: -W => No AutoBrightness !!    */

Call SL_Qual_Change;
Call SL_Denoise_Change;
Call SL_MedFilt_Change;
Call SL_Brightness_Change "SL_Brightness";
Call SL_RedMult_Change    "SL_RedMult";
Call SL_GreenMult_Change  "SL_GreenMult";
Call SL_BlueMult_Change   "SL_BlueMult";
Call SL_ChromAberRed_Change;
Call SL_ChromAberBlue_Change;

ok = VRSet("MMRaw",  "Enabled", 0 );
ok = VRSet("PB_Go",  "Enabled", 0 );

ok = VRSet("PICT_1", "Userdata", VRGet("PICT_1", "Width") VRGet("PICT_1", "Height") );
ok = VRSet("PICT_2", "Userdata", VRGet("PICT_2", "Width") VRGet("PICT_2", "Height") );

Call ZInit_CamData;

/* ----------------------------------------     */
/* Hintergrund-Farben wiederholen:              */
/* ----------------------------------------     */

Val = SysINI( INIFile, "BackColor", "Window1" );
if Val <> "ERROR:" then ok = VRSet("Window1", "BackColor", Val );

Val = SysINI( INIFile, "BackColor", "PICT_1" );
if Val <> "ERROR:" then ok = VRSet("PICT_1", "BackColor", Val );

/* ----------------------------------------     */
/* INI-Werte setzen:                            */
/* ----------------------------------------     */

Val = SysINI( INIFile, "Settings", "JpgQual" );
if Val <> "ERROR:" then YGlob.YJpgQual = Val;
                   else;YGlob.YJpgQual = 75;

Val = SysINI( INIFile, "Settings", "JpgProg" );
if Val <> "ERROR:" then YGlob.YJpgProg = Val;
                   else;YGlob.YJpgProg = 0;

Val = SysINI( INIFile, "Settings", "PPMPath" );
if Val <> "ERROR:" then YGlob.YPPMPath = Val;
                   else;YGlob.YPPMPath = "<rawdir>";

Val = SysINI( INIFile, "Settings", "RAW_Ext" );
if Val <> "ERROR:" then YGlob.YRAW_Ext = Val;
                   else;YGlob.YRAW_Ext = "*.RAW;*.CRW;*.CR2";

ok = VRSet( "GB_HowTo",  "Visible", \(SysINI(INIFile, "Settings", "DontShow")=1) );

Call ZLoad_Profile YGlob.YPrfName;

/* Erstmaliges Setzen der Default-Werte:    */
Call CB_WhiteBal_Click;

DriveLetrs = "A: B: C: D: E: F: G: H: I: J: K: L: M: N: O: P: Q: R: S: T: U: V: W: X: Y: Z:";
value      = RxSysValues( "SysInfo." )
BootDrv    = SysInfo.Boot_Drive;
BootDrive  = word(DriveLetrs, BootDrv);

/* --------------------------           */
/* Feststellen Landessprache:           */
/* --------------------------           */
rc  = RxQueryCountryInfo( "Countrydata." )
CountryCode = Countrydata.Country_Code;
if CountryCode = 40 ,   /* Schweiz      */
 | CountryCode = 41 ,
 | CountryCode = 43 ,
 | CountryCode = 49
then;do;
   YLang.Ger = 1;YLang.Eng = 0;
end;
else;do;
   YLang.Eng = 1;YLang.Ger = 0;
end;
YLang.Suffx.Eng = "E";
YLang.Suffx.Ger = "D";

if YLang.Eng then   YLang.Suffix = YLang.Suffx.Eng;   /* Suffix fÅr ...             */
else;               YLang.Suffix = YLang.Suffx.Ger;   /* ... die externen Help-File */


if ( YLang.Ger ) then do
   Call XSay "Willkommen bei "YGlob.YProg" Ver. "YGlob.YVers", Home=" || YGlob.YHomeDir || ".";
end;
else;do
   Call XSay "Welcome to "YGlob.YProg" ver. "YGlob.YVers", Home=" || YGlob.YHomeDir || ".";
end;

/* -----------------------          */
/* Help-Modul adressieren:          */
/* -----------------------          */
ok = VRSet("Window1", "HelpFile",  "MainHlp"||YLang.Suffix||".inf" );
ok = VRSet("Window1", "HelpTitle", "General Help for PMRaw" );

/* -------------------------------      */
/* Text "Preview-Image" einsetzen:      */
/* -------------------------------      */
DT_Preview = VRCreate("GB_1", "DESCRIPTIVETEXT",        ,
                      "Caption", "Preview-Image", ,
                      "Font", "9.WarpSans",       ,
                      "left", 360, "Top", 490,    ,
                      "Width", 690, "Height", 300,    ,
                      "Autosize", 1               ,
                     );

ok = VRSet("PICT_2", "Visible", 0);

    window = VRWindow()
    call VRMethod window, "CenterWindow"
    call VRSet window, "Visible", 1
    call VRMethod window, "Activate"
    drop window


IMG_FS = Initargs.1;
if VRFileExists(IMG_FS) then 
   Call MM_Load_Click_2;

return;     /* ... from INIT            */

/* ----------------------------------------------------    */
/* AuffÅllen links Zahl mit fÅhrenden Nullen bzw. PadC:    */
/* ----------------------------------------------------    */
PadZero: procedure
    What = arg(1);
    Leng = arg(2);
    PadC = arg(3);  if PadC == "" then PadC = "0";   /* Padding-Char.    */
    return left(PadC, Leng-length(What), PadC)||What;

/* ------------------------------       */
/* XSay: Neu: 'REPL'-Param              */
/*       fÅr im Stand lfd. Zeilen       */
/* ------------------------------       */
XSay: procedure
What = arg(1);
Aux  = arg(2);  /* erklÑrender Text, nur wenn What <> Leer   */
Mode = arg(3);  /* "REPL" | ""  */

if strip(What) = "" | What="TOF" | What="BOF" then return;

if Aux <> "" then
   What = Aux||What;

What = time()"."substr(time("LONG"),10,2)"> "What;

if Mode= "REPL" then do
   ok = VRSet("LB_XSay", "Painting", 0);
   Indx = VRGet("LB_XSay", "Count");
   ok = VRMethod("LB_XSay", "Delete", Indx);
end;

/* ++ debug: ++ */
if (0) then say What;

ok = VRMethod("LB_XSay", "Addstring", What);
ok = VRSet("LB_XSay", "Selected", VRGet("LB_XSay", "Count"));
ok = VRSet("LB_XSay", "Painting", 1);
return 0;

/*:VRX         LB_BatchFiles_Click
*/
LB_BatchFiles_Click: 

ok = VRMethod("LB_BatchFiles", "GetSelectedList", "Sels." );

ok = VRSet("CB_BatchSelOnly","Set", (Sels.0 > 0) );

return

/*:VRX         LB_XSay_DoubleClick
*/
LB_XSay_DoubleClick: 

Buttons.1 = "OK";
Buttons.2 = "Put on Clipboard";
Buttons.0 =  2;

ok = VRMethod("LB_XSay", "GetSelectedList", "indexes.");

What = VRMethod("LB_XSay", "GetString", indexes.1);

/* Bereinigen dcraw-Kommandozeile um XSay-Timestamp:   */
What = strip( subword(What,2),,"'");

ok = VRMessage( VRWindow(), What,    ,
                "Message in the Log Window", "I", "Buttons.", 2, 1          ,
              );


if ok = 2 then do
   ok = VRMethod( "Application", "PutClipboard", What );
end;

return 0;

/*:VRX         MLE_PTP_ContextMenu
*/
MLE_PTP_ContextMenu: 
ok = VRMethod("MMCam_Mess", "Popup");
return

/*:VRX         MM_Cam_Click
*/
MM_Cam_Click: 

ok = VRSet("Window1", "Visible", 0 );
Call VRLoadSecondary "WIN_Cam", "WAIT";

ok = VRSet("Window1", "Visible", 1 );
ok = VRSet("Window1", "SiblingOrder", 1 );

if IMG_FS <> "" then do

   ok = VRSet("PICT_1", "Painting", 0);
   ok = VRSet("PICT_1", "Autosize", 0);

   Call MM_Load_Click_2;
end;

return

/*:VRX         MM_Exit_Click
*/
MM_Exit_Click: 
Call PB_Exit_Click;
return

/*:VRX         MM_Load_Click
*/
MM_Load_Click: 


Call XSay "gbmsize=" || SysSearchPath("PATH", "gbmsize.exe");

ok = VRSet("MMRaw",  "Enabled", 0 );
ok = VRSet("PB_Go",  "Enabled", 0 );

ok = VRSet("PICT_1", "Painting", 0);
ok = VRSet("PICT_2", "Painting", 0);

ok = VRSet("PICT_1", "Autosize", 0);
ok = VRSet("PICT_1", "Width",  word( VRGet("PICT_1", "Userdata"),1) );
ok = VRSet("PICT_1", "Height", word( VRGet("PICT_1", "Userdata"),2) );


ok = VRSet("DT_Preview", "Visible", 0);     /* 'JPG-Preview'  (zunÑchst)        */

Bak_Dir = directory();

ImgDir = SysINI( INIFile, "Settings", "ImgDir" );
if ImgDir <> "ERROR:" then
   ok = directory(ImgDir);

RAW_Ext = SysINI( YGlob.YHomeDir||INIFile, "Settings", "RAW_Ext");
if RAW_Ext = "ERROR:" then
   RAW_Ext = "*.*";

IMG_FS = VRFileDialog( VRWindow(), "Select RAW-format-image:", "OPEN", RAW_Ext );

ok = directory(Bak_Dir);

if IMG_FS = "" then do
   ok = VRSet("PICT_1", "Painting", 1);
   ok = VRSet("PICT_2", "Painting", 1);
   RETURN;
end;


MM_Load_Click_2:        /* <==== Entry-2 === bringt IMG_FS mit <================    */

ok = VRSet("PICT_1", "PicturePath", "");    /* Clear Main-Picture               */
ok = VRSet("PICT_2", "PicturePath", "");

ImgDir = filespec("drive",IMG_FS) || filespec("path",IMG_FS);
ImgDir = strip(ImgDir,"T","\");

ok = SysINI( INIFile, "Settings", "ImgDir", ImgDir );

Call ZRefresh_CamData;
ok = VRSet("MMRaw", "Enabled", 0 );
ok = VRSet("PB_ShowCamdata", "Enabled", 0 );

Call ZDel_Intermediate "PPM", PPM_File;     /* falls vorhanden aus voriger Image-Verarbeitung: delete PPM   */

/* Vorbereitungen fÅr Thumbnail-Processing:                 */
Posi  = Lastpos(".",IMG_FS);
FT    = translate( right(IMG_FS, length(IMG_FS)-Posi) );
Rumpf = left(IMG_FS, Posi);     /* keep Rumpf!  (inkl. '.') */
Ext   = FT;

/* -------------------              */
/* Extract Thumbnail:               */
/* -------------------              */

cmd = YGlob.ydcraw.exe '-e' '"'IMG_FS'"';   /* extract IMG_nnn.thumb.jpg            */

Call XSay "Extracting thumbnail-image ...";
cmd;
if RC = 0 then
   Call XSay "...done!";
else;
   Call XSay "Error extracting thumbnail, RC="RC;

ThumbFile = Rumpf || "thumb.jpg";   /* wird so von dcraw erzeugt        */

ok = SysFileTree( ThumbFile, "files.", "FO" );
if files.0 = 1 then do
   ok = ZDispl_NonBMP( ThumbFile, "PICT_2" );
   ok = VRSet("DT_Preview", "Visible", 1);

   Call ZDel_Intermediate "THM", ThumbFile, "JPG";  /* sofort wieder lîschen Thumbfile          */

end;

/* Alternativ: Schau, ob vielleicht ein gleichnamiges JPG-Bild im Verzeichnis sich befindet:    */

JPG_File = Rumpf || "*";

if VRGet("PICT_2", "PicturePath") = "" then do
   ok = ZDispl_NonBMP( "NoPreview.bmp", "PICT_2" );
end;

ok = VRDestroy( DT_Preview );   /* Der Mohr hat seine Schuldigkeit getan ...    */

ok = ZCenterObjects("GB_1", "PICT_2", "DEPENDENT" );
ok = VRSet("PICT_1", "Painting", 1);
ok = VRSet("PICT_2", "Visible",  1);
ok = VRSet("PICT_2", "Painting", 1);

ok = VRSet("PB_Go",  "Enabled", 1 );

ok = VRSet("Window1", "Caption", VRGet("Window1","Userdata") " -- '" || filespec("name",IMG_FS) || "'" );    /* save for later use   */

Call ZGet_CamData;

return IMG_FS;  /* keep Rumpf, Thumbfile !          */

----------------------------------

MM_Load_ShowThumb: Procedure; /* alte Version       */
JPG_File = arg(1);

++ erfordert hbmtest in der Auslieferung !! ++

ok = SysFileTree( JPG_File, "files.", "FO" );
if files.0 > 1 then do      /* 1 ist immer (*.RAW)  */
   do i = 1 to files.0
      JPG_File = files.i;   /* vermutetes JPG_File  */
      Posi = Lastpos(".",JPG_File);
      xExt = right(JPG_File, length(JPG_File)-Posi);
      if translate(xExt) <> Ext then do

         if translate(xExt) = "JPG" then do
            /* ----------------------------------                   */
            /* JPG_File im Mini-Fenster anzeigen: (JPG heisst JPG)  */
            /* ----------------------------------                   */
            ok = ZDispl_NonBMP( JPG_File, "PICT_2" );
            ok = VRSet("DT_Preview", "Visible", 1);
         end;
         else;do
            /* ----------------------------------                      */
            /* JPG_File im Mini-Fenster anzeigen: (JPG heisst anders)  */
            /* ----------------------------------                      */
            cmd = 'hbmtest -g JPG "'JPG_File'" > gbmtest.log';
            cmd;
            if RC = 0 then do
               txt = charin("gbmtest.log",1,20);
               ok = stream("gbmtest.log","c","close");
               Dimens = word(txt,1);    /* xxxx,yyyy,cc         */
               ok = ZDispl_NonBMP( JPG_File, "PICT_2", Dimens );
               ok = VRSet("DT_Preview", "Visible", 1);
            end;
         end;
         LEAVE;
      end;
   end;
end;
return 0;
/*:VRX         MM_LoadPrf_Click
*/
MM_LoadPrf_Click:

ProfDir = YGlob.YHomedir;

FileName = VRFileDialog( VRWindow(), "Select Profile", "Open", ProfDir||"*.prf" );

if FileName <> "" then do
   FileName = filespec("name",FileName);
   ok = VRSet("EF_PrfName", "Value", FileName );
   YGlob.YPrfName = FileName;
   ok = SysINI( INIFile, "Settings", "PrfName", YGlob.YPrfName );

   Call ZLoad_Profile YGlob.YPrfName;

end;

return;

/*:VRX         MM_ProcDir_Click
*/
MM_ProcDir_Click: 

Bak_Dir = directory();

ImgDir = SysINI( INIFile, "Settings", "ImgDir" );
say "ImgDir="ImgDir"!";
if ImgDir <> "ERROR:" then
   ok = directory(ImgDir);

RAW_Ext = SysINI( YGlob.YHomeDir||INIFile, "Settings", "RAW_Ext");
if RAW_Ext = "ERROR:" then
   RAW_Ext = "*.CR2;*.DCW;*.CRW;*.NEF";

IMG_FS = VRFileDialog( VRWindow(), "Select directory for batch-processing:", "OPEN",    ,
                       RAW_Ext, ,   ,
                     );

ok = directory(Bak_Dir);

if IMG_FS = "" then do
   RETURN;
end;

IMG_Dir = filespec("drive",IMG_FS) || filespec("path",IMG_FS);

ok = SysINI( INIFile, "Settings", "ImgDir", strip(IMG_Dir,"T","\") );

/* aus RAW_Ext => Stem der Extensions:      */

What = RAW_Ext;
Extens. = "";
do i = 1 by 1 until What = ""
   parse value What with Ext ";" What;
   Extens.i = Ext;
end;
Extens.0 = i;

/* Beware IMG_Dir, Extens.:          */

ok = VRLoadSecondary("WIN_Batch", "WAIT");

return 0;

/*:VRX         MM_SettResetExt_Click
*/
MM_SettResetExt_Click: 

ok = SysINI(INIFile, "Settings", "ExtImag", "DELETE:");

return

/*:VRX         MM_SettSett_Click
*/
MM_SettSett_Click: 

ok = VRLoadSecondary( "WIN_Sett", "WAIT" );

return;

/*:VRX         MMAck_Copy_Click
*/
MMAck_Copy_Click: 

/* !Obj is set      */

ok = VRMethod("Application", "PutClipboard", VRGet( !Obj, "Value" ) );

return

/*:VRX         MMCam_Copy_Click
*/
MMCam_Copy_Click: 
Oper = arg(1);  /* [ "Move" | "" ] */

if Oper = "" then Oper = "Copy";

/* !CurRec is set       */

ImpoDir = strip(VRGet("EF_Cam_ImpDir", "Value"),"T","\") || "\";    /* immer mit '\'        */

ok = VRMethod("CN_CamFiles", "GetRecordList", "Selected", "Sels." );

if Sels.0 = 0 then RETURN -1;

Call XSay_Cam "copying ... please wait", 1;

do i = 1 to Sels.0
   Hndle = VRMethod("CN_CamFiles", "GetFieldData", Sels.i, HndHndle );
   ok = MMCam_Copy_Single( Hndle, i, (Oper="Move"), Sels.i );
end;
Call XSay_Cam "copying ... please wait", "D";
return 0;

/* ---------------------------------------  */
MMCam_Copy_Single: Procedure Expose OutFile ImpoDir hndFName;
Hndle = arg(1);
FNo   = arg(2);
Move  = arg(3);
Rec   = arg(4);

if VRGet("CB_Cam_Repl", "Set") then 
   Repl = "-r";
else;
   Repl = "";

FName = VRMethod("CN_CamFiles", "GetFieldData", Rec, hndFName );

FType = translate( right( FName, length(FName) - lastpos(".",FName) ) );

'ptpro.exe -f 'Hndle' 'Repl' "'ImpoDir'*" > 'OutFile;   /* copy unter selbem Namen  */
/* RC ist immer 0 !!!!!         */

RC = Get_ptpro_RC();    /* Rausfieseln RC aus OutFile  */

if RC <> "done" then do
   ProbCause = "";
   if RC = ""        then ProbCause = "File already on disk";
   if RC = 3         then ProbCause = "invalid disk or directory";
   if RC = 112       then ProbCause = "No more disk space";
   if RC = "SYSFAIL" then ProbCause = "Sysfail - refer to VX-Console";
   ok = VRMessage( VRWindow(), "Error has occured copying file from camera, code="RC, ProbCause, "E" );
   return RC;
end;

/* Bei JPGs: Hinzukopieren Thumbnail, falls gewÅnscht:  */
if FType = "JPG" then do
   if VRGet("CB_Cam_InclThm","Set") then do
      /* save Thm-File  */
      'ptpro.exe -t 'Hndle' 'Repl' "'ImpoDir'*.thm" > 'OutFile; /* copy unter *.thm  */
      Call ZCam_OutMess VRGet("CB_Cam_KumMsg","Set");
   end;
end;

if RC = "done" then
   ok = VRMethod("CN_CamFiles", "SetRecordAttr", Rec, "Selected", 0 );

if (FNo = 1) & \(VRGet("CB_Cam_KumMsg","Set")) then 
   ok = VRSet("MLE_PTP", "Value", "" );    /* Clear beim ersten mal    */

Call ZCam_OutMess 1;

/* ------------------------     */
/* Ist Lîschen angefordert?     */
/* ------------------------     */
if RC = "done" then do
   if (Move) then do
      "ptpro.exe -e "Hndle"  * > "OutFile;  /* copy unter selbem Namen  */
      RC = Get_ptpro_RC();      /* Rausfieseln RC aus OutFile           */

      if RC = "done" then
         ok = VRMethod("CN_CamFiles", "RemoveRecord", Rec );

      Call ZCam_OutMess VRGet("CB_Cam_KumMsg","Set");
   end;
end;

return RC;

------------------
Get_ptpro_RC: Procedure Expose OutFile;
/* Rausfieseln RC aus OutFile:  */

OutData = CharIn(OutFile,1,chars(OutFile));

if length(OutData) < 3 then do

   RETURN "SYSFAIL";
end;

OutData = left(OutData, length(OutData)-2);     /* strip "0D0A"x        */
RC = word(right(OutData,7), 2);                 /* 'rc= 112'            */
say "RC="RC"!";
ok = stream(OutFile,"c","close")
return RC;  /* [ "done" | nnn ]                 */

/*:VRX         MMCam_Erase_Click
*/
MMCam_Erase_Click: 

ok = VRMethod("CN_CamFiles", "GetRecordList", "Selected", "Sels." );
if Sels.0 = 0 then RETURN -1;

But = VRMessage( VRWindow(), "Erase "Sels.0" images from camera?","","Q",   ,
                 "But_OC."  ,
               );
if But <> 1 then RETURN -1;

Call XSay_Cam "Erasing ... please wait", 1;

do i = 1 to Sels.0
   Hndle = VRMethod("CN_CamFiles", "GetFieldData", Sels.i, HndHndle );
   "ptpro.exe -e "Hndle" > "OutFile;

   if RC = 0 then
      ok = VRMethod("CN_CamFiles", "RemoveRecord", Sels.i );

end;
Call XSay_Cam "Erasing ... please wait", "D";

return;

/*:VRX         MMCam_Load_Click
*/
MMCam_Load_Click: 

/* !CurRec is set, file-entry muss selected sein!           */

ok = VRMethod("CN_CamFiles", "GetRecordList", "Selected", "Sels." );
if Sels.0 > 1 then do
   ok = VRMessage( VRWindow(), "Only one image file may be loaded at a time" );
   RETURN -1;
end;

ImpoDir = strip(VRGet("EF_Cam_ImpDir", "Value"),"T","\") || "\";    /* immer mit '\'        */

FName = VRMethod("CN_CamFiles", "GetFieldData", !CurRec, hndFName );
FSpec = ImpoDir || FName;
FType = translate( right( FName, length(FName) - lastpos(".",FName) ) );

FNam1 = left(FName, length(FName) - length(FType)-1); /* Name ohne Ext    */

if FType = "JPG" then do
   ok = VRMessage( VRWindow(), "You must select a RAW-file-format for the LOAD-function" );
   RETURN -1;
end;

/* ----------------------   */
/* Replace-Option setzen:   */
/* ----------------------   */
if VRGet("CB_Cam_Repl", "Set") then 
   Repl = "-r";
else;
   Repl = "";

/* Zuerst muss Image nach Import-Directory kopiert werden:  */

Call XSay_Cam "Copying "FName" to '" ||  VRGet("EF_Cam_ImpDir","Value")"'", 1

ok = VRSet("WIN_Wait", "Visible", 1);       /* please wait...               */

Hndle = VRMethod("CN_CamFiles", "GetFieldData", !CurRec, HndHndle );
ok = MMCam_Copy_Single( Hndle, , (Oper="Load"), !CurRec );

ok = VRSet("WIN_Wait", "Visible", 0);       /* please wait...  -end-        */

if ok < 0 then  /* kein ImpoDir angegeben   */
   RETURN -1;

ImgName = VRMethod("CN_CamFiles", "GetFieldData", !CurRec, hndFName );
IMG_FS = VRGet("EF_Cam_ImpDir", "Value" ) || ImgName;   /* beware IMG_FS    */

/* Hinzukopieren Thumbnail, falls gewÅnscht: */

/* +++ obsolet mit dcraw-Version 8.81, wo die Thumbnails direkt con der Camera geholt werden:

if VRGet("CB_Cam_InclThm","Set") then do
   /* zuerst den JPG-Eintrag suchen:         */
   ok = VRMethod("CN_CamFiles", "GetRecordList", "ALL", "Recs.")
   do i = 1 to Recs.0
      FName = VRMethod("CN_CamFiles", "GetFieldData", Recs.i, hndFName );
      FTyp2 = translate( right( FName, length(FName) - lastpos(".",FName) ) );
      FNam2 = left(FName, length(FName) - length(FTyp2)-1); /* Name ohne Ext    */
      if FNam2 = FNam1 & FTyp2 = "JPG" then do
         /* save Thm-File from orig. JPG-File:  */
         Hndle = VRMethod("CN_CamFiles", "GetFieldData", Recs.i, hndHndle );
         cmd = "ptpro.exe -t "Hndle" "Repl" "ImpoDir"*.thm > "OutFile; /* copy unter *.thm  */
         cmd;
         Call ZCam_OutMess VRGet("CB_Cam_KumMsg","Set");
         LEAVE;
      end;
   end;
   if i >= Recs.0 then do
      /* es waren nur RAW-images in der Camera:                     */
      /* Fehlermeldung nur, wenn nicht schon im Import-Directory:   */
      ThmSource = FNam1".JPG";
      ok = SysFileTree( ImpoDir || ThmSource, "files.", "F");
      if files.0 = 0 then
         ok = VRMessage( VRWindow(), ,
                        "Creation of thumbnail impossible because there is no "ThmSource"-file on camera"   ,
                       );
   end;
end;
+++++ */

Call WIN_Cam_Close; /* IMG_FS: RÅckgabe-Parameter       */

return

/*:VRX         MMCam_Move_Click
*/
MMCam_Move_Click: 

Call MMCam_Copy_Click "Move";

return

/*:VRX         MMCam_SaveMess_Click
*/
MMCam_SaveMess_Click: 

return

/*:VRX         MMHelp_About_Click
*/
MMHelp_About_Click: 

Call VRLoadSecondary "WIN_Ack", "Wait";

return;


/*:VRX         MMHelp_Help_Click
*/
MMHelp_Help_Click: 

ok = VRMethod("Window1", "InvokeHelp");

return;

/*:VRX         MMRaw_LoadExt_Click
*/
MMRaw_LoadExt_Click: 

Call ZLoad_Ext YGlob.YImgFile;

return;

/*:VRX         MMRaw_SaveAs48bpp_PNG_Click
*/
MMRaw_SaveAs48bpp_PNG_Click: 

Call ZSave_Raw YGlob.YImgFile, "PNG";

return

/*:VRX         MMRaw_SaveAs48bpp_Tif_Click
*/
MMRaw_SaveAs48bpp_Tif_Click: 

Call ZSave_Raw YGlob.YImgFile, "TIF";

return

/*:VRX         MMRaw_SaveAsBMP_Click
*/
MMRaw_SaveAsBMP_Click: 

Call ZSave_Raw YGlob.YImgFile, "BMP";

return

/*:VRX         MMRaw_SaveAsJPG_Click
*/
MMRaw_SaveAsJPG_Click: 

Call ZSave_Raw YGlob.YImgFile, "JPG";

return

/*:VRX         PB_Ack_Close_Click
*/
PB_Ack_Close_Click: 
Call WIN_Ack_Close;
return

/*:VRX         PB_BatchBrowse_Click
*/
PB_BatchBrowse_Click: 

TargetDir = VRFileDialog( VRWindow(), "Select Target-Dir", "Open", "TargetDir", , ,  );

if TargetDir = "" then RETURN -1;

TargetDir = filespec("drive",TargetDir) || filespec("path",TargetDir);

ok = VRSet("EF_BatchTargetDir", "Value", TargetDir );

return;

/*:VRX         PB_BatchClose_Click
*/
PB_BatchClose_Click: 
Call WIN_Batch_Close;
return

/*:VRX         PB_BatchGo_Click
*/
PB_BatchGo_Click: 

if \VRGet("CB_BatchSelOnly","Set") then do
   Sels. = "";
   do i = 1 to VRGet("LB_BatchFiles","Count")
      Sels.i = i;
   end;
   Sels.0 = VRGet("LB_BatchFiles","Count");
   ok = VRMethod("LB_BatchFiles", "SetSelectedList", "Sels." );
end;

ok = VRMethod("LB_BatchFiles", "GetSelectedList", "Sels." );


if VRGet("RB_PPM","Set")  then Ext = "PPM";
if VRGet("RB_TIFF","Set") then Ext = "TIFF";

JPG_FileSpec = "";

/* -----------      */
/* Here we go:      */
/* -----------      */
do i = 1 to Sels.0

   if VRGet("CB_BatchCanc","Set") then do
      ok = VRMethod("LB_BatchCons", "AddString", "batch-processing cancelled by user-request" );
      LEAVE;
   end;

   Img_File = VRMethod("LB_BatchFiles", "GetString", Sels.i );
   IMG_FS = VRGet("DT_35","Caption") || IMG_File;

   if i > 1 then
      ok = VRMethod("LB_BatchCons", "AddString", "" );  /* eine Leerzeile zwischen jedem File   */

   cmd = ZBuild_Cmd( IMG_FS );
   ok = VRMethod("LB_BatchCons", "AddString", cmd );
   cmd;
   if RC = 0 then 
     ok = VRMethod("LB_BatchCons", "AddString", "...done - RC="RC );
   else;do
     ok = VRMethod("LB_BatchCons", "AddString", "...unsuccessful! - RC="RC );
     ITERATE;
   end;

   /* ---------------------------------------   */
   /* Bestimmen Name der Ausgabe (TIFF/PPM):    */
   /* ----------------------------------------  */
   Posi  = Lastpos(".",IMG_FS);
   Rumpf = left(IMG_FS, Posi);    /* inkl. '.'  */
   YGlob.YImgFile = Rumpf || Ext;

   if VRGet("CB_BatchJPG","Set") then do
      if VRGet("CB_BatchRes","Set") then ResRatio = VRGet("SPIN_ResRatio","Value");
                                    else ResRatio = "";
      Ret = ZSave_Raw( YGlob.YImgFile, "JPG", "NODIAG", VRGet("SPIN_JpgQual","Value"), ResRatio );
      RC           = word(Ret,1);
      JPG_FileSpec = subword(Ret,2);
      if RC = 0 then do
         ok = VRMethod("LB_BatchCons", "AddString", "...Saved jpg from "Ext" as "JPG_FileSpec  ); 

         /* ------------------------------         */ 
         /* After JPG: Delete TIFF / PPM ?         */ 
         /* ------------------------------         */ 
         if VRGet("CB_BatchNoTif","Set") then do
            nok = SysFileDelete( YGlob.YImgFile );
            if nok <> 0 then
               ok = VRMethod("LB_BatchCons", "AddString", "Error deleting "YGlob.YImgFile", code="nok  ); 
            else;
               ok = VRMethod("LB_BatchCons", "AddString", "...deleted "YGlob.YImgFile ); 
         end;
      end;

   end;

   /* ---------------------------       */
   /* Um-kopieren in Target-Dir ?       */
   /* ---------------------------       */
   if VRGet("CB_BatchTargetDir","Set") then do

      if \VRGet("CB_BatchNoTif","Set") then do  /* wenn nicht zuvor 'lîschen tiff / ppm' spezifiziert wurde */
         Target_FS = VRGet("EF_BatchTargetDir","Value") || filespec("name",YGlob.YImgFile);
         "copy "YGlob.YImgFile Target_FS;
         if RC = 0 then do
            "del "YGlob.YImgFile;
            if RC = 0 then  ok = VRMethod("LB_BatchCons", "AddString", "..." || Ext "moved to "Target_FS );   
                      else; ok = VRMethod("LB_BatchCons", "AddString", "...error moving to "Target_FS", code="RC );   
         end;
         else;
            ok = VRMethod("LB_BatchCons", "AddString", "...error copying "YGlob.YImgFile" to "Target_FS", code="RC );   
      end;

      if JPG_FileSpec <> "" then do
         Target_FS = VRGet("EF_BatchTargetDir","Value") || filespec("name",JPG_FileSpec);
         "copy "JPG_FileSpec Target_FS;
         if RC = 0 then do
            "del "JPG_FileSpec;
            if RC = 0 then  ok = VRMethod("LB_BatchCons", "AddString", "...JPG moved to "Target_FS );   
                      else; ok = VRMethod("LB_BatchCons", "AddString", "...error moving to "Target_FS", code="RC );   
         end;
         else;
            ok = VRMethod("LB_BatchCons", "AddString", "...error copying jpg-file "JPG_FileSpec" to "Target_FS", code="RC );   
      end;
   end;

end;
ok = VRMethod("LB_BatchCons", "AddString", "" );  /* eine Leerzeile      */
ok = VRMethod("LB_BatchCons", "AddString", Sels.0 "files processed" );
ok = beep(222,333);

return;

/*:VRX         PB_BatchHlp_Click
*/
PB_BatchHlp_Click: 

ok = VRMethod("WIN_Batch", "InvokeHelp");

return 0;

/*:VRX         PB_Exit_Click
*/
PB_Exit_Click: 

if VRInfo("AltPressed") = 1 then do
   ok =  VRRedirectStdIO("ON");  /* Show console!     */
   say "Console made visible by explicit request!";
   return;
end;

if VRInfo("ShiftPressed") = 1 then do
   ok =  VRRedirectStdIO("OFF");  /* Make Show console invisibl!     */
   Call Xsay "Console made invisible by explicit request!";
   return;
end;

if VRInfo("CtrlPressed") = 1 then do
   !YSay = 1;  /* make debugging-info visible     */
   Call XSay "debugging-info made visible by explicit request!";
   return;
end;


Call Quit;

return

/*:VRX         PB_Go_Click
*/
PB_Go_Click: 

/* IMG_FS is set (from MM_Load)     */

NotSup_Proceed = 1;

ok = VRSet("WIN_Wait", "Visible", 1);       /* please wait...   */

cmd = ZBuild_Cmd( IMG_FS );

Call XSay "'"cmd"'";
cmd;
dcraw_RC = RC;

Call XSay "-completed-";

Call ZShowVerbose;

if dcraw_RC = 0 then do
   /* ----------------------------------            */
   /* Out-File im Mini-Fenster anzeigen:            */
   /* ----------------------------------            */
   if VRGet("RB_PPM","Set")  then do;  Ext = "PPM";  PPM_File = Rumpf || Ext; end;
   if VRGet("RB_TIFF","Set") then do;  Ext = "TIFF"; PPM_File = "";           end;
   YGlob.YImgFile = Rumpf || Ext;
   ok = ZDispl_NonBMP( YGlob.YImgFile, "PICT_1" );

   ok = VRSet("MMRaw", "Enabled", 1 );
   ok = VRSet("PB_ShowCamdata", "Enabled", 1 );
end;
else;
   Call XSay "Error: RC/dcraw="RC;

ok = VRSet("GB_HowTo", "Visible", 0 );

ok = VRSet("WIN_Wait", "Visible", 0);   /* please wait...           */

ok = VRSet("PICT_1", "Painting", 1);    /* DurchfÅhren Bildwechsel  */

return

/*:VRX         PB_Notsup_Canc_Click
*/
PB_Notsup_Canc_Click: 

NotSup_Proceed = 0;

Call WIN_NotSup_Close;
return

/*:VRX         PB_Notsup_Proceed_Click
*/
PB_Notsup_Proceed_Click: 

NotSup_Proceed = 1;

Call WIN_NotSup_Close;
return

/*:VRX         PB_SettCanc_Click
*/
PB_SettCanc_Click: 


Call WIN_Sett_Close;

return

/*:VRX         PB_SettOK_Click
*/
PB_SettOK_Click: 

!JpgQual = Padzero( VRGet("EF_JpgQual", "Value"), 3 );

if verify( !JpgQual, "0123456789" ) > 0     ,
 | !JpgQual > 100 then do
   ok = VRMessage( VRWindow(), "Invalid JPG-Quality", "Must be between 01 and 100" );
   RETURN -1;
end;

!RAW_Ext = VRGet("EF_RAW_Ext", "Value");

!PPMPath = VRGet("EF_PPMPath", "Value");
if \VrIsDir( !PPMPath ) & !PPMPath <> "<rawdir>" then do
   ok = VRMessage( VRWindow(), "Invalid PPM-Path", "Error", "E" );
   RETURN -1;
end;

!dcrExfn = VRGet("EF_dcrawExe", "Value");
if \VrFileExists( !dcrExfn ) then do
   ok = VRMessage( VRWindow(), "name of dcraw.exe does not exist", "'"!dcrExfn"' not found", "E" );
   RETURN -1;
end;

YGlob.YJpgQual   = !JpgQual;
YGlob.YJpgProg   = VRGet("CB_JpgProg", "Set");
YGlob.YPPMPath   = !PPMPath;
YGlob.YRAW_Ext   = !RAW_Ext;
YGlob.Ydcraw.exe = !dcrExfn;

ok = SysINI( INIFile, "Settings", "JpgQual", YGlob.YJpgQual );
ok = SysINI( INIFile, "Settings", "JpgProg", YGlob.YJpgProg );
ok = SysINI( INIFile, "Settings", "PPMPath", YGlob.YPPMPath );
ok = SysINI( INIFile, "Settings", "RAW_Ext", YGlob.YRAW_Ext );
ok = SysINI( Def_PrfName, "Settings", "dcraw.exe", YGlob.Ydcraw.exe );

ok = SysINI( INIFile, "Settings", "DelPPM", ( VRGet( "CB_DelPPM", "Set") ) );
ok = SysINI( INIFile, "Settings", "DelTHM", ( VRGet( "CB_DelTHM", "Set") ) );

Call WIN_Sett_Close;

return

/*:VRX         PB_ShowCamdata_Click
*/
PB_ShowCamdata_Click: 

If word( VRGet("PB_ShowCamdata","Caption"), 1 ) = "show" then do
   ok = VRSet("PB_ShowCamdata","Caption", "hide" Subword( VRGet("PB_ShowCamdata","Caption"), 2 ) );

   Call VRSet "WIN_Camdata", "Visible", 1;
   Call VRSet "WIN_Camdata", "Windowstate", "normal";
end;
else;do
   ok = VRSet("WIN_Camdata","Windowstate", "Minimized");
   ok = VRSet("PB_ShowCamdata","Caption", "show" Subword( VRGet("PB_ShowCamdata","Caption"), 2 ) );
end;

return
/*:VRX         PB_Verbos_Close_Click
*/
PB_Verbos_Close_Click: 
ok = VRSet("WIN_Verbos","Visible",0);
return;

/*:VRX         PBCam_Browse_Click
*/
PBCam_Browse_Click: 

ImpoDir = VRFileDialog( VRWindow(),     ,
                        "Select a target-directory for image-files", "Open", "ImpoDir", , , ,
                      );

if ImpoDir = "" then RETURN -1;

ImpoDir = filespec("drive",ImpoDir) || filespec("path",ImpoDir);

ImpoDir = strip(ImpoDir,"T","\") || "\";    /* immer mit '\'        */

ok = VRSet("EF_Cam_ImpDir", "Value", ImpoDir );

return;

/*:VRX         PBCam_Close_Click
*/
PBCam_Close_Click: 

Call WIN_Cam_Close;

return

/*:VRX         PBCam_Connect_Click
*/
PBCam_Connect_Click: 

Call XSay_Cam "Connecting to camera", 1;

"ptpro.exe -d > "OutFile;

Call ZCam_OutMess 0;

"ptpro.exe -c > "OutFile;

Call ZCam_OutMess VRGet("CB_Cam_KumMsg","Set");

PBCam_Connect_Click2:   /* <========= Entry-2 (nach Move: Neu aufbauen) ============    */

"ptpro.exe -l > "OutFile;

ok = VRSet("CN_CamFiles", "Caption", "Files found in camera:" );
ok = VRSet("CN_CamFiles", "Painting", 0 );

ok = VRMethod("CN_CamFiles", "RemoveRecord", "ALL" );

NumFile_Totl = 0;
FileSiz_Totl = 0;

StartFiles = 0;
do while lines(OutFile) > 0
   Rec = LineIn( OutFile );
   Hnd = word(Rec,1);
   FSz = word(Rec,2);
   FDt = word(Rec,3);
   FTm = word(Rec,4);
   FNm = word(Rec,5);

   Hnd = strip(Hnd,"T","09"x);

   if (StartFiles) then do
      HndRec = VRMethod("CN_CamFiles", "AddRecord" );
      ok = VRMethod("CN_CamFiles", "SetFieldData",  HndRec, HndHndle, Hnd );
      ok = VRMethod("CN_CamFiles", "SetFieldData",  HndRec, HndFName, FNm );
      ok = VRMethod("CN_CamFiles", "SetFieldData",  HndRec, HndFSize, FSz );
      ok = VRMethod("CN_CamFiles", "SetFieldData",  HndRec, HndFDate, FDt FTm );
      ok = VRMethod("CN_CamFiles", "SetRecordAttr", HndRec, "Filename", "" );   /* wird erst bei Copy/Move gefÅllt  */

      NumFile_Totl = NumFile_Totl + 1;
      FileSiz_Totl = FileSiz_Totl + FSz;
   end;

   if (Hnd = "Handle") & (FSz = "Size") then
      StartFiles = 1;

end;
ok = stream( OutFile, "c","close" );

say "NumFile_Totl="NumFile_Totl"!";

/* -----------------            */
/* Counter ausgeben:            */
/* -----------------            */
FileSiz_Totl = format( FileSiz_Totl/(1024**2), 4,2 ) "MB";
NumFile_Totl = NumFile_Totl "files";
Call ZSet_Counter "FileSiz_Totl"; 
Call ZSet_Counter "NumFile_Totl";

ok = VRSet("CN_CamFiles", "Painting", 1 );


ok = VRSet("CN_CamFiles", "Painting", 1 );

Call XSay_Cam "Connecting to camera", "D";

return;

ZSet_Counter: Procedure Expose  ,
                        NumFile_Totl FileSiz_Totl NumFile_Sel FileSiz_Sel;
Counter = arg(1);
Init    = ( left(arg(2),1) = "I" );

if (Init) then
   Add = "";
else;do
   _Z = "Add = "Counter; interpret _Z;
   if(0) then Add = "0D0A"x || Add;
end;

say "_Z="_Z", Add="Add"!";

if(0) then
   ok = VRSet( "DT_Cam_"Counter, "Caption", VRGet( "DT_Cam_"Counter, "Userdata") Add );
else
   ok = VRSet( "DT_Cam_"Counter, "Caption", Add );

return 0;
/*:VRX         PBCam_Help_Click
*/
PBCam_Help_Click: 
ok = VRMethod("WIN_Cam", "InvokeHelp");
return

/*:VRX         Pict_1_ContextMenu
*/
Pict_1_ContextMenu: 

if VRGet("PICT_1", "PicturePath" ) = "" then RETURN -1;

ok = VRMethod( "MMRaw", "Popup" );

return

/*:VRX         Quit
*/
Quit:

/* Intermediate files lîschen:        */
Call ZDel_Intermediate "PPM", PPM_File;
Call ZDel_Intermediate "THM", ThumbFile, "JPG";

/* Color saven  */

ok = SysINI( INIFile, "BackColor", "Window1", VRGet( "Window1", "BackColor") );
ok = SysINI( INIFile, "BackColor", "PICT_1",  VRGet( "PICT_1",  "BackColor") );

ok = SysINI( INIFile, "Settings", "DontShow", ( VRGet( "CB_DontShow", "Set") | \VRGet("GB_HowTo","Visible") ) );

Call ZSave_Profile;

/* Vorige TempDatei lîschen:                  */
if VRFileExists( YGlob.YTempName ) then
   ok = SysFileDelete( YGlob.YTempName );

ok = RXListboxToFile( VRGet("LB_XSay", "hWnd"), , "PMRaw.log" );

ok = VRRedirectStdIO("OFF"); /* Makes console invisible  */

    window = VRWindow()
    call VRSet window, "Shutdown", 1
    drop window
return

/*:VRX         RB_Out16Bit_Click
*/
RB_Out16Bit_Click: 

if VRGet("RB_Out16Bit","Set") then do
   if \ (SysINI( INIFile, "Settings", "DontShow2" ) = 1 ) then do
      ok = VRLoadSecondary("WIN_NotSup", "WAIT"); /* 16bit not supported in further processing   */
   end;
end;

return;

/*:VRX         RB_PPM_Click
*/
RB_PPM_Click: 

if VRGet("RB_PPM","Set") then 
   ok = VRMessage( VRWindow(), "Warning: Exif-data will get lost in PPM-format", "Use TIFF instead", "I" );

return

/*:VRX         SL_Bluemult_Change
*/
SL_Bluemult_Change: 

ok = ZGet_SlidVal( VRInfo("Object"), arg(1) );

return;

/*:VRX         SL_Brightness_Change
*/
SL_Brightness_Change: 

ok = ZGet_SlidVal( VRInfo("Object"), arg(1) );

return

/*:VRX         SL_ChromAberBlue_Change
*/
SL_ChromAberBlue_Change: 
Call SL_ChromAber_Change "Blue";
return;

SL_ChromAber_Change:
Color = arg(1);

Wert = VRGet("SL_ChromAber"Color,"Percentile");

If Wert < 50 then do
   Wert = 0.999 + Wert / 100000;
end;
If Wert = 50 then Wert = "0";
If Wert > 50 then do
   Wert = 1.001 + Wert / 100000;
end;

ok = VRSet("SL_ChromAber"Color, "Userdata", Wert);


if VRGet("SL_ChromAberRed","Userdata") + VRGet("SL_ChromAberBlue","Userdata") = 0 then do
   ok = VRSet("GB_ChromAberr", "Caption", VRGet("GB_ChromAberr", "Userdata") "-none-");
   ok = VRSet("CB_ChromAberr","Set",0);
end;
else;do
   ok = VRSet("GB_ChromAberr", "Caption", VRGet("GB_ChromAberr", "Userdata") );
   ok = VRSet("CB_ChromAberr","Set",1);
end;

return Wert;
/*:VRX         SL_ChromAberRed_Change
*/
SL_ChromAberRed_Change: 
Call SL_ChromAber_Change "Red";    /* in "SL_ChromAberBlue_Change"      */
return;

/*:VRX         SL_Denoise_Change
*/
SL_Denoise_Change: 


Wert = VRGet("SL_Denoise","Percentile") * 10;

if Wert = 0 then do
   ok = VRSet("DT_DenoiseNone", "ForeColor", "RED");
   ok = VRSet("SL_Denoise",     "Userdata",  "");
end;
else;do
   ok = VRSet("DT_DenoiseNone", "ForeColor", "<default>");
   ok = VRSet("SL_Denoise",     "Userdata",  "-n" Wert);
end;  

return;

/*:VRX         SL_Greenmult_Change
*/
SL_Greenmult_Change: 

ok = ZGet_SlidVal( VRInfo("Object"), arg(1) );

return

/*:VRX         SL_MedFilt_Change
*/
SL_MedFilt_Change: 

Wert = VRGet("SL_MedFilt","Percentile");

Wert = Wert % (100 % (6-1));    /* 6= Anzahl Ticks  */
                        /* Wert ergibt somit 0,1,2,3 => direkt verwendbar fÅr dcraw */

if Wert = 0 then do
   ok = VRSet("DT_MedFilt", "ForeColor", "RED");
   ok = VRSet("SL_MedFilt", "Userdata",  "");
end;
else;do
   ok = VRSet("DT_MedFilt", "ForeColor", "<default>");
   ok = VRSet("SL_MedFilt", "Userdata",  "-m" Wert);
end;  

ok = VRSet("DT_Times",   "Caption",   Wert "times");

return;

/*:VRX         SL_Qual_Change
*/
SL_Qual_Change: 

NumTicks = VRGet("SL_Qual","Ticks");

Wert = VRGet("SL_Qual","Percentile");

Wert = Wert % (100 % (NumTicks-1));
                        /* Wert ergibt somit 0,1,2,3 => direkt verwendbar fÅr dcraw */

ok = VRSet("SL_Qual","Userdata", "-q" Wert);

Drop NumTicks;

return;

/*:VRX         SL_Redmult_Change
*/
SL_Redmult_Change: 

ok = ZGet_SlidVal( VRInfo("Object"), arg(1) );

return

/*:VRX         WIN_Ack_Close
*/
WIN_Ack_Close: 
    window = VRInfo( "Window" )
    call VRDestroy window
    drop window
return

/*:VRX         WIN_Ack_Create
*/
WIN_Ack_Create: 

Top  = VRGet("GB_HowTo", "Top")  + VRGet("Window1", "Top") + 433;;
Left = VRGet("GB_HowTo", "Left") + VRGet("Window1", "Left");

ok = VRSet("WIN_Ack", "Top",  Top );
ok = VRSet("WIN_Ack", "Left", Left );

call VRSet "WIN_Ack", "Visible", 1;
call VRMethod "WIN_Ack", "Activate";

return;

/*:VRX         WIN_Batch_Close
*/
WIN_Batch_Close: 

if VRGet("CB_BatchTargetDir","Set") then
   ok = SysINI( INIFile, "Settings", "BatchTargetDir", VRGet("EF_BatchTargetDir","Value") );

/* --------------------     */
/* User-Farben sichern:     */
/* --------------------     */
ok = SysINI( INIFile, "BackColor", "LB_BatchFiles", VRGet( "LB_BatchFiles", "BackColor") );
ok = SysINI( INIFile, "ForeColor", "LB_BatchFiles", VRGet( "LB_BatchFiles", "ForeColor") );

ok = SysINI( INIFile, "BackColor", "LB_BatchCons",  VRGet( "LB_BatchCons",  "BackColor") );
ok = SysINI( INIFile, "ForeColor", "LB_BatchCons",  VRGet( "LB_BatchCons",  "ForeColor") );


if VRGet("CB_BatchSaveLog","Set") then
   ok = RXListboxToFile( VRGet("LB_BatchCons", "hWnd"), , "PMRaw_btch.log" );

    window = VRInfo( "Window" )
    call VRDestroy window
    drop window
return

/*:VRX         WIN_Batch_Create
*/
WIN_Batch_Create: 

/* IMG_Dir, Extens. are set       */

ok = VRSet("DT_35",             "Caption", IMG_Dir );

Val = SysINI( INIFile, "Settings", "BatchTargetDir" );
if Val = "ERROR:" then
   ok = VRSet("EF_BatchTargetDir", "Value",   IMG_Dir );
else;
   ok = VRSet("EF_BatchTargetDir", "Value",   Val );

/* --------------------------------------------------------------   */
/* Nur die Files gem. Extension-Filter in die Listbox Åbernehmen:   */
/* --------------------------------------------------------------   */
do i = 1 to Extens.0

   ok = SysFileTree( IMG_Dir || Extens.i, "files.", "FO" );
   do j = 1 to files.0
      ok = VRMethod("LB_BatchFiles", "AddString", filespec("name", files.j) );
   end;

end;

/* ----------------------------------------------------             */
/* Versorgen Captions je nach gewÑhltem Ausgabe-Format:             */
/* ----------------------------------------------------             */
if VRGet("RB_Tiff","Set") then do;
                                Capt1 = "Create TIFF-images from RAW";
                                Capt2 = "Delete TIFF-images after";
                          end;
                          else do;
                                Capt1 = "Create PPM-images from RAW";
                                Capt2 = "Delete PPM-images after";
                          end;

ok = VRSet("CB_BatchDoWhat",  "Caption", Capt1 );
ok = VRSet("CB_BatchNoTif",   "Caption", Capt2 );

/* ----------------------------         */
/* Initialisieren Spinbuttons:          */
/* ----------------------------         */
/* ==> JPG-Quality:                     */
Lst.0 = 0;
do i = 50 to 99;
   a = Lst.0 +1;
   Lst.a = i;   Lst.0 = a;
end;
ok1 = VRMethod("SPIN_JpgQual", "SetStringList", "Lst." );
ok2 = VRSet("SPIN_JpgQual", "Index", 50 - (99 - YGlob.YJpgQual) );

/* ==> Resize-Ratio:                    */
Lst.0 = 0;
do i = 5 to 95 by 5;
   a = Lst.0 +1;
   Lst.a = i;   Lst.0 = a;
end;
ok1 = VRMethod("SPIN_ResRatio", "SetStringList", "Lst." );
ok2 = VRSet("SPIN_ResRatio", "Index", (Lst.0 % 2) );

/* -----------------------          */
/* Help-Modul adressieren:          */
/* -----------------------          */
ok = VRSet("WIN_Batch", "HelpFile",  "MainHlp"||YLang.Suffix||".inf" );
ok = VRSet("WIN_Batch", "HelpTitle", "General Help for PMRaw" );
if ( YLang.Ger ) then
   ok = VRSet("WIN_Batch", "HelpTag", "Massenverarbeitung (Batch)" );
else
   ok = VRSet("WIN_Batch", "HelpTag", "Batch-processing" );

/* --------------------------------*/
/* User-Farben wiederherstellen:   */
/* --------------------------------*/
ok = VRSet( "LB_BatchFiles", "BackColor", SysINI( INIFile, "BackColor", "LB_BatchFiles") );
ok = VRSet( "LB_BatchFiles", "ForeColor", SysINI( INIFile, "ForeColor", "LB_BatchFiles") );

ok = VRSet( "LB_BatchCons",  "BackColor", SysINI( INIFile, "BackColor", "LB_BatchCons") );
ok = VRSet( "LB_BatchCons",  "ForeColor", SysINI( INIFile, "ForeColor", "LB_BatchCons") );


ok = VRSet("PB_BatchBrowse",    "Enabled", VRGet("CB_BatchTargetDir","Set") );
ok = VRSet("EF_BatchTargetDir", "Enabled", VRGet("CB_BatchTargetDir","Set") );

    call WIN_Batch_Init
return

/*:VRX         WIN_Batch_Init
*/
WIN_Batch_Init: 
    window = VRInfo( "Object" )
    if( \VRIsChildOf( window, "Notebook" ) ) then do
        call VRMethod window, "CenterWindow"
        call VRSet window, "Visible", 1
        call VRMethod window, "Activate"
    end
    drop window
return

/*:VRX         WIN_Cam_Close
*/
WIN_Cam_Close: 

ok = SysINI( INIFile, "Font",      "MLE_PTP",     VRGet( "MLE_PTP",     "Font") );
ok = SysINI( INIFile, "BackColor", "MLE_PTP",     VRGet( "MLE_PTP",     "BackColor") );
ok = SysINI( INIFile, "ForeColor", "MLE_PTP",     VRGet( "MLE_PTP",     "ForeColor") );

ok = SysINI( INIFile, "BackColor", "CN_CamFiles", VRGet( "CN_CamFiles", "BackColor") );
ok = SysINI( INIFile, "ForeColor", "CN_CamFiles", VRGet( "CN_CamFiles", "ForeColor") );

ok = SysINI( INIFile, "Settings", "ImpoDir", strip( VRGet("EF_Cam_ImpDir", "Value"),"T","\") || "\" );

/* ------------------       */
/* Messages ausgeben:       */
/* ------------------       */
if VRGet("CB_Cam_OutMsg","Set") then do
   ok = CharOut( OutFile, VRGet("MLE_PTP", "Value"), 1 );
   ok = stream( OutFile, "c","close");
end;

    window = VRInfo( "Window" )
    call VRDestroy window
    drop window
return

/*:VRX         WIN_Cam_Create
*/
WIN_Cam_Create: 

IMG_FS = "";    /* wird gesetzt wenn 'MMCam_Load' geclickt wird     */

OutFile = "$ptp.msg";

ImpoDir = SysINI( INIFile, "Settings", "ImpoDir" );
if ImpoDir = "ERROR:" then ImpoDir = "";
ok = VRSet("EF_Cam_ImpDir", "Value", ImpoDir );

if VRGet("EF_Cam_ImpDir", "Value") = "" then do
   if SysINI( INIFile, "Settings", "ImgDir" ) <> "ERROR:" then
      ok = VRSet("EF_Cam_ImpDir", "Value", strip(SysINI( INIFile, "Settings", "ImgDir" ),"T","\") || "\");
end;

ok = VRSet( "CN_CamFiles", "BackColor", SysINI( INIFile, "BackColor", "CN_CamFiles") );
ok = VRSet( "CN_CamFiles", "ForeColor", SysINI( INIFile, "ForeColor", "CN_CamFiles") );

ok = VRSet( "MLE_PTP", "Font",      SysINI( INIFile, "Font",      "MLE_PTP") );
ok = VRSet( "MLE_PTP", "BackColor", SysINI( INIFile, "BackColor", "MLE_PTP") );
ok = VRSet( "MLE_PTP", "ForeColor", SysINI( INIFile, "ForeColor", "MLE_PTP") );

/* -----------------------          */
/* Help-Modul adressieren:          */
/* -----------------------          */
ok = VRSet("WIN_Cam", "HelpFile",  "CamHlp"||YLang.Suffix||".inf" );
ok = VRSet("WIN_Cam", "HelpTitle", "Help for the Camera-Module" );

/* --------------------------------------------------------------   */
/* Zuvor prÅfen, ob korrekte Version von 'usbresmg.sys' vorhanden:  */
/* --------------------------------------------------------------   */

SysName = translate('usbresmg.sys');

Found = 0;
InFile = BootDrive"\config.sys";
do while lines(InFile) > 0
   Rec = translate( LineIn(InFile) );
   if word( Rec, 1 ) = "REM" then ITERATE;
   if Pos(SysName, Rec) > 0 then do
      parse value Rec with muell "=" SysFSpec;
      Found = 1;
      LEAVE;
   end;
end;
ok = stream( InFile, "c","close" );

if \(Found) then do
   ok = VRMessage( VRWindow(), "There is no '"SysName"' found in your '"InFile"'. "     , 
                             ||"Most probably connection to camera will fail", "", "E"  ,
                 );
end;
else;do
   /* schauen, korrektes Datum:      */

   /* -----------------------------  */
   /* Hole Datum des 'usbresmg.sys'  */
   /* -----------------------------  */
   handle = FileOpen( SysFSpec,"r","e" );
   if handle <> 0 then do
      ok = FileGetInfo(handle,"info","date");
      SysDate = info.1;     /* MM TT JJJJ       */
say "SysDate="SysDate"!"
   end
   handle = FileClose( SysFSpec );

   VglDate = "20050606";
   ThsDate = word(SysDate,3) || Padzero( word(SysDate,1),2) || Padzero( word(SysDate,2),2)

   if ThsDate < VglDate then do
      ok = VRSet("DT_Cam_Warn", "Caption", "Warning! Your '"SysFSpec"' is older then is assumed to be neccessary" ,  
              || " (connection to camera may not function correctly)" );
   end;
end;

/* Ggf. alle Controls hochschieben (falls keine Warning anzuzeigen):    */

if left( VRGet("DT_Cam_Warn", "Caption") , 1 ) = "<" then do

   Delta = VRGet("GB_Cam_Ctrls", "Top") - VRGet("DT_Cam_Warn", "Top");
   ok = VRSet("GB_Cam_Ctrls", "Top",    VRGet("GB_Cam_Ctrls",  "Top") - Delta );
   ok = VRSet("GB_Cam_Ctrls", "Height", VRGet("GB_Cam_Ctrls",  "Height") + Delta );
   ok = VRSet("MLE_PTP",      "Height", VRGet("MLE_PTP",       "Height") + Delta );
   ok = VRSet("CB_Cam_KumMsg","Top",    VRGet("CB_Cam_KumMsg", "Top") + Delta );
   ok = VRSet("CB_Cam_OutMsg","Top",    VRGet("CB_Cam_OutMsg", "Top") + Delta );
   ok = VRSet("PBCam_Close",  "Top",    VRGet("PBCam_Close",   "Top") + Delta );
   ok = VRSet("EF_Cam_Xsay",  "Top",    VRGet("EF_Cam_Xsay",   "Top") + Delta );

   ok = VRSet("DT_Cam_Warn", "Visible", 0 );

end;

HndHndle  = VRMethod("CN_CamFiles", "AddField", "String", "Handle:",        "" )
HndFName  = VRMethod("CN_CamFiles", "AddField", "String", "Filename:",      "" )
HndFSize  = VRMethod("CN_CamFiles", "AddField", "String", "Filesize:",      "" )
HndFDate  = VRMethod("CN_CamFiles", "AddField", "String", "Date Time:",     "" )

ok = VRMethod("CN_CamFiles", "SetFieldAttr", HndHndle, "Visible", 0 );

/* Counter-Anzeige initialisieren:          */
Call ZSet_Counter "NumFile_Totl", "Init";   /* in PBCam_Connect */
Call ZSet_Counter "FileSiz_Totl", "Init";
Call ZSet_Counter "NumFile_Sel",  "Init";
Call ZSet_Counter "FileSiz_Sel",  "Init"; 


    call WIN_Cam_Init
return

/*:VRX         WIN_Cam_Init
*/
WIN_Cam_Init: 
    window = VRInfo( "Object" )
    if( \VRIsChildOf( window, "Notebook" ) ) then do
        call VRMethod window, "CenterWindow"
        call VRSet window, "Visible", 1
        call VRMethod window, "Activate"
    end
    drop window
return

/*:VRX         WIN_Camdata_Close
*/
WIN_Camdata_Close: 

    window = VRInfo( "Window" )
    call VRDestroy window
    drop window
return

/*:VRX         WIN_Camdata_Create
*/
WIN_Camdata_Create: 


    window = VRInfo( "Object" )
    call VRMethod window, "CenterWindow"
    call VRMethod window, "Activate"
    drop window
return

/*:VRX         WIN_NotSup_Close
*/
WIN_NotSup_Close: 


ok = SysINI( INIFile, "Settings", "DontShow2", VRGet( "CB_Notsup_DontShow", "Set") );

    window = VRInfo( "Window" )
    call VRDestroy window
    drop window
return

/*:VRX         WIN_NotSup_Create
*/
WIN_NotSup_Create: 

ok = VRSet("DT_NotSup", "Caption",  ,
           "16 bit output format cannot be displayed." || "0D0A"x   ,
         ||"The only way of further processing is with specialized image processing programs, such as" || "0D0A"x   ,
         ||"Adobe Photoshop (for *.PSD) or OS/2 FaxView (*.PPM)."    ,
          );

    window = VRInfo( "Object" )
    call VRMethod window, "CenterWindow"
    call VRSet window, "Visible", 1
    call VRMethod window, "Activate"
    drop window
return

/*:VRX         WIN_Sett_Close
*/
WIN_Sett_Close: 
    window = VRInfo( "Window" )
    call VRDestroy window
    drop window
return

/*:VRX         WIN_Sett_Create
*/
WIN_Sett_Create: 

ok = VRSet("EF_JpgQual",  "Value", YGlob.YJpgQual );
ok = VRSet("CB_JpgProg",  "Set",   YGlob.YJpgProg );
ok = VRSet("EF_PPMPath",  "Value", YGlob.YPPMPath );
ok = VRSet("EF_RAW_Ext",  "Value", YGlob.YRAW_Ext );
ok = VRSet("EF_dcrawExe", "Value", YGlob.ydcraw.exe );  /* stammt nicht aus SysINI, sondern default.prf     */

    window = VRInfo( "Object" )
        call VRMethod window, "CenterWindow"
        call VRSet window, "Visible", 1
        call VRMethod window, "Activate"
    drop window
return

/*:VRX         WIN_Verbos_Close
*/
WIN_Verbos_Close: 
    call WIN_Verbos_Fini
return

/*:VRX         WIN_Verbos_Create
*/
WIN_Verbos_Create: 
    window = VRInfo( "Object" )
    call VRMethod window, "CenterWindow"
    call VRMethod window, "Activate"
    drop window
return;

/*:VRX         WIN_Verbos_Fini
*/
WIN_Verbos_Fini: 
    window = VRInfo( "Window" )
    call VRDestroy window
    drop window
return
/*:VRX         WIN_Wait_Close
*/
WIN_Wait_Close: 
    window = VRInfo( "Window" )
    call VRDestroy window
    drop window
return

/*:VRX         WIN_Wait_Create
*/
WIN_Wait_Create: 
/*     call WIN_Wait_Init   */
window = VRInfo( "Object" )
call VRMethod window, "CenterWindow"
call VRMethod window, "Activate"
drop window

return

/*:VRX         Window1_Close
*/
Window1_Close:
    call Quit
return

/*:VRX         XSay_Cam
*/
XSay_Cam: Procedure
What = arg(1);
Oper = arg(2);  /* [ "1"(st) | "D"(one) ]  */

What = What"...";
if Oper = "D" then
   What = What "Done!";

ok = VRSet("EF_Cam_Xsay", "Value", What );

return 0;

/*:VRX         ZBuild_Cmd
*/
ZBuild_Cmd: Procedure Expose YGlob.
IMG_FS = arg(1);

/* Interpolate RGGB as four colors: */

if (VRGet("CB_RGGB","Set"))    then RGGB = VRGet("CB_RGGB", "Userdata");   else RGGB = ""; /* fÅhrt zu unlesbaren Dateien   */

if (VRGet("CB_Verbose","Set")) then Verbose = "-v";  else Verbose = "";

/* Quality setzen:                  */

Qual    = VRGet("SL_Qual",   "Userdata");
Denois  = VRGet("SL_Denoise","Userdata");
MedFilt = VRGet("SL_MedFilt","Userdata");

/* Ausgabeformat setzen:            */
if (VRGet("RB_PPM", "Set"))   then OutFrm = VRGet("RB_PPM",  "Userdata");
if (VRGet("RB_TIFF","Set"))   then OutFrm = VRGet("RB_TIFF", "Userdata");

/* Weissabgleich setzen:            */
if (VRGet("RB_WB_Auto","Set"))   then WB = VRGet("RB_WB_Auto",  "Userdata");
if (VRGet("RB_WB_Camera","Set")) then WB = VRGet("RB_WB_Camera","Userdata");

/* Colorspace setzen:               */
if (VRGet("RB_ColSpc_raw",  "Set"))   then ColSpc = VRGet("RB_ColSpc_raw",   "Userdata");
if (VRGet("RB_ColSpc_RGB",  "Set"))   then ColSpc = VRGet("RB_ColSpc_RGB",   "Userdata");
if (VRGet("RB_ColSpc_Adobe","Set"))   then ColSpc = VRGet("RB_ColSpc_Adobe", "Userdata");
if (VRGet("RB_ColSpc_Kodak","Set"))   then ColSpc = VRGet("RB_ColSpc_Kodak", "Userdata");
if (VRGet("RB_ColSpc_Wide", "Set"))   then ColSpc = VRGet("RB_ColSpc_Wide",  "Userdata");

/* Output setzen:                   */

if (VRGet("RB_Out8Bit",  "Set"))   then OutOp = VRGet("RB_Out8Bit",  "Userdata");
if (VRGet("RB_Out16Bit", "Set"))   then OutOp = VRGet("RB_Out16Bit", "Userdata");

/* Brightness setzen:               */
Brght = VRGet("EF_Brightness","Value");

if \ (VRGet("CB_AutoBright", "Set")) then       /* ++ umgekehrt !! ++   */
   AutoBright = VRGet("CB_AutoBright",  "Userdata");
else;
   AutoBright = "";

/* Whitebalance setzen:            */
if VRGet("CB_WhiteBal","Set") then do
   RMult = VRGet("EF_Redmult",  "Value");
   GMult = VRGet("EF_Greenmult","Value");
   BMult = VRGet("EF_Bluemult", "Value");
   WhiteBal = "-r" RMult GMult BMult "1.001";
end;
else;
   WhiteBal = "";

/* Chromatic Aberration setzen:            */
if VRGet("CB_ChromAberr", "Set") then do
   RMult = VRGet("SL_ChromAberRed",  "Userdata");
   BMult = VRGet("SL_ChromAberBlue", "Userdata");
   ChromAberr = "-C" RMult BMult;
end;
else;
   ChromAberr = "";

AddParms = VRGet("EF_AddParms",  "Value");

/* unused:              */
if VRGet("CB_Verbose","Set") then do
   VbsFile = SysTempFileName("$$Verbos.???");
   ok = VRRedirectStdIO("ON",VbsFile);
end;

cmd = space( YGlob.ydcraw.exe Verbose Qual MedFilt OutFrm Denois WB "-b" Brght WhiteBal ChromAberr OutOp ColSpc AutoBright AddParms '"'IMG_FS'"' , 1);

return cmd;
/*:VRX         ZCam_OutMess
*/
ZCam_OutMess: Procedure Expose OutFile;
Kumul = ( arg(1) = 1 );
Text  = arg(2);         /* opt. Normalerweise Inhalt von Datei 'OutFile'    */

if (Kumul) then
   OldVal = VRGet("MLE_PTP", "Value");
else
   OldVal = "";

if Text = "" then
   Text = CharIn( OutFile, 1, Chars(OutFile) );

ok = VRSet("MLE_PTP", "Value", OldVal || Text );

if(0) then ok = VRMethod("MLE_PTP", "SetFirstChar", length(VRGet("MLE_PTP","Value"))+2  );

ok = stream( OutFile, "c","close" );

return 0;

/*:VRX         ZCenterObjects
*/
ZCenterObjects: procedure;
OuterObj = arg(1);
InnerObj = arg(2);
Relation = arg(3);  /* [ "DEPENDENT" | "" ]   */

if(0) then do
   OldLeft = VRGet(InnerObj,"Left");
   say "OldLeft="VRMethod("Screen", "TwipsToPixels", OldLeft );
end;

if Relation = "DEPENDENT" then do /* 'Dependent' heisst: des inneren Object's 'Left' bezieht sich auf das OuterObject (wÑhrend bei non-dependent beide sich auf ihr umgebendes Window beziehen)   */
   LeftOffset = 0;
   TopOffset  = 0;
end;
else;do
   LeftOffset = VRGet(OuterObj,"Left");
   TopOffset  = VRGet(OuterObj,"Top");
end;

NewLeft = LeftOffset    ,
        + ( VRGet(OuterObj,"Width")  - VRGet(InnerObj,"Width") ) %2;
NewTop  = TopOffset    ,
        + ( VRGet(OuterObj,"Height") - VRGet(InnerObj,"Height") ) %2;

ok = VRSet(InnerObj, "Left", NewLeft  );
ok = VRSet(InnerObj, "Top",  NewTop   );

return 0;

/*:VRX         ZCount_Selected
*/
ZCount_Selected: Procedure Expose HndFSize FileSiz_Sel NumFile_Sel;

FileSiz_Sel = 0;

ok = VRMethod("CN_CamFiles", "GetRecordList", "Selected", "Sels." );
do i = 1 to Sels.0
    FSz = VRMethod("CN_CamFiles", "GetFieldData", Sels.i, HndFSize );
    FileSiz_Sel = FileSiz_Sel + FSz;
end;

FileSiz_Sel = format( FileSiz_Sel/(1024**2), 4,2 ) "MB";   /* wie in PBCam_Connect */
NumFile_Sel = Sels.0 "files";

return 0;

/*:VRX         ZDel_Intermediate
*/
ZDel_Intermediate: Procedure Expose INIFile;
Type    = arg(1);   /* [ "PPM" | "THM" ]                                */
Outfile = arg(2);   /* PPM_File kann auch *.PSD sein (nicht mehr!)      */
AltType = arg(3);   /* Falls Datei-Endung nicht identisch ist mt Anforderungstyp */

if Outfile = "" then RETURN -1;

/* PrÅfen, ob Endung Åbereinstimmt :         */
Posi = Lastpos( ".", Outfile );
If Posi = 0 then RETURN;        /* Sysfail   */
Ext = right(Outfile, length(Outfile)-Posi);

if AltType <> "" then xxxType = AltType;
                 else;xxxType = Type;

if translate(Ext) = translate(xxxType) then NOP;
else;do
   ok = beep(222,333);
   Call XSay "File-extension of intermediate file doesn't match requested type of file to delete";
   RETURN -1;
end;

Cond = (SysINI(INIFile, "Settings", "Del" || Type)=1);

if Cond then do

   ok = SysFileTree( Outfile, "files.", "FO");
   if files.0 = 1 then do
      ok = SysFileDelete( files.1 );
   end;
   else;
      Call XSay "No intermediate file of name '"Outfile"' to delete";

end;

return 0;

/*:VRX         ZDispl_NonBMP
*/
ZDispl_NonBMP: Procedure Expose INIFile YGlob. Notsup_Proceed;
Img_FS = arg(1);
PICT   = arg(2);    /* hat in "Userdata" seine ursprÅngliche Width Height       */
Dimens = arg(3);    /* xxxx,yyyy,cc  JPG-file with non-jpg-extension            */

/* Voraussetzung: PICT hat in "Userdata" seine ursprÅngliche Width Height       */

   /* Vorige TempDatei lîschen:                  */
   if VRFileExists( YGlob.YTempName ) then
      ok = SysFileDelete( YGlob.YTempName );

   ok = VRSet( PICT, "PicturePath", "");         /* Vorbereiten Bildwechsel     */

   if Dimens = "" then do
      ImgDim = X_GetImgSize( Img_FS, directory() ); /* ++ Version fÅr non-BMPs ++  */
      X_Size = word(ImgDim,1);
      Y_Size = word(ImgDim,2);

      if translate( left(X_Size,5) ) = "ERROR" then do
         ok = beep(211,444);
         if Notsup_Proceed = 1 then
            Call XSay "Image '"Img_FS"' cannot be displayed b/a 16bit-color format";
         else;
            Call XSay "Image '"Img_FS"' cannot be displayed, probably file not found";
         RETURN -1;
      end;
      DontGuess = "";
   end;
   else;do
      /* JPG-Datei die nicht .JPG heisst:               */
      DontGuess = "-g JPG";     /* ++ erfordert hbmsize */
      parse value Dimens with X_Size "," Y_Size "," bpp;    /* bits-per-pixel unused    */
   end;

   YGlob.YTempName = YGlob.YHomeDir || SysTempFileName("$Tmp???.bmp");

   TargX_Size = VRMethod("Screen", "TwipsToPixels", word(VRGet( PICT, "Userdata"),1) );
   TargY_Size = VRMethod("Screen", "TwipsToPixels", word(VRGet( PICT, "Userdata"),2) );
   Aux = ZResize_Dims(X_Size,Y_Size,TargX_Size,TargY_Size,"P");
   cmd = "gbmsize "DontGuess" -w" word(Aux,1) "-h" word(Aux,2) '"\"'Img_FS'\""' '"\"' || YGlob.YTempName || '\""';
say "?cmd="cmd"!";
   cmd;

   if RC=0 then do

      ok = VRSet( PICT, "PicturePath", YGlob.YTempName);
      ok = VRSet( PICT, "Autosize", 1);
      ok = VRSet( PICT, "Top", 120);
      ok = VRSet( PICT, "Border", 1);

      ok = VRSet( PICT, "ResizePicture", 1);

   end;
   else;
      Call XSay "Error creating Mini-Preview-Image";

   ok = VRSet( PICT, "Painting", 1);

return 0;

/*:VRX         ZGet_CamData
*/
ZGet_CamData:

/* -----------------------------        */
/* Zuerst die Camera-Data holen:        */
/* -----------------------------        */
LogFile = SysTempFileName("$$Consol.???");
ok = VRRedirectStdIO("ON",LogFile);

cmd = YGlob.ydcraw.exe '-i -v "'IMG_FS'"';
cmd;
ok = stream(LogFile,"c","close");
ok = VRRedirectStdIO("OFF");

/* Nun auswerten:                       */
do while lines(LogFile) > 0
   Rec = strip(LineIn(LogFile));
   if Rec = "" then ITERATE;
   if word(Rec,1) = "Filename:"  then do
      aux = Subword(Rec,2);                         /* full path                */
      ok = VRSet("DT_Laengenberechnung", "Caption", aux );
      if VRGet("DT_Laengenberechnung","width") > VRGet("DT_Filename","width") then do
         /* dann nur filename:                      */
         aux = filespec("drive",Subword(Rec,2)) || "\...\" || filespec("name",Subword(Rec,2));
      end;

      ok = VRSet("DT_Filename", "Caption", aux);
      ITERATE;
   end;
   if word(Rec,1) = "Aperture:"  then do; ok = VRSet("DT_Aperture", "Caption", Subword(Rec,2)); ITERATE;end;
   if word(Rec,1) = "Camera:"    then do; ok = VRSet("DT_Camera",   "Caption", Subword(Rec,2)); ITERATE;end;
   if word(Rec,1) = "Shutter:"   then do; ok = VRSet("DT_Shutter",  "Caption", Subword(Rec,2)); ITERATE;end;
   if word(Rec,1) = "Timestamp:" then do; ok = VRSet("DT_Timestamp","Caption", Subword(Rec,2)); ITERATE;end;
   if word(Rec,1) = "Owner:"     then do; ok = VRSet("DT_Owner",    "Caption", Subword(Rec,2)); ITERATE;end;
   if Subword(Rec,1,2) = "Focal length:" then do; ok = VRSet("DT_FocLen","Caption", Subword(Rec,3)); ITERATE;end;
   if Subword(Rec,1,2) = "ISO speed:"    then do; ok = VRSet("DT_ISO",   "Caption", Subword(Rec,3)); ITERATE;end;
end;
ok = stream(LogFile,"c","close");
ok = SysFileDelete(LogFile);
/* -----------------------------        */

return 0;

/*:VRX         ZGet_SlidVal
*/
ZGet_SlidVal: Procedure Expose SlidVals.
SL_Obj = arg(1);

if SL_Obj = "" then SL_Obj = arg(2);    /* Mimik nur fÅr Besorgen Werte im INIT     */

Val = VRGet( SL_Obj, "Percentile" );
if Val = 100 then Val = 99;             /* Clip Percentile unter 100                */

if Val <= 50 then  NewVal = Val / 50;
else;do

   Equiv_Perc_51  = 1.100;
   Equiv_Perc_100 = 9.999;

   /* Verteilen auf 50 Percentiles:        */
   Fak = ( Equiv_Perc_100 - Equiv_Perc_51 ) / 50;
   
   NewVal = Equiv_Perc_51 + (Val - 50 ) * Fak;

end;

Name = VRGet( SL_Obj, "Name" );
parse value Name with muell "_" Type;

Result = strip( Format(NewVal,1,4) );     /* der Wert wird fÅr dcraw Åbergeben    */

!Z = 'ok = VRSet("EF_'Type'", "Value", Result );'; interpret !Z;

return Result;

/* ------
transform:
0 .... 25 ... 50 .... 75 ... 100
0.000 0.5 ...1.0 ....5.0 ... 10.000

0 %     => 0.00

10 %    => 0.200
20 %    => 0.400
30 %    => 0.600
40 %    => 0.800
50 %    => 1.000

51 %    => 1.100
60 %    => 2.000
70 %    => 5.000
80 %    => 7.000
90 %    => 9.000

100 %   => 9.999

----
delta = 9.999 - 1.100 = 8.899

    8.899 / 50

--- */
/*:VRX         ZInit_CamData
*/
ZInit_CamData: 

/* öberflÅssig! Weil zu keiner Zeit CamDaten stehen die nicht zum BIld passen!  */

Call ZInit_CamData_Single "Camera";
Call ZInit_CamData_Single "Filename";
Call ZInit_CamData_Single "Timestamp";
Call ZInit_CamData_Single "Owner";
Call ZInit_CamData_Single "ISO";
Call ZInit_CamData_Single "Shutter";
Call ZInit_CamData_Single "Aperture";
Call ZInit_CamData_Single "FocLen";

return;

ZInit_CamData_Single:
What = arg(1);
ok = VRSet("DT_"What,"Userdata", VRGet("DT_"What, "Caption") );
return 0;
/*:VRX         ZLoad_Ext
*/
ZLoad_Ext: Procedure Expose INIFile YGlob.

/* Starten Externes Bildverarbeitungs-Programm:     */

Image_FS = arg(1);

say "Image_FS="Image_FS"!";

/* ---------------------------------        */
/* Externen Programm-Namen besorgen:        */
/* ---------------------------------        */
ExtImag = SysINI(INIFile, "Settings", "ExtImag");

if ExtImag = "ERROR:" then do

   ok = VRMessage( VRWindow(), "For the first time using an external image editor "||"0D0A"x ||     ,
                              "you must specify which program you want to use", "Select a program"  ,
                 );

   ExtImag = VRFileDialog( VRWindow(), "Select external editor program:", "OPEN", "*.exe" );

   ok = SysINI(INIFile, "Settings", "ExtImag", ExtImag)

   ExtImag = SysINI(INIFile, "Settings", "ExtImag");   /* nochmal...   */

end;

if ExtImag = "ERROR:" then RETURN -1;

/* ---------------------------------        */
/* Externen Editor SYNCHRON starten:        */
/* ---------------------------------        */

Bak_Dir = directory();

Neu_Dir = strip( filespec("drive",ExtImag) || filespec("path",ExtImag), "T", "\" );
ok = directory( Neu_Dir );

ExtImag '"'Image_FS'"';

if RC <> 0 then do
   ok = beep( 111,444 );
   Call XSay "Error starting external image-editor-program '"ExtImag"', code="RC;
end;

ok = directory( Bak_Dir );

return 0;
/*:VRX         ZLoad_Profile
*/
ZLoad_Profile: Procedure;

YGlob.YPrfName = arg(1);

ok = VRSet("SL_Qual",      "Percentile", SysINI( YGlob.YPrfName, "Settings", "Qual" ) );

ok = VRSet("RB_PPM",       "Set", SysINI( YGlob.YPrfName, "OutFrm", "PPM" ) );
ok = VRSet("RB_TIFF",      "Set", SysINI( YGlob.YPrfName, "OutFrm", "TIFF" ) );

ok = VRSet("RB_WB_Auto",   "Set", SysINI( YGlob.YPrfName, "WhitBal", "Auto" ) );
ok = VRSet("RB_WB_Camera", "Set", SysINI( YGlob.YPrfName, "WhitBal", "Cam" ) );

ok = VRSet("RB_Out8bit",   "Set", SysINI( YGlob.YPrfName, "OutBit", "8bit" ) );
ok = VRSet("RB_Out16bit",  "Set", SysINI( YGlob.YPrfName, "OutBit", "16bit" ) );

ok = VRSet("RB_ColSpc_raw",  "Set", SysINI( YGlob.YPrfName, "ColSpc", "raw" ) );
ok = VRSet("RB_ColSpc_RGB",  "Set", SysINI( YGlob.YPrfName, "ColSpc", "RGB" ) );
ok = VRSet("RB_ColSpc_Adobe","Set", SysINI( YGlob.YPrfName, "ColSpc", "Adobe" ) );

ok = VRSet("SL_Denoise",    "Percentile", SysINI( YGlob.YPrfName, "Settings", "Denoise" ) );
ok = VRSet("SL_Brightness", "Percentile", SysINI( YGlob.YPrfName, "Settings", "Brightn" ) );

ok = VRSet("SL_ChromAberRed",  "Percentile", SysINI( YGlob.YPrfName, "Settings", "ChromAberRed" ) );
ok = VRSet("SL_ChromAberBlue", "Percentile", SysINI( YGlob.YPrfName, "Settings", "ChromAberBlue" ) );

ok = VRSet("CB_WhiteBal",   "Set", SysINI( YGlob.YPrfName, "Settings", "ManWB" ) );
ok = VRSet("SL_RedMult",    "Percentile", SysINI( YGlob.YPrfName, "Settings", "RedMult" ) );
ok = VRSet("SL_GreenMult",  "Percentile", SysINI( YGlob.YPrfName, "Settings", "GreenMult" ) );
ok = VRSet("SL_BlueMult",   "Percentile", SysINI( YGlob.YPrfName, "Settings", "BlueMult" ) );

ok = VRSet("SL_MedFilt",    "Percentile", SysINI( YGlob.YPrfName, "Settings", "MedFilt" ) );

ok = VRSet("CB_AutoBright", "Set", SysINI( YGlob.YPrfName, "Settings", "AutoBright" ) );

Val = SysINI( YGlob.YPrfName, "Settings", "AddParms" );
if Val = "ERROR:" then
   ok = VRSet("EF_AddParms",   "Value", "" );
else;
   ok = VRSet("EF_AddParms",   "Value", Val );


return 0;

/*:VRX         ZRefresh_CamData
*/
ZRefresh_CamData: 

Call ZRefresh_CamData_Single "Camera";
Call ZRefresh_CamData_Single "Filename";
Call ZRefresh_CamData_Single "Timestamp";
Call ZRefresh_CamData_Single "Owner";
Call ZRefresh_CamData_Single "ISO";
Call ZRefresh_CamData_Single "Shutter";
Call ZRefresh_CamData_Single "Aperture";
Call ZRefresh_CamData_Single "FocLen";

return;

ZRefresh_CamData_Single:
What = arg(1);
ok = VRSet("DT_"What,"Caption", VRGet("DT_"What, "Userdata") );
return 0;

/*:VRX         ZResize_Dims
*/
ZResize_Dims: Procedure

/* -------------------------------------------------------  */
/* Diese Function liefert X und Y so, dass ein Image mit    */
/* Original-Y und -Y 'X_Size' und 'Y_Size' in ein Rechteck  */
/* (Target) in jedem Fall reinpasst, unter Beibehaltung     */
/* des korrekten SeitenverhÑltnisses.                       */
/* -------------------------------------------------------  */

/* alles in Pixels !!                     */

X_Size    = arg(1);   /* Source-Width     */
Y_Size    = arg(2);   /* Source-Height    */
Target_X  = arg(3);   /* Target-Width     */
Target_Y  = arg(4);   /* Target-Height    */
Scale     = arg(5);   /* ["P(ixels)" | "T(wips)" ]  Scala fÅr RÅckgabe */

say "X_Size,Y_Size="X_Size","Y_Size"!";

Source_Ratio = X_Size   % Y_Size;
Target_Ratio = Target_X % Target_Y;

X_Ratio = X_Size / Target_X;
Y_Ratio = Y_Size / Target_Y;

Ratio = Max( X_Ratio, Y_Ratio );

if Scale = "T" then
        Fak = VRMethod("Screen","PixelsToTwips",1);
else;   Fak = 1;

New_X = (( X_Size / Ratio )%1) * Fak;
New_Y = (( Y_Size / Ratio )%1) * Fak;

return New_X New_Y;

/*:VRX         ZSave_Profile
*/
ZSave_Profile: Procedure Expose INIFile YGlob.

if \ VRGet("CB_SavePrf","Set") then RETURN -1;

YGlob.YPrfName = VRGet("EF_PrfName","Value" );

/* Sicherstellen Endung '*.prf':        */
if right( translate(YGlob.YPrfName),4 ) <> ".PRF" then
   YGlob.YPrfName = YGlob.YPrfName || ".prf";

ok = SysINI( INIFile, "Settings", "PrfName", YGlob.YPrfName );

ok = stream(YGlob.YPrfName,"c","open");
ok = stream(YGlob.YPrfName,"c","close");

ok = SysINI( YGlob.YPrfName, "Settings", "Qual",   VRGet("SL_Qual", "Percentile") );

ok = SysINI( YGlob.YPrfName, "OutFrm", "PPM",  VRGet("RB_PPM",  "Set") );
ok = SysINI( YGlob.YPrfName, "OutFrm", "TIFF", VRGet("RB_TIFF", "Set") );

ok = SysINI( YGlob.YPrfName, "WhitBal", "Auto", VRGet("RB_WB_Auto",   "Set") );
ok = SysINI( YGlob.YPrfName, "WhitBal", "Cam",  VRGet("RB_WB_Camera", "Set") );

ok = SysINI( YGlob.YPrfName, "OutBit", "8bit",  VRGet("RB_Out8bit",  "Set") );
ok = SysINI( YGlob.YPrfName, "OutBit", "16bit", VRGet("RB_Out16bit", "Set") );

ok = SysINI( YGlob.YPrfName, "ColSpc", "raw",   VRGet("RB_ColSpc_raw",  "Set") );
ok = SysINI( YGlob.YPrfName, "ColSpc", "RGB",   VRGet("RB_ColSpc_RGB",  "Set") );
ok = SysINI( YGlob.YPrfName, "ColSpc", "Adobe", VRGet("RB_ColSpc_Adobe","Set") );

ok = SysINI( YGlob.YPrfName, "Settings", "Denoise",  VRGet("SL_Denoise",    "Percentile") );
ok = SysINI( YGlob.YPrfName, "Settings", "Brightn",  VRGet("SL_Brightness", "Percentile") );

ok = SysINI( YGlob.YPrfName, "Settings", "ChromAberRed",  VRGet("SL_ChromAberRed",  "Percentile") );
ok = SysINI( YGlob.YPrfName, "Settings", "ChromAberBlue", VRGet("SL_ChromAberBlue", "Percentile") );

ok = SysINI( YGlob.YPrfName, "Settings", "ManWB",     VRGet("CB_WhiteBal",  "Set") );
ok = SysINI( YGlob.YPrfName, "Settings", "RedMult",   VRGet("SL_RedMult",   "Percentile") );
ok = SysINI( YGlob.YPrfName, "Settings", "GreenMult", VRGet("SL_GreenMult", "Percentile") );
ok = SysINI( YGlob.YPrfName, "Settings", "BlueMult",  VRGet("SL_BlueMult",  "Percentile") );

ok = SysINI( YGlob.YPrfName, "Settings", "MedFilt",   VRGet("SL_MedFilt",   "Percentile") );

ok = SysINI( YGlob.YPrfName, "Settings", "AutoBright", VRGet("CB_AutoBright",  "Set") );

ok = SysINI( YGlob.YPrfName, "Settings", "AddParms",  VRGet("EF_AddParms",  "Value") );

"ren" translate(YGlob.YPrfName) YGlob.YPrfName; /* beware lower-case of Profile-Name    */

return 0;

/*:VRX         ZSave_Raw
*/
ZSave_Raw: Procedure Expose YGlob. INIFile;
Source_FS = arg(1); /* PPM-File                 */
TargFrmt  = arg(2); /* [ "BMP" | "JPG" ] oder 48bpp: [ "TIF" | "PNG" ]   */
NoDiag    = arg(3); /* [ "NODIAG" | "" ]        */
JPGQual   = arg(4); /* [ "" | <spin-value> ]    */
ResRatio  = arg(5); /* [ "" | <spin-value> ]    */

if JPGQual = "" then
   JPGQual = YGlob.YJpgQual;

TargFrmt  = translate( TargFrmt );

Filename = filespec("name", Source_FS );

Posi = Lastpos(".",Filename);
FileRumpf = left(Filename, Posi-1);
TargFName = FileRumpf || "." || TargFrmt;

/* --------------------------               */
/* JPG-Output-Options bilden: ++ obsolete mit nconvert ++ */
/* --------------------------               */
if TargFrmt = "JPG" then do 
   if YGlob.YJpgProg = 1 then
      PrOpt = ",Prog";
   else;
      PrOpt = "";
   JpgOpts = ",Quality="JPGQual || PrOpt;
end;
else;
   JpgOpts = "";


if ResRatio <> "" then do
   ResRatio = ResRatio || "%";
   ResRatio = "-resize "ResRatio ResRatio;
end;

Bak_Dir = directory();

SavePath = SysINI( INIFile, "Settings", "SavePath" );
if SavePath = "ERROR:" then
   SavePath = "";

if NoDiag <> "NODIAG" then
   Save_FS = VRFileDialog( VRWindow(), "Save RAW-Image-File as", "Save", SavePath||TargFName, , , );
else;do
   Posi = Lastpos(".",Source_FS);
   FS_Rumpf = left(Source_FS, Posi-1);
   Save_FS   = FS_Rumpf || "." || TargFrmt;
end;

ok = directory( Bak_Dir );

if Source_FS = Save_FS  ,
 | Save_FS = ""         then RETURN -1;

Call XSay "Saving '"Save_FS"'...";

SavePath = filespec("drive", Save_FS ) || filespec("path", Save_FS );
ok = SysINI( INIFile, "Settings", "SavePath", SavePath );

if TargFrmt = "JPG" | TargFrmt = "BMP" then do
   if TargFrmt = "JPG" then Fmt = "jpeg";
   if TargFrmt = "BMP" then Fmt = "bmp";

/* cmd = 'gbmsize "\"'Source_FS'\""' '"\"'Save_FS'\""' || JpgOpts;      +++ kann kein Exif! +++ */
   cmd = 'nconvert -out 'Fmt' -q 'JPGQual ResRatio' -o "'Save_FS'" "'Source_FS'"';
end;
else;do
   /* neu: ab gbm 1.37: Export als 48bpp (16bit pro Farbe):     */
   cmd = 'gbmsize "\"'Source_FS'\",ext_bpp" "\"'Save_FS'\""';   /* +++ kann aber kein Exif! +++ */
end;

if VRIsValidObject("LB_BatchCons") then
   ok = VRMethod("LB_BatchCons", "AddString", cmd );
else;
   Call XSay cmd;

if(1) then cmd; else;RC=0

if RC = 0 then 
   Call XSay "'"Save_FS"' successfully created";
else;do
   Call XSay "Error creating '"Save_FS"', code="RC;
   if TargFrmt = "PNG" then
      Call XSay "...PNG does not support 48 bpp.";  /* Mutmassung ...       */

   ok = beep(222,333);
end;

return RC Save_FS;

/*:VRX         ZShowVerbose
*/
ZShowVerbose: 

/* Verbose-Messages anzeigen:   */

if VRGet("CB_Verbose","Set") then do
   ok = stream(VbsFile,"c","close");
   ok = VRRedirectStdIO("OFF");

   ok = VRMethod("LB_Verbos","CLEAR" );

   do while lines(VbsFile) > 0
      Rec = LineIn(VbsFile);
      if strip( Rec ) = "" then ITERATE;
      ok = VRMethod("LB_Verbos","AddString", Rec );
   end;
   ok = stream(VbsFile,"c","close");
   ok = SysFileDelete(VbsFile);
   ok = VRSet("WIN_Verbos","Visible",1);
end;

return 0;

