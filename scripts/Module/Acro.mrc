/*
* DragoonCore Acro
*
* @author Valfa
* @version 1.0
* @db Module/Acro.ini
*
* Ersetzt Wörter nach interner oder eigener Vorgabe
*/

/*
* Class Alias
* var %var $dcAcro
*
* @param $1 Datenbank objekt (optional)
*/
alias dcAcro {
  var %this = dcAcro           | ; Name of Object (Alias name)
  var %base = dcBase        | ; Name of BaseClass, $null for none  

  /*
  * Start of data parsing
  * Do not edit
  */

  if (!$prop) { goto init }
  if (!$hget($1) && $prop != init) { echo -a * Error: Object not initialized %this | halt }
  ;if (if %base == $null && $hget($1,BASE) != %this) { echo -a * Error: Object is not from %this | halt }
  if (if %base != $null && $hget($1,INIT) != %this) { echo -a * Error: Object is not from %this | halt }
  if ($isalias($+(%this,.,$prop,.PRIVATE))) { echo -a * ERROR: Unable to access Method $qt(%prop) | halt }
  goto $prop
  halt

  :error
  if (goto isin $error && %base != $null) {
    .reseterror
    set % [ $+ [ %base ] ] $prop $1-
    return $ [ $+ [ %base ] ]
  }
  else {
    echo -a $iif($error,$v1,Unknown error) in Class: %this
    .reseterror
    return 0
  }  
  /*
  * Your Class methods
  * Start editing here
  */

  :init
  var %x $dcBase(%this,%base).init
  return $dcAcro.init(%x,$1)

  :destroy
  return $dcAcro.destroy($1)

  :writeConfig
  return $dcAcro.writeConfig($1)

  :getListObject
  return $dcAcro.getListObject($1,$2)

  :newAcro
  return $dcAcro.newAcro($1,$2,$3-)

  :editAcro
  return $dcAcro.editAcro($1,$2,$3,$4-)

  :saveAcro
  return $dcAcro.saveAcro($1,$2,$3-)

  :checkAcro
  return $dcAcro.checkAcro($1,$2,$3,$4)

  :delAcro
  return $dcAcro.delAcro($1,$2)

  :applyDefaultStyle
  return $dcAcro.applyDefaultStyle($1,$2-)

  :applyColorSettings
  return $dcAcro.applyColorSettings($1,$2-)

  :getErrorObject
  return $hget($1,error)

  :loadDefaults
  return $dcAcro.loadDefaults($1)

}

/*
* Erzeugt ein Acro-Objekt
*
* @param $1 dcAcro objekt
* @param $2 dcDbs objekt (optional)
* @return dcAcro objekt
*/
alias -l dcAcro.init {
  if ($2 == $null || $hget($2,database) != modul_acro) { 
    var %db $dcDbs(modul_acro)
    hadd %db createDB 1
  }
  else {
    var %db $2
    hadd %db createDB 0
  }
  hadd $1 dbhash %db

  .noop $dcDbs(%db,section,config).set
  var %acro.c1 $dcDbs(%db,c1).getValue
  var %acro.c2 $dcDbs(%db,c2).getValue
  var %acro.lu $dcDbs(%db,list_user).getValue
  var %acro.ls $dcDbs(%db,list_script).getValue
  if (%acro.c1 == $null) { var %acro.c1 $dcDbs(%db,c1).getscriptValue }
  if (%acro.c2 == $null) { var %acro.c2 $dcDbs(%db,c2).getscriptValue }
  if (%acro.ls == $null) { var %acro.ls $dcDbs(%db,list_script).getscriptValue }
  if (%acro.lu == $null) { var %acro.lu $dcDbs(%db,list_user).getscriptValue }

  hadd $1 c1 $iif(%acro.c1 < 10,0) $+ %acro.c1
  hadd $1 c2 $iif(%acro.c2 < 10,0) $+ %acro.c2
  hadd $1 list_user %acro.lu
  hadd $1 list_script %acro.ls
  hadd $1 dcDbslist_user $dcDbsList(%db,user,list)
  hadd $1 dcDbslist_script $dcDbsList(%db,script,list)
  hadd $1 limit_set c1,c2,list_user,list_script,auto_style
  hadd $1 error $dcError()
  hadd $1 auto_style 0
  .noop $dcDbs(%db,section).set

  return $1
}

/*
* Zerstört ein dcAcro Objekt
*
* @param $1 dcAcro objekt
* @return 1
*/
alias -l dcAcro.destroy {
  .noop $dcDbsList($hget($1,dcDbslist_user)).destroy
  .noop $dcDbsList($hget($1,dcDbslist_script)).destroy
  .noop $dcError($hget($1,error)).destroy
  if ($hget($1,createDB) == 1) {
    .noop $dcDbs($hget($1,dbhash)).destroy
  }
  .noop $dcBase($1).destroy
  return 1
}

