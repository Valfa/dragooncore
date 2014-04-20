/*
* DragoonCore Auto Identify
*
* @author Valfa
* @version 1.0
* @db Module/Auto Identify.ini
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

  :saveConfig
  return $dcAutoIdent.saveConfig($1,$2,$3)

  :checkConfig
  return $dcAutoIdent.checkConfig($1,$2,$3)

  :getErrorObject
  return $hget($1,error.obj)

  :setNick
  return $dcAutoIdent.setNick($1,$2)

  :clearNick
  return $dcAutoident.clearNick($1)

  :saveNick
  return $dcAutoIdent.saveNick($1,$2,$3)

  :delNick
  return $dcAutoIdent.delNick($1)

  :checkNick
  return $dcAutoIdent.checkNick($1,$2,$3)

  :clearSubNicks
  return $dcAutoIdent.clearSubNicks($1)

  :addSubNick
  return $dcAutoident.addSubNick($1,$2)

  :checkSubNick
  return $dcAutoIdent.checksubNick($1,$2)

  :delSubNick
  return $dcAutoIdent.delSubNick($1,$2)

  :getPassword
  return $dcAutoIdent.getPassword($1,$2)

  :sameGroup
  return $dcAutoIdent.sameGroup($1,$2,$3)
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
    var %db $dcDbs(modul_auto_identify)
    hadd %db createDB 1
  }
  else {
    var %db $2
    hadd %db createDB 0
  }
  hadd $1 dbhash %db
  .noop $dcDbs(%db,section,config).set
  var %pwd $dcDbs(%db,pwd).getValue
  var %connect $dcDbs(%db,connect).getValue
  if (%pwd == $null) { var %pwd $dcDbs(%db,pwd).getScriptValue }
  if (%connect == $null) { var %connect $dcDbs(%db,connect).getScriptValue }
  hadd $1 config.pwd $dcDecryptValue(%pwd)
  hadd $1 config.connect %connect
  hadd $1 nicklist $dcDbsList(%db,user,nicks)
  hadd $1 error.obj $dcError
  hadd $1 nick.name $null
  hadd $1 nick.pwd $null
  hadd $1 nick.grouplist 0
  hadd $1 limit_get config.pwd,config.connect,nicklist,nick.name,nick.pwd,nick.grouplist

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
    .noop $dcDbs($hget($1,dbhash)).destroy
  }
  .noop $dcError($hget($1,error.obj)).destroy
  if ($hget($1,nicklist)) { .noop $dcDbsList($hget($1,nicklist)).destroy }
  if ($hget($1,nick.grouplist)) { .noop $dcDbsList($hget($1,nick.grouplist)).destroy }
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
alias -l dcAutoIdent.saveConfig {
  if ($dcAutoIdent($1,$2,$3).checkConfig) {    
    .noop $dcDbs($hget($1,dbhash),section,config).set
    if ($2 != $null) { .noop $dcDbs($hget($1,dbhash),pwd,$2).setEncryptedValue | hadd $1 config.pwd $2 }
    else { .noop $dcDbs($hget($1,dbhash),pwd).deleteItem | hdel $1 config.pwd }
    .noop $dcDbs($hget($1,dbhash),connect,$3).setValue | hadd $1 config.connect $3

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
  if ($2 != $null && !$dcCheck($2).space) {
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
* Lädt die Daten zu einem Nick
*
* @param $1 dcAutoident objekt
* @param $2 nick
* @return 1 oder 0
*/
alias -l dcAutoIdent.setNick {
  .noop $dcDbs($hget($1,dbhash),section,nicks).set
  if ($dcDbs($hget($1,dbhash),$2).getValue) {
    if ($hget($1,nick.grouplist)) { .noop $dcDbsList($hget($1,nick.grouplist)).destroy }
    hadd $1 nick.name $2
    hadd $1 nick.pwd $dcDbs($hget($1,dbhash),$2).getEncryptedValue
    hadd $1 nick.grouplist $dcDbsList($hget($1,dbhash),user,$2)
    return 1
  }
  else {
    return 0
  }
}

