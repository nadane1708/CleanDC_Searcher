/*
-----------------------Script Info-----------------------
Tested Windows Version: 10.0.17763.379 Enterprise LTSC (x64) (a.k.a Windows 10 Enterprise LTSC (x64))
Tested Autohotkey Version: 1.1.30.03 Unicode 32-bit
First Release Date : 2018/04/29
Last Modified : 2019/04/06
Version: v0.79 Beta
Author: Nayeon♥ (TWICE Gallery)
---------------------------------------------------------
*/

/*
full_command_line := DllCall("GetCommandLine", "str")

if not (A_IsAdmin or RegExMatch(full_command_line, " /restart(?!\S)"))
{
	MsgBox, , 알림, 관리자 권한으로 실행하여 주시기 바랍니다.
    try
    {
        if A_IsCompiled
            Run *RunAs "%A_ScriptFullPath%" /restart
        else
            Run *RunAs "%A_AhkPath%" /restart "%A_ScriptFullPath%"
    }
    ExitApp
}
*/

#NoEnv
#Persistent
#SingleInstance Off
#KeyHistory 0
SetBatchLines, -1
SetWinDelay, 0
ListLines, Off 
ComObjError(false)
DetectHiddenWindows, On

#Include Lib\DownloadFile().ahk
#Include Lib\Unzip().ahk

global __scriptVer := "20190406_a"
global _ver := "v0.79 Beta"
req := ComObjCreate("WinHttp.WinHttpRequest.5.1")
global req

#Include Lib\verLog.txt

Menu, Tray, Add, Restore, Restore
Menu, Tray, Default, Restore

FileInstall, Lib\CleanDC_Searcher.Alert.wav, %A_Temp%\CleanDC_Searcher.Alert.wav, 1
FileInstall, Lib\USkin.dll, %A_Temp%\USkin.dll, 1
FileInstall, Lib\Milikymac.msstyles, %A_Temp%\Milikymac.msstyles, 1

SkinForm(Apply, A_Temp . "\USkin.dll", A_Temp . "\Milikymac.msstyles")

gosub, var_init
gosub, gui_init
gosub, init_load

;SetTimer, WatchMouse, 50

SetTimer, w_log, 1800000
return

/*
~LButton::
WinGetClass, Class, ahk_id %ID%
IfNotEqual, Class, tooltips_class32, Return
WinGet, style, style, ahk_id %ID% 
If ! ( style & 0x40 )
     Return

LV_GetText(tmp_tt_text, 1, 2)
IfInString, ttext, % tmp_tt_text
	WinActivate, ahk_id %hID%

tmp_tt_text := ""
ttext:= ""
return
*/

w_log:
Gui, 1:Submit, Nohide

log_subject := Object()
Loop, % LV_GetCount()
{
	LV_GetText(log_subjectNum, A_Index, 2)
	log_subject.InsertAt(A_Index, log_subjectNum)
}

log_subjectInit := 1
Loop, % LV_GetCount()
{
	if StrLen(log_subject[A_Index]) > log_subjectInit
		log_subjectInit := StrLen(log_subject[A_Index])
}

txt_out := ""
Loop, % LV_GetCount()
{
	LV_GetText(log_gallNum, A_Index, 1)
	LV_GetText(log_nickNum, A_Index, 3)
	
	txt_out .= Format("{:}|{:}|{:}`r`n", log_gallNum, PadStr(log_subject[A_Index], log_subjectInit), log_nickNum)
}

FormatTime, t_now, , yyyy-MM-dd_HH-mm-ss
file_name := "log_" t_now ".txt"
FileAppend, %txt_out%, %file_name%
return

/*
WatchMouse:
MouseGetPos,,, ID,,2
ControlGetText, ttext,, ahk_id %ID%
return
*/

update_check:
SplashTextOn, , , 업데이트 확인중...
req.Open("GET", "http://www.dctwicegallery.ml/", false)
req.Send()
req.WaitForResponse()
global up_html := req.ResponseText
SplashTextOff

