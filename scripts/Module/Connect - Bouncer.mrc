alias dc.connectBouncer.createPanel { 
set %config.dialog dcConf
  dc.connectBouncer.createPanelContent
  dc.connectBouncer.fillPanelControls
  dc.connectBouncer.fillBouncerData

}

alias dc.connectBouncer.destroyPanel {
  unset %connect.bnc.*
;  return 1 
}

alias dc.connectBouncer.events { 
  if ($2 == sclick) {
    if ($3 == 2 && $xdid(%config.dialog,2).sel != %connect.bnc.sel) {
      set %connect.bnc.sel $xdid(%config.dialog,2).sel
      unset %connect.bnc.mode
      dc.connectBouncer.fillBouncerData
    }
    elseif ($3 == 75) {
      if ($4 == 1) { dc.connectBouncer.sclickToolbar.connect }
      if ($4 == 3) { dc.connectBouncer.sclickToolbar.save }
      if ($4 == 4) { dc.connectBouncer.sclickToolbar.new }  
      if ($4 == 5) { dc.connectBouncer.sclickToolbar.edit }
      if ($4 == 6) { dc.connectBouncer.sclickToolbar.delete }
    }
  }
}

alias -l dc.connectBouncer.createPanelContent {
  xdid -c %config.dialog %config.basePanelID 1 panel $config.panelCenter(435,540)

  xdid -c %config.dialog 1 100 text 0 0 200 25
  xdid -t %config.dialog 100 Server Verwaltung
  xdid -f %config.dialog 100 + default 14 Arial

  xdid -c %config.dialog 1 101 text 5 25 100 20
  xdid -t %config.dialog 101 Bouncer
  xdid -f %config.dialog 101 + default 10 Verdana

  xdid -c %config.dialog 1 75 toolbar 5 50 425 30 flat list nodivider noauto tooltips
  ;xdid -x %config.dialog 75 +b
  xdid -l %config.dialog 75 24
  xdid -w %config.dialog 75 +nh 0 images/ico/connect_sl_connect.ico
  xdid -w %config.dialog 75 +nh 0 images/ico/connect_sl_disconnect.ico
  xdid -w %config.dialog 75 +nh 0 images/ico/page_white_add.ico
  xdid -w %config.dialog 75 +nh 0 images/ico/page_white_edit.ico
  xdid -w %config.dialog 75 +nh 0 images/ico/page_white_delete.ico
  xdid -w %config.dialog 75 +nh 0 images/ico/disk.ico

  xdid -w %config.dialog 75 +dhg 0 images/ico/connect_sl_connect.ico
  xdid -w %config.dialog 75 +dhg 0 images/ico/connect_sl_disconnect.ico
  xdid -w %config.dialog 75 +dhg 0 images/ico/page_white_add.ico
  xdid -w %config.dialog 75 +dhg 0 images/ico/page_white_edit.ico
  xdid -w %config.dialog 75 +dhg 0 images/ico/page_white_delete.ico
  xdid -w %config.dialog 75 +dhg 0 images/ico/disk.ico

  xdid -a %config.dialog 75 1 +ld 30 1 $chr(9) Verbindung herstellen
  xdid -a %config.dialog 75 2 +ad 0 0 -
  xdid -a %config.dialog 75 3 +ld 30 6 $chr(9) BouncerDaten speichern
  xdid -a %config.dialog 75 4 +l 30 3 $chr(9) Bouncer hinzufügen
  xdid -a %config.dialog 75 5 +ld 30 4 $chr(9) Bouncerdaten bearbeiten
  xdid -a %config.dialog 75 6 +ld 30 5 $chr(9) Bouncer löschen

  xdid -c %config.dialog 1 2 list 5 85 190 455 tabstop vsbar

  xdid -c %config.dialog 1 102 text 200 25 200 20
  xdid -t %config.dialog 102 Bouncer Daten
  xdid -f %config.dialog 102 + default 10 Verdana

  xdid -c %config.dialog 1 103 text 205 65 100 20
  xdid -t %config.dialog 103 Name
  xdid -c %config.dialog 1 3 edit 205 85 225 20 tabstop disabled

  xdid -c %config.dialog 1 104 text 205 115 100 20
  xdid -t %config.dialog 104 Bouncer Typ
  xdid -c %config.dialog 1 4 comboex 205 135 225 300 dropdown tabstop disabled

  xdid -c %config.dialog 1 105 text 205 165 100 20
  xdid -t %config.dialog 105 Addresse
  xdid -c %config.dialog 1 5 edit 205 185 225 20 tabstop disabled

  xdid -c %config.dialog 1 106 text 205 215 100 20
  xdid -t %config.dialog 106 Port
  xdid -c %config.dialog 1 6 edit 205 235 175 20 number tabstop disabled
  xdid -c %config.dialog 1 7 check 385 235 40 20 tabstop disabled
  xdid -t %config.dialog 7 SSL

  xdid -c %config.dialog 1 108 text 205 265 100 20
  xdid -t %config.dialog 108 Benutzer
  xdid -c %config.dialog 1 8 edit 205 285 225 20 tabstop disabled

  xdid -c %config.dialog 1 109 text 205 315 100 20
  xdid -t %config.dialog 109 Passwort
  xdid -c %config.dialog 1 9 edit 205 335 225 20 password tabstop disabled

  ;xdid -c %config.dialog 1 80 button 272 380 100 20 tabstop disabled
  ;xdid -t %config.dialog 80 Speichern

}

