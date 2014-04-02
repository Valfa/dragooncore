alias dc.connectServerlist.createPanel { 
set %config.dialog dcConf
halt
  dc.connectServerlist.createPanelContent
  dc.connectServerlist.fillTreeview

  if ($xdid(%config.dialog,2,root).num > 0) {
    xdid -c %config.dialog 2 1
    dc.connectServerList.createNetworkControls 
  }
}

alias dc.connectServerlist.destroyPanel {
  unset %connect.sl.*
  ;return 1 
}

alias dc.connectServerlist.events { 
  if ($2 == dclick) {
    if ($numtok($xdid(%config.dialog,2).selpath,32) == 1) {
      dc.connectServerList.loadServers 1
    }
  }
  elseif ($2 == selchange) {
    if ($3 == 2 && $xdid(%config.dialog,2,root).num > 0 ) {
      dc.connectServerList.changeToolbar2 
      if ($numtok($xdid(%config.dialog,2).selpath,32) == 1) {
        dc.connectServerList.createNetworkControls
        dc.connectServerList.fillNetworkControls  
      }
      else {
        dc.connectServerList.createServerControls
        dc.connectServerList.fillServerData 
      }
    }
  }
  elseif ($2 == sclick) {
    if ($3 == 75) {
      if ($4 == 1) { dc.connectServerList.connect }
      if ($4 == 3) { dc.connectServerList.addNetwork }
      if ($4 == 4) { dc.connectServerList.delNetwork }
    }
    if ($3 == 76) {
      if ($4 == 1) { dc.connectServerList.saveNetworkData }
      if ($4 == 2) { dc.connectServerList.saveServer }
      if ($4 == 3) { dc.connectServerList.newServer }
      if ($4 == 5) { dc.connectServerList.editServer }
      if ($4 == 6) { dc.connectServerList.delServer }
    }
  }
}

alias -l dc.connectServerList.loadServers {
  if ($xdid(%config.dialog,2,$xdid(%config.dialog,2).selpath).num == 0) {
    var %serverList $serverList($xdid(%config.dialog,2).seltext)
    .noop $serverList(%serverList).prepareWhile
    while ($serverList(%serverList).next) {
      var %serverData $serverData($serverList(%serverList).getValue)
      xdid -a %config.dialog 2 $+($xdid(%config.dialog,2).selpath $serverList(%serverList).getPos,$chr(9),+ 0 0 0 0 0 $rgb(0,0,255) $rgb(255,0,255) $serverData(%serverData,desc).get,$chr(9),$serverList(%serverList).getValue)
      .noop $serverData(%serverData).destroy
    }
    .noop $serverList(%serverList).destroy
    if ($1 == 1) {
      .timer 1 1 xdid -t %config.dialog 2 +e $xdid(%config.dialog,2).selpath
    }
  }
}

