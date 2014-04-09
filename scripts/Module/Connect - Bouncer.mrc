/*
* Class Alias
* var %var $dcConnectBnc
*
* @param $1 Datenbank objekt (optional)
*/
alias dcConnectBnc {
  var %this = dcConnectBnc           | ; Name of Object (Alias name)
  var %base = BaseClass        | ; Name of BaseClass, $null for none  

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
  var %x $baseClass(%this,%base).init
  return $dcConnectBnc.init(%x,$1)

  :destroy
  return $dcConnectBnc.destroy($1)
  
  :getErrorObject
  return $hget($1,error.obj)

  :setBouncer
  return $dcConnectBnc.setBouncer($1,$2)

  :getBouncerData
  return $dcConnectBnc.getBouncerData($1)

  :connect
  return $dcConnectBnc.connect($1)

  :clearData
  return $dcConnectBnc.clearData($1)

  :delBnc
  return $dcConnectBnc.delBnc($1,$2)

  :saveBncData
  return $dcConnectBnc.saveBncData($1,$2,$3,$4,$5,$6,$7)

  :checkBncData
  return $dcConnectBnc.checkBncData($1,$2,$3,$4,$5,$6,$7)
}

/*
* Initialisiert ein dcConnectBnc Objekt
*
* @param $1 dcConnectBnc Objekt
* @param $2 dbhash (obtional)
* @return dcConnectBnc objekt
*/
alias -l dcConnectBnc.init {
  if ($2 == $null || $hget($2,database) != modul_connect_bnc) { 
    var %db $dbs(modul_connect_bnc)
    hadd %db createDB 1
  }
  else {
    var %db $2
    hadd %db createDB 0
  }
  hadd $1 dbhash %db
  hadd $1 error.obj $dcError
  hadd $1 bnclist $dbsList(%db,user)
  hadd $1 typelist $dbsList(%db,script,bnc_types)
  hadd $1 current.bnc $null
  hadd $1 mode new

  hadd $1 limit_get bnclist,typelist,current.bnc,type,address,port,user,pwd

  return $1
}

/*
* zerstört ein dcConnectBnc objekt
*
* @param $1 dcConnectBnc objekt
* @return 1
*/
alias -l dcConnectBnc.destroy {
  .noop $dcError($hget($1,error.obj)).destroy
  if ($hget($1,createDB) == 1) {
    .noop $dbs($hget($1,dbhash)).destroy
  }
  .noop $dbsList($hget($1,bnclist)).destroy
  .noop $dbsList($hget($1,typelist)).destroy
  .noop $baseClass($1).destroy
  return 1
}

/*
* setzt den aktiven Bouncer
*
* @param $1 dcConnectBnc objekt
* @param $2 bouncer
* @return 1 oder 0
*/
alias -l dcConnectBnc.setBouncer {
  hadd $1 current.bnc $2
  return $dcConnectBnc($1).getBouncerData 
}

/*
* Liest die daten zum aktuellen Bouncer aus
*
* @param $1 dcConnectBnc objekt
* @return 1 oder 0
*/
alias -l dcConnectBnc.getBouncerData {
  var %list $dbsList($hget($1,dbhash),user,$hget($1,current.bnc))
  if (%list) {
    .noop $dbs($hget($1,dbhash),$hget($1,current.bnc)).setSection
    hadd $1 type $dbs($hget($1,dbhash),type).getUserValue
    hadd $1 address $dbs($hget($1,dbhash),address).getUserValue
    hadd $1 port $dbs($hget($1,dbhash),port).getUserValue
    hadd $1 user $dbs($hget($1,dbhash),user).getUserValue
    hadd $1 pwd $decryptValue($dbs($hget($1,dbhash),pwd).getUserValue)
    hadd $1 mode edit
    .noop $dbsList(%list).destroy
    return 1
  }
  else {
    return 0
  }
}

