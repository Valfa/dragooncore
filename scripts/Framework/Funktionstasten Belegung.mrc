/*
* Funktionstastenbelegung für das DragoonCore Framework
*
* @author Valfa
* @version 1.0
*
* Verwaltet die Funktionstasten belegungen
*/

/*
* Class Alias
* var %var $fkeyList
*
* param $1 dcDbs objekt
*/
alias dcFkeyList {
  var %this = dcFkeyList           | ; Name of Object (Alias name)
  var %base = dcList        | ; Name of BaseClass, $null for none  

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
  var %x $dcList(%this,%base).init
  return $dcFkeyList.init(%x,$1)

  :isDisabled
  return $hget($1,isDisabled)

  :isSet
  return $hget($1,isSet)

  :fkey
  return $hget($1,fkey)

  :group
  return $hget($1,group)

  :command 
  return $hget($1,command)

  :command_line
  return $hget($1,command_line)
  
  :destroy
  return $dcFkeyList.destroy($1)
}

/*
* Initialisiert die Liste
*
* @param $1 dcFkeyList objekt
* @param $2 dcDbs objekt
* @return dcFkeyList objekt
*/
alias -l dcFkeyList.init {
  hadd $1 pos 1
  hadd $1 last 36
  hadd $1 list $dcDbsList($2,user,__key_assignments__)
  hadd $1 dbhash $2
  hadd $1 getdata 1
  .noop $dcFkeyList.getData($1)
  return $1
}

/*
* Löscht ein dcFkeyList objekt
*
* @param $1 dcFkeyList objekt
* @return 1
*/
alias -l dcFkeyList.destroy {
  .noop $dcDbsList($hget($1,list)).destroy
  .noop $dcBase($1).destroy
  return 1
}

/*
* Ermittelt die Daten für eine Taste
*
* @param $1 dcFkeyList objekt
* @return 1
*/
alias dcFkeyList.getData {
  .noop $dcDbsList($hget($1,list),$hget($1,pos)).setPos
  hadd $1 current_item $dcDbsList($hget($1,list)).getItem
  var %tmp $dcDbsList($hget($1,list)).getValue
  hadd $1 current_value %tmp
  if (%tmp == 0) {
    hadd $1 isSet 0
    ;hadd $1 isDisabled $dcFkeyList($1,$dcDbsList($hget($1,list)).getItem).isDisabled
    hadd $1 isDisabled $iif($dcDbs($hget($1,dbhash),__disabled__,$dcDbsList($hget($1,list)).getItem).getScriptValue != $null,1,0)
    hadd $1 fkey $dcDbsList($hget($1,list)).getItem
    hadd $1 group $null
    hadd $1 command $null
    hadd $1 command_line $null
  }
  else {
    hadd $1 isSet 1
    hadd $1 fkey $dcDbsList($hget($1,list)).getItem
    hadd $1 group $gettok(%tmp,1,44)
    if ($gettok(%tmp,1,44) == __user__) {
      hadd $1 group Benutzer
      hadd $1 command $null
      hadd $1 command_line $gettok(%tmp,3,44)
    }
    else {
      if ($left($gettok(%tmp,2,44),1) == s) {
        var %cmd_tmp $dcDbs($hget($1,dbhash),$gettok(%tmp,1,44),$gettok(%tmp,2,44)).getScriptValue
      }
      else {
        var %cmd_tmp $dcDbs($hget($1,dbhash),$gettok(%tmp,1,44),$gettok(%tmp,2,44)).getValue
      }
      hadd $1 command $gettok(%cmd_tmp,1,44)
      hadd $1 command_line $gettok(%cmd_tmp,2,44)
    }
  }

  return 1
}

/*
* Prüft ob ein TastenBelegung Deaktiviert ist
*
* @param $1 dcFkeyList objekt
* @param $2 Taste(n)
* @return 1 (deaktiviert) oder 0 (aktiv)
*/
alias -l dcFkeyList.isDisabled {
  if ($dcDbs($hget($1,dbhash),__disabled__,$2).getScriptValue != $null) {
    return 1
  }
  else {
    return 0
  }
}