alias -l dc.connectServerlist.createPanelContent {
  xdid -c %config.dialog %config.basePanelID 1 panel $config.panelCenter(435,540)

  xdid -c %config.dialog 1 100 text 0 0 200 25
  xdid -t %config.dialog 100 Server Verwaltung
  xdid -f %config.dialog 100 + default 14 Arial
  ;xdid -x %config.dialog 100 +b

  xdid -c %config.dialog 1 101 text 5 25 100 20
  xdid -t %config.dialog 101 Serverliste
  xdid -f %config.dialog 101 + default 10 Verdana
  ;xdid -x %config.dialog 101 +b

  xdid -c %config.dialog 1 102 text 200 25 235 20
  xdid -t %config.dialog 102 Einstellungen für
  xdid -f %config.dialog 102 + default 10 Verdana

  xdid -c %config.dialog 1 75 toolbar 5 50 190 30 flat list nodivider noauto tooltips
  ;xdid -x %config.dialog 75 +b
  xdid -l %config.dialog 75 24
  xdid -w %config.dialog 75 +nh 0 images/ico/connect_sl_connect.ico
  xdid -w %config.dialog 75 +nh 0 images/ico/connect_sl_disconnect.ico
  xdid -w %config.dialog 75 +nh 0 images/ico/connect_sl_server_add.ico
  xdid -w %config.dialog 75 +nh 0 images/ico/connect_sl_server_delete.ico

  xdid -w %config.dialog 75 +dhg 0 images/ico/connect_sl_connect.ico
  xdid -w %config.dialog 75 +dhg 0 images/ico/connect_sl_disconnect.ico
  xdid -w %config.dialog 75 +dhg 0 images/ico/connect_sl_server_add.ico
  xdid -w %config.dialog 75 +dhg 0 images/ico/connect_sl_server_delete.ico


  xdid -a %config.dialog 75 1 +l 30 1 $chr(9) Verbindung herstellen
  xdid -a %config.dialog 75 2 +ad 0 0 -
  xdid -a %config.dialog 75 3 +l 30 3 $chr(9) Leeres Netzwerk hinzufügen (temporär)
  xdid -a %config.dialog 75 4 +l 30 4 $chr(9) Netzwerk löschen

  xdid -c %config.dialog 1 76 toolbar 205 50 235 30 flat list nodivider noauto tooltips
  xdid -l %config.dialog 76 24
  xdid -w %config.dialog 76 +nh 0 images/ico/disk.ico
  xdid -w %config.dialog 76 +nh 0 images/ico/page_white_add.ico
  xdid -w %config.dialog 76 +nh 0 images/ico/page_white_find.ico
  xdid -w %config.dialog 76 +nh 0 images/ico/page_white_edit.ico
  xdid -w %config.dialog 76 +nh 0 images/ico/page_white_delete.ico

  xdid -w %config.dialog 76 +dhg 0 images/ico/disk.ico
  xdid -w %config.dialog 76 +dhg 0 images/ico/page_white_add.ico
  xdid -w %config.dialog 76 +dhg 0 images/ico/page_white_find.ico
  xdid -w %config.dialog 76 +dhg 0 images/ico/page_white_edit.ico
  xdid -w %config.dialog 76 +dhg 0 images/ico/page_white_delete.ico

  xdid -a %config.dialog 76 1 +l 30 1 $chr(9) Netzwerkdaten Speichern
  xdid -a %config.dialog 76 2 +ldh 30 1 $chr(9) Serverdaten Speichern
  xdid -a %config.dialog 76 3 +l 30 2 $chr(9) Server hinzufügen
  xdid -a %config.dialog 76 4 +ld 30 3 $chr(9) Serverdaten ermitteln
  xdid -a %config.dialog 76 5 +ld 30 4 $chr(9) Serverdaten bearbeiten
  xdid -a %config.dialog 76 6 +ld 30 5 $chr(9) Server löschen



  xdid -c %config.dialog 1 2 treeview 5 85 190 455 haslines nohscroll showsel
  xdid -l %config.dialog 2 24
  xdid -w %config.dialog 2 +n 0 images/ico/folder.ico
  xdid -w %config.dialog 2 +n 0 images/ico/folder_error.ico
  xdid -w %config.dialog 2 +n 0 images/ico/folder_star.ico

  xdid -c %config.dialog 1 3 panel 200 85 235 455

}

alias -l dc.connectServerList.changeToolbar2 {
  if ($numtok($xdid(%config.dialog,2).selpath,32) == 1) {
    xdid -t %config.dialog 76 1 +
    xdid -t %config.dialog 76 2 +dh
    xdid -t %config.dialog 76 4 +d
    xdid -t %config.dialog 76 5 +d
    xdid -t %config.dialog 76 6 +d
  }
  else {
    xdid -t %config.dialog 76 1 +h
    xdid -t %config.dialog 76 2 +d
    xdid -t %config.dialog 76 4 +d
    xdid -t %config.dialog 76 5 +
    xdid -t %config.dialog 76 6 +
  }
}

