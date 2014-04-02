alias dc.connectAutoconnect.createPanel {
set %config.dialog dcConf
  dc.connectAutoconnect.createPanelContent
  dc.connectAutoconnect.fillPanelControls

}

alias dc.connectAutoconnect.destroyPanel {
  unset %connect.ac.*
  ;return 1 
}

alias dc.connectAutoconnect.events { 
  if ($2 == sclick) {
    if ($3 == 3) { dc.connectAutoconnect.fillServerDropdown }
    if ($3 == 75 && $4 == 1) { dc.connectAutoconnect.move up }
    if ($3 == 76 && $4 == 1) { dc.connectAutoconnect.move down }
    if ($3 == 80) { dc.connectAutoconnect.save }
    if ($3 == 81) { dc.connectAutoconnect.add.server }
    if ($3 == 82) { dc.connectAutoconnect.add.bouncer }
    if ($3 == 83) { dc.connectAutoconnect.delEntry }
  }
  elseif ($2 == selected) {
    if ($3 == 2) { dc.connectAutoConnect.list.sclick }
  }
}

alias -l dc.connectAutoconnect.createPanelContent {
  xdid -c %config.dialog %config.basePanelID 1 panel $config.panelCenter(435,540)

  xdid -c %config.dialog 1 100 text 0 0 200 25
  xdid -t %config.dialog 100 Server Verwaltung
  xdid -f %config.dialog 100 + default 14 Arial

  xdid -c %config.dialog 1 101 text 5 25 150 20
  xdid -t %config.dialog 101 AutoConnect Liste
  xdid -f %config.dialog 101 + default 10 Verdana

  xdid -c %config.dialog 1 2 listview 5 50 390 300 report checkbox fullrow grid singlesel noheadersort showsel
  xdid -t %config.dialog 2 +l 0 20 $chr(9) +l 0 30 Nr. $chr(9) +l 0 60 Typ $chr(9) +l 0 135 Netzwerk $chr(9) +l 0 140 Server

  xdid -c %config.dialog 1 75 toolbar 400 175 30 30 flat list nodivider noauto tooltips
  xdid -c %config.dialog 1 76 toolbar 400 210 30 30 flat list nodivider noauto tooltips

  xdid -l %config.dialog 75 24
  xdid -l %config.dialog 76 24
  xdid -w %config.dialog 75 +nh 0 images/ico/arrow_up.ico
  xdid -w %config.dialog 76 +nh 0 images/ico/arrow_down.ico

  xdid -w %config.dialog 75 +dhg 0 images/ico/arrow_up.ico
  xdid -w %config.dialog 76 +dhg 0 images/ico/arrow_down.ico

  xdid -a %config.dialog 75 1 +ld 30 1 $chr(9) Auf
  xdid -a %config.dialog 76 1 +ld 30 1 $chr(9) Ab

  xdid -c %config.dialog 1 80 button 295 355 100 20
  xdid -t %config.dialog 80 Speichern

  xdid -c %config.dialog 1 83 button 5 355 100 20 disabled
  xdid -t %config.dialog 83 Löschen

  xdid -c %config.dialog 1 102 text 5 380 200 20
  xdid -t %config.dialog 102 Server hinzufügen
  xdid -f %config.dialog 102 + default 10 Verdana

  xdid -c %config.dialog 1 3 comboex 25 400 125 300 dropdown disabled
  xdid -c %config.dialog 1 4 comboex 155 400 125 300 dropdown disabled
  xdid -c %config.dialog 1 81 button 295 400 100 20 disabled
  xdid -t %config.dialog 81 Hinzufügen

  xdid -c %config.dialog 1 103 text 5 430 200 20
  xdid -t %config.dialog 103 Bouncer hinzufügen
  xdid -f %config.dialog 103 + default 10 Verdana

  xdid -c %config.dialog 1 5 comboex 155 450 125 300 dropdown disabled
  xdid -c %config.dialog 1 82 button 295 450 100 20 disabled
  xdid -t %config.dialog 82 Hinzufügen
}

alias -l dc.connectAutoconnect.fillNetworkDropdown {
  var %list $networkList
  .noop $networkList(%list).prepareWhile
  while ($networkList(%list).next) {
    xdid -a %config.dialog 3 0 0 0 0 0 $networkList(%list).getValue
  }
  .noop $networkList(%list).destroy
  if ($xdid(%config.dialog,3).num > 0) {
    xdid -e %config.dialog 3
    xdid -c %config.dialog 3 1
    dc.connectAutoconnect.fillServerDropdown 
  }
}