/*
* Class Alias
* var %var $dcFkey
*
* @param $1 Datenbank objekt (optional)
*/
alias dcFkey {
  var %this = dcFkey           | ; Name of Object (Alias name)
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
  return $dcFkey.init(%x,$1)

  :destroy
  return $dcFkey.destroy($1)

  :getGroups
  return $dcFkey.getGroups($1)

  :getGroupCommands
  return $dcFkey.getGroupCommands($1,$2)

  :saveKeyScript
  return $dcFkey.saveKeyScript($1,$2,$3,$4)

  :saveKeyUser
  return $dcFkey.saveKeyuser($1,$2,$3-)

  :getErrorObject
  return $hget($1,error.obj)

  :delKey
  return $dcFkey.delKey($1,$2)
  
  :evalKey
  return $dcFkey.evalKey($1,$2)
  
  :createUserList
  return $dcFkey.createUserList($1)

}

/*
* Initialisiert ein dcFkey objekt
*
* @param $1 dcFkey objekt
* @param $2 dcDbs objekt
* @return dcFkey objekt
*/
alias -l dcFkey.init {
  if ($2 == $null || $hget($2,database) != fw_fkey) { 
    var %db $dcDbs(fw_fkey)
    hadd %db createDB 1
  }
  else {
    var %db $2
    hadd %db createDB 0
  }
  hadd $1 dbhash %db
  
  .noop $dcFkey($1).createUserList

  hadd $1 fkeylist $dcFkeyList(%db)
  hadd $1 grouplist $dcList
  hadd $1 commandlist $dcList
  hadd $1 error.obj $dcError

  .noop $dcFkey($1).getGroups

  hadd $1 limit_get fkeylist,grouplist,commandlist,dbhash

  return $1
}

/*
* Zerstört ein dcFkey objekt
*
* @param $1 dcFkey objekt
* @return 1
*/
alias -l dcFkey.destroy {
  if ($hget($1,createDB) == 1) {
    .noop $dcDbs($hget($1,dbhash)).destroy
  }
  .noop $dcFkeyList($hget($1,fkeylist)).destroy
  .noop $dcList($hget($1,grouplist)).destroy
  .noop $dcList($hget($1,commandlist)).destroy
  .noop $dcList($hget($1,error.obj)).destroy
  .noop $dcBase($1).destroy
  return 1
}

/*
* Kopiert die vorgaben Liste in die User db, falls nicht vorhanden
*
* @param $1 $dcFkey objekt
* @return 1
*/
alias -l dcFkey.createUserList {
  if (!$dcDbsList($hget($1,dbhash),user,__key_assignments__)) {
    var %list $dcDbsList($hget($1,dbhash),script,__key_assignments__)
    .noop $dcDbsList(%list).prepareWhile
    .noop $dcDbs($hget($1,dbhash),section,__key_assignments__).set
    while ($dcDbsList(%list).next) {
      .noop $dcDbs($hget($1,dbhash),$dcDbsList(%list).getItem,$dcDbsList(%list).getValue).setValue
    }
    .noop $dcDbsList(%list).destroy
  }
  
  return 1
}

/*
* Ermittelt die Befehls-Gruppen
*
* @param $1 dcFkey objekt
* @return 1
*/
alias -l dcFkey.getGroups {
  var %list $dcDbsList($hget($1,dbhash),script,__groups__)
  if (%list) {
    .noop $dcDbsList(%list).prepareWhile
    while ($dcDbsList(%list).next) {
      .noop $dcList($hget($1,grouplist),$dcDbsList(%list).getItem $+ $chr(44) $+ script).addLastElement
    }
    .noop $dcDbsList(%list).destroy
  }
  var %list $dcDbsList($hget($1,dbhash),user,__groups__)
  if (%list) {
    .noop $dcDbsList(%list).prepareWhile
    while ($dcDbsList(%list).next) {
      .noop $dcList($hget($1,grouplist),$dcDbsList(%list).getItem $+ $chr(44) $+ user).addLastElement
    }
    .noop $dcDbsList(%list).destroy
  }
  return 1
}

/*
* Liest die Befehle für eine Gruppe aus
*
* @param $1 dcfkey objekt
* @param $2 gruppe
* @return 1
*/
alias -l dcFkey.getGroupCommands {
  .noop $dcList($hget($1,commandlist)).clear
  var %find $hfind($hget($1,grouplist),$2*,1,w).data
  var %list $dcDbsList($hget($1,dbhash),$gettok($hget($hget($1,grouplist),%find),2,44),$2)
  .noop $dcDbsList(%list).prepareWhile
  while ($dcDbsList(%list).next) {
    .noop $dcList($hget($1,commandlist),$gettok($dcDbsList(%list).getValue,1,44)).addLastElement
  }
  .noop $dcDbsList(%list).destroy
  return 1
}