/*
* schreibt die Config
* @param $1 dcAcro objekt
* @return 1
*/
alias -l dcAcro.writeConfig {
  .noop $dcDbs($hget($1,dbhash),section,config).set
  .noop $dcDbs($hget($1,dbhash),c1,$hget($1,c1)).setValue
  .noop $dcDbs($hget($1,dbhash),c2,$hget($1,c2)).setValue
  .noop $dcDbs($hget($1,dbhash),list_user,$hget($1,list_user)).setValue
  .noop $dcDbs($hget($1,dbhash),list_script,$hget($1,list_script)).setValue
  .noop $dcDbs($hget($1,dbhash),section).set
  return 1
}

/*
* gibt ein dcDbsList Objekt zurück
*
* @param $1 dcAcro objekt
* @param $2 Benutzer (user) oder Vorgaben (script) Liste
* @return dcDbsList objekt oder 0
*/
alias -l dcAcro.getListObject {
  if ($2 == user || $2 == script) {
    return $hget($1,dcDbslist_ $+ $2)
  }
  else {
    return 0
  }
}

/*
* Überprüft Daten für ein Acro
* 
* @param $1 dcAcro objekt
* @param $2 item nr (0 für new)
* @param $3 kürzel
* @param $4 ersetzung
* @return 1 oder 0
*/
alias -l dcAcro.checkAcro {
  .noop $dcDbs($hget($1,dbhash),section,list).set
  .noop $dcError($hget($1,error)).clear

  if ($3 == $null) {
    .noop $dcError($hget($1,error),Kürzel darf nicht leer sein).add
  }
  elseif (!$dcCheck($3).space) {
    .noop $dcError($hget($1,error),Kürzel darf keine Leerzeichen enthalten).add
  }
  else {
    if (($2 == 0 && $dcDbs($hget($1,dbhash),$3).getValue != $null) || $&
      ($2 > 0 && $dcDbs($hget($1,dbhash),$3).getItem != $2)) {
      .noop $dcError($hget($1,error),Kürzel darf nur einmal vorkommen).add
    }
  }

  if ($4- == $null) {
    .noop $dcError($hget($1,error),Ersetzung darf nicht leer sein).add
  }
  elseif (!$dcCheck($4-).addspace) {
    .noop $dcError($hget($1,error),Ersetzung enthält unzulässige Leerzeichen).add
  }

  if ($dcError($hget($1,error)).count > 0) {
    return 0
  }
  else {
    return 1
  }
}

/*
* fügt der user-liste ein neues Acro hinzu
*
* @param $1 dcAcro objekt
* @param $2 kürzel
* @param $3 ersetzung
* @return 1 oder 0
*/
alias -l dcAcro.newAcro {
  if ($dcAcro($1,0,$2,$3-).checkAcro) {
    .noop $dcAcro($1,$2,$3-).saveAcro
    if ($hget($1,dcDbslist_user) == 0) {
      hadd $1 dcDbslist_user $dcDbsList($hget($1,dbhash),user,list)
    }
    else {
      hinc $hget($1,dcDbslist_user) last  
    }
    return 1
  }
  else {
    return 0
  }
}

/*
* bearbeitet ein Acro der User-Liste
*
* @param $1 dcAcro objekt
* @param $2 nr. des acro
* @param $3 kürzel
* @param $4 ersetzung
* @return 1 oder 0
*/
alias -l dcAcro.editAcro {
  if ($dcAcro($1,$2,$3,$4-).checkAcro) {
    .noop $dcAcro($1,$3,$4-).saveAcro
    return 1
  }
  else {
    return 0
  }
}

/*
* speichert das acro in der Datenbank
*
* @param $1 dcAcro objekt
* @param $2 kürzel
* @param $3- ersetzung
* @return 1
*/
alias -l dcAcro.saveAcro {
  .noop $dcDbs($hget($1,dbhash),section,list).set
  if ($hget($1,auto_style) == 1) {
    .noop $dcDbs($hget($1,dbhash),$2,$dcAcro($1,$3-).applyDefaultStyle).setValue
  }
  else {
    .noop $dcDbs($hget($1,dbhash),$2,$3-).setValue
  }
  return 1
}