/*
* Stellt die Verbindung zu einem Bouncer her
*
* @param $1 dcConnectBnc objekt
* @param $2 neues fenster (1 oder 0), default 1
* @return 1
*/
alias -l dcConnectBnc.connect {
  if ($hget($1,current.bnc)) {
    if ($2 == 0) { var %para $null }
    else { var %para -m }

    var %loginmode $dbs($hget($1,dbhash),bnc_types,$hget($1,type)).getScriptValue

    if (%loginmode == user:pwd) {
      var %pwd $hget($1,user) $+ $chr(58) $+ $hget($1,pwd)
      .server %para $hget($1,address) $hget($1,port) %pwd
    }
    elseif (%loginmode == pwd_ident) {
      var %connect.obj $dcConnect
      var %ident $dcConnect.getIdent(0,1)
      .noop $dcConnect(%connect.obj).destroy
      var %ident $puttok(%ident,$hget($1,user) $+ @mybouncer.at,3,32)
      .server %para $hget($1,address) $hget($1,port) $hget($1,pwd) -i %ident
    }
    return 1
  }
  else {
    .noop $dcError($hget($1,error.obj)).clear
    .noop $dcError($hget($1,error.obj),Bouncer ist nicht ausgewählt).add
    return 0
  }
}

/*
* Setzt alle Bouncer Spezifischen Daten auf $null
*
* @param $1 dcConnectBnc objekt
* @return 1
*/
alias -l dcConnectBnc.clearData {
  hadd $1 current.bnc $null
  hadd $1 type $null
  hadd $1 address $null
  hadd $1 port $null
  hadd $1 user $null
  hadd $1 pwd $null
  hadd $1 mode new
  return 1
}

/*
* Löscht einen Bouncer
*
* @param $1 dcConnectBnc objekt
* @return 1 oder 0
*/
alias -l dcConnectBnc.delBnc {
  if ($hget($1,current.bnc)) {
    .noop $dbs($hget($1,dbhash),$hget($1,current.bnc)).deleteUserSection
    .noop $dcConnectBnc($1).clearData
    return 1
  }
  else {
    .noop $dcError($hget($1,error.obj)).clear
    .noop $dcError($hget($1,error.obj),Bouncer ist nicht ausgewählt).add
    return 0
  }
}

/*
* Überprüft die übergebenen Daten
*
* @param $1 dcConnectBnc objekt
* @param $2 Bouncer Name
* @param $3 type
* @param $4 addresse
* @param $5 port
* @param $6 user
* @param $7 pwd
* @return 1 oder 0
*/
alias -l dcConnectBnc.checkBncData {
  .noop $dcError($hget($1,error.obj)).clear
  var %list $dbsList($hget($1,dbhash),user,$2)
  if (%list) {
    if (($hget($1,mode) == new) || ($hget($1,mode) == edit && $hget($1,current.bnc) != $2)) {
      .noop $dcError($hget($1,error.obj),Bouncername bereits vorhanden).add
    }
    .noop $dbsList(%list).destroy
  }
  if ($2 == $null) {
    .noop $dcError($hget($1,error.obj),Bouncername darf nicht leer sein).add
  }
  elseif ($regex(regex,$2,[[:space:]])) {
    .noop $dcError($hget($1,error.obj),Bouncername darf keine Leerzeichen enthalten).add
  }
  if ($3 == $null) {
    .noop $dcError($hget($1,error.obj),Bouncertyp wurde nicht gewählt).add
  }
  elseif ($dbs($hget($1,dbhash),bnc_types,$3).getScriptValue == $null) {
    .noop $dcError($hget($1,error.obj),Bouncertyp ist ungültig).add
  }
  if ($4 == $null) {
    .noop $dcError($hget($1,error.obj),Serveraddresse fehlt).add
  }
  elseif ($regex(regex,$4,^localhost$|^([a-z]+\.)*[a-z0-9]([a-z]|[0-9]|[-_\.~])*\.[a-z][a-z]+|(\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3})) == 0) {
    .noop $dcError($hget($1,error.obj),Serveraddresse ungültig).add
  }
  if ($5 == $null) {
    .noop $dcError($hget($1,error.obj),Port nicht eingetragen).add
  }
  elseif ($regex(regex,$5,(^(\+)?[1-9][0-9]{3,4})((,|-)?([1-9][0-9]{3,4}))*$) == 0) {
    .noop $dcError($hget($1,error.obj),Portangabe ungültig).add
  }
  if (6 == $null) {
    .noop $dcError($hget($1,error.obj),Benutzername darf nicht leer sein).add
  }
  elseif ($regex(regex,$6,[[:space:]])) {
    .noop $dcError($hget($1,error.obj),Benutzername darf keine Leerzeichen enthalten).add
  }
  if ($7 == $null) {
    .noop $dcError($hget($1,error.obj),Passwort darf nicht leer sein).add
  }

  if ($dcError($hget($1,error.obj)).count > 0) {
    return 0
  }
  else {
    return 1
  }  
}