/*
* Speichert eine Zuweisung mit Script Vorgaben
*
* @param $1 dcFkey objekt
* @param $2 Tastenkürzel
* @param $3 Gruppen-nr
* @param $4 item-nr
* @return 1 oder 0
*/
alias -l dcFkey.saveKeyScript {
  var %group $gettok($hget($hget($1,grouplist),n $+ $3),1,44)
  var %id $left($gettok($hget($hget($1,grouplist),n $+ $3),2,44),1) $+ $4
  .noop $dcDbs($hget($1,dbhash),__key_assignments__,$2,%group $+ $chr(44) $+ %id).setValue
  return 1
}

/*
* Speichert eine Zuweisung mit User Vorgaben
*
* @param $1 dcFkey objekt
* @param $2 Tastenkürzel
* @param $3- Befehl
* @return 1 oder 0
*/
alias -l dcFkey.saveKeyUser {
  .noop $dcError($hget($1,error.obj)).clear
  if (!$dcCheck($3-).addSpace) {
    .noop $dcError($hget($1,error.obj),Eingabe enthält unzulässige Leerzeichen).add
  }

  if ($dcError($hget($1,error.obj)).count > 0) {
    return 0
  }
  else {
    .noop $dcDbs($hget($1,dbhash),__key_assignments__,$2,__user__ $+ $chr(44) $+ u0 $+ $chr(44) $+ $3-).setValue
    return 1
  }
}

/*
* Löscht eine Zuweisung / setzt diese auf 0
*
* @param $1 dcFkey objekt
* @return 1
*/
alias -l dcfkey.delKey {
  .noop $dcDbs($hget($1,dbhash),__key_assignments__,$2,0).setValue
  return 1
}

/*
* Führt einen hinterlegten Befehl aus
*
* @param $1 dcFkey objekt
* @param $2 tasten kürzel
* @return Befehlszeile
*/
alias -l dcFkey.evalKey {
  var %keynr $dcDbs($hget($1,dbhash),__key_assignments__,$2).getItem
  .noop $dcFkeyList($hget($1,fkeylist),%keynr).setPos
  return $dcFkeyList($hget($1,fkeylist)).command_line
}

/*
* Class Alias
* var %var $dcFkeyDialog
*
* @param $1 dialog name
* @param $2 Datenbank hash (optional)
*/
alias dcFkeyDialog {
  var %this = dcFkeyDialog           | ; Name of Object (Alias name)
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
  return $dcFkeyDialog.init(%x,$1,$2)

  :destroy
  return $dcFkeyDialog.destroy($1)

  :createControls
  return $dcFkeyDialog.createControls($1)

  :fillFkeyList
  return $dcFkeyDialog.fillFkeyList($1)

  :fillGroupList
  return $dcFkeyDialog.fillGroupList($1)

  :fillGroupCommands
  return $dcFkeyDialog.fillGroupCommands($1)

  :sclickFkeyList
  return $dcFKeyDialog.sclickFKeyList($1)

  :changeInputScript
  return $dcFkeyDialog.changeInputScript($1)

  :changeInputUser
  return $dcFkeyDialog.changeInputUser($1)

  :saveKey
  return $dcFkeyDialog.saveKey($1)

  :editUserBox
  return $dcFkeyDialog.editUserBox($1)

  :delkey
  return $dcFkeyDialog.delKey($1)
}

/*
* Initialisiert ein dcFkeyDialog objekt
*
* @param $1 dcFkeydialog objekt
* @param $2 dialog name
* @param $3 dcDbs objekt
* @return dcFkeyDialog objekt
*/
alias -l dcFkeyDialog.init {
  hadd $1 fkey.obj $dcFkey($3)
  if ($2 != $null) { hadd $1 dialog.name $2 }
  else { hadd $1 dialog.name dcFkey }

  .noop $dcDialog($1,435,540).createBasePanel
  .noop $dcFkeyDialog($1).createControls
  .noop $dcFkeyDialog($1).fillFkeyList
  .noop $dcFkeyDialog($1).fillGroupList

  return $1
}