/*
* wendet den Standart style für acros an, sofern aktiviert
*
* @param $1 dcAcro objekt
* @param $2- zu bearbeitende text
* @return bearbeitete text
*/
alias -l dcAcro.applyDefaultStyle {
  var %return $strip($2-)
  var %i 1
  while (%i <= $numtok(%return,32)) {
    var %tmp $gettok(%return,%i,32)
    var %rep 1 $+ $left(%tmp,1) $+ 2 $+ $mid(%tmp,2) $+ 
    var %return $puttok(%return,%rep,%i,32)
    inc %i
  }
  return %return
}

/*
* löscht ein Acro
*
* @param $1 dcAcro objekt
* @param $2 das zu löschende Acro
* @return 1 oder 0
*/
alias -l dcAcro.delAcro {
  .noop $dcDbs($hget($1,dbhash),section,list).set
  if ($dcDbs($hget($1,dbhash),$2).getValue != $null) {
    .noop $dcDbs($hget($1,dbhash),$2).deleteItem
    hdec $hget($1,dcDbslist_user) last
    return 1
  }
  else {
    return 0
  }
}

/*
* wendet Die Farbeinstellungen laut Konfiguration an
*
* @param $1 dcAcro objekt
* @param $2- acro (normal)
* @return acro (angepasst)
*/
alias -l dcAcro.applyColorSettings {
  return $replace($2-,1, $+ $hget($1,c1),2, $+ $hget($1,c2))
}

/*
* Lädt die Standard Config
*
* @param $1 dcAcro objekt
* @return 1
*/
alias -l dcAcro.loadDefaults {
  .noop $dcDbs($hget($1,dbhash),section,config).set
  hadd $1 c1 $dcDbs($hget($1,dbhash),c1).getScriptValue
  hadd $1 c2 $dcDbs($hget($1,dbhash),c2).getScriptValue
  hadd $1 list_user $dcDbs($hget($1,dbhash),list_user).getScriptValue
  hadd $1 list_script $dcDbs($hget($1,dbhash),script).getScriptValue
  return 1
}

/*
* Class Alias
* var %var $dcAcroDialog
*
* @param $1 dialog name
* @param $2 Datenbank hash (optional)
*/
alias dcAcroDialog {
  var %this = dcAcroDialog           | ; Name of Object (Alias name)
  var %base = dcDialog        | ; Name of BaseClass, $null for none  

  /*
  * Start of data parsing
  * Do not edit
  */

  if (!$prop) { goto init }
  if (!$hget($1) && $prop != init) { echo -a * Error: Object not initialized %this | halt }
  ;if (if %base == $null && $hget($1,BASE) != %this) { echo -a * Error: Object is not from %this | halt }
  if (if %base != $null && $hget($1,INIT) != %this) { echo -a * Error: Object is not from %this | halt }
  if ($isalias($+(%this,.,$prop,.PRIVATE))) { echo -a * ERROR: Unable to access Method $qt(%prop) | halt }
  goto $prop
  halt

  :error
  if (goto isin $error && %base != $null) {
    .reseterror
    set % [ $+ [ %base ] ] $prop $1-
    return $ [ $+ [ %base ] ]
  }
  else {
    echo -a $iif($error,$v1,Unknown error) in Class: %this
    .reseterror
    return 0
  }  
  /*
  * Your Class methods
  * Start editing here
  */

  :init
  var %x $dcDialog(%this,%base)
  return $dcAcroDialog.init(%x,$1,$2)

  :destroy
  return $dcAcroDialog.destroy($1)

  :createControls
  return $dcAcroDialog.createControls($1)

  :setConfigControls
  return $dcAcroDialog.setConfigControls($1)

  :saveConfig
  return $dcAcroDialog.saveConfig($1)

  :changeAcroList
  return $dcAcroDialog.changeAcroList($1,$2)

  :fillAcroList
  return $dcAcroDialog.fillAcroList($1)

  :changeToolbar
  return $dcAcroDialog.changeToolbar($1)

  :selectAcro
  return $dcAcroDialog.selectAcro($1)

  :fillAcroEditControls
  return $dcAcroDialog.fillAcroEditControls($1)

  :setAutoStyle
  return $dcAcroDialog.setAutoStyle($1)

  :addUserListEntry
  return $dcAcroDialog.addUserListEntry($1,$2,$3)

  :newAcro
  return $dcAcroDialog.newAcro($1)

  :editAcro
  return $dcAcroDialog.editAcro($1)

  :delAcro
  return $dcAcroDialog.delAcro($1)

  :saveAcro
  return $dcAcroDialog.saveAcro($1)

  :setPreview
  return $dcAcroDialog.setPreview($1)

  :loadDefaults
  return $dcAcroDialog.loadDefaults($1)

}