alias -l dc.connectBouncer.fillPanelControls {
  var %db $dbs(modul_connect)
  var %dbslist $dbsList(%db,script,bnc_types)
  .noop $dbsList(%dbslist).prepareWhile
  if (%dbslist) {
    while ($dbsList(%dbslist).next) {
      xdid -a %config.dialog 4 0 0 0 0 0 $dbsList(%dbslist).getItem
    }
    .noop $dbsList(%dbslist).destroy
  }

  var %dbslist $dbsList(%db,bnc)
  if (%dbslist) {
    .noop $dbsList(%dbslist).prepareWhile
    while ($dbsList(%dbslist).next) {
      xdid -a %config.dialog 2 0 $dbsList(%dbslist).getItem
    }
    .noop $dbsList(%dbslist).destroy
    xdid -c %config.dialog 2 1
    set %connect.bnc.sel 1
  }
  .noop $dbs(%db).destroy
}

alias -l dc.connectBouncer.enableControls {
  xdid -e %config.dialog 3
  xdid -e %config.dialog 4
  xdid -e %config.dialog 5
  xdid -e %config.dialog 6
  xdid -e %config.dialog 7
  xdid -e %config.dialog 8
  xdid -e %config.dialog 9
  ;xdid -e %config.dialog 80
}

alias -l dc.connectBouncer.disableControls {
  xdid -b %config.dialog 3
  xdid -b %config.dialog 4
  xdid -b %config.dialog 5
  xdid -b %config.dialog 6
  xdid -b %config.dialog 7
  xdid -b %config.dialog 8
  xdid -b %config.dialog 9
  ;xdid -e %config.dialog 80
}

alias -l dc.connectBouncer.clearControls {
  xdid -r %config.dialog 3
  xdid -u %config.dialog 4
  xdid -r %config.dialog 5
  xdid -r %config.dialog 6
  xdid -u %config.dialog 7
  xdid -r %config.dialog 8
  xdid -r %config.dialog 9
}

alias -l dc.connectBouncer.changeToolbar {
  if ($xdid(%config.dialog,2).sel == 0) {
    xdid -t %config.dialog 75 1 +d
    xdid -t %config.dialog 75 3 +d
    xdid -t %config.dialog 75 4 +
    xdid -t %config.dialog 75 5 +d
    xdid -t %config.dialog 75 6 +d
  }
  else {
    xdid -t %config.dialog 75 1 +
    xdid -t %config.dialog 75 3 +d
    xdid -t %config.dialog 75 4 +
    xdid -t %config.dialog 75 5 +
    xdid -t %config.dialog 75 6 +

  }
}