/*
* Speichert Bouncer Daten
*
* @param $1 dcConnectBnc objekt
* @param $2 Bouncer Name
* @param $3 type
* @param $4 addresse
* @param $5 port
* @param $6 user
* @param $7 pwd
* @return 1 oder 0
*/
alias -l dcConnectBnc.saveBncData {
  if ($dcConnectBnc($1,$2,$3,$4,$5,$6,$7).checkBncData) {
    .noop $dbs($hget($1,dbhash),$2).setSection
    if ($hget($1,mode) == edit && $hget($1,current.bnc) != $2) {
      var %line $read($dbs($hget($1,dbhash),config_user).get,w,* $+ $chr(91) $+ $hget($1,current.bnc) $+ $chr(93) $+ *,0)
      .write -l $+ $readn $qt($dbs($hget($1,dbhash),config_user).get) $chr(91) $+ $2 $+ $chr(93)
    } 
    .noop $dbs($hget($1,dbhash),type,$3).setUserValue
    .noop $dbs($hget($1,dbhash),address,$4).setUserValue
    .noop $dbs($hget($1,dbhash),port,$5).setUserValue
    .noop $dbs($hget($1,dbhash),user,$6).setUserValue
    .noop $dbs($hget($1,dbhash),pwd,$encryptValue($7)).setUserValue

    hadd $1 current.bnc $2
    hadd $1 type $3
    hadd $1 address $4
    hadd $1 port $5
    hadd $1 user $6
    hadd $1 pwd $7
    hadd $1 mode edit
    return 1
  }
  else {
    return 0
  }
}

/*
* Class Alias
* var %var $dcConnectBncDialog
*
* @param $1 dialog name
*/
alias dcConnectBncDialog {
  var %this = dcConnectBncDialog           | ; Name of Object (Alias name)
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
  return $dcConnectBncDialog.init(%x,$1)

  :destroy
  return $dcConnectBncDialog.destroy($1)

  :createControls
  return $dcConnectBncDialog.createControls($1)

  :fillBouncerList
  return $dcConnectBncDialog.fillBouncerList($1)

  :setBouncerTypes
  return $dcConnectBncDialog.setBouncerTypes($1)

  :setBouncerData
  return $dcConnectBncDialog.setBouncerData($1)

  :changeToolbar
  return $dcConnectBncDialog.changeToolbar($1)

  :selectBnc
  return $dcConnectBncDialog.selectBnc($1)

  :newBnc
  return $dcConnectBncDialog.newBnc($1)

  :editBnc
  return $dcConnectBncDialog.editBnc($1)

  :delBnc
  return $dcConnectBncDialog.delBnc($1)
  
  :saveBncData
  return $dcConnectBncDialog.saveBncData($1)
}

/*
* Initialisiert das dcConnectBncDialog objekt
*
* @param $1 dcConnectBncDialog objekt
* @param $2 dialog name
* @param $3 dbhash oder $null
* @return dcConnectBncDialog objekt
*/
alias -l dcConnectBncDialog.init {
  hadd $1 connect.bnc.obj $dcConnectBnc($3)
  if ($2 != $null) { hadd $1 dialog.name $2 }
  else { hadd $1 dialog.name dcConnectBnc }

  .noop $dcDialog($1,435,540).createBasePanel
  .noop $dcConnectBncDialog($1).createControls
  .noop $dcConnectBncDialog($1).fillBouncerList
  .noop $dcConnectBncDialog($1).setBouncerTypes
  .noop $dcConnectBncDialog($1).setBouncerData

  return $1
}