/*
* Initialisiert ein dcAcroDialog objekt
*
* @param $1 dcAcroDialog Objekt
* @param $2 dialog name oder $null
* @param $3 db hash oder $null
* @return $1
*/
alias -l dcAcroDialog.init {
  hadd $1 acro.obj $dcAcro($3)
  if ($2 != $null) { hadd $1 dialog.name $2 }
  else { hadd $1 dialog.name dcAcro }

  .noop $dcDialog($1,435,540).createBasePanel
  .noop $dcAcroDialog($1).createControls
  .noop $dcAcroDialog($1).setConfigControls

  if ($dcAcro($hget($1,acro.obj),list_user).get == 1 && $dcAcro($hget($1,acro.obj),list_script).get == 0) {
    .noop $dcAcroDialog($1,user).changeAcroList
    .noop $dcDialog($1,7).checkControls
  }
  else {
    .noop $dcAcroDialog($1,script).changeAcroList
    .noop $dcDialog($1,6).checkControls
  }

  return $1
}

/*
* löscht ein dcAcroDialog Objekt
*
* @param $1 dcAcroDialog objekt
* @return 1
*/
alias -l dcAcroDialog.destroy {
  .noop $dcAcro($hget($1,acro.obj)).destroy
  .noop $dcBase($1).destroy
  return 1
}

/*
* Erstellt alle Bedienelemente
*
* @param $1 dcAcroDialog objekt
* @return 1
*/
alias -l dcAcroDialog.createControls {

  xdid -c $hget($1,dialog.name) 1 100 text 0 0 200 25
  xdid -t $hget($1,dialog.name) 100 Acro
  xdid -f $hget($1,dialog.name) 100 + default 14 Arial

  xdid -c $hget($1,dialog.name) 1 101 text 5 25 300 20
  xdid -t $hget($1,dialog.name) 101 Acro Einstellungen
  xdid -f $hget($1,dialog.name) 101 + default 10 Verdana

  xdid -c $hget($1,dialog.name) 1 102 text 5 50 50 20
  xdid -t $hget($1,dialog.name) 102 Farbe 1:

  xdid -c $hget($1,dialog.name) 1 2 colorcombo 55 45 100 300
  xdid -m $hget($1,dialog.name) 2

  xdid -c $hget($1,dialog.name) 1 103 text 160 50 50 20
  xdid -t $hget($1,dialog.name) 103 Farbe 2:

  xdid -c $hget($1,dialog.name) 1 3 colorcombo 210 45 100 300
  xdid -m $hget($1,dialog.name) 3

  xdid -c $hget($1,dialog.name) 1 104 text 5 82 70 20
  xdid -t $hget($1,dialog.name) 104 aktive Listen:

  xdid -c $hget($1,dialog.name) 1 4 check 80 80 75 20
  xdid -t $hget($1,dialog.name) 4 Vorgaben

  xdid -c $hget($1,dialog.name) 1 5 check 155 80 75 20
  xdid -t $hget($1,dialog.name) 5 Benutzer

  xdid -c $hget($1,dialog.name) 1 80 button 320 80 100 20
  xdid -t $hget($1,dialog.name) 80 Speichern

  xdid -c $hget($1,dialog.name) 1 105 text 5 110 150 20
  xdid -t $hget($1,dialog.name) 105 Acro Liste
  xdid -f $hget($1,dialog.name) 105 + default 10 Verdana

  xdid -c $hget($1,dialog.name) 1 6 radio 5 130 70 20
  xdid -t $hget($1,dialog.name) 6 Vorgaben

  xdid -c $hget($1,dialog.name) 1 7 radio 80 130 70 20
  xdid -t $hget($1,dialog.name) 7 Benutzer

  xdid -c $hget($1,dialog.name) 1 8 list 5 150 175 390 nointegral vsbar

  xdid -c $hget($1,dialog.name) 1 75 toolbar 190 110 200 30 flat list nodivider noauto tooltips
  xdid -l $hget($1,dialog.name) 75 24
  xdid -w $hget($1,dialog.name) 75 +nh 0 images/ico/page_white_add.ico
  xdid -w $hget($1,dialog.name) 75 +nh 0 images/ico/page_white_edit.ico
  xdid -w $hget($1,dialog.name) 75 +nh 0 images/ico/page_white_delete.ico

  xdid -w $hget($1,dialog.name) 75 +dhg 0 images/ico/page_white_add.ico
  xdid -w $hget($1,dialog.name) 75 +dhg 0 images/ico/page_white_edit.ico
  xdid -w $hget($1,dialog.name) 75 +dhg 0 images/ico/page_white_delete.ico

  xdid -a $hget($1,dialog.name) 75 1 +ld 30 1 $chr(9) Acro hinzufügen
  xdid -a $hget($1,dialog.name) 75 2 +ld 30 2 $chr(9) Acro bearbeiten
  xdid -a $hget($1,dialog.name) 75 3 +ld 30 3 $chr(9) Acro löschen

  xdid -c $hget($1,dialog.name) 1 106 text 190 150 100 20
  xdid -t $hget($1,dialog.name) 106 Kürzel
  xdid -c $hget($1,dialog.name) 1 9 edit 190 170 245 20 tabstop autohs disabled

  xdid -c $hget($1,dialog.name) 1 107 text 190 200 100 20
  xdid -t $hget($1,dialog.name) 107 Ersetzung
  xdid -c $hget($1,dialog.name) 1 10 edit 190 220 245 20 tabstop autohs disabled
  xdid -c $hget($1,dialog.name) 1 11 check 200 240 100 20 disabled
  xdid -t $hget($1,dialog.name) 11 automatisch

  xdid -c $hget($1,dialog.name) 1 108 text 190 270 100 20
  xdid -t $hget($1,dialog.name) 108 Vorschau
  xdid -c $hget($1,dialog.name) 1 12 richedit 190 290 245 20 tabstop autohs readonly disabled
  xdid -m $hget($1,dialog.name) 12
  
  xdid -c $hget($1,dialog.name) 1 81 button 190 320 100 20 disabled default
  xdid -t $hget($1,dialog.name) 81 Speichern
  return 1
}

