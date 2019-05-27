#NoEnv
#UseHook

;Per-mapping settings, saved and loaded to and from the ini file.
global mapping_name := "default"
global left_key := "Left"
global right_key := "Right"
global down_key := "Down"
global up_key := "Up"
global deadzone_x = 10
global deadzone_y = 10
global reset_mouse := true
global reset_x = 100
global reset_y = 100
global frequency = 50
;GUI values
global mapping_name_combo := ""
global left_key_edit := ""
global right_key_edit := ""
global down_key_edit := ""
global up_key_edit := ""
global deadzone_x_edit := ""
global deadzone_y_edit := ""
global reset_mouse_check := ""
global reset_x_edit := ""
global reset_y_edit := ""
global frequency_edit := ""
;Running states
global mapping_list := ""
global mapping_array := []
global gui_created := false
global show_gui := true
global active := true
global last_x = 0
global last_y = 0
global x_key_down = 0
global y_key_down = 0

if (!FileExist("mouse_control.ini"))
	SaveMapping()
GetMappingList()
LoadMapping(mapping_list[1])

Gui, +Delimiter`n
Gui, Add, Text, , Mapping:
Gui, Add, ComboBox, x+m vmapping_name_combo gMappingSelected Choose1, %mapping_list%
Gui, Add, Button, x+m gNewMappingPressed, &New
Gui, Add, Button, x+m gDeleteMappingPressed, &Delete
Gui, Add, Text, xm, Keys
Gui, Add, Text, xm w35 right, Left:
Gui, Add, Edit, x+m w80 vleft_key_edit gSettingChanged, %left_key%
gui, Add, Text, x+m w35 right, Right:
Gui, Add, Edit, x+m w80 vright_key_edit gSettingChanged, %right_key%
Gui, Add, Text, xm w35 right, Down:
Gui, Add, Edit, x+m w80 vdown_key_edit gSettingChanged, %down_key%
Gui, Add, Text, x+m w35 right, Up:
Gui, Add, Edit, x+m w80 vup_key_edit gSettingChanged, %up_key%
Gui, Add, Text, xm, Deadzone
Gui, Add, Text, xm w35 right, X:
Gui, Add, Edit, x+m w80 vdeadzone_x_edit gSettingChanged Number, %deadzone_x%
Gui, Add, Text, x+m w35 right, Y:
Gui, Add, Edit, x+m w80 vdeadzone_y_edit gSettingChanged Number, %deadzone_y%
Gui, Add, Text, xm, Reset Mouse:
Gui, Add, CheckBox, x+m vreset_mouse_check gSettingChanged
GuiControl, , reset_mouse_check, %reset_mouse%
Gui, Add, Text, xm w35 right, X:
Gui, Add, Edit, x+m w80 vreset_x_edit gSettingChanged Number, %reset_x%
Gui, Add, Text, x+m w35 right, Y:
Gui, Add, Edit, x+m w80 vreset_y_edit gSettingChanged Number, %reset_y%
Gui, Add, Text, xm, Frequency (ms):
Gui, Add, Edit, x+m w80 vfrequency_edit gSettingChanged Number, %frequency%
Gui, Add, Button, xm+95 w80 gOK, OK
Gui, Add, Text, xm w270 Center, Welcome to BloodyNex's Mouse Control
Gui, Add, Text, xm w270, You can press alt+o to show or hide this window at any time. When this window is hidden, you can also press alt+m to activate or deactivate mouse tracking and resetting without opening this window.`n`nYou may enter keys using AHK names (such as left, alt, and lshift) or by entering a letter, number, or symbol key. Capitalized letters will act as if shift is pressed when used.`n`nDeadzone is used much like it is for joysticks, requiring a certain distance (velocity, in this case) before that direction's key is pressed.`n`nReset mouse will cause this script to move the mouse back to the coordinates you've selected after each cycle to prevent stopping once the mouse reaches the edges of the screen.`n`nFrequency determines how often, in milliseconds, the mouse position is checked and the key presses are updated. The higher this value, the higher deadzone x and y should be to function as intended.
Gui, Show
gui_created = true
SetTimer, CheckMousePosition, %frequency%

MappingSelected:
GuiControlGet, mapping_name_combo
if (InArray(mapping_name_combo, mapping_array))
	LoadMapping(mapping_name_combo)
return

NewMappingPressed:
GuiControlGet, mapping_name_combo
mapping_name := mapping_name_combo
SaveMapping()
GetMappingList()
return

DeleteMappingPressed:
GuiControlGet, mapping_name_combo
DeleteMapping(mapping_name_combo)
return

SettingChanged:
if (A_GuiControl = "left_key_edit")
{
	GuiControlGet, left_key_edit
	left_key := left_key_edit
}
else if (A_GuiControl = "right_key_edit")
{
	GuiControlGet, right_key_edit
	right_key := right_key_edit
}
else if (A_GuiControl = "down_key_edit")
{
	GuiControlGet, down_key_edit
	down_key := down_key_edit
}
else if (A_GuiControl = "up_key_edit")
{
	GuiControlGet, up_key_edit
	up_key := up_key_edit
}
else if (A_GuiControl = "deadzone_x_edit")
{
	GuiControlGet, deadzone_x_edit
	deadzone_x := deadzone_x_edit
}
else if (A_GuiControl = "deadzone_y_edit")
{
	GuiControlGet, deadzone_y_edit
	deadzone_y := deadzone_y_edit
}
else if (A_GuiControl = "reset_mouse_check")
{
	GuiControlGet, reset_mouse_check
	if (reset_mouse_check = 1)
		reset_mouse := true
	else
		reset_mouse := false
}
else if (A_GuiControl = "reset_x_edit")
{
	GuiControlGet, reset_x_edit
	reset_x := reset_x_edit
}
else if (A_GuiControl = "reset_y_edit")
{
	GuiControlGet, reset_y_edit
	reset_y := reset_y_edit
}
else if (A_GuiControl = "frequency_edit")
{
	GuiControlGet, frequency_edit
	frequency := frequency_edit
	SetTimer, CheckMousePosition, %frequency%
}
SaveMapping()
return

GuiClose:
Gui, Show, Hide
show_gui := false
return

OK:
Gui, Show, Hide
show_gui := false
return

CheckMousePosition:
if (!show_gui && active)
{
	MouseGetPos, mouse_x, mouse_y
	if (mouse_x + deadzone_x < last_x)
	{
		if (x_key_down = 1)
			Send, {%right_key% up}
		if (x_key_down != -1)
		{
			Send, {%left_key% down}
			x_key_down = -1
		}
	}
	else if (mouse_x - deadzone_x > last_x)
	{
		if (x_key_down = -1)
			Send, {%left_key% up}
		if (x_key_down != 1)
		{
			Send, {%right_key% down}
			x_key_down = 1
		}
	}
	else
	{
		if (x_key_down = -1)
		{
			Send, {%left_key% up}
			x_key_down = 0
		} 
		else if (x_key_down = 1)
		{
			Send, {%right_key% up}
			x_key_down = 0
		}
	}
	if (mouse_y - deadzone_y > last_y)
	{
		if (y_key_down = 1)
			Send, {%up_key% up}
		if (y_key_down != -1)
		{
			Send, {%down_key% down}
			y_key_down = -1
		}
	} 
	else if (mouse_y + deadzone_y < last_y)
	{
		if (y_key_down = -1)
			Send, {%down_key% up}
		if (y_key_down != 1)
		{
			Send, {%up_key% down}
			y_key_down = 1
		}
	}
	else
	{
		if (y_key_down = -1)
		{
			Send, {%down_key% up}
			y_key_down = 0
		} 
		else if (y_key_down = 1)
		{
			Send, {%up_key% up}
			y_key_down = 0
		}
	}
	if (reset_mouse)
	{
		MouseMove, reset_x, reset_y
		last_x := reset_x
		last_y := reset_y
	}
	else
	{
		last_x := mouse_x
		last_y := mouse_y
	}
}
return

InArray(value, search_array)
{
	Loop % search_array.MaxIndex()
	{
		if (search_array[A_Index] = value)
			return A_Index
	}
	return 0
}

GetMappingList()
{
	IniRead, mapping_list, mouse_control.ini
	mapping_array := StrSplit(mapping_list, "`n")
	if (gui_created)
	{
		GuiControl, , mapping_name_combo, `n%mapping_list%
		GuiControl, ChooseString, mapping_name_combo, %mapping_name%
	}
}

SaveMapping()
{
	IniWrite, %left_key%, mouse_control.ini, %mapping_name%, left_key
	IniWrite, %right_key%, mouse_control.ini, %mapping_name%, right_key
	IniWrite, %down_key%, mouse_control.ini, %mapping_name%, down_key
	IniWrite, %up_key%, mouse_control.ini, %mapping_name%, up_key
	IniWrite, %deadzone_x%, mouse_control.ini, %mapping_name%, deadzone_x
	IniWrite, %deadzone_y%, mouse_control.ini, %mapping_name%, deadzone_y
	IniWrite, %reset_mouse%, mouse_control.ini, %mapping_name%, reset_mouse
	IniWrite, %reset_x%, mouse_control.ini, %mapping_name%, reset_x
	IniWrite, %reset_y%, mouse_control.ini, %mapping_name%, reset_y
	IniWrite, %frequency%, mouse_control.ini, %mapping_name%, frequency
}

DeleteMapping(name)
{
	if (!InArray(name, mapping_array))
		return
	IniDelete, mouse_control.ini, %name%
	GetMappingList()
	if (name = mapping_name)
	{
		LoadMapping(mapping_array[1])
	}
}

LoadMapping(name)
{
	if !(InArray(name, mapping_array))
		return false
	IniRead, left_key, mouse_control.ini, %name%, left_key
	IniRead, right_key, mouse_control.ini, %name%, right_key
	IniRead, down_key, mouse_control.ini, %name%, down_key
	IniRead, up_key, mouse_control.ini, %name%, up_key
	IniRead, deadzone_x, mouse_control.ini, %name%, deadzone_x
	IniRead, deadzone_y, mouse_control.ini, %name%, deadzone_y
	IniRead, reset_mouse, mouse_control.ini, %name%, reset_mouse
	IniRead, reset_x, mouse_control.ini, %name%, reset_x
	IniRead, reset_y, mouse_control.ini, %name%, reset_y
	IniRead, frequency, mouse_control.ini, %name%, frequency
	if (gui_created)
	{
		GuiControl, ChooseString, mapping_name_combo, %name%
		GuiControl, , left_key_edit, %left_key%
		GuiControl, , right_key_edit, %right_key%
		GuiControl, , down_key_edit, %down_key%
		GuiControl, , up_key_edit, %up_key%
		GuiControl, , deadzone_x_edit, %deadzone_x%
		GuiControl, , deadzone_y_edit, %deadzone_y%
		GuiControl, , reset_mouse_check, %reset_mouse%
		GuiControl, , reset_x_edit, %reset_x%
		GuiControl, , reset_y_edit, %reset_y%
		GuiControl, , frequency_edit, %frequency%
		SetTimer, CheckMousePosition, %frequency%
	}
	mapping_name := name
	return true
}

!O::
if (show_gui)
{
	Gui, Show, Hide
	show_gui := false
}
else
{
	Gui, Show
	show_gui := true
}
return

!M::
if (active)
{
	active := false
} 
else if (show_gui = false)
{
	active := true
	if (reset_mouse)
	{
		MouseMove, reset_x, reset_y
		last_x := reset_x
		last_y := reset_y
	} 
	else 
	{
		MouseGetPos, last_x, last_y
	}
}
return