IfNotInString, up_html, Hello World
{
	MsgBox, 서버에서 업데이트 정보를 확인할 수 없습니다. 나중에 다시 시도하여 주세요.
	return
}

RegExMatch(up_html, "<p>(\d{8}_\w)</p>", __serverVer)
if(__scriptVer <> __serverVer1)
{
	MsgBox, 4, 업데이트 알림, 새로운 업데이트가 있습니다. 자동으로 업데이트 하시겠습니까?
		IfMsgBox, No, return
		
		DownloadFile("http://dctwicegallery.ml/cleandc/" . __serverVer1 . ".bin", A_Temp . "\~AHK_" . __serverVer1 . ".zip")
		SplashTextOn, , , 압축 푸는 중...
		global unZipErr := Unzip(A_Temp . "\~AHK_" . __serverVer1 . ".zip", A_WorkingDir)
		FileDelete, %A_Temp%\~AHK_%__serverVer1%.zip
		SplashTextOff
			if (unZipErr = -0821)
			{
				MsgBox,, 업데이트 오류, 압축 풀기 실패. 나중에 다시 시도하여 주세요.
				return
			}
		MsgBox,, 업데이트 완료, 새로운 버전으로 실행하여 주세요.
		goto, GetOut
}

return

var_init:
global love := chr(9829)
global path := A_WorkingDir . "\CleanDC_Searcher.Setting.ini"

global cr_Vol := ""

global t_pr_nm := ""
global t_pr_kw := ""
global t_pr_us := ""
global ld_pr_nm := Object()
global ld_pr_kw := Object()
global ld_pr_us := Object()
global tmp_pr_nm := "직접 입력"

global seek := ""
global seek_user := ""
global stack := ""
global t_notice := ""
global t_subject := ""
global t_writer := ""
global t_flag := ""
global IsContain := false
global temp_notice := Object()
global temp_subject := Object()
global temp_writer := Object()
global array_notice := Object()
global array_subject := Object()
global array_writer := Object()
global index := ""
global v_index := ""
global IsNewTitle := ""
global temp_new := ""

global sel_col := ""
global eventinfo := ""
global lv_1 := "", lv_2 := "", lv_3 := ""

global tmp_tt_text := ""
global ttext:= ""

OnExit, GetOut
return

init_load:
IfNotExist, % path
	return

SplashTextOn, , , 프리셋 목록 업데이트 중...
GuiControl, , preset_choice, |

IniRead, supply_op, %path%, Option, supply_option
Loop
{
	IniRead, t_pr_nm, %path%, %A_Index%, name, %A_Space%
	IniRead, t_pr_kw, %path%, %A_Index%, keyword, %A_Space%
	IniRead, t_pr_us, %path%, %A_Index%, user, %A_Space%
	ld_pr_nm[A_Index] := t_pr_nm
	ld_pr_kw[A_Index] := t_pr_kw
	ld_pr_us[A_Index] := t_pr_us
	
	if !(ld_pr_nm[A_Index])
	{
		ld_pr_nm.Pop()
		ld_pr_kw.Pop()
		ld_pr_us.Pop()
		
		break
	}
	
	tmp_pr_nm .= "|"
							. t_pr_nm
}

t_pr_nm := "", t_pr_kw := "", t_pr_us := ""

GuiControl,, preset_choice, % tmp_pr_nm
tmp_pr_nm := "직접 입력"

if (supply_op <> "ERROR")
	if(supply_op)
	{
		IniRead, t_preset, %path%, Option, preset
		IniRead, t_alert, %path%, Option, alert
		IniRead, t_popup, %path%, Option, popup
		IniRead, t_volume, %path%, Option, volume
		
		GuiControl, , IsSup_Op, 1
		GuiControl, Choose, preset_choice, %t_preset%
		gosub, DDL
		GuiControl, , IsAlert, %t_alert%
		GuiControl, , IsPopup, %t_popup%
		if  ! t_popup
			gosub, IsPopup
		GuiControl, , slider_Vol, %t_volume%
		gosub, slider_Vol
	}
	else
		GuiControl, Choose, preset_choice, 1

