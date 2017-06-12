#!/usr/bin/wish
# vim: foldmarker=<<<,>>>
# licensing / boilerplate / blathering:
# this cruddy clone is distributed under the terms of the BSD licensing scheme, with addendums as I state below. 
# 	By nature of the language, you have free access to modify it, but by natuer of the licensing, you also have 
# 	my blessing to do with it as you please. Should you improve the game, i would respectfully request that you 
# 	send said improvements to me, for the benefit of any others who might be nutty enough to use this. Should 
# 	you *sell* this code, or include it in any product / distribution, or in any way make money off of it (ha ha)
# 	then i would request that you give me some of the action. I think that's only fair. Not doing so will simply
# 	point you out for what you are. You MAY NOT distribute this file, or any part therof or derived work without
# 	this agreement. By using the software, you agree to my terms, and violation will result in a plague of
# 	underpants gnomes infesting your sock drawer. You may, with my explicit consent, draw pleasure from this work
# 	or use it in any educational arena for free (ha ha ha (again)). This software is distributed AS IS, and I take
# 	no responsibility for any consequences of use, including, but not excluded to: hardware damage, brain damage,
# 	time management crises that result in the termination of long-term relationships or potention relationships,
# 	George W Bush being a moron and blowing up more innocent people (even if he was playing this at the time),
# 	data loss, time loss, hair loss, plagues of insects, frogs or snakes, fire from above or even failure of
# 	your mouse to take the strain. So don't bother even considering to form a committee to formulate a plan to 
# 	do coffee and discuss a date to scheme a way to get back at me (in any manner). That being said, if you have
# 	a constructiv request / criticism (which manages to make use of more than 10 words of the english language),
# 	I will take it into consideration. I may even fix any bugs that arise. But I may not. 'Tis a knife's edge
# 	you traverse. Before constructing a long draft of complaints and flames, please remember that this is the 
# 	very first tcl/tk application i have ever written. I think it beats "Helllo World", 'tho admittedly not by
# 	much. I hope that you enjoy it.

# default setup parameters <<<1
array set cfg {
	request_no_images 	0
	theme 				"default"
	numrows 			10
	numcols 			10
	nummines			10
	bwidthpix			20
	bheightpix			20
	bwidthtext			1
	bheighttext			1
	gametype			0
	forecolor_1			"#1111FF"
	forecolor_2			"#11FF11"
	forecolor_3			"#FF1111"
	forecolor_4			"#11FFFF"
	forecolor_5			"#FF11FF"
	forecolor_6			"#FFFF11"
	forecolor_7			"#CCCCCC"
	aforecolor_1		"#6666FF"
	aforecolor_2		"#66FF66"
	aforecolor_3		"#FF6666"
	aforecolor_4		"#66FFFF"
	aforecolor_5		"#FF66FF"
	aforecolor_6		"#FFFF66"
	aforecolor_7		"#FFFFFF"
	savecfg				1
}
array set gametypes {
	0,rows				10
	0,cols 				10
	0,mines				10
	1,rows 				15
	1,cols 				15 
	1,mines				22
	2,rows 				20 
	2,cols 				20 
	2,mines				40
}
set hi						{"Bob the builder" 90 "Barney the Purple Dinosour" 180 "Chris the Ninja Pirate" "360"}
array set hiname {
	0				"Tiny Grasshopper"
	1               "Ninny Ninja" 	 
	2               "Thai Kwon Dodo"  
}
set BoardInitiated 			0
set gameover				1
proc readCFG {} { #<<<1
	if {[file exists "mynes.cfg"]} {
		if {[catch {set fp [open "mynes.cfg" r]}]} {
			puts "unable to open mynes.cfg for reading. Config parameters will be set to defaults."
		} else {
			foreach {index value} [read -nonewline $fp] {
				set ::cfg($index) $value
			}
			close $fp
		}
		if {[info exists ::cfg(request_no_images)]} {
			if {[info exists ::cfg(theme)]} {
				if {$::cfg(theme)=="none"} {
					set ::cfg(request_no_images) 1
				} else {
					set ::cfg(request_no_images) 0
				}
			}
		}
	} else {
		puts "mynes.cfg not found. Default config used."
	}
}

proc writeCFG {} { #<<<1
	if {[catch {set fp [open "mynes.cfg" w]}]} {
		puts "Unable to open mynes.cfg for writing. Config file not updated."
	} else {
		foreach {index value} [array get ::cfg] {
			puts $fp "$index\t$value"
		}
		close $fp
	}
}