alias -l dc.connectServerList.createServerControls {
  xdid -d %config.dialog 1 3
  xdid -c %config.dialog 1 3 panel 200 85 235 455

  xdid -t %config.dialog 102 Einstellungen für $+ $chr(32) $+ $xdid(%config.dialog,2,$gettok($xdid(%config.dialog,2).selpath,1,32)).text

  xdid -c %config.dialog 3 103 text 5 5 200 20
  xdid -t %config.dialog 103 Serverdaten
  xdid -f %config.dialog 103 + default 10 Verdana

  xdid -c %config.dialog 3 104 text 5 25 100 20
  xdid -t %config.dialog 104 Beschreibung
  xdid -c %config.dialog 3 4 edit 5 45 225 20 autohs tabstop disabled

  xdid -c %config.dialog 3 105 text 5 75 100 20
  xdid -t %config.dialog 105 Server Addresse
  xdid -c %config.dialog 3 5 edit 5 95 225 20 autohs tabstop disabled

  xdid -c %config.dialog 3 106 text 5 125 100 20
  xdid -t %config.dialog 106 Ports
  xdid -c %config.dialog 3 6 edit 5 145 225 20 autohs tabstop disabled

  xdid -c %config.dialog 3 107 text 5 175 100 20
  xdid -t %config.dialog 107 SSL-Ports
  xdid -c %config.dialog 3 7 edit 5 195 225 20 autohs tabstop disabled

  xdid -c %config.dialog 3 108 text 5 225 100 20
  xdid -t %config.dialog 108 Passwort
  xdid -c %config.dialog 3 8 edit 5 245 225 20 autohs tabstop password disabled

  ;xdid -c %config.dialog 3 81 button 62 300 100 20 disabled
  ;xdid -t %config.dialog 81 Speichern
}

alias -l dc.connectServerList.createNetworkControls {
  xdid -d %config.dialog 1 3
  xdid -c %config.dialog 1 3 panel 200 85 235 455

  xdid -t %config.dialog 102 Einstellungen für $+ $chr(32) $+ $xdid(%config.dialog,2).seltext

  xdid -c %config.dialog 3 120 text 5 5 200 20
  xdid -t %config.dialog 120 Netzwerk Ident
  xdid -f %config.dialog 120 + default 10 Verdana

  xdid -c %config.dialog 3 121 text 5 25 100 20
  xdid -t %config.dialog 121 Nick
  xdid -c %config.dialog 3 10 edit 5 45 225 20 autohs tabstop tabstop

  xdid -c %config.dialog 3 122 text 5 75 100 20
  xdid -t %config.dialog 122 Alternativer Nick
  xdid -c %config.dialog 3 11 edit 5 95 225 20 autohs tabstop tabstop

  xdid -c %config.dialog 3 123 text 5 125 100 20
  xdid -t %config.dialog 123 Name
  xdid -c %config.dialog 3 12 edit 5 145 225 20 autohs tabstop tabstop

  xdid -c %config.dialog 3 124 text 5 175 100 20
  xdid -t %config.dialog 124 E-Mail
  xdid -c %config.dialog 3 13 edit 5 195 225 20 autohs tabstop tabstop

  xdid -c %config.dialog 3 14 check 5 225 225 20 tabstop
  xdid -t %config.dialog 14 als Standard

  xdid -c %config.dialog 3 125 text 5 255 200 20
  xdid -t %config.dialog 125 Netzwerk Perform
  xdid -f %config.dialog 125 + default 10 Verdana

  xdid -c %config.dialog 3 15 edit 5 275 225 150 autovs return multi tabstop

  ;xdid -c %config.dialog 3 80 button 62 435 100 20 tabstop
  ;xdid -t %config.dialog 80 Speichern


}