SplashTextOff
if(supply_op)
	gosub, BTN
return

gui_init:
OnMessage(0x112, "WM_SYSCOMMAND")
Gui, Add, Text, x26 y27 w120 h20 , 갤러리 id
Gui, Add, Edit, x26 y47 w180 h20 vgall_ID , twice
Gui, Add, Text, x26 y87 w200 h20 vtext_kw , 검색 키워드 (쉼표로 구분)
Gui, Add, Edit, x26 y107 w180 h20 vkeyword , 
Gui, Add, Button, x36 y147 w100 h30 gBTN , 검색
Gui, Add, Button, x146 y147 w100 h30 gStop , 중지
Gui, Add, GroupBox, x16 y7 w240 h180 , 설정
Gui, Add, ListView, x266 y27 w390 h340 AltSubmit hwndLV_LView glist_view , 글번호|제목|작성자
Gui, Add, GroupBox, x256 y7 w410 h370 , 필터링 목록
Gui, Add, Text, x26 y207 w120 h20 , - 키워드 프리셋
Gui, Add, DropDownList, x26 y227 w220 AltSubmit Choose1 gDDL vpreset_choice , 직접 입력|
Gui, Add, Button, x166 y207 w80 h20 gPreset , 프리셋 편집
Gui, Add, GroupBox, x16 y187 w240 h190 , 고급설정
Gui, Add, Text, x26 y257 w140 h20 , - 유저 차단`, 키워드 차단
Gui, Add, CheckBox, x26 y277 w90 h20 , 활성화
Gui, Add, Button, x166 y257 w80 h20 gBlock , 차단 설정
Gui, Add, Text, x26 y307 w80 h20 , - 알림 설정
Gui, Add, CheckBox, x26 y327 w80 h20 Checked vIsAlert , 알림음 켜기
Gui, Add, CheckBox, x26 y352 w110 h20 Checked gIsPopup vIsPopup , ★ 트레이팁 켜기
Gui, Add, CheckBox, x140 y352 w110 h20 vIsSup_Op , 현재 설정 유지
Gui, Add, Text, x116 y307 w110 h20 , - 알림음 볼륨 설정
Gui, Add, Text, x196 y327 w40 h20 vtext_Vol ,
Gui, Add, Slider, x116 y327 w80 h20 Range0-100 AltSubmit gslider_Vol vslider_Vol ,
Gui, Add, Button, x586 y383 w80 h20 gVer , 버전정보
Gui, Add, Button, x495 y383 w90 h20 gupdate_check , 업데이트 확인

Gui, Margin, 10, 10
Gui, Font, s9, Courier New
Gui, Font, cSilver,
Gui, Add, Text, x16 y387 w390 h20 gtgall , Made with %love% and AHK 2013-%A_YYYY%, Nayeon%love% (TWICE Gallery)
Gui, Font,,
Gui, Show, h405 w672 , 클린디씨 검색기 %_ver%
Gui, +HwndhID

SoundGet, cr_Vol, MASTER, VOLUME
cr_Vol := Round(cr_Vol)
GuiControl,, slider_Vol, % cr_Vol
GuiControl,, text_Vol, % cr_Vol

OnMessage(0x200, "WM_MOUSEMOVE")  ; for List View Mouse Hover Tooltips
Return

BTN:
gosub, Load
SetTimer, Load, 10000
return

Stop:
SetTimer, Load, Off
return

Load:
Gui, Submit, NoHide

if(preset_choice == 1)
	seek := StrSplit(StrReplace(keyword, " ", ""), ",")
else
{
	seek := StrSplit(StrReplace(ld_pr_kw[preset_choice - 1], " ", ""), ",")
	seek_user := StrSplit(StrReplace(ld_pr_us[preset_choice - 1], " ", ""), ",")
}

url := "http://gall.dcinside.com/board/lists/?id="
		. gall_ID

req.open("GET", url, false)
req.SetRequestHeader("User-Agent", "Mozilla/5.0 (Windows NT 5.1) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/41.0.2224.3 Safari/537.36")
req.SetRequestHeader("Accept", "text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8")
req.SetRequestHeader("Accept-Charset", "ISO-8859-1,utf-8;q=0.7,*;q=0.3")
req.SetRequestHeader("Accept-Encoding", "none")
req.SetRequestHeader("Accept-Language", "en-US,en;q=0.8")
req.SetRequestHeader("Connection", "keep-alive")
req.send()
req.WaitForResponse()

reqText := req.ResponseText

p := 1, m := ""
while p := RegExMatch(reqText, "s)ub-content(.*?)</tr>", m, p + StrLen(m))
{	
	RegExMatch(m, "gall_num.*?>(.*?)</td>", notice)
	t_notice := notice1
	RegExMatch(m, "class=""icon_img.*?""></em>(.*?)</a>", subject)
	t_subject := subject1
	RegExMatch(m, "'nickname.*?><em>(.*?)</em></span>", writer)
	IfInString, m, class="ip"
		RegExMatch(m, "class=""ip"">(.*?)</span>", ip)
	else
		ip1 := ""
	t_writer := writer1 . ip1

	If !(t_notice ~= "[0-9]")
		continue

	Loop, % seek.Length()
	{
		IfInString, t_subject, % seek[A_Index]
			IsContain := true
		IfNotEqual, preset_choice, 1
			if(t_writer = seek_user[A_Index])
				IsContain := true
	}
	if(!IsContain)
		continue
	
	IsContain := false
	
	if(t_notice <= array_notice[array_notice.Length()])
		break
	
	index++
	
	if(index = 1)
	{		
		if(!stack && t_notice)
		{
			stack := t_notice
			IsNewTitle := true
		}
		else if(stack < t_notice)
		{
			stack := t_notice
			IsNewTitle := true
		}
		else
		{
			index := ""
			IsNewTitle := ""
			temp_new := ""
			return
		}
	}
	
	temp_notice[index] := t_notice
	temp_subject[index] := t_subject
	temp_writer[index] := t_writer
	temp_new .= t_subject "`n"
}
index := ""