alias -l dc.connectBouncer.fillBouncerData {
  if ($xdid(%config.dialog,2).sel > 0) {
    dc.connectBouncer.disableControls
    dc.connectBouncer.clearControls
    dc.connectBouncer.changeToolbar
    var %db $dbs(modul_connect)
    var %section $xdid(%config.dialog,2,$xdid(%config.dialog,2).sel).text
    .noop $dbs(%db,%section).setSection
    xdid -a %config.dialog 3 %section

    var %dbslist $dbsList(%db,script,bnc_types)
    if (%dbslist) {
      .noop $dbsList(%dbslist).prepareWhile
      while ($dbsList(%dbslist).next) {
        if ($dbsList(%dbslist).getItem == $dbs(%db,bnc,type).getCustomValue) {
          xdid -c %config.dialog 4 $dbsList(%dbslist).getPos
          break
        }
      }
      .noop $dbsList(%dbslist).destroy
    }

    xdid -a %config.dialog 5 $dbs(%db,bnc,address).getCustomValue
    if ($left($dbs(%db,bnc,port).getCustomValue,1) == $chr(43)) {
      xdid -c %config.dialog 7
      xdid -a %config.dialog 6 $mid($dbs(%db,bnc,port).getCustomValue,2)
    }
    else {
      xdid -a %config.dialog 6 $dbs(%db,bnc,port).getCustomValue  
    }
    xdid -a %config.dialog 8 $dbs(%db,bnc,user).getCustomValue
    xdid -a %config.dialog 9 $decryptValue($dbs(%db,bnc,pwd).getCustomValue)
  }
  .noop $dbs(%db).destroy
}

alias -l dc.connectBouncer.sclickToolbar.new {
  xdid -u %config.dialog 2
  dc.connectBouncer.enableControls
  dc.connectBouncer.clearControls
  dc.connectBouncer.changeToolbar
  xdid -t %config.dialog 75 3 +
  set %connect.bnc.mode new
}

alias -l dc.connectBouncer.sclickToolbar.edit {
  dc.connectBouncer.enableControls
  dc.connectBouncer.changeToolbar
  xdid -t %config.dialog 75 1 +d
  xdid -t %config.dialog 75 3 +
  xdid -t %config.dialog 75 5 +d
  xdid -t %config.dialog 75 6 +d
  set %connect.bnc.mode edit
}

alias -l dc.connectBouncer.sclickToolbar.delete {
  var %db $dbs(modul_connect)
  .noop $dbs(%db,bnc,$xdid(%config.dialog,3).text).deleteCustomSection
  xdid -d %config.dialog 2 $xdid(%config.dialog,2).sel
  dc.connectBouncer.disableControls
  dc.connectBouncer.clearControls
  dc.connectBouncer.changeToolbar
  .noop $dcx(MsgBox,ok exclamation modal owner $dialog(%config.dialog).hwnd $chr(9) OK $chr(9) Bouncer wurde gelöscht)
  .noop $dbs(%db).destroy
}

alias -l dc.connectBouncer.checkData {
  var %error 0
  var %errortext Es sind Fehler aufgetreten. Bitte überprüfen sie ihre Eingaben: $lf
  if ($xdid(%config.dialog,2,$chr(9) $xdid(%config.dialog,3).text $chr(9),W,0).find) {
    if (%connect.bnc.mode == new) {
      inc %error
      var %errortext %errortext $+ $lf $+ * Bouncername bereits vorhanden
    }
    elseif (%connect.bnc.mode == edit && $xdid(%config.dialog,2,$xdid(%config.dialog,2).sel).text != $xdid(%config.dialog,3).text) {
      inc %error
      var %errortext %errortext $+ $lf $+ * Bouncername bereits vorhanden
    }
  }
  if ($xdid(%config.dialog,3).text == $null) {
    inc %error
    var %errortext %errortext $+ $lf $+ * Bouncername darf nicht leer sein
  }
  elseif ($regex(regex,$xdid(%config.dialog,3).text,[[:space:]])) {
    inc %error
    var %errortext %errortext $+ $lf $+ * Bouncername darf keine Leerzeichen enthalten
  }
  if ($xdid(%config.dialog,4).sel == $null) {
    inc %error
    var %errortext %errortext $+ $lf $+ * Bouncertyp wurde nicht gewählt
  }
  if ($xdid(%config.dialog,5).text == $null) {
    inc %error
    var %errortext %errortext $+ $lf $+ * Serveraddresse fehlt
  }
  elseif ($regex(regex,$xdid(%config.dialog,5).text,^localhost$|^([a-z]+\.)*[a-z0-9]([a-z]|[0-9]|[-_\.~])*\.[a-z][a-z]+|(\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3})) == 0) {
    inc %error
    var %errortext %errortext $+ $lf $+ * Serveraddresse ungültig
  }
  if ($xdid(%config.dialog,6).text == $null) {
    inc %error
    var %errortext %errortext $+ $lf $+ * Port nicht eingetragen
  }
  if ($xdid(%config.dialog,8).text == $null) {
    inc %error
    var %errortext %errortext $+ $lf $+ * Benutzername darf nicht leer sein
  }
  elseif ($regex(regex,$xdid(%config.dialog,8).text,[[:space:]])) {
    inc %error
    var %errortext %errortext $+ $lf $+ * Benutzername darf keine Leerzeichen enthalten
  }
  if ($xdid(%config.dialog,9).text == $null) {
    inc %error
    var %errortext %errortext $+ $lf $+ * Passwort darf nicht leer sein
  }

  if (%error > 0) {
    .noop $dcx(MsgBox,ok error modal owner $dialog(%config.dialog).hwnd $chr(9) Fehler $chr(9) %errortext )
    return 0
  }
  else {
    return 1
  }
}

