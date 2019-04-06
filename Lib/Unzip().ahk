/*
by BOT Loi (aka MusicBot)

오토핫키 L버전 zip 파일 풀기
Unzip for AutoHotkey_L Version.

Tested Window Version: 6.1.7601 (x32) (aka Window 7 (x32))
Tested Autohotkey Version: 1.1.24.04 Unicode 32-bit
Date : 2016/11/12
*/

Unzip(zfile, zFileToAs, Overwrite := True)
{
If(!Overwrite && FileExist (zFileToAs))
{
return, -0821 ;Return -0821 when Overwrite is False and file exist in the path(zFileToAs)
}

Zip := ComObjCreate("Shell.Application")  ;쉘 오브젝트 생성
Folder := Zip.NameSpace(zfile)   ; .ZIP 압축파일 지정
NewFolder := Zip.NameSpace(zFileToAs)                ; 압축을 풀 경로 설정

NewFolder.CopyHere(Folder.items, 4|16)          ; 압축해제, 압축을 풀 경로에 압축을 품, 항상 덮어씌움
}