/*
* liest und setzt den KonfiguarionsPart
*
* @param $1 dcAcroDialog objekt
* @return 1
*/
alias -l dcAcroDialog.setConfigControls {
  xdid -c $hget($1,dialog.name) 2 $calc($dcAcro($hget($1,acro.obj),c1).get + 1)
  xdid -c $hget($1,dialog.name) 3 $calc($dcAcro($hget($1,acro.obj),c2).get + 1)
  if ($dcAcro($hget($1,acro.obj),list_script).get == 1) { xdid -c $hget($1,dialog.name) 4 }
  if ($dcAcro($hget($1,acro.obj),list_user).get == 1) { xdid -c $hget($1,dialog.name) 5 }
  return 1
}

/*
* speichert die Konfiguration
*
* @param $1 dcAcroDialog objekt
* @return 1
*/
alias -l dcAcroDialog.saveConfig {
  .noop $dcAcro($hget($1,acro.obj),c1,$calc($xdid($hget($1,dialog.name),2).sel - 1)).set
  .noop $dcAcro($hget($1,acro.obj),c2,$calc($xdid($hget($1,dialog.name),3).sel - 1)).set
  .noop $dcAcro($hget($1,acro.obj),list_script,$xdid($hget($1,dialog.name),4).state).set
  .noop $dcAcro($hget($1,acro.obj),list_user,$xdid($hget($1,dialog.name),5).state).set
  .noop $dcAcro($hget($1,acro.obj)).writeConfig
  .noop $dcx(MsgBox,ok exclamation modal owner $dialog($hget($1,dialog.name)).hwnd $chr(9) OK $chr(9) Konfiguration gespeichert)
  return 1
}

/*
* Wechselt die Acro Liste
*
* @param $1 dcAcroDialog objekt
* @param $2 'script' oder 'user'
* @return 1
*/
alias -l dcAcroDialog.changeAcroList {
  hadd $1 active.list $2
  hdel $1 acro.mode
  .noop $dcDialog($1,9-12).disableControls
  .noop $dcAcroDialog($1).fillAcroList

  if ($xdid($hget($1,dialog.name),8).num > 0) {
    xdid -c $hget($1,dialog.name) 8 1
    .noop $dcAcroDialog($1).selectAcro
  }
  .noop $dcAcroDialog($1).changeToolbar
  return 1
}

/*
* Liest die Daten der aktuellen Liste und füllt das Control Element mit ihnen an
*
* @param $1 dcAcroDialog objekt
* @return 1
*/
alias -l dcAcroDialog.fillAcroList {
  .noop $dcDialog($1,8-10,12).clearControls
  var %acro.listhash $dcAcro($hget($1,acro.obj),$hget($1,active.list)).getListObject
  hadd $1 acro.listhash %acro.listhash
  if (%acro.listhash) {
    .noop $dcDbsList(%acro.listhash).prepareWhile
    while ($dcDbsList(%acro.listhash).next) {
      .noop $dcAcroDialog.addUserListEntry($1,$dcDbsList(%acro.listhash).getItem,$dcDbsList(%acro.listhash).getValue)     
    }
  }
  return 1
}