alias -l dc.connectAutoconnect.fillServerDropdown {
  xdid -r %config.dialog 4
  xdid -b %config.dialog 4
  xdid -b %config.dialog 81
  var %list $serverList($xdid(%config.dialog,3).seltext)
  .noop $serverList(%list).prepareWhile
  while ($serverList(%list).next) {
    var %server $ServerData($serverList(%list).getValue)
    xdid -a %config.dialog 4 0 0 0 0 0 $serverData(%server,desc).get
    .noop $serverData(%server).destroy
  }
  .noop $serverList(%list).destroy
  if ($xdid(%config.dialog,4).num > 0) {
    xdid -e %config.dialog 4

    var %check $xdid(%config.dialog,2,$chr(9) $xdid(%config.dialog,3).seltext $chr(9),W,4,1).find
    if (%check != $null) {
      var %check2 $xdid(%config.dialog,4,$chr(9) $xdid(%config.dialog,2,$gettok(%check,1,32),5).text $chr(9),W,1).find
      xdid -c %config.dialog 4 %check2
      xdid -t %config.dialog 81 Ändern
      set %connect.ac.mode edit
    }
    else {
      xdid -c %config.dialog 4 1
      xdid -t %config.dialog 81 Hinzufügen
      set %connect.ac.mode add
    }
    xdid -e %config.dialog 81 
  }
}

alias -l dc.connectAutoConnect.fillBouncerDropdown {
  var %db $dbs(modul_connect)
  var %list $dbsList(%db,bnc)
  .noop $dbsList(%list).prepareWhile
  while ($dbsList(%list).next) {
    xdid -a %config.dialog 5 0 0 0 0 0 $dbsList(%list).getItem
  }
  .noop $dbsList(%list).destroy
  .noop $dbs(%db).destroy
  if ($xdid(%config.dialog,5).num > 0) {
    xdid -e %config.dialog 5
    xdid -c %config.dialog 5 1
    xdid -e %config.dialog 82
  }
}

alias -l dc.connectautoConnect.fillAutoconnectList {
  ;xdid -t %config.dialog 75 1 +d
  ;xdid -t %config.dialog 75 2 +dw
  var %db $dbs(modul_connect)
  var %list $dbsList(%db,user,autoconnect)
  .noop $dbsList(%list).prepareWhile
  while ($dbsList(%list).next) {
    var %nr $dbsList(%list).getPos
    var %active $calc($gettok($dbsList(%list).getValue,1,44) +1)
    if ($gettok($dbsList(%list).getItem,1,95) == SERVER) {
      var %type Server
      var %network $gettok($dbsList(%list).getItem,2,95)
      var %server $serverData($gettok($dbsList(%list).getValue,2,44))
      var %serverdesc $serverData(%server,desc).get
      .noop $serverData(%server).destroy
    }
    else {
      var %type Bouncer
      var %network $null
      var %serverdesc $gettok($dbsList(%list).getItem,2,95)
    }

    xdid -a %config.dialog 2 0 0 + 0 %active 0 0 $rgb(0,0,0) $rgb(0,0,0) $chr(9) + 0 0 $rgb(0,0,0) $rgb(0,0,0) %nr $chr(9) $&
      + 0 0 $rgb(0,0,0) $rgb(0,0,0) %type $chr(9) + 0 0 $rgb(0,0,0) $rgb(0,0,0) %network $chr(9) + 0 0 $rgb(0,0,0) $rgb(0,0,0) %serverdesc

  }
  .noop $dbsList(%list).destroy

}

alias -l dc.connectAutoconnect.fillPanelControls {
  dc.connectAutoconnect.fillNetworkDropdown
  dc.connectAutoConnect.fillBouncerDropdown
  dc.connectautoConnect.fillAutoconnectList
}