proc readHiscores {} { #<<<1
	if {[file exists "mynes.hi"]} {
		if {[catch {set fp [open "mynes.hi" r]}]} {
			puts "unable to open mynes.hi for reading. Hi scores will be set to defaults."
		} else {
			set tmp [read -nonewline $fp]
			close $fp
#			clean up what we have read to make sure that there is no cruft in there
			set gametype 0
			foreach {name score} $tmp {
				set i [expr {$gametype * 2}]
				set j [expr {$i+1}]
				set ::hi [lreplace [lreplace $::hi $i $i $name] $j $j $score]
				incr gametype 
				if {$gametype>2} {break}
			}
		}
	} else {
		puts "mynes.hi not found. No hi scores recorded yet."
	}
}


proc setHiScore {gametype}  { #<<<1
	set currenttime [ReduceToNum [$::timerlabel cget -text]]
	puts "looking at index : [expr {($gametype*2)+1}]"
	set currenthi [lindex $::hi [expr {($gametype*2)+1}]]
	puts "Old hi: $currenthi \t New hi: $currenttime"
	if {$currenttime<$currenthi} {
		set ::hiName "[lindex $::hi [expr {$gametype*2}]]" 
		toplevel .newhi
		
		label .newhi.lblSplurb 	-text "Congratulations! You have made it into the Hero rankings!"
		label .newhi.lbl_Time	-text "Quest duration:"
		label .newhi.lblTime	-text "$currenttime"
		label .newhi.lblName	-text "Your credentials:"
		entry .newhi.entName	-textvariable ::hiName
		button .newhi.btnSave	-text "Immortalise me!" -command [list saveNewHi $gametype]
		grid .newhi.lblSplurb 	-row 1 -column 1 -columnspan 2 -ipadx 5 -ipady 5
		grid .newhi.lbl_Time 	-row 2 -column 1 -ipadx 5
		grid .newhi.lblTime		-row 2 -column 2 -ipadx 5
		grid .newhi.lblName		-row 3 -column 1 -ipadx 5
		grid .newhi.entName		-row 3 -column 2 -ipadx 5
		grid .newhi.btnSave		-row 4 -column 2 -ipadx 5 -ipady 5
		bind .newhi.entName <Key-Return> [list saveNewHi $gametype] 
		wm title .newhi "New Hi Score!"
		wm resizable .newhi 0 0
		moveToCenter .newhi
	}
}

proc saveNewHi {gametype} { #<<<1
	writeHiscores $gametype $::hiName [$::timerlabel cget -text]
	destroy .newhi
}

proc writeHiscores {{alter_gametype -1} {alter_name ""} {alter_time 0}} { #<<<1
	if {$alter_gametype>-1} {
		set i [expr {$alter_gametype*2}]
		set j [expr {$i+1}]
		set ::hi [lreplace [lreplace $::hi $i $i $alter_name] $j $j [ReduceToNum $alter_time]]
	}
	puts "new ::hi : $::hi"
	if {[catch {set fp [open "mynes.hi" w]}]} {
		puts "unable to open mynes.hi for writing. Hi scores will not be saved."
	} else {
		foreach {name score} $::hi {
			puts $fp "\{$name\} $score"
		}
		close $fp
	}
#	update the .hi dialog, if it is open
	set gametype 0
	foreach hiscore $::hi {
		set i [expr {$gametype * 2}]
		set j [expr {$i+1}]
		set r [expr {$gametype +3}]
		.hi.fraScores.lblHero$gametype conf -text [lindex $::hi $i]
		.hi.fraScores.lblTime$gametype conf -text [lindex $::hi $j]
		
		incr gametype
		if {$gametype>2} {break}
	}
}

