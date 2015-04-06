@ECHO off

REM
REM Vagrant Windows box factory
REM
REM @author Luke Carrier <luke@carrier.im>
REM @copyright 2015 Luke Carrier
REM @license GPL v3
REM

certutil -addstore -f "TrustedPublisher" E:\cert\oracle-vbox.cer
START /WAIT E:\VboxWindowsAdditions.exe /S