/*
* Ändert die Toolbar in Abhängigkeit der Auswahl
*
* @param $1 dcAcroDialog objekt
* @return 1
*/
alias -l dcAcroDialog.changeToolbar {
  if ($hget($1,active.list) == script) {
    xdid -t $hget($1,dialog.name) 75 1 +d
    xdid -t $hget($1,dialog.name) 75 2 +d
    xdid -t $hget($1,dialog.name) 75 3 +d
    xdid -b $hget($1,dialog.name) 81
  }  
  elseif ($hget($1,active.list) == user) {
    if ($xdid($hget($1,dialog.name),8).num == 0 && $hget($1,acro.mode) == $null) {
      xdid -t $hget($1,dialog.name) 75 1 +
      xdid -t $hget($1,dialog.name) 75 2 +d
      xdid -t $hget($1,dialog.name) 75 3 +d
      xdid -b $hget($1,dialog.name) 81
    }
    elseif ($hget($1,acro.mode) == new) {
      xdid -t $hget($1,dialog.name) 75 1 +
      xdid -t $hget($1,dialog.name) 75 2 +d
      xdid -t $hget($1,dialog.name) 75 3 +d
      xdid -e $hget($1,dialog.name) 81
    }
    elseif ($hget($1,acro.mode) == edit) {
      xdid -t $hget($1,dialog.name) 75 1 +
      xdid -t $hget($1,dialog.name) 75 2 +d
      xdid -t $hget($1,dialog.name) 75 3 +d
      xdid -e $hget($1,dialog.name) 81
    }
    else {
      xdid -t $hget($1,dialog.name) 75 1 +
      xdid -t $hget($1,dialog.name) 75 2 +
      xdid -t $hget($1,dialog.name) 75 3 +
      xdid -b $hget($1,dialog.name) 81
    }
  } 
}

/*
* füllt die Edits mit den Acro Infos
*
* @param $1 dcAcroDialog objekt
* @return 1
*/
alias -l dcAcroDialog.fillAcroEditControls {
  .noop $dcDialog($1,9-10,12).clearControls
  var %tmp $xdid($hget($1,dialog.name),8,$xdid($hget($1,dialog.name),8).sel).text
  .noop $dcDbsList($hget($1,acro.listhash),$xdid($hget($1,dialog.name),8).sel).setPos
  xdid -a $hget($1,dialog.name) 9 $gettok(%tmp,1,32)
  xdid -a $hget($1,dialog.name) 10 $dcDbsList($hget($1,acro.listhash)).getValue
  xdid -a $hget($1,dialog.name) 12 $gettok(%tmp,3-,32)
  return 1
}

/*
* Ein Acro wurde Selektiert
*
* @param $1 dcAcroDialog objekt
* @return 1
*/
alias -l dcAcroDialog.selectAcro {
  .noop $dcAcroDialog($1).fillAcroEditControls
  .noop $dcDialog($1,9-12).disableControls
  hdel $1 acro.mode
  if ($xdid($hget($1,dialog.name),7).state == 1) {
    .noop $dcAcroDialog($1).changeToolbar
  }
  return 1
}

/*
* aktiviert oder deaktiviert die Option AutoStyle
*
* @param $1 dcAcroDialog objekt
* @return 1
*/
alias -l dcAcroDialog.setAutoStyle {
  if ($xdid($hget($1,dialog.name),11).state == 1) { .noop $dcAcro($hget($1,acro.obj),auto_style,1).set }
  else { .noop $dcAcro($hget($1,acro.obj),auto_style,0).set }
  .noop $dcAcroDialog($1).setPreview
  return 1
}

/*
* fügt der AcroListe einen Eintrag hinzu
*
* @param $1 dcAcroDialog objekt
* @param $2 kürzel
* @param $3 ersetzung
* @return 1
*/
alias -l dcAcroDialog.addUserListEntry {
  var %fill $str(.,$calc(10 - $len($2)))
  var %long $dcAcro($hget($1,acro.obj),$3).applyColorSettings
  xdid -a $hget($1,dialog.name) 8 0 $2 $+ $chr(32) $+ %fill $+ $chr(32) $+ %long
  return 1
}

/*
* Bereitet den Dialog zum Hinzufügen eines neuen Acros vor
*
* @param $1 dcAcroDialog objekt
* @return 1
*/
alias -l dcAcroDialog.newAcro {
  .noop $dcDialog($1,9-10,12).clearControls
  .noop $dcDialog($1,9-12).enableControls
  hadd $1 acro.mode new
  .noop $dcAcroDialog($1).changeToolbar
  return 1
}