proc displayHiscores {{withdraw 0}} { #<<<1
	
	if {$withdraw} {
		toplevel .hi
		bind .hi <Key-Escape> [list destroy .hi]
		label .hi.lblSplurb -text "Mynes Hi Scores."

		set f [frame .hi.fraScores -borderwidth 2 -relief groove]
		label $f.head1 -text "Game Level." -borderwidth 1 -relief solid
		label $f.head2 -text "Hero Name." -borderwidth 1 -relief solid
		label $f.head3 -text "Quest duration." -borderwidth 1 -relief solid
		grid $f.head1 -row 1 -column 1 -sticky we -ipadx 5
		grid $f.head2 -row 1 -column 2 -sticky we -ipadx 5
		grid $f.head3 -row 1 -column 3 -sticky we -ipadx 5
		set gametype 0
		foreach hiscore $::hi {
			switch -- $gametype {
				"0"		{	label $f.lblGameType$gametype -text $::hiname($gametype)	}
				"1"		{	label $f.lblGameType$gametype -text $::hiname($gametype)	}
				"2"		{	label $f.lblGameType$gametype -text $::hiname($gametype)	}
			}
			set i [expr {$gametype * 2}]
			set j [expr {$i+1}]
			set r [expr {$gametype +3}]
			label $f.lblHero$gametype -text [lindex $::hi $i]
			label $f.lblTime$gametype -text [lindex $::hi $j]
			
			grid $f.lblGameType$gametype 	-row $r -column 1 -sticky w -ipadx 5
			grid $f.lblHero$gametype		-row $r -column 2 -sticky w -ipadx 5
			grid $f.lblTime$gametype		-row $r -column 3 -sticky e -ipadx 5
			
			incr gametype
			if {$gametype>2} {break}
		}
		
		button .hi.btnClose -text "Close" -command [list wm withdraw .hi]
		grid .hi.lblSplurb 	-row 1 -column 2
		grid rowconfig .hi.lblSplurb 2 -minsize 15
		grid .hi.fraScores 	-row 2 -column 1 -columnspan 3
		grid .hi.btnClose	-row 3 -column 3 -sticky we
		wm title .hi "Hi scores"
		wm resizable .hi 0 0
		wm withdraw .hi
		wm protocol .hi WM_DELETE_WINDOW [list wm withdraw .hi]
		moveToCenter .hi
	} else {
		wm deiconify .hi
	}
}


proc closewin {} { #<<<1
#	throw up a confirmation dialogue if there is a game in progress. 
	if {$::gameover} {
		exitmynes
	} else {
		grab .confirm
		wm deiconify .confirm
	}
}

proc unloadConfirm {} { #<<<1
	grab release .confirm
	wm withdraw .confirm
}

proc genConfirm {} {
	toplevel .confirm
	wm withdraw .confirm
	label .confirm.msg 	-text "Are you sure you would like to exit Mynes?"
	button .confirm.yes	-text "Yes" -command exitmynes
	button .confirm.no	-text "No" -command unloadConfirm
	grid .confirm.msg	-row 1 -column 1 -columnspan 2
	grid .confirm.yes	-row 2 -column 1
	grid .confirm.no	-row 2 -column 2
	wm title .confirm "Confirm exit."
	wm resizable .confirm 0 0
	bind <Key-Escape> .confirm unloadConfirm
	wm protocol .confirm WM_DELETE_WINDOW unloadConfirm
	moveToCenter .confirm
}

proc moveToCenter {toplevelname} { #<<<1
	update idletasks
	set screenw [winfo screenwidth $toplevelname]
	set screenh [winfo screenheight $toplevelname]
	set windim	[lindex [split [winfo geometry $toplevelname] +] 0]
	set winw	[lindex [split $windim x] 0]
	set winh	[lindex [split $windim x] 1]
	set newx	[expr {int(($screenw-$winw)/2)}]
	set newy	[expr {int(($screenh-$winh)/2)}]
	wm geometry $toplevelname [join [concat + $newx + $newy] ""]
}

proc exitmynes {} { #<<<1
#	we just want to make sure that configs are saved here
	if {$::cfg(savecfg)} {
		writeCFG
	}
	destroy .
}
proc ToggleSaveCFG {} { #<<<1
	set $::cfg(savecfg) !$::cfg(savecfg)
	
}

proc loadImage {themename filename} { #<<<1
	set thisimage [file join "themes" $themename [join [concat $filename ".gif"] ""]]
	if {[file exists $thisimage]} {
		image create photo [join [concat $filename "_image"] ""] -file $thisimage
		return 1
	} else {
		return 0
	}
}


proc go_home {} { #<<<1
	return {
		set initial_cwd	[pwd]
		set scriptpath		"./"
		set script  		[info script]
		if {$script == ""} {
			set script  [info nameofexecutable]
		}
		cd [file dirname $script]
		if {$script != ""} {
			while {![catch {set script  [file readlink $script]}]} {}
			set scriptpath      [file dirname $script]
			lappend auto_path   	$scriptpath
			cd $scriptpath
		}
	}
}

proc StartTimer {} { #<<<1
	global timerlabel
	global gamelength
	set gamelength 0
	$timerlabel configure -text "000"
	after 1000 DoTimer
}

proc DoTimer {} { #<<<1
	global gamelength
	global gameover
	global timerlabel
	global BoardInitiated
	if {$gameover==0 && $BoardInitiated==1} {
		incr gamelength
		$timerlabel configure -text [RowColName $gamelength 999]
		after 1000 DoTimer
	}
}

proc RowColName {thisnum maxnum} { #<<<1
	set namelen [string length $maxnum]
	while {[string length $thisnum]<$namelen} {
		set thisnum "0$thisnum"
	}
	return $thisnum
}