Loop, % temp_notice.Length()
{
	v_Index++
	array_notice[v_Index] := temp_notice[temp_notice.Length() - A_Index + 1]
	array_subject[v_Index] := temp_subject[temp_subject.Length() - A_Index + 1]
	array_writer[v_Index] := temp_writer[temp_writer.Length() - A_Index + 1]
}

LV_Delete()

Loop, % array_notice.Length()
	LV_Add(, array_notice[array_notice.Length() - A_Index + 1], array_subject[array_subject.Length() - A_Index + 1], array_writer[array_writer.Length() - A_Index + 1])

LV_ModifyCol(1, "auto")
LV_ModifyCol(2, "auto")
LV_ModifyCol(3, "auto")
temp_notice.RemoveAt(1, temp_notice.Length())
temp_subject.RemoveAt(1, temp_subject.Length())
temp_writer.RemoveAt(1, temp_writer.Length())

if IsNewTitle && IsPopup
{
	TrayTip, 새 글 알림, % temp_new
	if IsAlert
		SoundPlay, %A_Temp%\CleanDC_Searcher.Alert.wav
}
IsNewTitle := ""
temp_new := ""
return

IsPopup:
Gui, Submit, NoHide

if ! IsPopup
	GuiControl, Disable, IsAlert
else if IsPopup
	GuiControl, Enable, IsAlert
return

slider_Vol:
Gui, Submit, NoHide