/*
* Zerstört ein dcFkeyDialog objekt
*
* @param $1 dcFkeyDialog objekt
* @return 1
*/
alias -l dcFkeyDialog.destroy {
  .noop $dcFkey($hget($1,fkey.obj)).destroy
  .noop $dcBase($1).destroy
  return 1
}

/*
* Erstellt die BedienElemente
*
* @param $1 dcFkeyDialog objekt
* @return 1
*/
alias -l dcFkeyDialog.createControls {
  xdid -c $hget($1,dialog.name) 1 100 text 0 0 225 25
  xdid -t $hget($1,dialog.name) 100 Funktionstasten Belegung
  xdid -f $hget($1,dialog.name) 100 + default 14 Arial

  xdid -c $hget($1,dialog.name) 1 2 listview 0 25 435 250 report fullrow grid noheadersort showsel singlesel
  xdid -t $hget($1,dialog.name) 2 +l 0 60 Taste(n) $chr(9) +l 0 100 Gruppe $chr(9) +l 0 150 Befehl $chr(9) +l 0 120 Kommando

  xdid -c $hget($1,dialog.name) 1 10 radio 0 285 200 20 disabled
  xdid -t $hget($1,dialog.name) 10 Script/Modul Vorgabe
  xdid -f $hget($1,dialog.name) 10 + default 10 Verdana

  xdid -c $hget($1,dialog.name) 1 101 text 0 315 40 20
  xdid -t $hget($1,dialog.name) 101 Gruppe
  xdid -c $hget($1,dialog.name) 1 3 comboex 45 310 170 300 dropdown disabled
  xdid -c $hget($1,dialog.name) 1 102 text 220 315 40 20
  xdid -t $hget($1,dialog.name) 102 Befehl
  xdid -c $hget($1,dialog.name) 1 4 comboex 265 310 170 300 dropdown disabled

  xdid -c $hget($1,dialog.name) 1 11 radio 0 340 200 20 disabled
  xdid -t $hget($1,dialog.name) 11 Benutzer Vorgabe
  xdid -f $hget($1,dialog.name) 11 + default 10 Verdana

  xdid -c $hget($1,dialog.name) 1 7 edit 0 365 435 20 disabled

  xdid -c $hget($1,dialog.name) 1 5 button 50 400 150 20 disabled
  xdid -t $hget($1,dialog.name) 5 Zuweisung Speichern
  xdid -c $hget($1,dialog.name) 1 6 button 235 400 150 20 disabled
  xdid -t $hget($1,dialog.name) 6 Zuweisung Löschen

  return 1
}

/*
* Füllt die TastenBelegungsübersicht
*
* @param $1 dcFkeyDialog objekt
* @return 1
*/
alias -l dcFkeyDialog.fillFkeyList {
  var %list $dcFkey($hget($1,fkey.obj),fkeylist).get
  .noop $dcFkeyList(%list).prepareWhile
  while ($dcFkeyList(%list).next) {
    var %key $replacex($upper($dcFkeyList(%list).fkey),C, Strg + $chr(32),S,Shift + $chr(32))
    if ($dcFkeyList(%list).isSet == 0) {
      if ($dcFkeyList(%list).isDisabled == 1) {
        xdid -a $hget($1,dialog.name) 2 0 0 +c 0 0 0 0 $rgb(210,210,210) $rgb(0,0,0) %key $chr(9) + 0 0 $rgb(210,210,210) $rgb(0,0,0) DISABLED
      }
      else {
        xdid -a $hget($1,dialog.name) 2 0 0 + 0 0 0 0 $rgb(0,0,0) $rgb(0,0,0) %key
      }
    }
    else {
      xdid -a $hget($1,dialog.name) 2 0 0 + 0 0 0 0 $rgb(0,0,0) $rgb(0,0,0) %key $chr(9) + 0 0 $rgb(0,0,0) $rgb(0,0,0) $dcFkeyList(%list).group $chr(9) $&
        + 0 0 $rgb(0,0,0) $rgb(0,0,0) $dcFkeyList(%list).command $chr(9) + 0 0 $rgb(0,0,0) $rgb(0,0,0) $dcFkeyList(%list).command_line
    }
  }
  return 1
}

/*
* Füllt die GruppenListe
*
* @param $1 dcFkeyDialog objekt
* @return 1
*/
alias -l dcFkeyDialog.fillGroupList {
  var %list $dcFkey($hget($1,fkey.obj),grouplist).get
  .noop $dcList(%list).prepareWhile
  while ($dcList(%list).next) {
    xdid -a $hget($1,dialog.name) 3 0 0 0 0 0 $gettok($dcList(%list).getValue,1,44)
  }
  return 1
}