proc ReduceToNum {thisnum} { #<<<1
	set num [string trimleft $thisnum 0]
	if {$num ==""} {set num 0}
	return [format "%d" $num]
}

proc max {num1 num2} { #<<<1
	if {$num1>$num2} {
		return $num1
	} else {
		return $num2
	}
}

proc min {num1 num2} { #<<<1
	if {$num1<$num2} {
		return $num1
	} else {
		return $num2
	}
}

proc getForeColor {val} { #<<<1
	global defaultforecolor
	switch -- $val {
		"1" {return $::cfg(forecolor_1)}
		"2" {return $::cfg(forecolor_2)}
		"3" {return $::cfg(forecolor_3)}
		"4" {return $::cfg(forecolor_4)}
		"5" {return $::cfg(forecolor_5)}
		"6" {return $::cfg(forecolor_6)}
		"7" {return $::cfg(forecolor_7)}
		default {return $defaultforecolor}
	}
}

proc getActiveForeColor {val} { #<<<1
	global defaultforecolor
	switch -- $val {
		1 {return $::cfg(aforecolor_1)}
		2 {return $::cfg(aforecolor_2)}
		3 {return $::cfg(aforecolor_3)}
		4 {return $::cfg(aforecolor_4)}
		5 {return $::cfg(aforecolor_5)}
		6 {return $::cfg(aforecolor_6)}
		7 {return $::cfg(aforecolor_7)}
		default {return $defaultforecolor}
	}
}

proc Reveal {row col} { #<<<1
	global Barray
	global MineArray
	global BoardInitiated
	global statuslabel
	global revealedblocks
	global gameover
	global totalblocks
	global use_images
	if {$BoardInitiated==0} {
		puts "initiating board to $::cfg(numrows) $::cfg(numcols) $::cfg(nummines)"
		InitBoard $::cfg(numrows) $::cfg(numcols) $::cfg(nummines) $row $col
		StartTimer
	}
#	puts "revealing $row,$col -- Barray($row,$col): $Barray($row,$col)\t\tMineArray($row,$col): $MineArray($row,$col)"
	if {[$Barray($row,$col) cget -text]!="m" && [$Barray($row,$col) cget -text]!="?"} {
		if {$MineArray($row,$col)!="r"} {
			if {[string trim [$Barray($row,$col) cget -text]] == ""} {
				if {$use_images} {
					switch -- [string trim $MineArray($row,$col)] {
						"*" 	{set thisimage "mine_image"}
						""		{set thisimage "empty_image"}
						default	{set thisimage "$MineArray($row,$col)_image"}
					}
					$Barray($row,$col) configure -relief solid -text $MineArray($row,$col) -image  $thisimage \
						-fg "[getForeColor $MineArray($row,$col)]" -activeforeground "[getActiveForeColor $MineArray($row,$col)]"					
				} else {
					$Barray($row,$col) configure -relief solid -text $MineArray($row,$col) \
						-fg "[getForeColor $MineArray($row,$col)]" -activeforeground "[getActiveForeColor $MineArray($row,$col)]"
				}
				switch -- $MineArray($row,$col) {
					"*"	{
							$statuslabel configure -text "loser!"
							set gameover 1
							for {set y 0} {$y < $::cfg(numrows)} {incr y} {
								for {set x 0} {$x < $::cfg(numcols)} {incr x} {
									if {$MineArray($y,$x)=="*"} {
										if {$use_images} {
											$Barray($y,$x) configure -image mine_image -text "*" \
												-width $::cfg(bwidthpix) -height $::cfg(bheightpix) -padx 0 -pady 0
										} else {
											$Barray($y,$x) configure -text "*" -height $::cfg(bheighttext)\
												-width $::cfg(bwidthtext)
										}
									}
									switch -- [$Barray($y,$x) cget -text] {
										" " { $Barray($y,$x) configure -state disabled }
										"m" { if {$MineArray($y,$x)!="*"} {$Barray($y,$x) configure -background red}}
									}
								}
							}
						}
					""	{
							set MineArray($row,$col) "r"
							$Barray($row,$col) configure -text ""
							for {set y [max [expr {$row-1}] 0]} {$y < [min [expr $row+2] $::cfg(numrows)]} {incr y} {
								for {set x [max [expr {$col-1}] 0]} {$x < [min [expr $col+2] $::cfg(numcols)]} {incr x} {
									Reveal $y $x
								}
						}
					}
					
				}
				if {$gameover==0} {
					incr revealedblocks
					if {[expr $totalblocks-$revealedblocks]==$::cfg(nummines)} {
						$statuslabel configure -text "winner!"
						set gameover 1
						for {set y 0} {$y < $::cfg(numrows)} {incr y} {
							for {set x 0} {$x < $::cfg(numcols)} {incr x} {
								$Barray($y,$x) configure -state disabled
							}
						}
#						check if this makes it into the hi scores
						if {[lsearch "0 1 2" $::cfg(gametype)]>-1} {
							setHiScore $::cfg(gametype)
						}
					}
				}
			}
		}
	}
}