/*
* löscht ein dcConnectBncDialog Objekt
*
* @param $1 dcConnectBncDialog objekt
* @return 1
*/
alias -l dcConnectBncDialog.destroy {
  .noop $dcConnectBnc($hget($1,connect.bnc.obj)).destroy
  .noop $baseClass($1).destroy
  return 1
}

/*
* Erstellt die Bedien-Elemente
*
* @param $1 dcConnectBncDialog objekt
* @return 1
*/
alias -l dcConnectBncDialog.createControls {
  xdid -c $hget($1,dialog.name) 1 100 text 0 0 200 25
  xdid -t $hget($1,dialog.name) 100 Server Verwaltung
  xdid -f $hget($1,dialog.name) 100 + default 14 Arial

  xdid -c $hget($1,dialog.name) 1 101 text 5 25 100 20
  xdid -t $hget($1,dialog.name) 101 Bouncer
  xdid -f $hget($1,dialog.name) 101 + default 10 Verdana

  xdid -c $hget($1,dialog.name) 1 75 toolbar 5 50 425 30 flat list nodivider noauto tooltips
  xdid -l $hget($1,dialog.name) 75 24
  xdid -w $hget($1,dialog.name) 75 +nh 0 images/ico/connect_sl_connect.ico
  xdid -w $hget($1,dialog.name) 75 +nh 0 images/ico/connect_sl_disconnect.ico
  xdid -w $hget($1,dialog.name) 75 +nh 0 images/ico/page_white_add.ico
  xdid -w $hget($1,dialog.name) 75 +nh 0 images/ico/page_white_edit.ico
  xdid -w $hget($1,dialog.name) 75 +nh 0 images/ico/page_white_delete.ico

  xdid -w $hget($1,dialog.name) 75 +dhg 0 images/ico/connect_sl_connect.ico
  xdid -w $hget($1,dialog.name) 75 +dhg 0 images/ico/connect_sl_disconnect.ico
  xdid -w $hget($1,dialog.name) 75 +dhg 0 images/ico/page_white_add.ico
  xdid -w $hget($1,dialog.name) 75 +dhg 0 images/ico/page_white_edit.ico
  xdid -w $hget($1,dialog.name) 75 +dhg 0 images/ico/page_white_delete.ico

  xdid -a $hget($1,dialog.name) 75 1 +ld 30 1 $chr(9) Verbindung herstellen
  xdid -a $hget($1,dialog.name) 75 2 +ad 0 0 -
  xdid -a $hget($1,dialog.name) 75 3 +l 30 3 $chr(9) Bouncer hinzufügen
  xdid -a $hget($1,dialog.name) 75 4 +ld 30 4 $chr(9) Bouncerdaten bearbeiten
  xdid -a $hget($1,dialog.name) 75 5 +ld 30 5 $chr(9) Bouncer löschen

  xdid -c $hget($1,dialog.name) 1 2 list 5 85 190 455 tabstop vsbar

  xdid -c $hget($1,dialog.name) 1 102 text 200 25 200 20
  xdid -t $hget($1,dialog.name) 102 Bouncer Daten
  xdid -f $hget($1,dialog.name) 102 + default 10 Verdana

  xdid -c $hget($1,dialog.name) 1 103 text 205 65 100 20
  xdid -t $hget($1,dialog.name) 103 Name
  xdid -c $hget($1,dialog.name) 1 3 edit 205 85 225 20 tabstop disabled

  xdid -c $hget($1,dialog.name) 1 104 text 205 115 100 20
  xdid -t $hget($1,dialog.name) 104 Bouncer Typ
  xdid -c $hget($1,dialog.name) 1 4 comboex 205 135 225 300 dropdown tabstop disabled

  xdid -c $hget($1,dialog.name) 1 105 text 205 165 100 20
  xdid -t $hget($1,dialog.name) 105 Addresse
  xdid -c $hget($1,dialog.name) 1 5 edit 205 185 225 20 tabstop disabled

  xdid -c $hget($1,dialog.name) 1 106 text 205 215 100 20
  xdid -t $hget($1,dialog.name) 106 Port
  xdid -c $hget($1,dialog.name) 1 6 edit 205 235 175 20 number tabstop disabled
  xdid -c $hget($1,dialog.name) 1 7 check 385 235 40 20 tabstop disabled
  xdid -t $hget($1,dialog.name) 7 SSL

  xdid -c $hget($1,dialog.name) 1 108 text 205 265 100 20
  xdid -t $hget($1,dialog.name) 108 Benutzer
  xdid -c $hget($1,dialog.name) 1 8 edit 205 285 225 20 tabstop disabled

  xdid -c $hget($1,dialog.name) 1 109 text 205 315 100 20
  xdid -t $hget($1,dialog.name) 109 Passwort
  xdid -c $hget($1,dialog.name) 1 9 edit 205 335 225 20 password tabstop disabled

  xdid -c $hget($1,dialog.name) 1 80 button 272 380 100 20 tabstop disabled
  xdid -t $hget($1,dialog.name) 80 Speichern

  return 1
}