alias -l dc.connectAutoconnect.list.sclick {
  if ($xdid(%config.dialog,2,1).sel == 1 && $xdid(%config.dialog,2).num == 1) {
    xdid -t %config.dialog 75 1 +d
    xdid -t %config.dialog 76 1 +d
  }
  elseif ($xdid(%config.dialog,2,1).sel == 1) {
    xdid -t %config.dialog 75 1 +d
    xdid -t %config.dialog 76 1 +
  }
  elseif ($xdid(%config.dialog,2,1).sel == $xdid(%config.dialog,2).num) {
    xdid -t %config.dialog 75 1 +
    xdid -t %config.dialog 76 1 +d
  }
  else {
    xdid -t %config.dialog 75 1 +
    xdid -t %config.dialog 76 1 +
  }

  if ($xdid(%config.dialog,2,3).seltext == Server) {
    var %num $xdid(%config.dialog,3,$chr(9) $xdid(%config.dialog,2,4).seltext $chr(9),W,1).find
    xdid -c %config.dialog 3 %num
    dc.connectAutoconnect.fillServerDropdown
    var %num $xdid(%config.dialog,4,$chr(9) $xdid(%config.dialog,2,5).seltext $chr(9),W,1).find
    xdid -c %config.dialog 4 %num
    xdid -t %config.dialog 81 Ändern
    set %connect.ac.mode edit
  }
  else {
    var %num $xdid(%config.dialog,5,$chr(9) $xdid(%config.dialog,2,5).seltext $chr(9),W,1).find
    xdid -c %config.dialog 5 %num
  }
  xdid -e %config.dialog 83
}

alias -l dc.connectAutoconnect.add.server {
  if (%connect.ac.mode == add) {
    var %num $calc($xdid(%config.dialog,2).num + 1)
    xdid -a %config.dialog 2 0 0 + 0 2 0 0 $rgb(0,0,0) $rgb(0,0,0) $chr(9) + 0 0 $rgb(0,0,0) $rgb(0,0,0) %num $chr(9) $&
      + 0 0 $rgb(0,0,0) $rgb(0,0,0) Server $chr(9) + 0 0 $rgb(0,0,0) $rgb(0,0,0) $xdid(%config.dialog,3).seltext $chr(9) + 0 0 $rgb(0,0,0) $rgb(0,0,0) $xdid(%config.dialog,4).seltext
    xdid -c %config.dialog 2 %num
    xdid -t %config.dialog 81 Ändern
    set %connect.ac.mode edit
  }
  else {
    var %num $xdid(%config.dialog,2,$chr(9) $xdid(%config.dialog,3).seltext $chr(9),W,4,1).find
    xdid -v %config.dialog 2 $gettok(%num,1,32) 5 $xdid(%config.dialog,4).seltext
  }
}

alias -l dc.connectAutoconnect.add.bouncer {
  var %num $xdid(%config.dialog,2,$chr(9) $xdid(%config.dialog,5).seltext $chr(9),W,5,1).find
  var %error 0
  var %i 1
  while (%i <= $numtok(%num,32)) {
    if ($xdid(%config.dialog,2,$gettok(%num,%i,32),3).text == Bouncer) {
      .noop $dcx(MsgBox,ok error modal owner $dialog(%config.dialog).hwnd $chr(9) Fehler $chr(9) Bouncer bereits in Liste)
      var %error 1
      break
    }
    inc %i
  }
  if (%error == 0) {
    var %num $calc($xdid(%config.dialog,2).num + 1)
    xdid -a %config.dialog 2 0 0 + 0 2 0 0 $rgb(0,0,0) $rgb(0,0,0) $chr(9) + 0 0 $rgb(0,0,0) $rgb(0,0,0) %num $chr(9) $&
      + 0 0 $rgb(0,0,0) $rgb(0,0,0) Bouncer $chr(9) + 0 0 $rgb(0,0,0) $rgb(0,0,0) $chr(9) + 0 0 $rgb(0,0,0) $rgb(0,0,0) $xdid(%config.dialog,5).seltext
    xdid -c %config.dialog 2 %num
  }
}

alias -l dc.connectAutoconnect.delEntry {
  var %sel $xdid(%config.dialog,2).sel
  if ($xdid(%config.dialog,2,%sel,3).text == Server) {
    set %connect.ac.mode add
    xdid -t %config.dialog 81 Hinzufügen
  }
  xdid -d %config.dialog 2 %sel
  var %i %sel
  if ($xdid(%config.dialog,2).num >= %i) {
    while (%i <= $xdid(%config.dialog,2).num) {
      xdid -v %config.dialog 2 %i 2 %i
      inc %i
    }
    xdid -c %config.dialog 2 %sel
  }
  else {
    xdid -c %config.dialog 2 $xdid(%config.dialog,2).num
  }
}