proc AlterMineCount {minecount alterby} { #<<<1
	if {$alterby < 0} {
		if {$minecount == 0} { return $minecount }
	}
	return [expr {$minecount + $alterby}]
}

proc Mark {row col} { #<<<1
	global Barray
	global use_images 
	global minelabel
	global BoardInitiated
	if {$BoardInitiated} {
		if {$use_images} {
			switch --	[$Barray($row,$col) cget -text] {
				" "		{	$Barray($row,$col) configure -image flagged_image -text "m" -state disabled\
								-width $::cfg(bwidthpix) -height $::cfg(bheightpix)
							$minelabel conf -text [RowColName [AlterMineCount [ReduceToNum [$minelabel cget -text]] -1] $::cfg(nummines)]
							return 1
						}
				"m"		{	$Barray($row,$col) configure -image uncertain_image -text "?" -state disabled\
								-width $::cfg(bwidthpix) -height $::cfg(bheightpix)
							$minelabel conf -text [RowColName [AlterMineCount [ReduceToNum [$minelabel cget -text]] 1] $::cfg(nummines)]
							return 1
						}
				"?"		{	$Barray($row,$col) configure -image empty_image -state normal -text " "\
								-width $::cfg(bwidthpix) -height $::cfg(bheightpix)
							return 1
						}
			}
		} else {
			switch --	[$Barray($row,$col) cget -text] {
				" " 	{	$Barray($row,$col) configure -text "m" -state disabled
							$minelabel conf -text [RowColName [AlterMineCount [ReduceToNum [$minelabel cget -text]] -1] $::cfg(nummines)]
							return 1
						}
				"m"		{	$Barray($row,$col) configure -text "?"
							$minelabel conf -text [RowColName [AlterMineCount [ReduceToNum [$minelabel cget -text]] 1] $::cfg(nummines)]
							return 1 	}
				"?"		{	$Barray($row,$col) configure -text " " -state normal
							return 1
						}
				default {return 0}
			}
		}
	}
}

proc RevealSurrounding {row col} { #<<<1
	global Barray
	global gameover
	
	if {$gameover==0} {
		set curtext [$Barray($row,$col) cget -text]
		if {[string is integer $curtext]} {
			set rowstart [max [expr {$row-1}] 0]
			set rowend [min [expr $row+2] $::cfg(numrows)]
			set colstart [max [expr {$col-1}] 0]
			set colend [min [expr $col+2] $::cfg(numcols)]
			set markedmines 0
			set unsure 0
			
			for {set y $rowstart} {$y < $rowend} {incr y} {
				for {set x $colstart} {$x < $colend} {incr x} {
					switch -- [$Barray($y,$x) cget -text] {
						"m" 	{incr markedmines}
						"?"		{incr unsure}
					}
				}	
			}
			if {$unsure==0 && $markedmines==$curtext} {
				for {set y $rowstart} {$y < $rowend} {incr y} {
					for {set x $colstart} {$x < $colend} {incr x} {
						Reveal $y $x
					}
				}
			}
		}
	}
}

proc NewGame {} { #<<<1
	global Barray
	global statuslabel
	global MineArray
	global BoardInitiated
	global timerlabel
	global use_images
	global minelabel
	for {set y 0} {$y<$::cfg(numrows)} {incr y} {
		for {set x 0} {$x<$::cfg(numcols)} {incr x} {
			if {$use_images} {
				$Barray($y,$x) configure -state normal -relief raised -text " "	-image empty_image -background [. cget -background]
			} else {
				$Barray($y,$x) configure -state normal -relief raised -text " " -background [. cget -background]
			}
		}
	}
	set BoardInitiated 0
	$statuslabel conf -text "mine! mine! mine!"
	$minelabel conf -text $::cfg(nummines)
	$timerlabel conf -text "000"
}