alias -l dc.connectServerList.fillNetworkControls {
  var %ident $connect.getIdent()
  xdid -E %config.dialog 10 $gettok(%ident,1,32)
  xdid -E %config.dialog 11 $gettok(%ident,2,32)
  xdid -E %config.dialog 12 $gettok(%ident,3,32)
  xdid -E %config.dialog 13 $gettok(%ident,4-,32)

  var %ident $connect.getIdent($xdid(%config.dialog,2).seltext)
  xdid -ra %config.dialog 10 $gettok(%ident,1,32)
  xdid -ra %config.dialog 11 $gettok(%ident,2,32)
  xdid -ra %config.dialog 12 $gettok(%ident,3,32)
  xdid -ra %config.dialog 13 $gettok(%ident,4-,32)

  var %db $dbs(modul_connect,$xdid(%config.dialog,2).seltext)
  var %dbslist $dbsList(%db,user,perform)
  if (%dbslist) {
    .noop $dbsList(%dbslist).prepareWhile
    while ($dbsList(%dbslist).next) {
      xdid -i %config.dialog 15 $dbsList(%dbslist).getPos $dbsList(%dbslist).getValue
    }
    .noop $dbsList(%dbslist).destroy
  }
  .noop $dbs(%db).destroy
}

alias -l dc.connectServerlist.fillTreeview {
  var %networkList $networkList
  .noop $networkList(%networkList).prepareWhile
  while ($networkList(%networkList).next) {
    xdid -a %config.dialog 2 $+($networkList(%networkList).getPos,$chr(9),+ 1 1 0 0 0 $rgb(0,0,255) $rgb(255,0,255) $networkList(%networkList).getValue,$chr(9),$networkList(%networkList).getValue)

  }
  .noop $networkList(%networkList).destroy
}

alias -l dc.connectServerList.fillServerData {
  set %connect.sl.serverhash $serverData($xdid(%config.dialog,2,$xdid(%config.dialog,2).selpath).tooltip)
  xdid -ra %config.dialog 4 $serverData(%connect.sl.serverhash,desc).get
  xdid -ra %config.dialog 5 $serverData(%connect.sl.serverhash,address).get
  xdid -ra %config.dialog 6 $serverData(%connect.sl.serverhash,ports).get
  xdid -ra %config.dialog 7 $serverData(%connect.sl.serverhash,ssl-ports).get
  xdid -ra %config.dialog 8 $serverData(%connect.sl.serverhash,pass).get
  .noop $serverData(%connect.sl.serverhash).destroy
  unset %connect.sl.serverhash
}

alias -l dc.connect.ServerList.clearServerData {
  xdid -r %config.dialog 4
  xdid -r %config.dialog 5
  xdid -r %config.dialog 6
  xdid -r %config.dialog 7
  xdid -r %config.dialog 8
}