/*
* Füllt die Bouncer Liste
*
* @param $1 dcConnectBncDialog objekt
* @return 1
*/
alias -l dcConnectBncDialog.fillBouncerList {
  var %list $dcConnectBnc($hget($1,connect.bnc.obj),bnclist).get
  if (%list) {
    .noop $dbsList(%list).prepareWhile
    while ($dbsList(%list).next) {
      xdid -a $hget($1,dialog.name) 2 0 $dbsList(%list).getItem
    }
    xdid -c $hget($1,dialog.name) 2 1
    hadd $1 bnc.sel 1
  }
  return 1
}

/*
* Füllt die das Typen DropDown
*
* @param $1 dcConnectBncDialog objekt
* @return 1
*/
alias -l dcConnectBncDialog.setBouncerTypes {
  var %list $dcConnectBnc($hget($1,connect.bnc.obj),typelist).get
  .noop $dbsList(%list).prepareWhile
  if (%list) {
    while ($dbsList(%list).next) {
      xdid -a $hget($1,dialog.name) 4 0 0 0 0 0 $dbsList(%list).getItem
    }
  }
  return 1
}

/*
* Passt die Toolbar der Auswahl an
*
* @param $1 dcConnectBncDialog objekt
* @return 1
*/
alias -l dcConnectBncDialog.changeToolbar {
  if ($xdid($hget($1,dialog.name),2).sel == 0) {
    xdid -t $hget($1,dialog.name) 75 1 +d
    xdid -t $hget($1,dialog.name) 75 3 +
    xdid -t $hget($1,dialog.name) 75 4 +d
    xdid -t $hget($1,dialog.name) 75 5 +d

  }
  else {
    if ($hget($1,bnc.mode) == new) {
      xdid -t $hget($1,dialog.name) 75 1 +d
      xdid -t $hget($1,dialog.name) 75 3 +
      xdid -t $hget($1,dialog.name) 75 4 +d
      xdid -t $hget($1,dialog.name) 75 5 +d
    }
    elseif ($hget($1,bnc.mode) == edit) {
      xdid -t $hget($1,dialog.name) 75 1 +d
      xdid -t $hget($1,dialog.name) 75 3 +
      xdid -t $hget($1,dialog.name) 75 4 +d
      xdid -t $hget($1,dialog.name) 75 5 +d
    }
    else {
      xdid -t $hget($1,dialog.name) 75 1 +
      xdid -t $hget($1,dialog.name) 75 3 +
      xdid -t $hget($1,dialog.name) 75 4 +
      xdid -t $hget($1,dialog.name) 75 5 +
    }
  }
}