proc MakeBoard {rows cols} { #<<<1
	global Barray
	global empty_image
	global use_images
	
	for {set i 0} {$i < $rows} {incr i} {
		set rowname [RowColName $i $rows]
		for {set j 0} {$j < $cols} {incr j} {
			set colname [RowColName $j $cols]
			if {$use_images} {
				set Barray($j,$i) [button .boardframe.b$rowname$colname -command "Reveal $j $i" -text " " -padx 2 -pady 0 -borderwidth 1 \
					-image empty_image -width $::cfg(bwidthpix) -height $::cfg(bheightpix) -background [. cget -background]]
			} else {
				set Barray($j,$i) [button .boardframe.b$rowname$colname -command "Reveal $j $i"\
					-text " " -padx 2 -pady 0 -borderwidth 1 -width $::cfg(bwidthtext) -height $::cfg(bheighttext)]
			}
			bind .boardframe.b$rowname$colname <Button-3> "Mark $j $i"
			bind .boardframe.b$rowname$colname <Button-2> "RevealSurrounding $j $i"
			grid .boardframe.b$rowname$colname -row $i -column $j -sticky news
		}
	}
	set ::BoardInitiated 0
}

proc DestroyBoard {{rows 0} {cols 0}} { #<<<1
	if {$rows==0} {set rows $::cfg(numrows)}
	if {$cols==0} {set cols $::cfg(numcols)}
	for {set y 0} {$y < $rows} {incr y} {
		set rowname [RowColName $y $rows]
		for {set x 0} {$x < $cols} {incr x} {
			set colname [RowColName $x $cols]
			destroy .boardframe.b$rowname$colname
		}
	}
}

proc Rand {min max} { #<<<1
	set RET [expr {int(rand()*($max-$min)+$min)}]
#	check bounds
	if {$RET<$min} {
		set RET $min
	} elseif {$RET>$max} {
		set RET $max
	}
	return $RET
}

proc InitBoard {rows cols mines {skiprow -1} {skipcol -1}} { #<<<1
#	create the mines on the board
	global MineArray
	global BoardInitiated
	global revealedblocks
	global gameover
	
	set gameover 0
	set BoardInitiated 1
	set revealedblocks 0
	set gridsize [expr {$cols*$rows}]
	puts "placing mines.."

	catch {unset MineArray}
	set ::totalblocks [expr {$::cfg(numrows)*$::cfg(numcols)}]
	
	for {set m 0} {$m < $mines} {incr m} {
		set randcol [Rand 0 $cols]
		set randrow [Rand 0 $rows]
		if {[info exists MineArray($randrow,$randcol)] || $randcol==$skipcol || $randrow==$skiprow} {
			incr m -1
		} else {
			set MineArray($randrow,$randcol) "*"
		}
	}
#	mark the other squares according to the surrounding minecount
	puts "placing markers..."
	for {set y 0} {$y < $rows} {incr y} {
		for {set x 0} {$x < $cols} {incr x} {
			if {![info exists MineArray($y,$x)]} {
				set lminecount 0
				for {set j [expr {$y-1}]} {$j < [expr {$y+2}]} {incr j} {
					for {set i [expr {$x-1}]} {$i < [expr {$x+2}]} {incr i} {
						if {[info exists MineArray($j,$i)]} {
#						we have a mine: increment the mine count for this square
							if {$MineArray($j,$i)=="*"} {
								incr lminecount
							}
						}
					}
				}
				if {$lminecount==0} {
					set MineArray($y,$x) ""
				} else {
					set MineArray($y,$x) $lminecount
				}
			}
		}
	}
}

proc SetGame {} { #<<<1
	global gametype
	if {[lsearch "0 1 2" $gametype]>-1} {
		SetupGame rows "$::gametypes($gametype,rows)" cols "$::gametypes($gametype,cols)" mines "$::gametypes($gametype,mines)"
	} else {
		if {$gametype==3} {
			set ::custom_rows 10
			set ::custom_cols 10
			set ::custom_mines 10
			getCustomGame
		} else {
			puts "SetGame called with invalid gametype $gametype"
		}
	}
}

proc cancelCustom {} { #<<<1
	set ::custom_mines -1
	set ::gametype $::cfg(gametype)
	destroy .cg
}

proc setCustom {} { #<<<1
	destroy .cg
	if {$::custom_rows>0 && $::custom_cols>0 && $::custom_mines>0} {
		SetupGame rows $::custom_rows cols $::custom_cols mines $::custom_mines
	}
}