alias -l dc.connectAutoconnect.save {
  var %db $dbs(modul_connect)
  .noop $dbs(%db,autoconnect).setSection
  .noop $dbs(%db).deleteUserSection
  var %i 1
  while (%i <= $xdid(%config.dialog,2).num) {
    if ($xdid(%config.dialog,2,%i,3).text == Server) {
      var %item SERVER_ $+ $xdid(%config.dialog,2,%i,4).text
      var %list $serverList($xdid(%config.dialog,2,%i,4).text)
      .noop $serverList(%list).prepareWhile
      while ($serverList(%list).next) {
        var %server $serverData($serverList(%list).getValue)
        if ($serverData(%server,desc).get == $xdid(%config.dialog,2,%i,5).text) {
          var %value $calc($xdid(%config.dialog,2,%i).state - 1) $+ $chr(44) $+ $serverList(%list).getValue
          .noop $serverData(%server).destroy
          break
        }
        .noop $serverData(%server).destroy
      }
      .noop $serverList(%list).destroy     
    }
    else {
      var %item BOUNCER_ $+ $xdid(%config.dialog,2,%i,5).text
      var %value $calc($xdid(%config.dialog,2,%i).state - 1)
    }
    .noop $dbs(%db,%item,%value).setUserValue
    inc %i
  }
  .noop $dcx(MsgBox,ok exclamation modal owner $dialog(%config.dialog).hwnd $chr(9) OK $chr(9) Daten gespeichert)
  .noop $dbs(%db).destroy
}

alias -l dc.connectAutoconnect.move {
  var %sel.active $xdid(%config.dialog,2).sel
  var %active $xdid(%config.dialog,2,%sel.active).state
  var %type $xdid(%config.dialog,2,%sel.active,3).text
  var %net $xdid(%config.dialog,2,%sel.active,4).text
  var %server $xdid(%config.dialog,2,%sel.active,5).text  

  if ($1 == down) {
    var %sel.move $calc(%sel.active + 1)
    xdid -a %config.dialog 2 $calc(%sel.move + 1) 0 + 0 %active 0 0 $rgb(0,0,0) $rgb(0,0,0) $chr(9) + 0 0 $rgb(0,0,0) $rgb(0,0,0) %sel.move $chr(9) $&
      + 0 0 $rgb(0,0,0) $rgb(0,0,0) %type $chr(9) + 0 0 $rgb(0,0,0) $rgb(0,0,0) %net $chr(9) + 0 0 $rgb(0,0,0) $rgb(0,0,0) %server
    xdid -d %config.dialog 2 %sel.active
    xdid -v %config.dialog 2 %sel.active 2 %sel.active
  }
  elseif ($1 == up) {
    var %sel.move $calc(%sel.active - 1)
    xdid -a %config.dialog 2 %sel.move 0 + 0 %active 0 0 $rgb(0,0,0) $rgb(0,0,0) $chr(9) + 0 0 $rgb(0,0,0) $rgb(0,0,0) %sel.move $chr(9) $&
      + 0 0 $rgb(0,0,0) $rgb(0,0,0) %type $chr(9) + 0 0 $rgb(0,0,0) $rgb(0,0,0) %net $chr(9) + 0 0 $rgb(0,0,0) $rgb(0,0,0) %server
    xdid -d %config.dialog 2 $calc(%sel.active + 1)
    xdid -v %config.dialog 2 %sel.active 2 %sel.active
  }
  xdid -c %config.dialog 2 %sel.move

  if ($xdid(%config.dialog,2,1).sel == 1) {
    xdid -t %config.dialog 75 1 +d
    xdid -t %config.dialog 76 1 +
  }
  elseif ($xdid(%config.dialog,2,1).sel == $xdid(%config.dialog,2).num) {
    xdid -t %config.dialog 75 1 +
    xdid -t %config.dialog 76 1 +d
  }
}

alias dc.connectAutoconnect.onStart {
  var %db $dbs(modul_connect)
  var %list $dbsList(%db,user,autoconnect)
  .noop $dbsList(%list).prepareWhile
  var %first 1
  while ($dbsList(%list).next) {
    if ($gettok($dbsList(%list).getValue,1,44) == 1) {
      if ($gettok($dbsList(%list).getItem,1,95) == SERVER) {
        if (%first == 1) {
          server $gettok($dbsList(%list).getValue,2,44)
          unset %first
        }
        else {
          server -m $gettok($dbsList(%list).getValue,2,44)
        }
      }
      elseif ($gettok($dbsList(%list).getItem,1,95) == BOUNCER) {
        if (%first == 1) {
           dc.connectBouncer.connect $gettok($dbsList(%list).getItem,2,95)
          unset %first
        }
        else {
          dc.connectBouncer.connect $gettok($dbsList(%list).getItem,2,95) 1
        }
      }
    }
  }
  .noop $dbsList(%list).destroy
  .noop $dbs(%db).destroy
}