/*
* Füllt die BedienElemente mit den daten zum ausgewählten Bouncer
*
* @param $1 dcConnectBncDialog objekt
* @return 1
*/
alias -l dcConnectBncDialog.setBouncerData {
  .noop $dcDialog($1,3-9,80).disableControls
  .noop $dcDialog($1,3,5-6,8-9).clearControls
  .noop $dcDialog($1,4,7).uncheckControls
  .noop $dcConnectBncDialog($1).changeToolbar
  if ($dcConnectBnc($hget($1,connect.bnc.obj),$xdid($hget($1,dialog.name),2,$xdid($hget($1,dialog.name),2).sel).text).setBouncer) {
    xdid -a $hget($1,dialog.name) 3 $dcConnectBnc($hget($1,connect.bnc.obj),current.bnc).get
    xdid -c $hget($1,dialog.name) 4 $xdid($hget($1,dialog.name),4,$chr(9) $dcConnectBnc($hget($1,connect.bnc.obj),type).get $chr(9),W,1).find
    xdid -a $hget($1,dialog.name) 5 $dcConnectBnc($hget($1,connect.bnc.obj),address).get
    if ($left($dcConnectBnc($hget($1,connect.bnc.obj),port).get,1) == $chr(43)) {
      xdid -a $hget($1,dialog.name) 6 $mid($dcConnectBnc($hget($1,connect.bnc.obj),port).get,2)
      xdid -c $hget($1,dialog.name) 7
    }
    else {
      xdid -a $hget($1,dialog.name) 6 $dcConnectBnc($hget($1,connect.bnc.obj),port).get
    }
    xdid -a $hget($1,dialog.name) 8 $dcConnectBnc($hget($1,connect.bnc.obj),user).get
    xdid -a $hget($1,dialog.name) 9 $dcConnectBnc($hget($1,connect.bnc.obj),pwd).get

  }
  else {
    .noop $dcx(MsgBox,ok error modal owner $dialog($hget($1,dialog.name)).hwnd $chr(9) Fehler $chr(9) BouncerDaten konnten nicht ermittelt werden)
  }
  return 1
}

/*
* Ein Bouncer wurde ausgewählt
*
* @param $1 dcConnectBncDialog objekt
* @return 1
*/
alias -l dcConnectBncDialog.selectBNC {
  if ($xdid($hget($1,dialog.name),2).sel != $hget($1,bnc.sel)) {
    hadd $1 bnc.sel $xdid($hget($1,dialog.name),2).sel
    hdel $1 bnc.mode
    .noop $dcConnectBncDialog($1).setBouncerData
  }
  return 1  
}

/*
* Fügt einen neuen Bouncer hinzu
*
* @param $1 dcConnectBncDialog objekt
* @return 1
*/
alias -l dcConnectBncDialog.newBnc {
  xdid -u $hget($1,dialog.name) 2
  .noop $dcDialog($1,3-9,80).enableControls
  .noop $dcDialog($1,3,5-6,8-9).clearControls
  .noop $dcDialog($1,4,7).uncheckControls
  .noop $dcConnectBncDialog($1).changeToolbar
  .noop $dcConnectBnc($hget($1,connect.bnc.obj)).clearData
  hadd $1 bnc.mode new
  return 1
}

/*
* Bearbeitet einen ausgewählten Bouncer
*
* @param $1 dcConnectBncDialog objekt
* @return 1
*/
alias -l dcConnectBncDialog.editBnc {
  .noop $dcDialog($1,3-9,80).enableControls
  .noop $dcConnectBncDialog($1).changeToolbar
  hadd $1 bnc.mode edit
  return 1
}

/*
* Löscht einen ausgewählten Bouncer
*
* @param $1 dcConnectBncDialog objekt
* @return 1
*/
alias -l dcConnectBncDialog.delBnc {
  if ($dcConnectBnc($hget($1,connect.bnc.obj)).delBnc) {
    xdid -d $hget($1,dialog.name) 2 $xdid($hget($1,dialog.name),2).sel
    .noop $dcDialog($1,3-9,80).disableControls
    .noop $dcDialog($1,3,5-6,8-9).clearControls
    .noop $dcDialog($1,4,7).uncheckControls
    .noop $dcConnectBncDialog($1).changeToolbar
    .noop $dcx(MsgBox,ok exclamation modal owner $dialog($hget($1,dialog.name)).hwnd $chr(9) OK $chr(9) Bouncer wurde gelöscht)
  }
  else {
    .noop $dcx(MsgBox,ok error modal owner $dialog($hget($1,dialog.name)).hwnd $chr(9) Fehler $chr(9) Bouncer konnte nicht gelöscht werden)
  }
  return 1
}