GuiControl,, text_Vol, % slider_Vol
SoundSet, %slider_Vol%, MASTER, VOLUME
return

DDL:
Gui, Submit, NoHide

if(preset_choice = "1")
{
	GuiControl, Enable, text_kw
	GuiControl, Enable, keyword
}
else
{
	GuiControl, Disable, text_kw
	GuiControl, Disable, keyword
}

return

list_view:
Gui, Submit, NoHide

if(A_GuiEvent = "DoubleClick")
{
	LV_GetText(link, A_EventInfo, 1)
	
	if link ~= "[가-힣]"
		return
	
	Run, http://gall.dcinside.com/board/view/?id=%gall_ID%&no=%link%
}
else if(A_GuiEvent = "RightClick")
{
	LV_GetText(link2, A_EventInfo, 1)
	
	if link2 ~= "[가-힣]"
		return
	
	Clipboard = http://gall.dcinside.com/board/view/?id=%gall_ID%&no=%link2%
}
return

/*
ring:
Gui, Submit, NoHide

MsgBox % IsPopup
if ! IsPopup
	return

LV_GetText(t_flag, 1, 1)

if(!stack && t_flag)
{
	stack := t_flag
	TrayTip, 새 글 알림, % temp_new
	
	if IsAlert
		SoundPlay, %A_Temp%\CleanDC_Searcher.Alert.wav
}
else if(stack < t_flag)
{
	stack := t_flag
	TrayTip, 새 글 알림, % temp_new
	
	if IsAlert	
		SoundPlay, %A_Temp%\CleanDC_Searcher.Alert.wav
}
temp_new := ""
return
*/

tgall:
Run, http://gall.dcinside.com/board/lists/?id=twice
return


Preset:
Gui, 1:+Disabled

Gui, 2:Submit, NoHide
Gui, 2:Default
Gui, 2:Destroy

Gui, 2:Add, GroupBox, x6 y7 w250 h210 , 프리셋 설정
Gui, 2:Add, Text, x16 y27 w130 h20 , 프리셋 이름
Gui, 2:Add, Edit, x16 y47 w220 h20 vpreset_nm ,
Gui, 2:Add, Text, x16 y77 w130 h20 , 키워드 (쉼표로 구분)
Gui, 2:Add, Edit, x16 y97 w220 h20 vpreset_kw ,
Gui, 2:Add, Text, x16 y127 w130 h20 , 유저명 (쉼표로 구분)
Gui, 2:Add, Edit, x16 y147 w220 h20 vpreset_us ,
Gui, 2:Add, Button, x166 y177 w80 h30 gpr_add , 추가
Gui, 2:Add, GroupBox, x256 y7 w320 h350 , 프리셋 설정
Gui, 2:Add, ListView, x266 y27 w300 h280 AltSubmit gpr_lv , 프리셋|키워드|유저명
Gui, Add, Button, x266 y317 w80 h30 gpr_lv_del , 선택삭제
Gui, Add, Button, x356 y317 w80 h30 gpr_lv_del_all , 전체삭제
Gui, 2:Add, Button, x16 y317 w100 h30 gpr_sv , 저장
Gui, 2:Add, Button, x126 y317 w100 h30 gpr_cl , 취소
Gui, 2:Show, h366 w581, 프리셋 설정
Gui, 2:-SysMenu Owner1

gosub, pr_ld
Return

pr_lv:
if(A_GuiEvent = "Normal")
	sel_col := A_EventInfo
else if (A_GuiEvent = "DoubleClick")
{
	if ! A_EventInfo
		return
	
	eventinfo := A_EventInfo
	gosub, pr_lv_mod
}

return

pr_ld:
Loop, % ld_pr_nm.Length()
	LV_Add(, ld_pr_nm[A_Index], ld_pr_kw[A_Index], ld_pr_us[A_Index])

LV_ModifyCol(1, "auto")
LV_ModifyCol(2, "auto")
LV_ModifyCol(3, "auto")
return