alias -l dc.connectBouncer.sclickToolbar.save {
  if ($dc.connectBouncer.checkData) {
    var %db $dbs(modul_connect)
    .noop $dbs(%db,$xdid(%config.dialog,3).text).setSection
    .noop $dbs(%db,bnc).deleteCustomSection
    .noop $dbs(%db,bnc,type,$xdid(%config.dialog,4).seltext).setCustomValue
    .noop $dbs(%db,bnc,address,$xdid(%config.dialog,5).text).setCustomValue
    var %port $iif($xdid(%config.dialog,7).state == 1,$chr(43),) $+ $xdid(%config.dialog,6).text
    .noop $dbs(%db,bnc,port,%port).setCustomValue
    .noop $dbs(%db,bnc,user,$xdid(%config.dialog,8).text).setCustomValue
    .noop $dbs(%db,bnc,pwd,$encryptValue($xdid(%config.dialog,9).text)).setCustomValue

    if (%connect.bnc.mode == new) {
      xdid -a %config.dialog 2 0 $xdid(%config.dialog,3).text
    }
    elseif (%connect.bnc.mode == edit) {
      xdid -o %config.dialog 2 $xdid(%config.dialog,2).sel $xdid(%config.dialog,3).text
    }

    .noop $dcx(MsgBox,ok exclamation modal owner $dialog(%config.dialog).hwnd $chr(9) OK $chr(9) Daten gespeichert)
    .noop $dbs(%db).destroy
    
    set %connect.bnc.mode edit
  }
}

alias -l dc.connectBouncer.sclickToolbar.connect {
  dc.connectBouncer.connect $xdid(%config.dialog,3).text
}

alias dc.connectBouncer.connect {
if ($2 == 1) { var %para -m }
else { var %para $null }
  var %db $dbs(modul_connect)
  .noop $dbs(%db,$1).setSection
  var %loginmode $dbs(%db,bnc_types,$dbs(%db,bnc,type).getCustomValue).getScriptValue

  if (%loginmode == user:pwd) {
    var %pwd $dbs(%db,bnc,user).getCustomValue $+ $chr(58) $+ $decryptValue($dbs(%db,bnc,pwd).getCustomValue)
    .server -m $dbs(%db,bnc,address).getCustomValue $dbs(%db,bnc,port).getCustomValue %pwd
  }
  elseif (%loginmode == pwd_ident) {
    var %ident $connect.getIdent()
    var %ident $puttok(%ident,$dbs(%db,bnc,user).getCustomValue $+ @mybouncer.at,3,32)
    .server %para $dbs(%db,bnc,address).getCustomValue $dbs(%db,bnc,port).getCustomValue $decryptValue($dbs(%db,bnc,pwd).getCustomValue) -i %ident
  }
  .noop $dbs(%db).destroy
}