/*
* Speichert die Bnc Daten
*
* @param $1 dcConnectBncDialog objekt
* @return 1
*/
alias -l dcConnectBncDialog.saveBncData {
  if ($xdid($hget($1,dialog.name),7).state == 1) { var %port $chr(43) $+ $xdid($hget($1,dialog.name),6).text }
  else { var %port $xdid($hget($1,dialog.name),6).text }
  if ($dcConnectBnc($hget($1,connect.bnc.obj),$xdid($hget($1,dialog.name),3).text,$xdid($hget($1,dialog.name),4).seltext, $&
    $xdid($hget($1,dialog.name),5).text,%port,$xdid($hget($1,dialog.name),8).text,$xdid($hget($1,dialog.name),9).text).saveBncData) {
    if ($hget($1,bnc.mode) == new) {
      xdid -a $hget($1,dialog.name) 2 0 $xdid($hget($1,dialog.name),3).text
    }
    elseif ($hget($1,bnc.mode) == edit) {
      var %sel $xdid($hget($1,dialog.name),2).sel
      xdid -o $hget($1,dialog.name) 2 $xdid($hget($1,dialog.name),2).sel $xdid($hget($1,dialog.name),3).text
      xdid -c $hget($1,dialog.name) 2 %sel
    }

    .noop $dcx(MsgBox,ok exclamation modal owner $dialog($hget($1,dialog.name)).hwnd $chr(9) OK $chr(9) Daten gespeichert)

    hadd $1 bnc.mode edit
  }
  else {
    .noop $dcError($dcConnectBnc($hget($1,connect.bnc.obj)).getErrorObject,$dialog($hget($1,dialog.name)).hwnd).showDialog
  }
  return 1
}

/*
* Verbindet zu einem Bnc
*
* @param $1 dcConnectBncDialog objekt
* @return 1
*/
alias -l dcConnectBncDialog.connect {
  .noop $dcConnectBnc($hget($1,connect.bnc.obj)).connect
  return 1
}

/*
* Wird durch den Config-Dialog aufgerufen, initalisiert den Dialog
*
* @param $1 dcConfig objekt
*/
alias dc.connectBouncer.createPanel { 
  set %connect.bnc.dialog.obj $dcConnectBncDialog($dcConfig($1,dialog.name).get,$dcConfig($1,currentPanel.dbhash).get)
}

/*
* Wird durch den Config-Dialog aufgerufen, zerstört den Dialog
*/
alias dc.connectBouncer.destroyPanel {
  .noop $dcConnectBncDialog(%connect.bnc.dialog.obj).destroy
  unset %connect.bnc.*
}

/*
* Verwaltet Dialog-Ereignisse wie Mausklicks, Tastatureingaben, ...
*
* @param $1 DialogName
* @param $2 Ereignis
* @param $3 Betroffene ID
* @param $4 sonstiges
*/
alias dc.connectBouncer.events { 
  if ($2 == sclick) {
    if ($3 == 2) { .noop $dcConnectBncDialog(%connect.bnc.dialog.obj).selectBNC }
    elseif ($3 == 75) {
      if ($4 == 1) { .noop $dcConnectBncDialog(%connect.bnc.dialog.obj).connect }
      elseif ($4 == 3) { .noop $dcConnectBncDialog(%connect.bnc.dialog.obj).newBNC }  
      elseif ($4 == 4) { .noop $dcConnectBncDialog(%connect.bnc.dialog.obj).editBNC }
      elseif ($4 == 5) { .noop $dcConnectBncDialog(%connect.bnc.dialog.obj).delBNC }
    }
    elseif ($3 == 80) { .noop $dcConnectBncDialog(%connect.bnc.dialog.obj).saveBncData }
  }
}