pr_add:
Gui, 2:Submit, NoHide

if !preset_nm
{
	MsgBox,, 오류, 프리셋 이름을 설정해주세요.
	return
}

LV_Add(, preset_nm, preset_kw, preset_us)
LV_ModifyCol(1, "auto")
LV_ModifyCol(2, "auto")
LV_ModifyCol(3, "auto")
return

pr_sv:
Gui, 2:Submit, NoHide

MsgBox, 4, 저장, 프리셋 목록을 저장하시겠습니까? (이 과정은 돌이킬 수 없습니다.)
IfMsgBox, No, return
	
IfExist, % path
	FileDelete, % path

Loop, % LV_GetCount()
{
	LV_GetText(lv_1, A_Index, 1), LV_GetText(lv_2, A_Index, 2), LV_GetText(lv_3, A_Index, 3)
	
	IniWrite, %lv_1%, %path%, %A_Index%, name
	IniWrite, %lv_2%, %path%, %A_Index%, keyword
	IniWrite, %lv_3%, %path%, %A_Index%, user
}

MsgBox, , 완료, 예약 목록 저장이 완료되었습니다.

gosub, pr_cl
return

pr_cl:
Gui, 1:-Disabled
Gui, 2:Destroy
Gui, 1:Default

gosub, init_load
return

pr_lv_del:
LV_Delete(sel_col)
return

pr_lv_del_all:
LV_Delete()
return

pr_lv_mod:
return


Block:
Gui, 1:+Disabled

Gui, 3:Submit, NoHide
Gui, 3:Default
Gui, 3:Destroy