/*
* Füllt die Befehls Liste
*
* @param $1 dcFkeyDialog objekt
* @return 1
*/
alias -l dcfkeyDialog.fillGroupCommands {
  xdid -e $hget($1,dialog.name) 4
  xdid -r $hget($1,dialog.name) 4
  .noop $dcFkey($hget($1,fkey.obj),$xdid($hget($1,dialog.name),3).seltext).getGroupCommands
  var %list $dcFkey($hget($1,fkey.obj),commandlist).get
  .noop $dcList(%list).prepareWhile
  while ($dcList(%list).next) {
    xdid -a $hget($1,dialog.name) 4 0 0 0 0 0 $dcList(%list).getValue
    if ($dcList(%list).getValue == $xdid($hget($1,dialog.name),2,3).seltext) {
      xdid -c $hget($1,dialog.name) 4 $dcList(%list).getPos
    }
  }
}

/*
* Eintrag aus Liste wurde gewählt
*
* @param $1 dcFkeyDialog objekt
* @return 1
*/
alias -l dcFKeyDialog.sclickFKeyList {
  var %matchtext $xdid($hget($1,dialog.name),2,2).seltext
  if (%matchtext === DISABLED) {
    .noop $dcDialog($1,3-6,10-11).disableControls
    .noop $dcDialog($1,3-4,10-11).uncheckControls
    .noop $dcDialog($1,7).clearControls
  }
  elseif (%matchtext == Benutzer) {
    .noop $dcFkeyDialog($1).changeInputUser
    .noop $dcDialog($1,5-6,).enableControls

    var %item $dcDbs($dcFkey($hget($1,fkey.obj),dbhash).get,__key_assignments__,$xdid($hget($1,dialog.name),2,1).sel).getItem

    xdid -a $hget($1,dialog.name) 7 $gettok($dcDbs($dcFkey($hget($1,fkey.obj),dbhash).get,__key_assignments__,%item).getValue,3,44)
  }
  else {
    .noop $dcFkeyDialog($1).changeInputScript
    .noop $dcDialog($1,5-6).enableControls

    if (%matchtext != $null) {
      var %id $xdid($hget($1,dialog.name),3,$chr(9) %matchtext $chr(9),W,1).find
      xdid -c $hget($1,dialog.name) 3 %id
      .noop $dcFkeyDialog($1).fillGroupCommands
    }
    else {
      .noop $dcDialog($1,3-4).uncheckControls
      .noop $dcDialog($1,4-6).disableControls
    }
  }
}

/*
* RadioButton für Script Eingabe gewählt
*
* @param $1 dcFkeyDialog objekt
* @return 1
*/
alias -l dcFkeyDialog.changeInputScript {
  .noop $dcDialog($1,3,10-11).enableControls
  .noop $dcDialog($1,10).checkControls
  .noop $dcDialog($1,11).uncheckControls
  .noop $dcDialog($1,5-7).disableControls
  .noop $dcDialog($1,7).clearControls
}

/*
* RadioButton für User Eingabe gewählt
*
* @param $1 dcFkeyDialog objekt
* @return 1
*/
alias -l dcFkeyDialog.changeInputUser {
  .noop $dcDialog($1,3-6).disableControls
  .noop $dcDialog($1,7,10-11).enableControls
  .noop $dcDialog($1,3-4,10).uncheckControls
  .noop $dcDialog($1,11).checkControls
  .noop $dcDialog($1,7).clearControls
}