/*
* Bereitet den Dialog zum Bearbeiten eines Acros vor
*
* @param $1 dcAcroDialog objekt
* @return 1
*/
alias -l dcAcroDialog.editAcro {
  .noop $dcDialog($1,9-12).enableControls
  hadd $1 acro.mode edit
  .noop $dcAcroDialog($1).changeToolbar
  return 1
}

/*
* Speichert ein Acro
*
* @param $1 dcAcroDialog objekt
* @return 1
*/
alias -l dcAcroDialog.saveAcro {
  if ($hget($1,acro.mode) == new) {
    if ($dcAcro($hget($1,acro.obj),$xdid($hget($1,dialog.name),9).text,$xdid($hget($1,dialog.name),10).text).newAcro) {
      .noop $dcAcroDialog($1).fillAcroList
      .noop $dcDialog($1,9-10,12).clearControls
      xdid -F $hget($1,dialog.name) 9
    }
    else {
      .noop $dcError($dcAcro($hget($1,acro.obj)).getErrorObject,$dialog($hget($1,dialog.name)).hwnd).showDialog
    }
  }
  elseif ($hget($1,acro.mode) == edit) {
    if ($dcAcro($hget($1,acro.obj),$xdid($hget($1,dialog.name),8).sel,$xdid($hget($1,dialog.name),9).text,$xdid($hget($1,dialog.name),10).text).editAcro) {
      var %sel $xdid($hget($1,dialog.name),8).sel
      .noop $dcAcroDialog($1,user).changeAcroList
      xdid -c $hget($1,dialog.name) 8 %sel
    }
    else {
      .noop $dcError($dcAcro($hget($1,acro.obj)).getErrorObject,$dialog($hget($1,dialog.name)).hwnd).showDialog
    }
  }
}

/*
* Löscht ein Acro
*
* @param $1 dcAcroDialog objekt
* @return 1
*/
alias -l dcAcroDialog.delAcro {
  var %sel $xdid($hget($1,dialog.name),8).sel
  if ($dcAcro($hget($1,acro.obj),$gettok($xdid($hget($1,dialog.name),8,%sel).text,1,32)).delAcro) { 
    xdid -d $hget($1,dialog.name) 8 %sel
    if ($xdid($hget($1,dialog.name),8).num == 0) {
      .noop $dcDialog($1,9-10,12).clearControls
    }
    elseif (%sel > $xdid($hget($1,dialog.name),8).num) {
      xdid -c $hget($1,dialog.name) 8 $xdid($hget($1,dialog.name),8).num
      .noop $dcAcroDialog($1).selectAcro
    }
    else {
      xdid -c $hget($1,dialog.name) 8 %sel
      .noop $dcAcroDialog($1).selectAcro
    }
    .noop $dcx(MsgBox,ok exclamation modal owner $dialog($hget($1,dialog.name)).hwnd $chr(9) OK $chr(9) Acro erfolgreich gelöscht)
  }
  else {
    .noop $dcx(MsgBox,ok error modal owner $dialog($hget($1,dialog.name)).hwnd $chr(9) Fehler $chr(9) Acro konnte nicht gelöscht werden)
  }
}

/*
* Setzt den Preview
*
* @param $1 dcAcroDialog objekt
* @return 1
*/
alias -l dcAcroDialog.setPreview {
  if ($xdid($hget($1,dialog.name),11).state == 1) {
    var %tmp $dcAcro($hget($1,acro.obj),$xdid($hget($1,dialog.name),10).text).applyDefaultStyle  
  }
  else {
    var %tmp $xdid($hget($1,dialog.name),10).text
  }
  if (%tmp != $null) {
    xdid -ra $hget($1,dialog.name) 12 $dcAcro($hget($1,acro.obj),%tmp).applyColorSettings
  }
  else {
    xdid -r $hget($1,dialog.name) 12
  }
}

/*
* Lädt die Standard Config
*
* @param $1 dcAcroDialog objekt
* @return 1
*/
alias -l dcAcroDialog.loadDefaults {
  if ($dcAcro($hget($1,acro.obj)).loadDefaults) {
    .noop $dcAcroDialog($1).setConfigControls
  }
  return 1
}

/*
* Wird durch den Config-Dialog aufgerufen, initalisiert den Dialog
*
* @param $1 dcConfig objekt
*/
alias dc.acro.createPanel {
  set %dc.acro.dialog.obj $dcAcroDialog($dcConfig($1,dialog.name).get,$dcConfig($1,currentPanel.dbhash).get)
}