Gui, 3:Add, GroupBox, x6 y7 w500 h170 , 유저 차단
Gui, 3:Add, Text, x16 y27 w110 h20 , - 차단 유저 닉네임
Gui, 3:Add, Edit, x16 y47 w190 h20 vbl_user ,
Gui, 3:Add, Button, x216 y57 w60 h60 gbl_add_1 , -->
Gui, 3:Add, Text, x16 y77 w160 h20 , ※ 한번에 한 명만 추가 가능
Gui, 3:Add, Text, x16 y97 w160 h40 , ※ 아이피 차단 현재 불가`n    "ㅇㅇ" 차단 가능
Gui, 3:Add, ListBox, x296 y27 w200 h120 , 차단유저 리스트
Gui, 3:Add, Button, x306 y147 w80 h20 gbl_del_1 , 선택 삭제
Gui, 3:Add, Button, x396 y147 w80 h20 gbl_del_all_1 , 전체 삭제

Gui, 3:Add, GroupBox, x6 y187 w500 h170 , 키워드 차단
Gui, 3:Add, Text, x16 y207 w110 h20 , - 차단 단어
Gui, 3:Add, Edit, x16 y227 w190 h20 vbl_keyword ,
Gui, 3:Add, Button, x216 y237 w60 h60 gbl_add_2 , -->
Gui, 3:Add, Text, x16 y257 w170 h20 , ※ 한번에 한 단어만 추가 가능
Gui, 3:Add, ListBox, x296 y207 w200 h112 , 차단 단어 리스트
Gui, 3:Add, Button, x306 y327 w80 h20 gbl_del_2 , 선택 삭제
Gui, 3:Add, Button, x396 y327 w80 h20 gbl_del_all_2 , 전체 삭제

Gui, 3:Add, Button, x326 y367 w80 h30 gbl_sv , 저장
Gui, 3:Add, Button, x416 y367 w80 h30 gbl_cl , 취소

Gui, 3:Show, w511 h402, 차단 설정
Gui, 3:-SysMenu Owner1
return

bl_add_1:
bl_add_2:
Gui, 3:Submit, NoHide

if A_ThisLabel = "bl_add_1"
{
}

return

bl_del_1:
bl_del_2:

return

bl_del_all_1:
bl_del_all_2:

return

bl_sv:
Gui, 3:Submit, NoHide

gosub, bl_cl
return

bl_cl:
Gui, 1:-Disabled
Gui, 3:Destroy
Gui, 1:Default

gosub, init_load
return

Ver:
Gui, 3:Add, Text, x6 y7 w80 h20 , Version Info:
Gui, 3:Add, Edit, x6 y27 w460 h320 ReadOnly +Center , %ver_log%
Gui, 3:Add, Button, x230 y357 w100 h20 gli_Link , read license..

Gui, 3:Margin, 10, 10
Gui, 3:Font, s9, Courier New
Gui, 3:Add, Text, x6 y357 w220 h20 , GNU General Public License v3.0
Gui, 3:Font,,
Gui, 3:Show, w477 h381, 버전 정보
return

li_Link:
Run, https://www.gnu.org/licenses/gpl-3.0.html
return

WM_SYSCOMMAND(wParam)
{
	If (wParam = 61472) ; minimize
		SetTimer, Minimize, -1
	Else If (wParam = 61728) ; restore
		SetTimer, Restore, -1
}

DC_GetContext(num)
{
	global
	res:= "", res1 := ""
	req.Open("GET", "http://m.dcinside.com/board/" . gall_ID . "/" . num)
	req.SetRequestHeader("Accept", "text/html,application/xhtml+xml,application/xml;q=0.9,image/webp,image/apng,*/*;q=0.8")
	req.SetRequestHeader("Accept-Language", "ko,en-US;q=0.9,en;q=0.8")
	req.SetRequestHeader("User-Agent", "Mozilla/5.0 (Linux; Android 6.0; Nexus 5 Build/MRA58N) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/71.0.3578.98 Mobile Safari/537.36")
	req.Send()
	req.WaitForResponse()
	
	RegExMatch(req.ResponseText, "<meta name=""description"" content=""(.*?)"">", res)
	return res1
}

; Thanks to temp01 --------------------------------------------------------------------------
; for Fixed Width Strings
; https://autohotkey.com/board/topic/45543-fixed-width-strings/?p=283476
PadStr(str, size)
{
	loop % size-StrLen(str)
		str .= A_Space
	
	return str
}
; -----------------------------------------------------------------------------------------------

; Thanks to Micahs -------------------------------------------------------------------------------
; for List View Mouse Hover Tooltips
; https://autohotkey.com/board/topic/30486-listview-tooltip-on-mouse-hover/?p=280843

WM_MOUSEMOVE(wParam, lParam, msg, hwnd)
{
	global
	If(hwnd = LV_LView)	;only if the mouse moved over the listview
	{	LV_MouseGetCellPos(LV_CurrRow, LV_CurrCol, LV_LView)
		If(oldLV_CurrRow != LV_CurrRow)	;if it has changed
		{	oldLV_CurrRow := LV_CurrRow
			ToolTip,,,, 20
			counter := A_TickCount + 500
			Loop	;loop for 500 ms and cancel tip if row changed
			{	LV_MouseGetCellPos(LV_CurrRow, LV_CurrCol, LV_LView)
				IfNotEqual, oldLV_CurrRow, %LV_CurrRow%
				{	SetTimer, KillNow, -1
					Return
				}
				looper := A_TickCount
				IfGreater, looper, %counter%, Break
				sleep, 150
			}
			LV_GetText(txt1, LV_currRow, 1)
			txt2 := DC_GetContext(txt1)
			
			SetTimer, killTip, 500
			ToolTip, %txt2%,,,20
		}
		Return
		killTip:
			killTipCounter++
			MouseGetPos, , , outWm, outK, 2
			If(outK != LV_LView) or (killTipCounter >= 8)	;500ms*8 = ~4 secs
			{	;this lets us kill the tooltip immediately
				KillNow:
					SetTimer, killTip, Off
					ToolTip,,,, 20
					killTipCounter=0
				Return
			}
		Return
	}
	Else	;if not over lv, destroy tip
	{	SetTimer, killTip, -1	;go now once
	}
}

LV_MouseGetCellPos(ByRef LV_CurrRow, ByRef LV_CurrCol, LV_LView)
{	
	LVIR_LABEL = 0x0002					;LVM_GETSUBITEMRECT constant - get label info
	LVM_GETITEMCOUNT = 4100			;gets total number of rows
	LVM_SCROLL = 4116						;scrolls the listview
	LVM_GETTOPINDEX = 4135			;gets the first displayed row
	LVM_GETCOUNTPERPAGE = 4136	;gets number of displayed rows
	LVM_GETSUBITEMRECT = 4152		;gets cell width,height,x,y
	ControlGetPos, LV_lx, LV_ly, LV_lw, LV_lh, , ahk_id %LV_LView%	;get info on listview

	SendMessage, LVM_GETITEMCOUNT, 0, 0, , ahk_id %LV_LView%
	LV_TotalNumOfRows := ErrorLevel	;get total number of rows
	SendMessage, LVM_GETCOUNTPERPAGE, 0, 0, , ahk_id %LV_LView%
	LV_NumOfRows := ErrorLevel	;get number of displayed rows
	SendMessage, LVM_GETTOPINDEX, 0, 0, , ahk_id %LV_LView%
	LV_topIndex := ErrorLevel	;get first displayed row
	
	CoordMode, MOUSE, RELATIVE
	MouseGetPos, LV_mx, LV_my
	LV_mx -= LV_lx, LV_my -= LV_ly
	
	VarSetCapacity(LV_XYstruct, 16, 0)	;create struct
	Loop,% LV_NumOfRows + 1	;gets the current row and cell Y,H
	{	LV_which := LV_topIndex + A_Index - 1	;loop through each displayed row
		NumPut(LVIR_LABEL, LV_XYstruct, 0)	;get label info constant
		NumPut(A_Index - 1, LV_XYstruct, 4)	;subitem index
		SendMessage, LVM_GETSUBITEMRECT, %LV_which%, &LV_XYstruct, , ahk_id %LV_LView%	;get cell coords
		LV_RowY := NumGet(LV_XYstruct,4)	;row upperleft y
		LV_RowY2 := NumGet(LV_XYstruct,12)	;row bottomright y2
		LV_currColHeight := LV_RowY2 - LV_RowY ;get cell height
		If(LV_my <= LV_RowY + LV_currColHeight)	;if mouse Y pos less than row pos + height
		{	LV_currRow  := LV_which + 1	;1-based current row
			LV_currRow0 := LV_which		;0-based current row, if needed
			;LV_currCol is not needed here, so I didn't do it! It will always be 0. See my ListviewInCellEditing function for details on finding LV_currCol if needed.
			LV_currCol=0
			Break
		}
	}
}

; -----------------------------------------------------------------------------------------------

SkinForm(Param1 = "Apply", DLL = "", SkinName = ""){
	if(Param1 = Apply){
		DllCall("LoadLibrary", str, DLL)
		DllCall(DLL . "\USkinInit", Int,0, Int,0, AStr, SkinName)
	}else if(Param1 = 0){
		DllCall(DLL . "\USkinExit")
	}
}

Minimize:
	Critical
	Gui, Hide
	Menu, Tray, Icon
	Menu, Tray, Tip, 클린디시 갤러리 %_ver%
Return
   
Restore:
	Critical
	Menu, Tray, NoIcon
	Gui, Show
Return

GetOut:
gosub, w_log
GuiClose:
Gui, 1:Submit, Nohide
SetTimer, Load, Off

IniWrite, %IsSup_Op%, %path%, Option, supply_option
IniWrite, %preset_choice%, %path%, Option, preset
IniWrite, %IsAlert%, %path%, Option, alert
IniWrite, %IsPopup%, %path%, Option, popup
IniWrite, %slider_Vol%, %path%, Option, volume

SkinForm(0)
ExitApp
