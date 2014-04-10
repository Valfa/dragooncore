/*
* DragoonCore Auto Identify
*
* @author Valfa
* @version 1.0
*
* Führt automatisch Nickserv Identifies durch
*/

/*
* Class Alias
* var %var $dcAutoIdent
*
* @param $1 Datenbank hash (optional)
*/
alias dcAutoIdent {
  var %this = dcAutoIdent           | ; Name of Object (Alias name)
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
  return $dcAutoIdent.init(%x,$1)

  :destroy
  return $dcAutoident.destroy($1)

  :writeConfig
  return $dcAutoIdent.writeConfig($1,$2,$3)

  :checkConfig
  return $dcAutoIdent.checkConfig($1,$2,$3)

  :getErrorObject
  return $hget($1,error.obj)

  :addNickGroup
  return $dcAutoIdent.addNickGroup($1,$2,$3)

  :checkNickGroup
  return $dcAutoIdent.checkNickGroup($1,$2,$3)

}

/*
* Erzeugt ein AutoIdentify-Objekt
*
* @param $1 dcAutoIdent objekt
* @param $2 dcdbs hash (optional)
* @return dcAutoIdent objekt
*/
alias -l dcAutoIdent.init {
  if ($2 == $null || $hget($2,database) != modul_auto_identify) { 
    var %db $dcdbs(modul_auto_identify)
    hadd %db createDB 1
  }
  else {
    var %db $2
    hadd %db createDB 0
  }
  hadd $1 dbhash %db
  .noop $dcdbs(%db,config).setSection
  var %pwd $dcdbs(%db,pwd).getUserValue
  var %connect $dcdbs(%db,connect).getUserValue
  if (%pwd == $null) { var %pwd $dcdbs(%db,pwd).getScriptValue }
  if (%connect == $null) { var %connect $dcdbs(%db,connect).getScriptValue }
  hadd $1 config.pwd $decryptValue(%pwd)
  hadd $1 config.connect %connect
  hadd $1 error.obj $dcError
  hadd $1 limit_vars config.pwd,config.connect

  return $1
}

/*
* Vernichtet ein dcAutoIdent Objekt
*
* @param $1 dcautoident objekt
* @return 1
*/
alias -l dcAutoIdent.destroy {
  if ($hget($1,createDB) == 1) {
    .noop $dcdbs($hget($1,dbhash)).destroy
  }
  .noop $dcError($hget($1,error.obj)).destroy
  .noop $dcBase($1).destroy
  return 1
}

/*
* Speichert die aktuelle Konfiguartion
*
* @param $1 dcAutoIdent objekt
* @param $2 pwd
* @param $3 connect
* @return 1 oder 0
*/
alias -l dcAutoIdent.writeConfig {
  if ($dcAutoIdent($1,$2,$3).checkConfig) {    
    .noop $dcdbs($hget($1,dbhash),config).setSection
    if ($2 != $null) { .noop $dcdbs($hget($1,dbhash),pwd,$encryptValue($2)).setUserValue | hadd $1 config.pwd $2 }
    else { .noop $dcdbs($hget($1,dbhash),pwd).deleteUserItem | hdel $1 config.pwd }
    .noop $dcdbs($hget($1,dbhash),connect,$3).setUserValue | hadd $1 config.connect $3

    return 1
  }
  else {
    return 0
  }
}

/*
* Prüft die Konfiguartion vor dem speichern
*
* @param $1 dcAutoIdent objekt
* @param $2 pwd
* @param $3 connect
* @return 1 oder 0
*/
alias -l dcAutoIdent.checkConfig {
  .noop $dcError($hget($1,error.obj)).clear
  if ($regex(regex,$2,[[:space:]])) {
    .noop $dcError($hget($1,error.obj),Passwort darf keine Leerzeichen enthalten).add
  }

  if ($dcError($hget($1,error.obj)).count > 0) {
    return 0
  }
  else {
    return 1
  }
}

/*
* Fügt eine neue NickGruppe hinzu
*
* @param $1 dcautoident objekt
* @param $2 nick
* @param $3 pwd
* @return 1 oder 0
*/
alias -l dcAutoIdent.addNickGroup {
  if ($dcAutoIdent($1,$2,$3).checkNickGroup) {

    return 1
  }
  else {
    return 0
  }
}

/*
* Überprüft eine Nick Gruppe
*
* @param $1 dcautoident objekt
* @param $2 nick
* @param $3 pwd
* @return 1 oder 0
*/
alias -l dcAutoIdent.checkNickGroup {
  .noop $dcerror($hget($1,error.obj)).clear

  if ($regex(regex,$2,[[:space:]])) {
    .noop $dcError($hget($1,error.obj),Nick darf keine Leerzeichen enthalten).add
  }
  elseif







  if ($regex(regex,$3,[[:space:]])) {
    .noop $dcError($hget($1,error.obj),Passwort darf keine Leerzeichen enthalten).add
  }

  if ($dcError($hget($1,error.obj)).count > 0) {
    return 0
  }
  else {
    return 1
  }
}