/*
* Speichert eine Zuweisung
*
* @param $1 dcFkeyDialog objekt
* @return 1 oder 0
*/
alias -l dcFkeyDialog.saveKey {
  var %key $dcDbs($dcfkey($hget($1,fkey.obj),dbhash).get,__key_assignments__,$xdid($hget($1,dialog.name),2).sel).getItem
  if ($xdid($hget($1,dialog.name),10).state == 1) {
    if ($dcfkey($hget($1,fkey.obj),%key,$xdid($hget($1,dialog.name),3).sel,$xdid($hget($1,dialog.name),4).sel).saveKeyScript) {
      var %list $dcFkey($hget($1,fkey.obj),fkeylist).get
      .noop $dcFkeyList(%list,$xdid($hget($1,dialog.name),2).sel).setPos
      xdid -v $hget($1,dialog.name) 2 $xdid($hget($1,dialog.name),2).sel 2 $xdid($hget($1,dialog.name),3).seltext
      xdid -v $hget($1,dialog.name) 2 $xdid($hget($1,dialog.name),2).sel 3 $xdid($hget($1,dialog.name),4).seltext
      xdid -v $hget($1,dialog.name) 2 $xdid($hget($1,dialog.name),2).sel 4 $dcFkeyList(%list).command_line
      .noop $dcx(MsgBox,ok information modal owner $dialog($hget($1,dialog.name)).hwnd $chr(9) Erfolg $chr(9) Tastenzuweisung erfolgreich gespeichert)
      xdid -e $hget($1,dialog.name) 6
      return 1
    }
    else {
      .noop $dcError($dcAcro($hget($1,acro.obj)).getErrorObject,$dialog($hget($1,dialog.name)).hwnd).showDialog
      return 0
    }
  }
  elseif ($xdid($hget($1,dialog.name),11).state == 1) {
    if ($dcfkey($hget($1,fkey.obj),%key,$xdid($hget($1,dialog.name),7).text).saveKeyUser) {
      xdid -v $hget($1,dialog.name) 2 $xdid($hget($1,dialog.name),2).sel 2 Benutzer
      xdid -v $hget($1,dialog.name) 2 $xdid($hget($1,dialog.name),2).sel 3 $null
      xdid -v $hget($1,dialog.name) 2 $xdid($hget($1,dialog.name),2).sel 4 $xdid($hget($1,dialog.name),7).text
      .noop $dcx(MsgBox,ok information modal owner $dialog($hget($1,dialog.name)).hwnd $chr(9) Erfolg $chr(9) Tastenzuweisung erfolgreich gespeichert)
      xdid -e $hget($1,dialog.name) 6
      return 1
    }
    else {
      .noop $dcError($dcFkey($hget($1,fkey.obj)).getErrorObject,$dialog($hget($1,dialog.name)).hwnd).showDialog
      return 0
    }
  }
}

/*
* Eintrag in der UserBox wird geändert
*
* @param $1 dcfkey Dialog objekt
* @return 1
*/
alias -l dcfkeyDialog.editUserBox {
  if ($xdid($hget($1,dialog.name),7).text == $null) {
    xdid -b $hget($1,dialog.name) 5
  }
  else {
    xdid -e $hget($1,dialog.name) 5
  }
  return 1
}

/*
* Löscht eine Zuweisung
*
* @param $1 dcFkeyDialog objekt
* @return 1
*/
alias -l dcFkeyDialog.delKey {
  var %key $dcDbs($dcfkey($hget($1,fkey.obj),dbhash).get,__key_assignments__,$xdid($hget($1,dialog.name),2).sel).getItem
  .noop $dcFkey($hget($1,fkey.obj),%key).delKey
  xdid -v $hget($1,dialog.name) 2 $xdid($hget($1,dialog.name),2).sel 2 
  xdid -v $hget($1,dialog.name) 2 $xdid($hget($1,dialog.name),2).sel 3 
  xdid -v $hget($1,dialog.name) 2 $xdid($hget($1,dialog.name),2).sel 4 
  .noop $dcx(MsgBox,ok information modal owner $dialog($hget($1,dialog.name)).hwnd $chr(9) Erfolg $chr(9) Tastenzuweisung erfolgreich gelöscht)
  xdid -b $hget($1,dialog.name) 6
  return 1
}

/*
* Wird durch den Config-Dialog aufgerufen, initalisiert den Dialog
*
* @param $1 dcConfig objekt
*/
alias dc.frameworkFkey.createPanel {
  set %dc.fkey.dialog.obj $dcfkeyDialog($dcConfig($1,dialog.name).get,$dcConfig($1,currentPanel.dbhash).get)
}

/*
* Zu erledigende Aufgaben wenn das Panel zerstört
*/
alias dc.frameworkFkey.destroyPanel {
  .noop $dcFkeyDialog(%dc.fkey.dialog.obj).destroy
  unset %dc.fkey.dialog.obj
}