alias -l dc.connectServerList.checkNetworkData {
  var %error 0
  var %errortext $null
  if ($xdid(%config.dialog,10).text != $null && $regex(regex,$xdid(%config.dialog,10).text,[[:space:]]) == 1) {
    var %errortext * Nick darf keine Leerzeichen enthalten
    inc %error
  }
  if ($xdid(%config.dialog,11).text != $null && $regex(regex,$xdid(%config.dialog,11).text,[[:space:]]) == 1) {
    if (%error > 0) { var %errortext %errortext $+ $lf $+ * Alternativer Nick darf keine Leerzeichen enthalten }
    else { var %errortext * Alternativer Nick darf keine Leerzeichen enthalten }
    inc %error
  }
  if (($xdid(%config.dialog,10).text != $null && $xdid(%config.dialog,10).text == $xdid(%config.dialog,11).cue) || $&
    ($xdid(%config.dialog,11).text != $null && $xdid(%config.dialog,11).text == $xdid(%config.dialog,10).cue) || $&
    (($xdid(%config.dialog,10).text != $null && $xdid(%config.dialog,11).text != $null) && ($xdid(%config.dialog,10).text == $xdid(%config.dialog,11).text))) {
    if (%error > 0) { var %errortext %errortext $+ $lf $+ * Nick und Alternativer Nick duerfen nicht gleich sein }
    else { var %errortext * Nick und Alternativer Nick duerfen nicht gleich sein }
    inc %error
  }
  if ($xdid(%config.dialog,12).text != $null && $regex(regex,$xdid(%config.dialog,12).text,^[[:space:]]|[[:space:]]$) == 1) {
    if (%error > 0) { var %errortext %errortext $+ $lf $+ * Name ungültig }
    else { var %errortext * Name ungültig }
    inc %error
  }
  if ($xdid(%config.dialog,13).text != $null && $regex(regex,$xdid(%config.dialog,13).text,.+@.+\..+) == 0) {
    if (%error > 0) { var %errortext %errortext $+ $lf $+ * E-Mail Addresse ungültig }
    else { var %errortext * E-Mail Addresse ungültig }
    inc %error
  }

  var %i 1
  var %lines $xdid(%config.dialog,15).num
  while (%i <= %lines) {
    if (($xdid(%config.dialog,15,%i).text == $null || $pos($xdid(%config.dialog,15,%i).text,$chr(32),0) == $len($xdid(%config.dialog,15,%i).text)) && %i < %lines) {
      if (%error > 0) { var %errortext %errortext $+ $lf $+ * Perform darf keine Leerzeilen enthalten }
      else { var %errortext * Perform darf keine Leerzeilen enthalten }
      inc %error
      break
    }
    inc %i
  }

  if (%error > 0) {
    .noop $dcx(MsgBox,ok error modal owner $dialog(%config.dialog).hwnd $chr(9) Fehler $chr(9) Bitte Überprüfen Sie ihre Eingaben. $+ $lf $+ $lf $+ %errortext )
    return 0
  }
  else {
    return 1
  }
}

alias -l dc.connectServerList.saveNetworkData {
  if ($dc.connectServerList.checkNetworkData) {
    var %db $dbs(modul_connect,$xdid(%config.dialog,2).seltext,c)
    if (%db != 0) {
      .noop $dbs(%db,perform).setSection
      .noop $dbs(%db).deleteUserSection
      var %i 1
      var %lines $xdid(%config.dialog,15).num
      while (%i <= %lines) {
        if ($xdid(%config.dialog,15,%i).text != $null) {
          .noop $dbs(%db,n $+ %i,$xdid(%config.dialog,15,%i).text).setUserValue
        }
        inc %i
      }
      if ($xdid(%config.dialog,14).state == 1) {
        .noop $dbs(%db).destroy
        var %db $dbs(modul_connect)
      }
      .noop $dbs(%db,ident).setsection
      .noop $dbs(%db).deleteUserSection
      if ($xdid(%config.dialog,10).text != $null) { .noop $dbs(%db,nick,$xdid(%config.dialog,10).text).setUserValue }
      if ($xdid(%config.dialog,11).text != $null) { .noop $dbs(%db,anick,$xdid(%config.dialog,11).text).setUserValue }
      if ($xdid(%config.dialog,12).text != $null) { .noop $dbs(%db,fullname,$xdid(%config.dialog,12).text).setUserValue }
      if ($xdid(%config.dialog,13).text != $null) { .noop $dbs(%db,emailaddr,$xdid(%config.dialog,13).text).setUserValue }
    }
  }
  .noop $dcx(MsgBox,ok exclamation modal owner $dialog(%config.dialog).hwnd $chr(9) OK $chr(9) Daten gespeichert)
  .noop $dbs(%db).destroy
} 

alias -l dc.connectServerList.enableServerControls {
  xdid -e %config.dialog 4
  xdid -e %config.dialog 5
  xdid -e %config.dialog 6
  xdid -e %config.dialog 7
  xdid -e %config.dialog 8
}