proc getCustomGame {} { #<<<1
	toplevel .cg
	label .cg.lblSplurb -text "Custom game settings:"
	label .cg.lblRows	-text "Rows:"
	entry .cg.entRows	-textvariable ::custom_rows 
	label .cg.lblCols	-text "Columns:"
	entry .cg.entCols	-textvariable ::custom_cols 
	label .cg.lblMines	-text "Mines:"
	entry .cg.entMines	-textvariable ::custom_mines
	button .cg.btnCancel -text "Cancel" -command cancelCustom
	button .cg.btnGo	-text "Go" -command setCustom

	grid .cg.lblRows   -row 1 -column 1 -sticky w
	grid .cg.entRows   -row 1 -column 2 -sticky w
	grid .cg.lblCols   -row 2 -column 1 -sticky w
	grid .cg.entCols   -row 2 -column 2 -sticky w
	grid .cg.lblMines  -row 3 -column 1	-sticky w
	grid .cg.entMines  -row 3 -column 2	-sticky w
	grid .cg.btnCancel -row 4 -column 1 -sticky e
	grid .cg.btnGo	   -row 4 -column 2 -sticky w
	bind .cg <Key-Escape> cancelCustom
	wm resizable .cg 0 0
	wm title .cg "Custom game..."
	moveToCenter .cg
}

proc SetupGame {args} { #<<<1
	global minelabel
	set old_numrows 	$::cfg(numrows)
	set old_numcols		$::cfg(numcols)
	puts "old_numrows: $old_numrows \t old_numcols: $old_numcols"
	foreach {index value} $args {
		switch -- $index {
			"rows"  {if {[string is integer $value]} {set ::cfg(numrows) $value}}
			"cols"  {if {[string is integer $value]} {set ::cfg(numcols) $value}}
			"mines" {if {[string is integer $value]} {set ::cfg(nummines) $value}}
			default	{puts "SetupGame switch default called :: index is $index"}
		}
	}
#	figure out if the config sent matches one of the pre-determined games
	set requestedgame "$::cfg(numrows) x $::cfg(numcols) x $::cfg(nummines)"
	set ::cfg(gametype) 4	;# allows the fallback gametype to be custom
	for {set g 0} {$g < 3} {incr g} {
		if {"$::gametypes($g,rows) x $::gametypes($g,cols) x $::gametypes($g,mines)" == $requestedgame} {
			set ::cfg(gametype) $g
			break
		}
	}
	puts "creating new board: $::cfg(numrows) x $::cfg(numcols) with $::cfg(nummines) mines"
	DestroyBoard $old_numrows $old_numcols
	$minelabel conf -text $::cfg(nummines)
	MakeBoard $::cfg(numrows) $::cfg(numcols)
}

# the main code place
#1) get the board size from the input
set lastswitch "" 
set w .
bind $w <Key-Escape> [list closewin]
bind $w <Key-Alt-f>

# commandline switch parsing <<<1
foreach arg $argv {
	if {[string match "-*" $arg]} {
		set state "switch"
	} else {
		set state "val"
	}
	switch -- $state {
		switch 	{
						set swar($arg) ""
						set lastswitch $arg
					}
		val		{	
						if {[string length $lastswitch]>0} {
							set swar($lastswitch) $arg
							set lastswitch ""
						}
					}
	}
}
readCFG

foreach {index value} [array get swar] { 
	switch -- $index {
		-r			-
		--rows		-
		-rows		{ if {![info exists gametype_specified]} {set cfg(numrows) $value} }
		-c			-
		--cols		-
		-cols		{ if {![info exists gametype_specified]} {set cfg(numcols) $value} }
		-m			-
		--mines		-
		-mines		{ set cfg(nummines) $value }
		-g			-
		--gametype	-
		-gametype 	{ 	if {[lsearch "0 1 2 3" $value]>-1} {
							set cfg(gametype) 	$value
							set cfg(numrows) 	$::gametypes($value,rows)
							set cfg(nummines) 	$::gametypes($value,mines)
							set cfg(numcols) 	$::gametypes($value,cols)
							set gametype_specified 1
						} else {
							puts "bad gametype $value : gametype must be one of: 0 1 2 3"
						}
					}
		-t			-
		--theme		-
		-theme 		{ 	if {[string match -nocase $value "none"]} {
							set cfg(request_no_images) 1
							puts "text theme selected"
						} else {
							set cfg(theme) $value
							set cfg(request_no_images) 0
							puts "theme $cfg(theme) selected"
						}
					}
		-h			-
		--help		-
		-help 		{puts "mines: a bad M$ clone\ncommandline options:\n-r|-rows|--rows <number of rows> : set number of rows in grid\
						\n-c|-cols|--cols <number of cols> : set number of columns in grid\n-m|-mines|--mines <number of mines> : set how\
						many mines you want\n-t|-theme|--theme <name> specify theme name (name of valid theme dir in themes dir\
						\n\t'none' selects the text-tengine theme\
						\n-ch|-cfghelp|--cfghelp : give listing of options that can be set in the config file, and their default values\
						\n-h|-help|--help : this output"
				destroy .
				return}
		-ch			-
		-cfghelp	-
		--cfghelp 	{	puts "Config options: "
						foreach {index value} [array get cfg] {
							puts
						}
						puts "\nConfig options are set in mynes.cfg with \nkeyname keyvalue\npairs."
					}
		default 	{	set thisindex [join [lreplace [split $index {}] 0 0] ""]
						if {[info exists cfg($thisindex)]} {
							set cfg($thisindex) $value
						} else {
							puts "unrecognised switch \{$index\} passed on the commandline"
						}
					}
	}
}