/*
* Löscht die Daten zu einem Nick
*
* @param $1 dcAutoident objekt
* @return 1
*/
alias -l dcAutoident.clearNick {
  if ($hget($1,nick.grouplist)) { .noop $dcDbsList($hget($1,nick.grouplist)).destroy }
  hadd $1 nick.name $null
  hadd $1 nick.pwd $null
  hadd $1 nick.grouplist 0
}

/*
* Fügt eine neue NickGruppe hinzu
*
* @param $1 dcautoident objekt
* @param $2 nick
* @param $3 pwd
* @return 1 oder 0
*/
alias -l dcAutoIdent.saveNick {
  if ($dcAutoIdent($1,$2,$3).checkNick) {
    .noop $dcDbs($hget($1,dbhash),section,nicks).set
    .noop $dcDbs($hget($1,dbhash),$2,$3).setEncryptedValue
    hadd $1 nick.name $2
    hadd $1 nick.pwd $3
    hadd $1 nick.grouplist 0
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
alias -l dcAutoIdent.checkNick {
  .noop $dcerror($hget($1,error.obj)).clear
  if ($2 == $null) {
    .noop $dcError($hget($1,error.obj),Nick darf nicht leer sein).add
  }
  elseif (!$dcCheck($2).space) {
    .noop $dcError($hget($1,error.obj),Nick darf keine Leerzeichen enthalten).add
  }
  elseif ((!$hget($1,nick.name) && $dcDbs($hget($1,dbhash),nicks,$2).getValue) || ($hget($1,nick.name) != $2 && $dcDbs($hget($1,dbhash),nicks,$2).getValue)) {
    .noop $dcError($hget($1,error.obj),Nick bereits Vorhanden).add
  }
  else {
    var %list $dcDbsList($hget($1,dbhash),user)
    if (%list) {
      .noop $dcDbsList(%list).prepareWhile
      while ($dcDbsList(%list).next) {
        var %section $dcDbsList(%list).getItem
        if (%section == config || %section == nicks) {
          continue
        }
        if ($dcDbs($hget($1,dbhash),%section,$2).getValue) {
          echo -s s: %section
          .noop $dcError($hget($1,error.obj),Nick ist einem anderem Nick bereits zugeordnet (Gruppe)).add
          break
        }
      }
      .noop $dcDbsList(%list).destroy
    }
  }
  if ($3 == $null) {
    .noop $dcError($hget($1,error.obj),Passwort darf nicht leer sein).add
  }
  elseif (!$dcCheck($3).space) {
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
* Löscht einen Nick
*
* @param $1 dcAutoIdent objekt
* @return 1 oder 0
*/
alias -l dcAutoIdent.delNick {
  if ($hget($1,nick.name)) {
    .noop $dcDbs($hget($1,dbhash),nicks,$hget($1,nick.name)).deleteItem
    .noop $dcDbs($hget($1,dbhash),$hget($1,nick.name)).deleteSection
    .noop $dcAutoIdent($1).clearNick
    return 1
  }
  else {
    return 0
  }
}

/*
* Löscht alle Subnicks des aktuellen Nicks (Gruppe)
*
* @param $1 dcAutoIdent objekt
* @return 1
*/
alias -l dcAutoIdent.clearSubNicks {
  .noop $dcDbs($hget($1,dbhash),$hget($1,nick.name)).deleteSection
  return 1
}

/*
* Überprüft einen Subnick
*
* @param $1 dcAutoIdent objekt
* @param $2 subnick
* @return 1 oder 0
*/
alias -l dcAutoIdent.checkSubNick {
  .noop $dcerror($hget($1,error.obj)).clear
  if ($dcDbs($hget($1,dbhash),nicks,$2)) {
    .noop $dcError($hget($1,error.obj),Nick bereits als Hauptnick Vorhanden).add
  }
  else {
    var %list $dcDbsList($hget($1,dbhash),user)
    if (%list) {
      .noop $dcDbsList(%list).prepareWhile
      while ($dcDbsList(%list).next) {
        var %section $dcDbsList(%list).getItem
        if (%section == config || %section == nicks) {
          continue
        }
        if ($dcDbs($hget($1,dbhash),%section,$2).getValue) {
          .noop $dcError($hget($1,error.obj),Nick $2 ist bereits einem anderem Nick zugeordnet (Gruppe)).add
          break
        }
      }
      .noop $dcDbsList(%list).destroy
    }
  }

  if ($dcError($hget($1,error.obj)).count > 0) {
    return 0
  }
  else {
    return 1
  }
}

/*
* Fügt einem Nick einen SubNick hinzu (Gruppe)
*
* @param $1 dcAutoIdent objekt
* @param $2 subnick
* @return 1 oder 0
*/
alias -l dcAutoIdent.addSubNick {
  if ($hget($1,nick.name) && $dcAutoIdent($1,$2).checkSubNick) {
    .noop $dcDbs($hget($1,dbhash),$hget($1,nick.name),$2,$hget($1,nick.name)).setValue
    return 1
  }
  else {
    return 0
  }
}

/*
* Löscht einen SubNick (Gruppe)
*
* @param $1 dcAutoIdent objekt
* @param $2 subnick
* @return 1 oder 0
*/
alias -l dcAutoident.delSubNick {
  if ($hget($1,nick.name)) {
    .noop $dcDbs($hget($1,dbhash),$hget($1,nick.name),$2).deleteItem
    return 1
  }
  else {
    return 0
  }
}

/*
* Ermittelt das Passwort für einen beliebigen Nick
*
* @param $1 dcAutoIdent objekt
* @param $2 nick
* @return password oder $null
*/
alias -l dcAutoIdent.getPassword {
  if ($dcDbs($hget($1,dbhash),nicks,$2).getValue) {
    return $dcDbs($hget($1,dbhash),nicks,$2).getEncryptedValue
  }
  else {
    var %list $dcDbsList($hget($1,dbhash),user)
    var %pwd $null
    if (%list) {
      .noop $dcDbsList(%list).prepareWhile
      while ($dcDbsList(%list).next) {
        var %section $dcDbsList(%list).getItem
        if (%section == config || %section == nicks) {
          continue
        }
        if ($dcDbs($hget($1,dbhash),%section,$2).getValue) {
          var %pwd $dcDbs($hget($1,dbhash),nicks,$dcDbsList(%list).getItem).getEncryptedValue        
          break
        }
      }
      .noop $dcDbsList(%list).destroy
      if (!%pwd) {
        var %pwd $hget($1,config.pwd)
      }
      return %pwd
    }
  }
  return $null
}

/*
* Prüft ob 2 Nicks in der selben Gruppe sind
* 
* @param $1 dcAutoIdent objekt
* @param $2 nick1
* @param $3 nick2
* @return 1 oder 0
*/
alias -l dcAutoIdent.sameGroup {
  if ($2 != $3) {
    if ($dcDbs($hget($1,dbhash),nicks,$2).getValue && $dcDbs($hget($1,dbhash),nicks,$3).getValue) {
      return 0
    }
    else {
      if (($dcDbs($hget($1,dbhash),nicks,$2).getValue && $dcDbs($hget($1,dbhash),$2,$3).getValue) || $&
        ($dcDbs($hget($1,dbhash),nicks,$3).getValue && $dcDbs($hget($1,dbhash),$3,$2).getValue)) {
        return 1
      }
      else {
        var %list $dcDbsList($hget($1,dbhash),user)
        if (%list) {
          .noop $dcDbsList(%list).prepareWhile
          while ($dcDbsList(%list).next) {
            var %section $dcDbsList(%list).getItem
            if (%section == config || %section == nicks) {
              continue
            }
            if ($dcDbs($hget($1,dbhash),%section,$2).getValue && $dcDbs($hget($1,dbhash),%section,$3).getValue) {          
              .noop $dcDbsList(%list).destroy
              return 1
            }
          }
          .noop $dcDbsList(%list).destroy
        }
        return 0
      }
    }
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

  :fillNickList
  return $dcAutoIdentDialog.fillNickList($1)

  :selectNick
  return $dcAutoidentDialog.selectNick($1)

  :saveConfig
  return $dcAutoIdentDialog.saveConfig($1)

  :changeToolbar
  return $dcAutoIdentDialog.changeToolbar($1)

  :newNick
  return $dcAutoidentDialog.newNick($1)

  :editNick
  return $dcAutoidentDialog.editNick($1)

  :delNick
  return $dcAutoidentDialog.delNick($1)

  :saveNick
  return $dcAutoidentDialog.saveNick($1)
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
  .noop $dcAutoIdentDialog($1).fillNickList
  hadd $1 current.nick $null

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
  xdid -w $hget($1,dialog.name) 75 +nh 0 images/ico/page_white_add.ico
  xdid -w $hget($1,dialog.name) 75 +nh 0 images/ico/page_white_edit.ico
  xdid -w $hget($1,dialog.name) 75 +nh 0 images/ico/page_white_delete.ico

  xdid -w $hget($1,dialog.name) 75 +dhg 0 images/ico/page_white_add.ico
  xdid -w $hget($1,dialog.name) 75 +dhg 0 images/ico/page_white_edit.ico
  xdid -w $hget($1,dialog.name) 75 +dhg 0 images/ico/page_white_delete.ico

  xdid -a $hget($1,dialog.name) 75 1 +ld 30 1 $chr(9) Nick hinzufügen
  xdid -a $hget($1,dialog.name) 75 2 +ld 30 2 $chr(9) Nick bearbeiten
  xdid -a $hget($1,dialog.name) 75 3 +ld 30 3 $chr(9) Nick löschen

  xdid -c $hget($1,dialog.name) 1 4 list 5 150 175 390 hsbar

  xdid -c $hget($1,dialog.name) 1 104 text 190 100 100 20
  xdid -t $hget($1,dialog.name) 104 Nicks
  xdid -f $hget($1,dialog.name) 104 + default 10 Verdana

  xdid -c $hget($1,dialog.name) 1 105 text 190 130 100 20
  xdid -t $hget($1,dialog.name) 105 Nick:
  xdid -c $hget($1,dialog.name) 1 5 edit 190 150 245 20 autohs tabstop disabled

  xdid -c $hget($1,dialog.name) 1 106 text 190 180 100 20
  xdid -t $hget($1,dialog.name) 106 Passwort:
  xdid -c $hget($1,dialog.name) 1 6 edit 190 200 245 20 autohs tabstop password disabled

  xdid -c $hget($1,dialog.name) 1 107 text 190 230 200 20
  xdid -t $hget($1,dialog.name) 107 Nicks in Gruppe (optional)
  xdid -c $hget($1,dialog.name) 1 7 edit 190 250 245 250 autohs tabstop multi return vsbar disabled

  xdid -c $hget($1,dialog.name) 1 81 button 265 510 100 20 disabled
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
  if ($dcAutoIdent($hget($1,ident.obj),$xdid($hget($1,dialog.name),2).text,$xdid($hget($1,dialog.name),3).state).saveConfig) {
    .noop $dcx(MsgBox,ok exclamation modal owner $dialog($hget($1,dialog.name)).hwnd $chr(9) OK $chr(9) Konfiguartion gesichert)
    return 1
  }
  else {
    .noop $dcError($dcAutoident($hget($1,ident.obj)).getErrorObject,$dialog($hget($1,dialog.name)).hwnd).showDialog
    return 0
  }
}

/*
* Füllt die Nickliste
*
* @param $1 dcautoidentDialog objekt
* @return 1
*/
alias -l dcAutoIdentDialog.fillNickList {
  var %list $dcAutoIdent($hget($1,ident.obj),nicklist).get
  if (%list) {
    .noop $dcDbsList(%list).prepareWhile
    while ($dcDbsList(%list).next) {
      xdid -a $hget($1,dialog.name) 4 0 $dcDbsList(%list).getItem
    }
    if ($xdid($hget($1,dialog.name),4).num > 0)  {
      xdid -c $hget($1,dialog.name) 4 1
      .noop $dcAutoidentDialog($1).selectNick
    }
  }
}

/*
* Ein Nick wurde ausgewählt
*
* @param $1 dcautoidentDialog objekt
* @return 1
*/
alias -l dcAutoidentDialog.selectNick {
  hdel $1 nick.mode
  .noop $dcDialog($1,5-7,81).disableControls
  if ($xdid($hget($1,dialog.name),4,$xdid($hget($1,dialog.name),4).sel).text != $hget($1,current.nick)) {
    .noop $dcAutoidentDialog($1).changeToolbar
    hadd $1 current.nick $xdid($hget($1,dialog.name),4,$xdid($hget($1,dialog.name),4).sel).text
    ;echo -s $hget($1,current.nick) : $xdid($hget($1,dialog.name),4,$xdid($hget($1,dialog.name),4).sel).text
    if ($dcAutoIdent($hget($1,ident.obj),$hget($1,current.nick)).setNick) {
      .noop $dcDialog($1,5-7).clearControls
      xdid -a $hget($1,dialog.name) 5 $dcAutoIdent($hget($1,ident.obj),nick.name).get
      xdid -a $hget($1,dialog.name) 6 $dcAutoIdent($hget($1,ident.obj),nick.pwd).get
      var %list $dcAutoIdent($hget($1,ident.obj),nick.grouplist).get
      if (%list) {
        .noop $dcDbsList(%list).prepareWhile
        while ($dcDbsList(%list).next) {
          xdid -i $hget($1,dialog.name) 7 $dcDbsList(%list).getPos $dcDbsList(%list).getItem
        }
      }
    }
    else {
      .noop $dcx(MsgBox,ok error modal owner $dialog($hget($1,dialog.name)).hwnd $chr(9) Fehler $chr(9) Nick konnte nicht gefunden werden)
    }
  }
}

/*
* Ändert die Toolbar in Abhängigkeit der Auswahl
*
* @param $1 dcAutoIdentDialog objekt
* @return 1
*/
alias -l dcAutoidentDialog.changeToolbar {
  if ($hget($1,nick.mode) == new) {
    xdid -t $hget($1,dialog.name) 75 1 +
    xdid -t $hget($1,dialog.name) 75 2 +d
    xdid -t $hget($1,dialog.name) 75 3 +d
    xdid -e $hget($1,dialog.name) 81
  }
  elseif ($hget($1,nick.mode) == edit) {
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

/*
* Bereitet die BedienElemnte für das Hinzufügen eines neuen Nicks vor
*
* @param $1 dcautoidentDialog objekt
* @return 1
*/
alias -l dcAutoidentDialog.newNick {
  .noop $dcDialog($1,5-7,81).enableControls
  .noop $dcDialog($1,5-7).clearControls
  hadd $1 nick.mode new
  .noop $dcAutoidentDialog($1).changeToolbar
  return 1
}

/*
* Bereitet die BedienElemnte für das Bearbeiten eines Nicks vor
*
* @param $1 dcautoidentDialog objekt
* @return 1
*/
alias -l dcAutoidentDialog.editNick {
  .noop $dcDialog($1,5-7,81).enableControls
  hadd $1 nick.mode edit
  .noop $dcAutoidentDialog($1).changeToolbar
  return 1
}

/*
* Löscht einen Nick
*
* @param $1 dcautoidentDialog objekt
* @return 1 oder 0
*/
alias -l dcAutoidentDialog.delNick {
  var %sel $xdid($hget($1,dialog.name),4).sel
  if ($dcAutoIdent($hget($1,ident.obj)).delNick) {
    xdid -d $hget($1,dialog.name) 4 %sel
    if ($xdid($hget($1,dialog.name),4).num == 0) {
      .noop $dcDialog($1,5-7).clearControls
    }
    elseif (%sel > $xdid($hget($1,dialog.name),4).num) {
      xdid -c $hget($1,dialog.name) 4 $xdid($hget($1,dialog.name),4).num
      .noop $dcAutoIdentDialog($1).selectNick
    }
    else {
      xdid -c $hget($1,dialog.name) 4 %sel
      .noop $dcAutoIdentDialog($1).selectNick
    }
    .noop $dcx(MsgBox,ok exclamation modal owner $dialog($hget($1,dialog.name)).hwnd $chr(9) OK $chr(9) Nick erfolgreich gelöscht)
  }
  else {
    .noop $dcx(MsgBox,ok error modal owner $dialog($hget($1,dialog.name)).hwnd $chr(9) Fehler $chr(9) Nick konnte nicht gelöscht werden)
  }
}

/*
* Speichert die Aktuelle NickGruppe
*
* @param $1 dcAcroIdentDialog objekt
* @return 1 oder 0
*/
alias -l dcAutoidentDialog.saveNick {
  if ($hget($1,nick.mode) == new) { .noop $dcAutoident($hget($1,ident.obj)).clearNick }
  if ($dcAutoIdent($hget($1,ident.obj),$xdid($hget($1,dialog.name),5).text,$xdid($hget($1,dialog.name),6).text).saveNick) {
    if ($xdid($hget($1,dialog.name),4).num > 0) {
      .noop $dcAutoIdent($hget($1,ident.obj)).clearSubNicks
      var %i 1
      var %last $xdid($hget($1,dialog.name),7).num
      while (%i <= %last) {
        if (!$dcAutoIdent($hget($1,ident.obj),$xdid($hget($1,dialog.name),7,%i).text).addSubNick) {
          .noop $dcError($dcAutoident($hget($1,ident.obj)).getErrorObject,$dialog($hget($1,dialog.name)).hwnd).showDialog
          return 0
        }
        inc %i
      }
    }
    if ($hget($1,nick.mode) == new) {
      xdid -a $hget($1,dialog.name) 4 0 $xdid($hget($1,dialog.name),5).text
      xdid -c $hget($1,dialog.name) 4 $xdid($hget($1,dialog.name),4).num
      hadd $1 nick.mode edit
    }
    else {
      var %sel $xdid($hget($1,dialog.name),4).sel
      xdid -o $hget($1,dialog.name) 4 %sel $xdid($hget($1,dialog.name),5).text
      xdid -c $hget($1,dialog.name) 4 %sel
    }
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
      if ($4 == 1) { .noop $dcAutoidentDialog(%dc.autoIdent.dialog.obj).newNick }
      elseif ($4 == 2) { .noop $dcAutoidentDialog(%dc.autoIdent.dialog.obj).editNick }
      elseif ($4 == 3) { .noop $dcAutoidentDialog(%dc.autoIdent.dialog.obj).delNick }
    }
    elseif ($3 == 4) { .noop $dcAutoidentDialog(%dc.autoIdent.dialog.obj).selectNick }
    elseif ($3 == 80) { .noop $dcAutoIdentDialog(%dc.autoIdent.dialog.obj).saveConfig }
    elseif ($3 == 81) { .noop $dcAutoIdentDialog(%dc.autoIdent.dialog.obj).saveNick }
  }
}

/*
* AutoIdentify bei Connect
*
* @param $1 network
*/
alias dc.autoIdentify.onConnect {
  var %db $dcDbs(modul_auto_identify,$1)
  var %ident.obj $dcAutoIdent(%db)
  if ($dcAutoIdent(%ident.obj,config.connect).get) {
    var %pwd $dcAutoIdent(%ident.obj,$me).getPassword
    if (%pwd) {
      msg nickserv identify %pwd
    }
  }
  .noop $dcAutoIdent(%ident.obj).destroy
  .noop $dcDbs(%db).destroy
}

/*
* Autoidentify bei nickchange
*
* @param $1 hashtable
*/
alias dc.autoIdentify.onNick {
  var %db $dcDbs(modul_auto_identify,$hget($1,network))
  var %ident.obj $dcAutoIdent(%db)
  if (!$dcAutoident.sameGroup(%ident.obj,$hget($1,nick),$hget($1,newnick))) {
    var %pwd $dcAutoIdent(%ident.obj,$hget($1,newnick)).getPassword
    if (%pwd) {
      msg nickserv identify %pwd
    }
  }
  .noop $dcAutoIdent(%ident.obj).destroy
  .noop $dcDbs(%db).destroy
}

alias dc.auto_identify.load { }
alias dc.auto_identify.unload { }

menu channel,status {
  DragoonCore
  .Modul Konfiguartion
  ..Auto Identify:/config_modul autoident
}

menu menubar {
  Modul Konfiguartion
  .Auto Identify:/config_modul autoident
}