/*
* Verwaltet Dialog-Ereignisse wie Mausklicks, Tastatureingaben, ... für das Panel
*
* @param $1 DialogName
* @param $2 Ereignis
* @param $3 Betroffene ID
* @param $4 sonstiges
*/
alias dc.frameworkFkey.events {
  if ($2 == sclick) {
    if ($3 == 2) { .noop $dcFKeyDialog(%dc.fkey.dialog.obj).sclickFKeyList }
    if ($3 == 3) { .noop $dcFKeyDialog(%dc.fkey.dialog.obj).fillGroupCommands }
    if ($3 == 4) { xdid -e $1 5 }
    if ($3 == 5) { .noop $dcFKeyDialog(%dc.fkey.dialog.obj).saveKey }
    if ($3 == 6) { .noop  $dcFkeyDialog(%dc.fkey.dialog.obj).delKey }
    if ($3 == 10) { .noop $dcFkeyDialog(%dc.fkey.dialog.obj).changeInputScript }
    if ($3 == 11) { .noop $dcFkeyDialog(%dc.fkey.dialog.obj).changeInputUser }
  }
  elseif ($2 == edit) {
    if ($3 == 7) { .noop $dcfkeyDialog(%dc.fkey.dialog.obj).editUserBox }
  }
}

;alias f1 { $dcFkey.evalKey(%dc.fkey.obj,f1) }
alias f2 { $dcFkey.evalKey(%dc.fkey.obj,f2) }
alias f3 { $dcFkey.evalKey(%dc.fkey.obj,f3) }
alias f4 { $dcFkey.evalKey(%dc.fkey.obj,f4) }
alias f5 { $dcFkey.evalKey(%dc.fkey.obj,f5) }
alias f6 { $dcFkey.evalKey(%dc.fkey.obj,f6) }
alias f7 { $dcFkey.evalKey(%dc.fkey.obj,f7) }
alias f8 { $dcFkey.evalKey(%dc.fkey.obj,f8) }
alias f9 { $dcFkey.evalKey(%dc.fkey.obj,f9) }
alias f10 { $dcFkey.evalKey(%dc.fkey.obj,f10) }
;alias f11 { $dcFkey.evalKey(%dc.fkey.obj,f11) }
alias f12 { $dcFkey.evalKey(%dc.fkey.obj,f12) }

;alias sf1 { $dcFkey.evalKey(%dc.fkey.obj,sf1) }
alias sf2 { $dcFkey.evalKey(%dc.fkey.obj,sf2) }
alias sf3 { $dcFkey.evalKey(%dc.fkey.obj,sf3) }
alias sf4 { $dcFkey.evalKey(%dc.fkey.obj,sf4) }
alias sf5 { $dcFkey.evalKey(%dc.fkey.obj,sf5) }
alias sf6 { $dcFkey.evalKey(%dc.fkey.obj,sf6) }
alias sf7 { $dcFkey.evalKey(%dc.fkey.obj,sf7) }
alias sf8 { $dcFkey.evalKey(%dc.fkey.obj,sf8) }
alias sf9 { $dcFkey.evalKey(%dc.fkey.obj,sf9) }
alias sf10 { $dcFkey.evalKey(%dc.fkey.obj,sf10) }
alias sf11 { $dcFkey.evalKey(%dc.fkey.obj,sf11) }
alias sf12 { $dcFkey.evalKey(%dc.fkey.obj,sf12) }

alias cf1 { $dcFkey.evalKey(%dc.fkey.obj,cf1) }
alias cf2 { $dcFkey.evalKey(%dc.fkey.obj,cf2) }
alias cf3 { $dcFkey.evalKey(%dc.fkey.obj,cf3) }
alias cf4 { $dcFkey.evalKey(%dc.fkey.obj,cf4) }
alias cf5 { $dcFkey.evalKey(%dc.fkey.obj,cf5) }
alias cf6 { $dcFkey.evalKey(%dc.fkey.obj,cf6) }
alias cf7 { $dcFkey.evalKey(%dc.fkey.obj,cf7) }
alias cf8 { $dcFkey.evalKey(%dc.fkey.obj,cf8) }
alias cf9 { $dcFkey.evalKey(%dc.fkey.obj,cf9) }
alias cf10 { $dcFkey.evalKey(%dc.fkey.obj,cf10) }
alias cf11 { $dcFkey.evalKey(%dc.fkey.obj,cf11) }
alias cf12 { $dcFkey.evalKey(%dc.fkey.obj,cf12) }