if {![info exists gametype_specified]} {
#	check if the rows / cols /mines that we have conform to a standard gametype
	set cfg(gametype) 3
	for {set i 0} {$i<3} {incr i} {
		if {$cfg(numrows)==$gametypes($i,rows) && $cfg(numcols)==$gametypes($i,cols) && $cfg(nummines)==$gametypes($i,mines)} {
			set cfg(gametype) $i
			break
		}
	}
}
# if the number of mines hasn't been set, then set to the root of the number of squares
if {![info exists cfg(nummines)]} {
	set cfg(nummines) [expr {int($cfg(numrows)*$cfg(numcols)/10)}]
}
puts "Making board $cfg(numrows) x $cfg(numcols)"

# main form generation <<<1
frame .head -width 7
set statuslabel [label .head.status -text "mine! mine! mine!"]
set menu [menu .menu]
. conf -menu $menu
frame .boardframe
set m [menu $menu.m -tearoff 1]
$menu add cascade -label "File" -menu $m
$m add command -label "New Game" -command NewGame
$m add command -label "View Highscores" -command displayHiscores
$m add check -label "Retain settings" -variable cfg(savecfg) -command ToggleSaveCFG
$m add separator
$m add cascade -label "Game level" -menu $m.gametype
set gametypemenu [menu $m.gametype -tearoff 0 ]
set gametype $cfg(gametype)
$gametypemenu add radio -label $hiname(0) -variable gametype -value "0" -command SetGame
$gametypemenu add radio -label $hiname(1) -variable gametype -value "1" -command SetGame
$gametypemenu add radio -label $hiname(2) -variable gametype -value "2" -command SetGame
$gametypemenu add radio -label "Roll your own..." 	-variable gametype -value "3" -command SetGame
$m add separator
$m add command -label "Exit" -command closewin
set timerframe 		[frame .head.timerframe -relief groove -borderwidth 2]
set timerlabellabel [label $timerframe.timerlabel -text "Time: "]
set timerlabel 		[label $timerframe.timer -text "000" -width 5]
set mineframe 		[frame .head.mineframe -relief groove -borderwidth 2]
set minelabellabel 	[label $mineframe.minelabel -text "Mines left: "]
set minelabel		[label $mineframe.mines	-text [RowColName $cfg(nummines) $cfg(nummines)]]
set defaultforecolor [$m cget -fg]
pack $statuslabel -side top
pack $timerlabellabel -side left
pack $timerlabel -side right
pack $timerframe -side right
pack $minelabellabel -side left
pack $minelabel -side right
pack $mineframe -side left
pack .head -anchor center 
pack .boardframe -side top
wm resizable . 0 0
wm title . "Mynes"
wm protocol . WM_DELETE_WINDOW "closewin"
eval [go_home]

if {!$cfg(request_no_images)} {
	set imagecount 0
	puts "using theme: $cfg(theme)"
	set imagecount [expr {$imagecount+[loadImage $cfg(theme) "flagged"]}]
	set imagecount [expr {$imagecount+[loadImage $cfg(theme) "mine"]}]
	set imagecount [expr {$imagecount+[loadImage $cfg(theme) "uncertain"]}]
	set imagecount [expr {$imagecount+[loadImage $cfg(theme) "empty"]}]
	set imagecount [expr {$imagecount+[loadImage $cfg(theme) "1"]}]
	set imagecount [expr {$imagecount+[loadImage $cfg(theme) "2"]}]
	set imagecount [expr {$imagecount+[loadImage $cfg(theme) "3"]}]
	set imagecount [expr {$imagecount+[loadImage $cfg(theme) "4"]}]
	set imagecount [expr {$imagecount+[loadImage $cfg(theme) "5"]}]
	set imagecount [expr {$imagecount+[loadImage $cfg(theme) "6"]}]
	set imagecount [expr {$imagecount+[loadImage $cfg(theme) "7"]}]

	if {$imagecount==11} {
		set use_images true
	} else {
		set use_images false
		puts "loading of theme $theme_name failed: at least one required image is missing."
	}
} else { 
	set use_images false 
	puts "using classic text theme"
}

#set tcl_traceExec 2
# >>>
readHiscores
displayHiscores 1
genConfirm
MakeBoard $cfg(numrows) $cfg(numcols)
moveToCenter .
