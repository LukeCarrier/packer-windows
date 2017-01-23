;
; Vagrant Windows box factory
;
; @author Luke Carrier <luke@carrier.im>
; @copyright 2015 Luke Carrier
; @license GPL v3
;

ProgramFilesX86 := A_ProgramFiles . (A_PtrSize=8 ? " (x86)" : "")

; Path to WSIM
WSIMSystemImageManagerExecutable = %ProgramFilesX86%\Windows Kits\10\Assessment and Deployment Kit\Deployment Tools\WSIM\imgmgr.exe

; Window titles
WSIMSystemImageManagerTitle      = Windows System Image Manager
WSIMOpenWindowsImageTitle        = Open a Windows Image
WSIMSelectAnImageTitle           = Select an Image
WSIMGeneratingCatalogFileTitle   = Generating Catalog File
WSIMImageOneOfXRegEx             = Image (?P<Current>[0-9]+) of (?P<Count>[0-9]+)

WSIMEnsureActive()
{
    global WSIMSystemImageManagerTitle
    global WSIMSystemImageManagerExecutable

    IfWinNotExist, %WSIMSystemImageManagerTitle%
    {
        Run, %WSIMSystemImageManagerExecutable%
        WinWait, %WSIMSystemImageManagerTitle%
    }

    WinActivate
    WinMaximize
    SetKeyDelay, 0, 10
}

WSIMMakeImageCatalogs(imageFilename)
{
    global WSIMOpenWindowsImageTitle
    global WSIMSelectAnImageTitle
    global WSIMGeneratingCatalogFileTitle
    global WSIMImageOneOfXRegEx

    ; Open Tools -> Create Catalog...
    Send, {LAlt}
    Send, T
    Send, C

    ; Select Windows image
    WinWait, %WSIMOpenWindowsImageTitle%
    ControlSetText, Edit1, %imageFilename%, %WSIMOpenWindowsImageTitle%
    ControlClick, &Open, %WSIMOpenWindowsImageTitle%

    ; All images are selected by default -- just click OK
    WinWait %WSIMSelectAnImageTitle%
    ControlClick, OK, %WSIMSelectAnImageTitle%

    ; Wait for completion of all images
    ;
    ; The "Generating Catalog File" window will be discarded and re-opened for
    ; each catalog within the image. Wait for the window to become available,
    ; then determine whether to yield or wait for another window based on
    ; whether the "Image <Current> of <Count>" values are equal.
    Loop
    {
        WinWait, %WSIMGeneratingCatalogFileTitle%, " of "
        WinGetText, windowText, %WSIMGeneratingCatalogFileTitle%
        RegExMatch(windowText, WSIMImageOneOfXRegEx, Match)

        WinWaitClose, %WSIMGeneratingCatalogFileTitle%
    } Until %MatchCurrent% = %MatchCount%
}

catalogDir = %A_ScriptDir%\catalogs
Loop, Files, %catalogDir%\*, D
{
    imageFilename = %A_LoopFileLongPath%\install.wim

    WSIMEnsureActive()
    WSIMMakeImageCatalogs(imageFilename)
}