/*
* Wird durch den Config-Dialog aufgerufen, zerstört den Dialog
*/
alias dc.acro.destroyPanel {
  .noop $dcAcroDialog(%dc.acro.dialog.obj).destroy
  unset %dc.acro.*
  dc.acro.initGlobalAcroList
}

/*
* Verwaltet Dialog-Ereignisse wie Mausklicks, Tastatureingaben, ...
*
* @param $1 DialogName
* @param $2 Ereignis
* @param $3 Betroffene ID
* @param $4 sonstiges
*/
alias dc.acro.events { 
  if ($2 == sclick) {
    if ($3 == 6) { .noop $dcAcroDialog(%dc.acro.dialog.obj,script).changeAcroList }
    elseif ($3 == 7) { .noop $dcAcroDialog(%dc.acro.dialog.obj,user).changeAcroList }
    elseif ($3 == 8) { .noop $dcAcroDialog(%dc.acro.dialog.obj).selectAcro }
    elseif ($3 == 75) {
      if ($4 == 1) { .noop $dcAcroDialog(%dc.acro.dialog.obj).newAcro }
      elseif ($4 == 2) { .noop $dcAcroDialog(%dc.acro.dialog.obj).editAcro }
      elseif ($4 == 3) { .noop $dcAcroDialog(%dc.acro.dialog.obj).delAcro }
    }
    elseif ($3 == 11) { .noop $dcAcroDialog(%dc.acro.dialog.obj).setAutoStyle }
    elseif ($3 == 80) { .noop $dcAcroDialog(%dc.acro.dialog.obj).saveConfig }
    elseif ($3 == 81) { .noop $dcAcroDialog(%dc.acro.dialog.obj).saveAcro }
  }
  elseif ($2 == keyup && $3 == 10 && $4 == 13) { .noop $dcAcroDialog(%dc.acro.dialog.obj).saveAcro }
  elseif ($2 == keyup && $3 == 10) { .noop $dcAcroDialog(%dc.acro.dialog.obj).setPreview }

}

/*
* Lädt die Standard Einstellung
*/
alias dc.acro.loadDefaults {
  .noop $dcAcroDialog(%dc.acro.dialog.obj).loadDefaults
}

/*
* Erstllt eine Globale Acro Liste
*/
alias dc.acro.initGlobalAcroList {
  .hfree -w acrolist
  hmake acrolist 100
  var %acro $dcAcro()
  if ($dcAcro(%acro,list_script).get == 1) {
    .noop $dcDbsList($dcAcro(%acro,script).getListObject).prepareWhile
    while ($dcDbsList($dcAcro(%acro,script).getListObject).next) {
      hadd acrolist $dcDbsList($dcAcro(%acro,script).getListObject).getItem $dcAcro(%acro,$dcDbsList($dcAcro(%acro,script).getListObject).getValue).applyColorSettings
    }
  }

  if ($dcAcro(%acro,list_user).get == 1) {
    .noop $dcDbsList($dcAcro(%acro,user).getListObject).prepareWhile
    while ($dcDbsList($dcAcro(%acro,user).getListObject).next) {
      hadd acrolist $dcDbsList($dcAcro(%acro,user).getListObject).getItem $dcAcro(%acro,$dcDbsList($dcAcro(%acro,user).getListObject).getValue).applyColorSettings
    }
  }
  .noop $dcAcro(%acro).destroy
}

/*
* Bearbeitet die Eingabe
*
* @param $1 hashtable
*/
alias dc.acro.onInput {
  var %tmp $hget($1,text)
  var %i 1
  while (%i <= $numtok(%tmp,32)) {
    var %current $gettok(%tmp,%i,32)
    if ($hget(acrolist,%current) != $null) { var %tmp $puttok(%tmp,$hget(acrolist,%current),%i,32) }
    elseif (%current !isalnum) {
      var %j $len(%current)
      while (%j >= 1) {
        if ($mid(%current,%j,1) isalnum) {
          if ($left(%current,%j) isalnum) {
            if ($hget(acrolist,$left(%current,%j)) != $null) {
              var %tmp $puttok(%tmp,$hget(acrolist,$left(%current,%j)) $+ $mid(%current,$calc(%j + 1)),%i,32) 
            }
          }
          break
        }
        dec %j
      }
    }
    inc %i
  }
  hadd $1 text %tmp
}

alias dc.acro.load { dc.acro.initGlobalAcroList }

alias dc.acro.unload { .hfree -w acrolist }

menu channel,status {
  DragoonCore
  .Modul Konfiguartion
  ..Acro:/config_modul acro
}

menu menubar {
  Modul Konfiguartion
  .Acro:/config_modul acro
}