alias -l dc.connectServerList.newServer {
  dc.connectServerList.createServerControls
  dc.connectServerList.enableServerControls
  set %connect.sl.mode new
  xdid -t %config.dialog 76 1 +h
  xdid -t %config.dialog 76 2 +
}

alias -l dc.connectServerList.editServer {
  dc.connectServerList.enableServerControls
  set %connect.sl.mode edit
  xdid -t %config.dialog 76 2 +
}

alias -l dc.connectServerList.delServer {
  var %serverData $serverData($xdid(%config.dialog,2,$xdid(%config.dialog,2).selpath).tooltip)
  if ($serverData(%serverData).delServer == 1) {
    var %sel $xdid(%config.dialog,2).selpath
    xdid -d %config.dialog 2 %sel
    var %sel.root $gettok(%sel,1,32)
    if ($xdid(%config.dialog,2,%sel.root).num == 0) {
      xdid -c %config.dialog 2 %sel.root
      xdid -j %config.dialog 2 %sel.root $chr(9) 2 2 0
    }
    else {
      xdid -c %config.dialog 2 %sel
    }
  }
  else {
    .noop $dcx(MsgBox,ok error modal owner $dialog(%config.dialog).hwnd $chr(9) Fehler $chr(9) Server löschen fehlgeschlagen )
  }
  .noop $serverData(%serverData).destroy
}

alias -l dc.connectServerList.delNetwork {
  var %error 0
  var %list $serverList($xdid(%config.dialog,2,$gettok($xdid(%config.dialog,2).selpath,1,32)).text)
  .noop $serverList(%list).prepareWhile
  while ($serverList(%list).next) {
    var %server $serverData($serverList(%list).getValue)
    if ($serverData(%server).delServer == 0) {
      var %error 1
      .noop $serverData(%server).destroy
      break
    }
    .noop $serverData(%server).destroy
  }
  if (%error == 1) {
    .noop $dcx(MsgBox,ok error modal owner $dialog(%config.dialog).hwnd $chr(9) Fehler $chr(9) Netzwerk löschen fehlgeschlagen)
  }
  else {
    var %sel $gettok($xdid(%config.dialog,2).selpath,1,32)
    xdid -c %config.dialog 2 %sel
    xdid -d %config.dialog 2 %sel
    if ($xdid(%config.dialog,2,%sel).text == $null) {
      var %sel $calc(%sel - 1)
    }
    if (%sel == 0) { var %sel 1 }
    xdid -c %config.dialog 2 %sel
  }
}

alias -l dc.connectServerList.addNetwork {
  var %net $?="Name des Netzwerkes"
  if ($xdid(%config.dialog,2,$chr(9) %net $chr(9),W,0).find == 0) {
    xdid -a %config.dialog 2 $+($calc($xdid(%config.dialog,2,root).num + 1),$chr(9),+ 2 2 0 0 0 $rgb(0,0,255) $rgb(255,0,255) %net,$chr(9),%net)
  }
  else {
    .noop $dcx(MsgBox,ok error modal owner $dialog(%config.dialog).hwnd $chr(9) Fehler $chr(9) Netzwerk bereits in Liste)
  }
}

alias -l dc.connectServerList.connect {
  dc.connectServerList.loadServers
  if ($numtok($xdid(%config.dialog,2).selpath,32) == 1 && $xdid(%config.dialog,2,$xdid(%config.dialog,2).selpath).num > 0) {
    .server -m $xdid(%config.dialog,2).seltext
  }
  elseif ($numtok($xdid(%config.dialog,2).selpath,32) == 2) {
    .server -m $xdid(%config.dialog,2,$xdid(%config.dialog,2).selpath).tooltip
  }
}