/*
* Class Alias
* var %var $dcAutoIdentDialog
*
* @param $1 Datenbank hash (optional)
*/
alias dcAutoIdentDialog {
  var %this = dcAutoIdentDialog           | ; Name of Object (Alias name)
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
  return $dcAutoIdentDialog.init(%x,$1,$2)

  :destroy
  return $dcAutoidentDialog.destroy($1)

  :createControls
  return $dcAutoIdentDialog.createControls($1)

  :setConfig
  return $dcAutoIdentDialog.setConfig($1)

  :saveConfig
  return $dcAutoIdentDialog.saveConfig($1)

  :addNickGroup
  return $dcAutoidentDialog.addNickGroup($1)
}

/*
* Initialisiert den Acro Dialog
*
* @param $1 acro Dialog Objekt
* @param $2 db hash
* @param $3 dialog name oder $null
* @return $1
*/
alias -l dcAutoIdentDialog.init {
  hadd $1 ident.obj $dcAutoIdent($2)
  if ($3 != $null) { hadd $1 dialog.name $3 }
  else { hadd $1 dialog.name dcAutoIdent }

  .noop $dcDialog($1,435,540).createBasePanel
  .noop $dcAutoIdentDialog($1).createControls
  .noop $dcAutoIdentDialog($1).setConfig


  return $1
}

/*
* Zerstört ein dcAutoidentDialog objekt
*
* @param $1 dcAutoIdentDialog objekt
* @return 1
*/
alias -l dcAutoidentDialog.destroy {
  .noop $dcAutoident($hget($1,ident.obj)).destroy
  .noop $dcDialog($1).destroy
  return 1
}

/*
* Erstellt die Bedienelemente
*
* @param $1 dcAutoidentDialog objekt
* @return 1
*/
alias -l dcAutoIdentDialog.createControls {
  xdid -c $hget($1,dialog.name) 1 100 text 0 0 200 25
  xdid -t $hget($1,dialog.name) 100 Auto Identify
  xdid -f $hget($1,dialog.name) 100 + default 14 Arial

  xdid -c $hget($1,dialog.name) 1 101 text 5 25 100 20
  xdid -t $hget($1,dialog.name) 101 Einstellungen
  xdid -f $hget($1,dialog.name) 101 + default 10 Verdana

  xdid -c $hget($1,dialog.name) 1 102 text 5 50 130 20 right
  xdid -t $hget($1,dialog.name) 102 Standard Passwort:
  xdid -c $hget($1,dialog.name) 1 2 edit 140 50 295 20 autohs password tabstop

  xdid -c $hget($1,dialog.name) 1 3 check 5 70 149 20 right rjustify
  xdid -t $hget($1,dialog.name) 3 Auto Identify bei Connect: 

  xdid -c $hget($1,dialog.name) 1 80 button 335 70 100 20
  xdid -t $hget($1,dialog.name) 80 Speichern

  xdid -c $hget($1,dialog.name) 1 103 text 5 100 100 20
  xdid -t $hget($1,dialog.name) 103 Nick Liste
  xdid -f $hget($1,dialog.name) 103 + default 10 Verdana

  xdid -c $hget($1,dialog.name) 1 75 toolbar 5 120 175 30 flat list nodivider noauto tooltips
  xdid -l $hget($1,dialog.name) 75 24
  xdid -w $hget($1,dialog.name) 75 +nh 0 images/ico/page_white_stack.ico
  xdid -w $hget($1,dialog.name) 75 +nh 0 images/ico/page_white_add.ico
  xdid -w $hget($1,dialog.name) 75 +nh 0 images/ico/page_white_edit.ico
  xdid -w $hget($1,dialog.name) 75 +nh 0 images/ico/page_white_delete.ico

  xdid -w $hget($1,dialog.name) 75 +dhg 0 images/ico/page_white_stack.ico  
  xdid -w $hget($1,dialog.name) 75 +dhg 0 images/ico/page_white_add.ico
  xdid -w $hget($1,dialog.name) 75 +dhg 0 images/ico/page_white_edit.ico
  xdid -w $hget($1,dialog.name) 75 +dhg 0 images/ico/page_white_delete.ico

  xdid -a $hget($1,dialog.name) 75 1 +l 30 1 $chr(9) Nick/Nick Gruppe erstellen
  xdid -a $hget($1,dialog.name) 75 2 +ld 30 2 $chr(9) Nick hinzufügen
  xdid -a $hget($1,dialog.name) 75 3 +ld 30 3 $chr(9) Nick bearbeiten
  xdid -a $hget($1,dialog.name) 75 4 +ld 30 4 $chr(9) Nick löschen

  xdid -c $hget($1,dialog.name) 1 4 treeview 5 150 175 390 hasbuttons haslines showsel

  xdid -c $hget($1,dialog.name) 1 104 text 190 100 100 20
  xdid -t $hget($1,dialog.name) 104 Nicks
  xdid -f $hget($1,dialog.name) 104 + default 10 Verdana

  xdid -c $hget($1,dialog.name) 1 105 text 190 130 100 20
  xdid -t $hget($1,dialog.name) 105 Nick:
  xdid -c $hget($1,dialog.name) 1 5 edit 190 150 245 20 autohs tabstop disabled

  xdid -c $hget($1,dialog.name) 1 106 text 190 180 100 20
  xdid -t $hget($1,dialog.name) 106 Passwort:
  xdid -c $hget($1,dialog.name) 1 6 edit 190 200 245 20 autohs tabstop password disabled

  xdid -c $hget($1,dialog.name) 1 81 button 265 230 100 20 disabled
  xdid -t $hget($1,dialog.name) 81 Speichern

  return 1
}