alias -l dc.connectServerList.saveServer {
  if ($dc.connectServerList.checkServerData) {
    var %server $serverData()
    .noop $serverData(%server,desc,$xdid(%config.dialog,4).text).set
    .noop $serverData(%server,address,$xdid(%config.dialog,5).text).set
    .noop $serverData(%server,ports,$xdid(%config.dialog,6).text).set
    .noop $serverData(%server,ssl-ports,$xdid(%config.dialog,7).text).set
    .noop $serverData(%server,pass,$xdid(%config.dialog,8).text).set
    var %path $gettok($xdid(%config.dialog,2).selpath,1,32)
    .noop $serverData(%server,group,$xdid(%config.dialog,2,%path).text).set
    .noop $serverData(%server).newServer
    if (%connect.sl.mode == edit) {
      xdid -o %config.dialog 2 $xdid(%config.dialog,2).selpath $chr(9) $xdid(%config.dialog,5).text
      xdid -v %config.dialog 2 $xdid(%config.dialog,2).selpath $chr(9) $xdid(%config.dialog,4).text
    }
    else {
      xdid -j %config.dialog 2 %path $chr(9) 1 1 0
      var %path %path $+ $chr(32) $+ $calc($xdid(%config.dialog,2,%path).num + 1)
      xdid -a %config.dialog 2 $+(%path,$chr(9),+ 0 0 0 0 0 $rgb(0,0,255) $rgb(255,0,255) $xdid(%config.dialog,4).text,$chr(9),$xdid(%config.dialog,5).text)
      xdid -c %config.dialog 2 %path
      xdid -t %config.dialog 2 +e %path
    }
    set %connect.sl.mode edit
  }
}

alias -l dc.connectServerList.checkServerData {
  var %error 0
  var %errortext Es sind Fehler aufgetreten. Bitte überprüfen sie ihre Eingaben: $lf

  if ($xdid(%config.dialog,4).text == $null) {
    inc %error
    var %errortext %errortext $+ $lf $+ * Server Beschreibung darf nicht leer sein
  }
  elseif ($regex(regex,$xdid(%config.dialog,4).text,^[[:space:]]|[[:space:]]$) == 1) {
    inc %error
    var %errortext %errortext $+ $lf $+ * Server Beschreibung enthält unzulässige Leerzeichen
  }
  elseif ($xdid(%config.dialog,4).text == none) {
    inc %error
    var %errortext %errortext $+ $lf $+ * Server Beschreibung darf nicht $qt(none) lauten
  }
  else {
    var %path $xdid(%config.dialog,2,$chr(9) $+ $xdid(%config.dialog,4).text $+ $chr(9),W,1,$gettok($xdid(%config.dialog,2).selpath,1,32)).find
    if ((%connect.sl.mode == new  && %path != $null) || (%connect.sl.mode == edit && %path != $null && $xdid(%config.dialog,2).selpath != %path)) {
      inc %error
      var %errortext %errortext $+ $lf $+ * Server Beschreibung darf nur einmal pro Netzwerk existieren
    }
  }

  if ($xdid(%config.dialog,5).text == $null) {
    inc %error
    var %errortext %errortext $+ $lf $+ * Server Addresse darf nicht leer sein
  }
  elseif ($regex(regex,$xdid(%config.dialog,5).text,^localhost$|^([a-z]+\.)*[a-z0-9]([a-z]|[0-9]|[-_\.~])*\.[a-z][a-z]+|(\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3})) == 0) {
    inc %error
    var %errortext %errortext $+ $lf $+ * Server Addresse ungültig
  }
  else {
    var %server $serverData($xdid(%config.dialog,5).text)
    if ($serverData(%server,exists).get == 1 && (%connect.sl.mode == new || $&
      %connect.sl.mode == edit && $xdid(%config.dialog,5).text != $xdid(%config.dialog,2,$xdid(%config.dialog,2).selpath).tooltip)) {
      inc %error
      var %errortext %errortext $+ $lf $+ * Server Addresse darf nur einmal existieren
    }
    .noop $serverData(%server).destroy
  }

  var %server $serverData($xdid(%config.dialog,2,$xdid(%config.dialog,2).selpath).tooltip)
  if (%connect.sl.mode == edit && $xdid(%config.dialog,4).text != $serverData(%server,desc).get && $xdid(%config.dialog,5).text != $serverData(%server,address).get) {
    inc %error
    var %errortext %errortext $+ $lf $+ * Es darf nur die Server-Addresse oder der Name geändert werden nicht beides
  }
  .noop $serverData(%server).destroy

  if ($xdid(%config.dialog,6).text == $null && $xdid(%config.dialog,7).text == $null) {
    inc %error
    var %errortext %errortext $+ $lf $+ * Es muss zumindest ein normaler oder ein SSL-Port angegeben sein
  }
  else {
    if ($xdid(%config.dialog,6).text != $null && $regex(regex,$xdid(%config.dialog,6).text,(^[1-9][0-9]{3,4})((,|-)?([1-9][0-9]{3,4}))*$) == 0) {
      inc %error
      var %errortext %errortext $+ $lf $+ * Port Angabe ungültig 
    }
    if ($xdid(%config.dialog,7).text != $null && $regex(regex,$xdid(%config.dialog,7).text,(^[1-9][0-9]{3,4})((,|-)?([1-9][0-9]{3,4}))*$) == 0) {
      inc %error
      var %errortext %errortext $+ $lf $+ * SSL-Port Angabe ungültig
    }
  }

  if ($xdid(%config.dialog,8).text == none) {
    inc %error
    var %errortext %errortext $+ $lf $+ * Passwort darf nicht $qt(none) lauten
  }
  elseif ($regex(regex,$xdid(%config.dialog,8).text,^[[:space:]]|[[:space:]]$) == 1) {
    inc %error
    var %errortext %errortext $+ $lf $+ * Passwort ungültig
  }

  if (%error > 0) {
    .noop $dcx(MsgBox,ok error modal owner $dialog(%config.dialog).hwnd $chr(9) Fehler $chr(9) %errortext )
    return 0
  }
  else {
    return 1
  }

}

alias connect.getIdent {
  var %db $dbs(modul_connect,$1,r)
  if (%db == 0) {
    return $null
  }
  else {
    .noop $dbs(%db,ident).setSection
    var %nick $null
    var %anick $null
    var %fullname $null
    var %emailaddr $null    

    if ($dbs(%db,nick).getUserValue != $null) {
      var %nick $dbs(%db,nick).getUserValue
    }
    elseif ($1 == $null) {
      var %nick $dbs(%db,nick).getScriptValue
    }
    if ($dbs(%db,anick).getUserValue != $null) {
      var %anick $dbs(%db,anick).getUserValue
    }
    elseif ($1 == $null) {
      var %anick $dbs(%db,anick).getScriptValue
    }

    if ($dbs(%db,fullname).getUserValue != $null) {
      var %fullname $dbs(%db,fullname).getUserValue
    }
    elseif ($1 == $null) {
      var %fullname $dbs(%db,fullname).getScriptValue
    }

    if ($dbs(%db,emailaddr).getUserValue != $null) {
      var %emailaddr $dbs(%db,emailaddr).getUserValue
    }
    elseif ($1 == $null) {
      var %emailaddr $dbs(%db,emailaddr).getScriptValue
    }
    .noop $dbs(%db).destroy
    return %nick %anick %emailaddr %fullname
  }
}

alias dc.connectServerList.onConnect {
  var %db $dbs(modul_connect,$network,r)
  if (%db) {
    var %list $dbsList(%db,user,perform)
    if (%list) {
      .noop $dbsList(%list).prepareWhile
      while ($dbsList(%list).next) {
        $dbsList(%list).getValue
      }
      .noop $dbsList(%list).destroy
    }
    .noop $dbs(%db).destroy
  }
}