/*
* Setzt die Config-BedienElemente
*
* @param $1 dcAutoIdentDialog objekt
* @return 1
*/
alias -l dcAutoIdentDialog.setConfig {
  if ($dcAutoIdent($hget($1,ident.obj),config.pwd).get != $null) { xdid -a $hget($1,dialog.name) 2 $dcAutoIdent($hget($1,ident.obj),config.pwd).get }
  if ($dcAutoIdent($hget($1,ident.obj),config.connect).get == 1) { xdid -c $hget($1,dialog.name) 3 }
  return 1
}

/*
* Speichert die Konfiguartion
*
* @param $1 dcAutoIdentDialog objekt
* @return 1 oder 0
*/
alias -l dcAutoIdentDialog.saveConfig {
  ;  .noop $dcAutoident($hget($1,ident.obj),config.pwd,$xdid($hget($1,dialog.name),2).text).set
  ;  .noop $dcAutoIdent($hget($1,ident.obj),config.connect,$xdid($hget($1,dialog.name),3).state).set
  if ($dcAutoIdent($hget($1,ident.obj),$xdid($hget($1,dialog.name),2).text,$xdid($hget($1,dialog.name),3).state).writeConfig) {
    .noop $dcx(MsgBox,ok exclamation modal owner $dialog($hget($1,dialog.name)).hwnd $chr(9) OK $chr(9) Konfiguartion gesichert)
    return 1
  }
  else {
    .noop $dcError($dcAutoident($hget($1,ident.obj)).getErrorObject,$dialog($hget($1,dialog.name)).hwnd).showDialog
    return 0
  }
}

/*
* Bereitet die BedienElemnte für das Hinzufügen einer neuen NickGruppe vor
*
* @param $1 dcautoidentDialog objekt
* @return 1
*/
alias -l dcAutoidentDialog.addNickGroup {
  .noop $dcDialog($1,5-6,81).enableControls
  hadd $1 ident.mode add
  return 1
}

/*
* Speichert die Aktuelle NickGruppe
*
* @param $1 dcAcroIdentDialog objekt
* @return 1 oder 0
*/
alias -l dcAutoidentDialog.saveNickGroup {
  if ($dcAutoIdent($hget($1,ident.obj),$xdid($hget($1,dialog.name),5).text,$xdid($hget($1,dialog.name),6).text).addNickGroup) {
    .noop $dcx(MsgBox,ok exclamation modal owner $dialog($hget($1,dialog.name)).hwnd $chr(9) OK $chr(9) Nick gespeichert)
    return 1
  }
  else {
    .noop $dcError($dcAutoident($hget($1,ident.obj)).getErrorObject,$dialog($hget($1,dialog.name)).hwnd).showDialog
    return 0
  }
}











/*
* Wird durch den Config-Dialog aufgerufen, initalisiert den Dialog
*
* @param $1 dcConfig objekt
*/
alias dc.autoIdentify.createPanel { 
  set %dc.autoIdent.dialog.obj $dcAutoIdentDialog($dcConfig($1,currentPanel.dbhash).get,$dcConfig($1,dialog.name).get)
}

/*
* Wird durch den Config-Dialog aufgerufen, zerstört den Dialog
*/
alias dc.autoIdentify.destroyPanel { 
  .noop $dcAutoidentDialog(%dc.autoIdent.dialog.obj).destroy
}

/*
* Verwaltet Dialog-Ereignisse wie Mausklicks, Tastatureingaben, ...
*
* @param $1 DialogName
* @param $2 Ereignis
* @param $3 Betroffene ID
* @param $4 sonstiges
*/
alias dc.autoIdentify.events { 
  if ($2 == sclick) {
    if ($3 == 75) {
      if ($4 == 1) { .noop $dcAutoidentDialog(%dc.autoIdent.dialog.obj).addNickGroup }
    }
    if ($3 == 80) { .noop $dcAutoIdentDialog(%dc.autoIdent.dialog.obj).saveConfig }
  }
}
