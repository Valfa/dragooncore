/*
* DragoonCore Server Zentrale
*
* @author Valfa
* @version 1.0
*
* Server/Netzwerk Verwaltung mit Bouncer Support und Multi-Server AutoConnect
*/

/*
* Class Alias
* var %var $dcConnect
*
* @param $1 Datenbank objekt (optional)
*/
alias dcConnect {
  var %this = dcConnect           | ; Name of Object (Alias name)
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
  return $dcConnect.init(%x,$1)

  :destroy
  return $dcConnect.destroy($1)

  :getErrorObject
  return $hget($1,error.obj)

  :setNetwork
  return $dcConnect.setNetwork($1,$2)

  :getNetworkData
  return $dcConnect.getNetworkData($1)

  :getDefaultIdent
  return $dcConnect.getDefaultIdent($1)

  :getNetworkIdent
  return $dcConnect.getNetworkIdent($1)

  :getIdent
  return $dcConnect.getIdent($1,$2,$3,$4)

  :delNetwork
  return $dcConnect.delNetwork($1)

  :saveIdent
  return $dcConnect.saveIdent($1,$2,$3,$4,$5,$6)

  :checkIdent
  return $dcConnect.checkIdent($1,$2,$3,$4,$5)

  :prepareNewPerform
  return $dcConnect.prepareNewPerform($1)

  :addPerformLine
  return $dcConnect.addPerformLine($1,$2)
}

/*
* Initialisiert ein dcConnect Objekt
*
* @param $1 dcConnect Objekt
* @param $2 dbhash (obtional)
* @return dcConnect objekt
*/
alias -l dcConnect.init {
  if ($2 == $null || $hget($2,database) != modul_connect) { 
    var %db $dbs(modul_connect)
    hadd %db createDB 1
  }
  else {
    var %db $2
    hadd %db createDB 0
  }
  hadd $1 dbhash %db
  hadd $1 dbhash.local 0
  hadd $1 error.obj $dcError
  hadd $1 ident.default.nick $null
  hadd $1 ident.default.anick $null
  hadd $1 ident.default.emailaddr $null
  hadd $1 ident.default.fullname $null
  hadd $1 ident.local.nick $null
  hadd $1 ident.local.anick $null
  hadd $1 ident.local.emailaddr $null
  hadd $1 ident.local.fullname $null
  hadd $1 perform 0
  hadd $1 network $null
  hadd $1 limit_get perform
  .noop $dcConnect($1,0).getDefaultIdent
  return $1
}

/*
* zerstört ein dcConnect objekt
*
* @param $1 dcConnect objekt
* @return 1
*/
alias -l dcConnect.destroy {
  .noop $dcError($hget($1,error.obj)).destroy
  if ($hget($1,createDB) == 1) {
    .noop $dbs($hget($1,dbhash)).destroy
  }
  if ($hget($1,perform) != 0) {
    .noop $dbsList($hget($1,perform)).destroy
  }
  if ($hget($1,dbhash.local) != 0) {
    .noop $dbs($hget($1,dbhash.local)).destroy
  }
  .noop $baseClass($1).destroy
  return 1
}

/*
* Setzt das aktuelle Netzwerk
*
* @param $1 dcConnect objekt
* @param $2 Netzwerk
* @return 1
*/
alias -l dcConnect.setNetwork {
  if ($hget($1,perform) != 0) {
    .noop $dbsList($hget($1,perform)).destroy
    hadd $1 perform 0
  }
  if ($hget($1,dbhash.local) != 0) {
    .noop $dbs($hget($1,dbhash.local)).destroy
    hadd $1 dbhash.local 0
  }
  hadd $1 network $2
  hadd $1 dbhash.local $dbs(modul_connect,$2,r)
  hadd $1 ident.local.nick $null
  hadd $1 ident.local.anick $null
  hadd $1 ident.local.emailaddr $null
  hadd $1 ident.local.fullname $null
  .noop $dcConnect($1).getNetworkData
  return 1
}

/*
* Ermittelt die Standard ident Informationen
*
* @param $1 dcConnect objekt
* @return 1
*/
alias -l dcConnect.getDefaultIdent {
  .noop $dbs($hget($1,dbhash),ident).setSection

  if ($dbs($hget($1,dbhash),nick).getUserValue != $null) {
    hadd $1 ident.default.nick $dbs($hget($1,dbhash),nick).getUserValue
  }
  else {
    hadd $1 ident.default.nick $dbs($hget($1,dbhash),nick).getScriptValue
  }
  if ($dbs($hget($1,dbhash),anick).getUserValue != $null) {
    hadd $1 ident.default.anick $dbs($hget($1,dbhash),anick).getUserValue
  }
  else {
    hadd $1 ident.default.anick $dbs($hget($1,dbhash),anick).getScriptValue
  }
  if ($dbs($hget($1,dbhash),fullname).getUserValue != $null) {
    hadd $1 ident.default.fullname $dbs($hget($1,dbhash),fullname).getUserValue
  }
  else {
    hadd $1 ident.default.fullname $dbs($hget($1,dbhash),fullname).getScriptValue
  }
  if ($dbs($hget($1,dbhash),emailaddr).getUserValue != $null) {
    hadd $1 ident.default.emailaddr $dbs($hget($1,dbhash),emailaddr).getUserValue
  }
  else {
    hadd $1 ident.default.emailaddr $dbs($hget($1,dbhash),emailaddr).getScriptValue
  }
  return 1
}

/*
* Bestimmt die ident für das aktive Netzwerk
*
* @param $1 dcConnect objekt
* @return 1
*/
alias -l dcConnect.getNetworkIdent {
  if ($hget($1,dbhash.local)) {
    .noop $dbs($hget($1,dbhash.local),ident).setSection
    hadd $1 ident.local.nick $dbs($hget($1,dbhash.local),nick).getUserValue
    hadd $1 ident.local.anick $dbs($hget($1,dbhash.local),anick).getUserValue
    hadd $1 ident.local.emailaddr $dbs($hget($1,dbhash.local),emailaddr).getUserValue
    hadd $1 ident.local.fullname $dbs($hget($1,dbhash.local),fullname).getUserValue
  }
  return 1
}

/*
* Gibt die Ident zurück
*
* @param $1 dcConnect objekt
* @param $2 0 (default) oder 1 (aktuell gesetztes Netzwerk)
* @param $3 0 (einzelner Wert) oder 1 (vollständig)
* @param $4 (optional) wenn $2 0, dann Name des wertes (nick,anick,emailaddr,fullname)
* @return ident wert, ident String oder $null
*/
alias -l dcConnect.getIdent {
  if ($3 == 1) {
    var %nick $hget($1,ident.default.nick) 
    var %anick $hget($1,ident.default.anick) 
    var %emailaddr $hget($1,ident.default.emailaddr) 
    var %fullname $hget($1,ident.default.fullname)
    if ($2 == 1) {
      if ($hget($1,ident.local.nick) != $null) { var %nick $hget($1,ident.local.nick) }
      if ($hget($1,ident.local.anick) != $null) { var %anick $hget($1,ident.local.anick) }
      if ($hget($1,ident.local.emailaddr) != $null) { var %emailaddr $hget($1,ident.local.emailaddr) }
      if ($hget($1,ident.local.fullname) != $null) { var %fullname $hget($1,ident.local.fullname) }
    }
    return %nick %anick %emailaddr %fullname
  }
  else {
    if ($4 == nick || $4 == anick || $4 == emailaddr || $4 == fullname) {
      if ($2 == 0) { var %pre ident.default. }
      else { var %pre ident.local. }
      return $hget($1,%pre $+ $4)
    }
    else {
      return $null
    }
  }

}

/*
* Ermittelt gespeicherte daten für ein Bestimmtes Netzwerk
*
* @param $1 dcConnectObjekt
* @return 1
*/
alias -l dcConnect.getNetworkData {
  .noop $dcConnect($1).getNetworkIdent
  hadd $1 perform $dbsList($hget($1,dbhash.local),user,perform)
  return 1
}

/*
* Löscht ein Netzwerk
*
* @param $1 dcConnect objekt
* @return 1 oder 0
*/
alias -l dcConnect.delNetwork {
  .noop $dcError($hget($1,error.obj)).clear
  if ($hget($1,network) != $null) {
    var %list $serverList($hget($1,network))
    .noop $serverList(%list).prepareWhile
    while ($serverList(%list).next) {
      var %server $serverData($serverList(%list).getValue)
      if ($serverData(%server).delServer == 0) {
        .noop $dcError($hget($1,error.obj),$serverData(%server,address).get konnte nicht gelöscht werden).add
        .noop $serverData(%server).destroy
        break
      }
      .noop $serverData(%server).destroy
    }
    .noop $serverList(%list).destroy
    if ($dcError($hget($1,error.obj)).count > 0) {
      return 0
    }
    else {
      return 1
    }
  }
  else {
    .noop $dcError($hget($1,error.obj),Netzwerk nicht gesetzt).add
  }
}

/*
* Überprüft die Ident Informationen
*
* @param $1 dcConnect objekt
* @param $2 nick
* @param $3 anick
* @param $4 emailaddr
* @param $5 fullname
* @return 1 oder 0
*/
alias -l dcConnect.checkIdent {
  if ($2 != $null && $regex(regex,$2,[[:space:]]) == 1) {
    .noop $dcError($hget($1,error.obj),Nick darf keine Leerzeichen enthalten).add
  }
  if ($3 != $null && $regex(regex,$3,[[:space:]]) == 1) {
    .noop $dcError($hget($1,error.obj),Alternativer Nick darf keine Leerzeichen enthalten).add
  }
  if ($2 != $null && $3 != $null && $2 == $3) {
    .noop $dcError($hget($1,error.obj),Nick und Alternativer Nick duerfen nicht gleich sein).add
  }
  if ($4 != $null && $regex(regex,$4,.+@.+\..+) == 0) {
    .noop $dcError($hget($1,error.obj),E-Mail Addresse ungültig).add
  }
  if ($5 != $null && $regex(regex,$5,^[[:space:]]|[[:space:]]$) == 1) {
    .noop $dcError($hget($1,error.obj),Name ungültig).add
  }

  if ($dcError($hget($1,error.obj)).count > 0) {
    return 0
  }
  else {
    return 1
  }  
}

/*
* Speichert die Ident Informationen
*
* @param $1 dcConnect objekt
* @param $2 default? 1 oder 0
* @param $3 nick
* @param $4 anick
* @param $5 emailaddr
* @param $6 fullname
* @return 1 oder 0
*/
alias -l dcConnect.saveIdent {
  .noop $dcerror($hget($1,error.obj)).clear
  if ($2 == 0 && $hget($1,dbhash.local) == 0) {
    .noop $dcError($hget($1,error.obj),Netzwerk wurde nicht gesetzt).add
    return 0
  }  
  if ($dcConnect($1,$3,$4,$5,$6).checkIdent) {
    if ($2 == 1) { var %db $hget($1,dbhash) | var %pre ident.default. }
    else { var %db $hget($1,dbhash.local) | var %pre ident.local. }
    .noop $dbs(%db,ident).setSection
    .noop $dbs(%db).deleteUserSection
    if ($3 != $null) { .noop $dbs(%db,nick,$3).setUserValue | hadd $1 %pre $+ nick $3 }
    if ($4 != $null) { .noop $dbs(%db,anick,$4).setUserValue | hadd $1 %pre $+ anick $4 }
    if ($5 != $null) { .noop $dbs(%db,emailaddr,$5).setUserValue | hadd $1 %pre $+ emailaddr $5 }
    if ($6 != $null) { .noop $dbs(%db,fullname,$6).setUserValue | hadd $1 %pre $+ fullname $6 }
    return 1
  }
  else {
    return 0
  }
}

/*
* Bereitet das Speichern eines neuen Performs hinzu
*
* @param $1 dcConnect objekt
* @return 1 oder 0
*/
alias -l dcConnect.prepareNewPerform {
  .noop $dcerror($hget($1,error.obj)).clear
  if ($hget($1,dbhash.local) == 0) {
    .noop $dcError($hget($1,error.obj),Netzwerk wurde nicht gesetzt).add
    return 0
  } 
  .noop $dbs($hget($1,dbhash.local),perform).setSection
  .noop $dbs($hget($1,dbhash.local)).deleteUserSection
  hadd $1 perform.line 0
  return 1
}

/*
* Fügt dem Perform eine neue Zeile hinzu
*
* @param $1 dcConnect objekt
* @param $2 "Perform-Code"-Zeile
* @return 1 oder 0
*/
alias -l dcConnect.addPerformLine {
  if ($2 != $null && $regex(regex,$2,^[[:space:]]|[[:space:]]$) == 1) {
    .noop $dcError($hget($1,error.obj),Perform Zeile enthält unzulässige Leerzeichen).add
  }
  if ($dcError($hget($1,error.obj)).count > 0) {
    .noop $dbs($hget($1,dbhash.local)).deleteUserSection
    return 0
  }
  else {
    if ($2 != $null) {
      hinc $1 perform.line
      .noop $dbs($hget($1,dbhash.local),n $+ $hget($1,perform.line),$2).setUserValue
    }
    return 1
  }  
}

/*
* Class Alias
* var %var $dcConnectDialog
*
* @param $1 dialog name
*/
alias dcConnectDialog {
  var %this = dcConnectDialog           | ; Name of Object (Alias name)
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
  return $dcConnectDialog.init(%x,$1)

  :destroy
  return $dcConnectDialog.destroy($1)

  :createControls
  return $dcConnectDialog.createControls($1)

  :createNetworkControls
  return $dcConnectDialog.createNetworkControls($1)

  :createServerControls
  return $dcConnectDialog.createServerControls($1)

  :fillNetworkList
  return $dcConnectDialog.fillNetworkList($1)

  :loadServers
  return $dcConnectDialog.loadServers($1)

  :setNetworkControls
  return $dcConnectDialog.setNetworkControls($1)

  :setServerControls
  return $dcConnectDialog.setServerControls($1)

  :connect
  return $dcConnectDialog.connect($1)

  :delNetwork
  return $dcConnectDialog.delNetwork($1)

  :addNetwork
  return $dcConnectDialog.addNetwork($1)

  :newServer
  return $dcConnectDialog.newServer($1)

  :editServer
  return $dcConnectDialog.editServer($1)

  :delServer
  return $dcConnectDialog.delServer($1)

  :saveNetworkData
  return $dcConnectDialog.saveNetworkData($1)

  :saveServerData
  return $dcConnectDialog.saveServerData($1)

  :changeToolbar2
  return $dcConnectDialog.changeToolbar2($1)

  :selectTreeviewItem
  return $dcConnectDialog.selectTreeviewItem($1)
}

/*
* Initialisiert das dcConnectDialog objekt
*
* @param $1 dcConnectDialog objekt
* @param $2 dialog name
* @param $3 dbhash oder $null
* @return dcConnectDialog objekt
*/
alias -l dcConnectDialog.init {
  hadd $1 connect.obj $dcConnect($3)
  if ($2 != $null) { hadd $1 dialog.name $2 }
  else { hadd $1 dialog.name dcConnect }

  .noop $dcDialog($1,435,540).createBasePanel
  .noop $dcConnectDialog($1).createControls
  .noop $dcConnectDialog($1).createNetworkControls
  .noop $dcConnectDialog($1).fillNetworkList
  .noop $dcConnectDialog($1).setNetworkControls
  .noop $dcConnectDialog($1).loadServers

  return $1
}

/*
* löscht ein dcConnectDialog Objekt
*
* @param $1 dcConnectDialog objekt
* @return 1
*/
alias -l dcConnectDialog.destroy {
  .noop $dcConnect($hget($1,connect.obj)).destroy
  .noop $baseClass($1).destroy
  return 1
}

/*
* Erstellt die Basis BedienElemente
*
* @param $1 dcConnectDialog objekt
* @return 1
*/
alias -l dcConnectDialog.createControls {
  xdid -c $hget($1,dialog.name) 1 100 text 0 0 200 25
  xdid -t $hget($1,dialog.name) 100 Server Verwaltung
  xdid -f $hget($1,dialog.name) 100 + default 14 Arial

  xdid -c $hget($1,dialog.name) 1 101 text 5 25 100 20
  xdid -t $hget($1,dialog.name) 101 Serverliste
  xdid -f $hget($1,dialog.name) 101 + default 10 Verdana

  xdid -c $hget($1,dialog.name) 1 102 text 200 25 235 20
  xdid -t $hget($1,dialog.name) 102 Einstellungen für
  xdid -f $hget($1,dialog.name) 102 + default 10 Verdana

  xdid -c $hget($1,dialog.name) 1 75 toolbar 5 50 190 30 flat list nodivider noauto tooltips
  xdid -l $hget($1,dialog.name) 75 24
  xdid -w $hget($1,dialog.name) 75 +nh 0 images/ico/connect_sl_connect.ico
  xdid -w $hget($1,dialog.name) 75 +nh 0 images/ico/connect_sl_disconnect.ico
  xdid -w $hget($1,dialog.name) 75 +nh 0 images/ico/connect_sl_server_add.ico
  xdid -w $hget($1,dialog.name) 75 +nh 0 images/ico/connect_sl_server_delete.ico

  xdid -w $hget($1,dialog.name) 75 +dhg 0 images/ico/connect_sl_connect.ico
  xdid -w $hget($1,dialog.name) 75 +dhg 0 images/ico/connect_sl_disconnect.ico
  xdid -w $hget($1,dialog.name) 75 +dhg 0 images/ico/connect_sl_server_add.ico
  xdid -w $hget($1,dialog.name) 75 +dhg 0 images/ico/connect_sl_server_delete.ico

  xdid -a $hget($1,dialog.name) 75 1 +l 30 1 $chr(9) Verbindung herstellen
  xdid -a $hget($1,dialog.name) 75 2 +ad 0 0 -
  xdid -a $hget($1,dialog.name) 75 3 +l 30 3 $chr(9) Leeres Netzwerk hinzufügen (temporär)
  xdid -a $hget($1,dialog.name) 75 4 +l 30 4 $chr(9) Netzwerk löschen

  xdid -c $hget($1,dialog.name) 1 76 toolbar 205 50 235 30 flat list nodivider noauto tooltips
  xdid -l $hget($1,dialog.name) 76 24
  xdid -w $hget($1,dialog.name) 76 +nh 0 images/ico/page_white_add.ico
  xdid -w $hget($1,dialog.name) 76 +nh 0 images/ico/page_white_edit.ico
  xdid -w $hget($1,dialog.name) 76 +nh 0 images/ico/page_white_delete.ico

  xdid -w $hget($1,dialog.name) 76 +dhg 0 images/ico/page_white_add.ico
  xdid -w $hget($1,dialog.name) 76 +dhg 0 images/ico/page_white_edit.ico
  xdid -w $hget($1,dialog.name) 76 +dhg 0 images/ico/page_white_delete.ico

  xdid -a $hget($1,dialog.name) 76 1 +l 30 1 $chr(9) Server hinzufügen
  xdid -a $hget($1,dialog.name) 76 2 +ld 30 2 $chr(9) Serverdaten bearbeiten
  xdid -a $hget($1,dialog.name) 76 3 +ld 30 3 $chr(9) Server löschen

  xdid -c $hget($1,dialog.name) 1 2 treeview 5 85 190 455 haslines nohscroll showsel
  xdid -l $hget($1,dialog.name) 2 24
  xdid -w $hget($1,dialog.name) 2 +n 0 images/ico/folder.ico
  xdid -w $hget($1,dialog.name) 2 +n 0 images/ico/folder_error.ico
  xdid -w $hget($1,dialog.name) 2 +n 0 images/ico/folder_star.ico

  xdid -c $hget($1,dialog.name) 1 3 panel 200 85 235 455
  return 1
}

/*
* Erstellt die zusätzlichen Netzwerk-bedienElemente
*
* @param $1 dcConnectDialog objekt
* @return 1
*/
alias -l dcConnectDialog.createNetworkControls {
  xdid -d $hget($1,dialog.name) 1 3
  xdid -c $hget($1,dialog.name) 1 3 panel 200 85 235 455

  xdid -t $hget($1,dialog.name) 102 Einstellungen für $+ $chr(32) $+ $xdid($hget($1,dialog.name),2).seltext

  xdid -c $hget($1,dialog.name) 3 120 text 5 5 200 20
  xdid -t $hget($1,dialog.name) 120 Netzwerk Ident
  xdid -f $hget($1,dialog.name) 120 + default 10 Verdana

  xdid -c $hget($1,dialog.name) 3 121 text 5 25 100 20
  xdid -t $hget($1,dialog.name) 121 Nick
  xdid -c $hget($1,dialog.name) 3 10 edit 5 45 225 20 autohs tabstop tabstop

  xdid -c $hget($1,dialog.name) 3 122 text 5 75 100 20
  xdid -t $hget($1,dialog.name) 122 Alternativer Nick
  xdid -c $hget($1,dialog.name) 3 11 edit 5 95 225 20 autohs tabstop tabstop

  xdid -c $hget($1,dialog.name) 3 123 text 5 125 100 20
  xdid -t $hget($1,dialog.name) 123 E-Mail
  xdid -c $hget($1,dialog.name) 3 12 edit 5 145 225 20 autohs tabstop tabstop

  xdid -c $hget($1,dialog.name) 3 124 text 5 175 100 20
  xdid -t $hget($1,dialog.name) 124 Name
  xdid -c $hget($1,dialog.name) 3 13 edit 5 195 225 20 autohs tabstop tabstop

  xdid -c $hget($1,dialog.name) 3 14 check 5 225 225 20 tabstop
  xdid -t $hget($1,dialog.name) 14 als Standard

  xdid -c $hget($1,dialog.name) 3 125 text 5 255 200 20
  xdid -t $hget($1,dialog.name) 125 Netzwerk Perform
  xdid -f $hget($1,dialog.name) 125 + default 10 Verdana

  xdid -c $hget($1,dialog.name) 3 15 edit 5 275 225 150 autovs return multi tabstop

  xdid -c $hget($1,dialog.name) 3 80 button 62 435 100 20 tabstop
  xdid -t $hget($1,dialog.name) 80 Speichern
  return 1
}

/*
* Erstellt die zusätzlichen Server-bedienElemente
*
* @param $1 dcConnectDialog objekt
* @return 1
*/
alias -l dcConnectDialog.createServerControls {
  xdid -d $hget($1,dialog.name) 1 3
  xdid -c $hget($1,dialog.name) 1 3 panel 200 85 235 455

  xdid -t $hget($1,dialog.name) 102 Einstellungen für $+ $chr(32) $+ $xdid($hget($1,dialog.name),2,$gettok($xdid($hget($1,dialog.name),2).selpath,1,32)).text

  xdid -c $hget($1,dialog.name) 3 103 text 5 5 200 20
  xdid -t $hget($1,dialog.name) 103 Serverdaten
  xdid -f $hget($1,dialog.name) 103 + default 10 Verdana

  xdid -c $hget($1,dialog.name) 3 104 text 5 25 100 20
  xdid -t $hget($1,dialog.name) 104 Beschreibung
  xdid -c $hget($1,dialog.name) 3 4 edit 5 45 225 20 autohs tabstop disabled

  xdid -c $hget($1,dialog.name) 3 105 text 5 75 100 20
  xdid -t $hget($1,dialog.name) 105 Server Addresse
  xdid -c $hget($1,dialog.name) 3 5 edit 5 95 225 20 autohs tabstop disabled

  xdid -c $hget($1,dialog.name) 3 106 text 5 125 100 20
  xdid -t $hget($1,dialog.name) 106 Ports
  xdid -c $hget($1,dialog.name) 3 6 edit 5 145 225 20 autohs tabstop disabled

  xdid -c $hget($1,dialog.name) 3 107 text 5 175 100 20
  xdid -t $hget($1,dialog.name) 107 SSL-Ports
  xdid -c $hget($1,dialog.name) 3 7 edit 5 195 225 20 autohs tabstop disabled

  xdid -c $hget($1,dialog.name) 3 108 text 5 225 100 20
  xdid -t $hget($1,dialog.name) 108 Passwort
  xdid -c $hget($1,dialog.name) 3 8 edit 5 245 225 20 autohs tabstop password disabled

  xdid -c $hget($1,dialog.name) 3 81 button 62 300 100 20 disabled
  xdid -t $hget($1,dialog.name) 81 Speichern
  return 1
}

/*
* Lädt die Server zum ausgewählten Netzwerk
*
* @param $1 dcConnectDialog objekt
* @param $2 expand 1 (optional)
* @return 1
*/
alias -l dcConnectDialog.loadServers {
  if ($xdid($hget($1,dialog.name),2,$xdid($hget($1,dialog.name),2).selpath).num == 0) {
    var %serverList $serverList($xdid($hget($1,dialog.name),2).seltext)
    .noop $serverList(%serverList).prepareWhile
    while ($serverList(%serverList).next) {
      var %serverData $serverData($serverList(%serverList).getValue)
      xdid -a $hget($1,dialog.name) 2 $+($xdid($hget($1,dialog.name),2).selpath $serverList(%serverList).getPos,$chr(9),+ 0 0 0 0 0 $rgb(0,0,255) $rgb(255,0,255) $serverData(%serverData,desc).get,$chr(9),$serverList(%serverList).getValue)
      .noop $serverData(%serverData).destroy
    }
    .noop $serverList(%serverList).destroy
    if ($2 == 1) {
      xdid -t $hget($1,dialog.name) 2 +e $xdid($hget($1,dialog.name),2).selpath
    }
  }
  return 1
}

/*
* Füllt die netzwerk Liste auf
*
* @param $1 dcConnectDialog objekt
* @return 1
*/
alias -l dcConnectDialog.fillNetworkList {
  var %networkList $networkList
  .noop $networkList(%networkList).prepareWhile
  while ($networkList(%networkList).next) {
    xdid -a $hget($1,dialog.name) 2 $+($networkList(%networkList).getPos,$chr(9),+ 1 1 0 0 0 $rgb(0,0,255) $rgb(255,0,255) $networkList(%networkList).getValue,$chr(9),$networkList(%networkList).getValue)

  }
  .noop $networkList(%networkList).destroy
  xdid -c $hget($1,dialog.name) 2 1
  return 1
}

/*
* Füllt die Netzwerk BedienElemente
*
* @param $1 dcConnectDialog objekt
* @return 1
*/
alias -l dcConnectDialog.setNetworkControls {
  .noop $dcConnect($hget($1,connect.obj),$xdid($hget($1,dialog.name),2).seltext).setNetwork
  var %ident $dcConnect($hget($1,connect.obj),0,1).getIdent
  xdid -E $hget($1,dialog.name) 10 $gettok(%ident,1,32)
  xdid -E $hget($1,dialog.name) 11 $gettok(%ident,2,32)
  xdid -E $hget($1,dialog.name) 12 $gettok(%ident,3,32)
  xdid -E $hget($1,dialog.name) 13 $gettok(%ident,4-,32)

  var %ident.nick $dcConnect($hget($1,connect.obj),1,0,nick).getIdent
  var %ident.anick $dcConnect($hget($1,connect.obj),1,0,anick).getIdent
  var %ident.emailaddr $dcConnect($hget($1,connect.obj),1,0,emailaddr).getIdent
  var %ident.fullname $dcConnect($hget($1,connect.obj),1,0,fullname).getIdent
  if (%ident.nick != $null) { xdid -ra $hget($1,dialog.name) 10 %ident.nick }
  if (%ident.anick != $null) { xdid -ra $hget($1,dialog.name) 11 %ident.anick }
  if (%ident.emailaddr != $null) { xdid -ra $hget($1,dialog.name) 12 %ident.emailaddr }
  if (%ident.fullname != $null) { xdid -ra $hget($1,dialog.name) 13 %ident.fullname }

  var %list $dcConnect($hget($1,connect.obj),perform).get
  if (%list) {
    .noop $dbsList(%list).prepareWhile
    while ($dbsList(%list).next) {
      xdid -i $hget($1,dialog.name) 15 $dbsList(%list).getPos $dbsList(%list).getValue
    }
  }
  return 1
}

/*
* Füllt die Server BedienElemente
*
* @param $1 dcConnectDialog objekt
* @return 1
*/
alias -l dcConnectDialog.setServerControls {
  set %connect.sl.serverhash $serverData($xdid($hget($1,dialog.name),2,$xdid($hget($1,dialog.name),2).selpath).tooltip)
  xdid -ra $hget($1,dialog.name) 4 $serverData(%connect.sl.serverhash,desc).get
  xdid -ra $hget($1,dialog.name) 5 $serverData(%connect.sl.serverhash,address).get
  xdid -ra $hget($1,dialog.name) 6 $serverData(%connect.sl.serverhash,ports).get
  xdid -ra $hget($1,dialog.name) 7 $serverData(%connect.sl.serverhash,ssl-ports).get
  xdid -ra $hget($1,dialog.name) 8 $serverData(%connect.sl.serverhash,pass).get
  .noop $serverData(%connect.sl.serverhash).destroy
  unset %connect.sl.serverhash
  return 1
}

/*
* Stellt die Verbindung zum Ausgewählten Server her
*
* @param $1 dcConnectDialog objekt
* @return 1
*/
alias -l dcConnectDialog.connect {
  .noop $dcConnectDialog($1).loadServers
  if ($numtok($xdid($hget($1,dialog.name),2).selpath,32) == 1 && $xdid($hget($1,dialog.name),2,$xdid($hget($1,dialog.name),2).selpath).num > 0) {
    .server -m $xdid($hget($1,dialog.name),2).seltext
  }
  elseif ($numtok($xdid($hget($1,dialog.name),2).selpath,32) == 2) {
    .server -m $xdid($hget($1,dialog.name),2,$xdid($hget($1,dialog.name),2).selpath).tooltip
  }
}

/*
* Fügt der Liste ein leeres Netzwerk hinzu
*
* @param $1 dcConnectDialog objekt
* @return 1
*/
alias -l dcConnectDialog.addNetwork {
  var %net $?="Name des Netzwerkes"
  if (%net == none) {
    .noop $dcx(MsgBox,ok error modal owner $dialog($hget($1,dialog.name)).hwnd $chr(9) Fehler $chr(9) Netzwerk darf nicht $qt(none) lauten)
    return 1
  }
  elseif (%net != $null) {
    if ($xdid($hget($1,dialog.name),2,$chr(9) %net $chr(9),W,0,root).find == 0) {
      xdid -a $hget($1,dialog.name) 2 $+($calc($xdid($hget($1,dialog.name),2,root).num + 1),$chr(9),+ 2 2 0 0 0 $rgb(0,0,255) $rgb(255,0,255) %net,$chr(9),%net)
    }
    else {
      .noop $dcx(MsgBox,ok error modal owner $dialog($hget($1,dialog.name)).hwnd $chr(9) Fehler $chr(9) Netzwerk bereits in Liste)
    }
  }
  return 1
}

/*
* Löscht ein Netzwerk
*
* @param $1 dcConnectDialog objekt
* @return 1
*/
alias -l dcConnectDialog.delNetwork {
  if ($dcConnect($hget($1,connect.obj)).delNetwork) {
    var %sel $gettok($xdid($hget($1,dialog.name),2).selpath,1,32)
    xdid -c $hget($1,dialog.name) 2 %sel
    xdid -d $hget($1,dialog.name) 2 %sel
    if ($xdid($hget($1,dialog.name),2,%sel).text == $null) {
      var %sel $calc(%sel - 1)
    }
    if (%sel == 0) { var %sel 1 }
    xdid -c $hget($1,dialog.name) 2 %sel
  }
  else {
    .noop $dcx(MsgBox,ok error modal owner $dialog($hget($1,dialog.name)).hwnd $chr(9) Fehler $chr(9) Netzwerk löschen fehlgeschlagen)
  }
  return 1
}

/*
* Fügt einem Netzwerk einen neuen Server hinzu
*
* @param $1 dcConnectDialog objekt
* @return 1
*/
alias -l dcConnectDialog.newServer {
  .noop $dcConnectDialog($1).createServerControls
  .noop $dcDialog($1,4-8,81).enableControls
  hadd $1 server.mode new
  .noop $dcConnectDialog($1).changeToolbar2
  return 1
}

/*
* Bearbeitet die Daten für einen ausgewählten Server
*
* @param $1 dcConnectDialog objekt
* @return 1
*/
alias -l dcConnectDialog.editServer {
  .noop $dcDialog($1,4-8,81).enableControls
  hadd $1 server.mode edit
  .noop $dcConnectDialog($1).changeToolbar2
  return 1
}

/*
* Löscht einen ausgewählten Server
*
* @param $1 dcConnectDialog objekt
* @return 1
*/
alias -l dcConnectDialog.delServer {
  var %serverData $serverData($xdid($hget($1,dialog.name),2,$xdid($hget($1,dialog.name),2).selpath).tooltip)
  if ($serverData(%serverData).delServer) {
    var %sel $xdid($hget($1,dialog.name),2).selpath
    xdid -d $hget($1,dialog.name) 2 %sel
    var %sel.root $gettok(%sel,1,32)
    if ($xdid($hget($1,dialog.name),2,%sel.root).num == 0) {
      xdid -c $hget($1,dialog.name) 2 %sel.root
      xdid -j $hget($1,dialog.name) 2 %sel.root $chr(9) 2 2 0
    }
    else {
      xdid -c $hget($1,dialog.name) 2 %sel
    }
  }
  else {
    .noop $dcx(MsgBox,ok error modal owner $dialog($hget($1,dialog.name)).hwnd $chr(9) Fehler $chr(9) Server löschen fehlgeschlagen )
  }
  .noop $serverData(%serverData).destroy
  return 1
}

/*
* Speichert die NetzwerkDaten
*
* @param $1 dcConnectDialog objekt
* @return 1 oder 0
*/
alias -l dcConnectDialog.saveNetworkData {
  if (!$dcConnect($hget($1,connect.obj),$xdid($hget($1,dialog.name),14).state,$xdid($hget($1,dialog.name),10).text,$xdid($hget($1,dialog.name),11).text, $&
    $xdid($hget($1,dialog.name),12).text,$xdid($hget($1,dialog.name),13).text).saveIdent) {
    .noop $dcError($dcConnect($hget($1,connect.obj)).getErrorObject,$dialog($hget($1,dialog.name)).hwnd).showDialog
    return 0
  }
  if ($xdid($hget($1,dialog.name),14).state == 1) {
    xdid -E $hget($1,dialog.name) 10 $xdid($hget($1,dialog.name),10).text
    xdid -E $hget($1,dialog.name) 11 $xdid($hget($1,dialog.name),11).text
    xdid -E $hget($1,dialog.name) 12 $xdid($hget($1,dialog.name),12).text
    xdid -E $hget($1,dialog.name) 13 $xdid($hget($1,dialog.name),13).text
  }
  .noop $dcConnect($hget($1,connect.obj)).prepareNewPerform

  var %i 1
  var %lines $xdid($hget($1,dialog.name),15).num
  while (%i <= %lines) {
    if (!$dcConnect($hget($1,connect.obj),$xdid($hget($1,dialog.name),15,%i).text).addPerformLine) {
      .noop $dcError($dcConnect($hget($1,connect.obj)).getErrorObject,$dialog($hget($1,dialog.name)).hwnd).showDialog
      return 0
    }
    inc %i
  }
  .noop $dcx(MsgBox,ok exclamation modal owner $dialog($hget($1,dialog.name)).hwnd $chr(9) OK $chr(9) Netzwerk Informationen erfolgreich gespeichert)
  hdel $1 server.mode
  return 1
}

/*
* Speichert die Server Daten
*
* @param $1 dcConnectDialog objekt
* @return 1
*/
alias -l dcConnectDialog.saveServerData {
  if ($hget($1,server.mode) == new) { var %server $serverData }
  else { var %server $serverData($xdid($hget($1,dialog.name),2,$xdid($hget($1,dialog.name),2).selpath).tooltip) }
  var %path $gettok($xdid($hget($1,dialog.name),2).selpath,1,32)
  .noop $serverData(%server,$xdid($hget($1,dialog.name),2,%path).text).setGroup
  .noop $serverData(%server,$xdid($hget($1,dialog.name),4).text).setDesc
  .noop $serverData(%server,$xdid($hget($1,dialog.name),5).text).setAddress
  .noop $serverData(%server,$xdid($hget($1,dialog.name),6).text).setPorts
  .noop $serverData(%server,$xdid($hget($1,dialog.name),7).text).setSSL-Ports
  .noop $serverData(%server,$xdid($hget($1,dialog.name),8).text).setPass

  if ($serverData(%server).saveServer) {
    if ($hget($1,server.mode) == edit) {
      xdid -o $hget($1,dialog.name) 2 $xdid($hget($1,dialog.name),2).selpath $chr(9) $xdid($hget($1,dialog.name),5).text
      xdid -v $hget($1,dialog.name) 2 $xdid($hget($1,dialog.name),2).selpath $chr(9) $xdid($hget($1,dialog.name),4).text
    }
    else {
      hadd $1 selchange 0
      xdid -j $hget($1,dialog.name) 2 %path $chr(9) 1 1 0
      var %path %path $+ $chr(32) $+ $calc($xdid($hget($1,dialog.name),2,%path).num + 1)
      xdid -a $hget($1,dialog.name) 2 $+(%path,$chr(9),+ 0 0 0 0 0 $rgb(0,0,255) $rgb(255,0,255) $xdid($hget($1,dialog.name),4).text,$chr(9),$xdid($hget($1,dialog.name),5).text)
      xdid -c $hget($1,dialog.name) 2 %path
      xdid -t $hget($1,dialog.name) 2 +e %path
      hadd $1 selchange 1
    }
    hadd $1 server.mode edit
  }
  else {
    .noop $dcError($serverData(%server).getErrorObject,$dialog($hget($1,dialog.name)).hwnd).showDialog
  }
  .noop $serverData(%server).destroy
  return 1
}

/*
* Passt die 2. Toolbar entsprechend der Auswahl an
*
* @param $1 dcConnectDialog objekt
* @return 1
*/
alias -l dcConnectDialog.changeToolbar2 {
  if ($numtok($xdid($hget($1,dialog.name),2).selpath,32) == 1) {
    xdid -t $hget($1,dialog.name) 76 1 +
    xdid -t $hget($1,dialog.name) 76 2 +d
    xdid -t $hget($1,dialog.name) 76 3 +d
  }
  else {
    if ($hget($1,server.mode) == new) {
      xdid -t $hget($1,dialog.name) 76 1 +
      xdid -t $hget($1,dialog.name) 76 2 +d
      xdid -t $hget($1,dialog.name) 76 3 +d
    }
    elseif ($hget($1,server.mode) == edit) {
      xdid -t $hget($1,dialog.name) 76 1 +
      xdid -t $hget($1,dialog.name) 76 2 +d
      xdid -t $hget($1,dialog.name) 76 3 +d
    }
    else {
      xdid -t $hget($1,dialog.name) 76 1 +
      xdid -t $hget($1,dialog.name) 76 2 +
      xdid -t $hget($1,dialog.name) 76 3 +
    }
  }
  return 1
}

/*
* Ein Treeview Item wurde gewählt
*
* @param $1 dcConnectDialog objekt
* @return 1
*/
alias -l dcConnectDialog.selectTreeviewItem {
  if ($hget($1,selchange) != 0) {
    hdel $1 server.mode
    .noop $dcConnectDialog($1).changeToolbar2
    if ($numtok($xdid($hget($1,dialog.name),2).selpath,32) == 1) {
      .noop $dcConnectDialog($1).createNetworkControls
      .noop $dcConnectDialog($1).setNetworkControls  
    }
    else {
      .noop $dcConnectDialog($1).createServerControls
      .noop $dcConnectDialog($1).setServerControls  
    }
  }
  return 1
}

/*
* Wird durch den Config-Dialog aufgerufen, initalisiert den Dialog
*
* @param $1 dcConfig objekt
*/
alias dc.connectServerlist.createPanel { 
  set %connect.dialog.obj $dcConnectDialog($dcConfig($1,dialog.name).get,$dcConfig($1,currentPanel.dbhash).get)
}

/*
* Wird durch den Config-Dialog aufgerufen, zerstört den Dialog
*/
alias dc.connectServerlist.destroyPanel {
  .noop $dcConnectDialog(%connect.dialog.obj).destroy
  unset %connect.*
}

/*
* Verwaltet Dialog-Ereignisse wie Mausklicks, Tastatureingaben, ...
*
* @param $1 DialogName
* @param $2 Ereignis
* @param $3 Betroffene ID
* @param $4 sonstiges
*/
alias dc.connectServerlist.events {
  if (!%connect.dialog.obj) { halt }
  if ($2 == dclick) {
    if ($numtok($xdid($1,2).selpath,32) == 1) {
      .noop $dcConnectDialog(%connect.dialog.obj,1).loadServers
    }
  }
  elseif ($2 == selchange) {
    if ($3 == 2 && $xdid($1,2,root).num > 0 ) { .noop $dcConnectDialog(%connect.dialog.obj).selectTreeviewItem }
  }
  elseif ($2 == sclick) {
    if ($3 == 75) {
      if ($4 == 1) { .noop $dcConnectDialog(%connect.dialog.obj).connect }
      if ($4 == 3) { .noop $dcConnectDialog(%connect.dialog.obj).addNetwork }
      if ($4 == 4) { .noop $dcConnectDialog(%connect.dialog.obj).delNetwork }
    }
    if ($3 == 76) {
      if ($4 == 1) { .noop $dcConnectDialog(%connect.dialog.obj).newServer }
      if ($4 == 2) { .noop $dcConnectDialog(%connect.dialog.obj).editServer }
      if ($4 == 3) { .noop $dcConnectDialog(%connect.dialog.obj).delServer }
    }
    if ($3 == 80) { .noop $dcConnectDialog(%connect.dialog.obj).saveNetworkData }
    if ($3 == 81) { .noop $dcConnectDialog(%connect.dialog.obj).saveServerData } 
  }
}

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

/*
* Class Alias
* var %var $fkeyList
*
* param $1 dbs objekt
*/
alias dcConnectAcList {
  var %this = dcConnectAcList           | ; Name of Object (Alias name)
  var %base = BaseListClass        | ; Name of BaseClass, $null for none  

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
  var %x $baseListClass(%this,%base).init
  return $dcConnectAcList.init(%x,$1)

  :destroy
  return $dcConnectAcList.destroy($1)

  :type
  return $hget($1,type)

  :group
  return $hget($1,group)

  :active
  return $hget($1,active)

  :server
  return $hget($1,server)
}

/*
* Initialisiert die Liste
*
* @param $1 dcConnectAcList objekt
* @param $2 dbs objekt
* @return dcConnectAcList objekt
*/
alias -l dcConnectAcList.init {
  hadd $1 list $dbsList($2,user,autoconnect)
  hadd $1 dbhash $2
  hadd $1 getdata 1
  if ($hget($1,list)) {
    hadd $1 pos 1
    hadd $1 last $dbsList($hget($1,list)).count
    .noop $dcConnectAcList.getData($1)

  }
  else {
    .noop $dcConnectAcList($1).destroy
    return 0
  }
  return $1
}

/*
* Löscht ein dcConnectAcList objekt
*
* @param $1 dcConnectAcList objekt
* @return 1
*/
alias -l dcConnectAcList.destroy {
  if ($hget($1,list)) {
    .noop $dbsList($hget($1,list)).destroy
  }
  .noop $baseClass($1).destroy
  return 1
}

/*
* Ermittelt die Daten für die aktuelle Auswahl
*
* @param $1 dcConnectAcList objekt
* @return 1
*/
alias dcConnectAcList.getData {
  if ($hget($1,list)) {
    .noop $dbsList($hget($1,list),$hget($1,pos)).setPos
    hadd $1 active $gettok($dbsList($hget($1,list)).getValue,1,44)
    var %type $gettok($dbsList($hget($1,list)).getItem,1,95)
    if (%type == SERVER) {
      hadd $1 type Server
      hadd $1 group $gettok($dbsList($hget($1,list)).getItem,2,95)
      hadd $1 server $gettok($dbsList($hget($1,list)).getValue,2,44)
    }
    else {
      hadd $1 type Bouncer
      hadd $1 group $null
      hadd $1 server $gettok($dbsList($hget($1,list)).getItem,2,95)
    }
  }
  return 1
}

/*
* Class Alias
* var %var $dcConnectAC
*
* @param $1 Datenbank objekt (optional)
*/
alias dcConnectAc {
  var %this = dcConnectAc           | ; Name of Object (Alias name)
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
  return $dcConnectAc.init(%x,$1)

  :destroy
  return $dcConnectAc.destroy($1)

  :getErrorObject
  return $hget($1,error.obj)

  :clearList
  return $dcConnectAc.clearList($1)

  :addServer
  return $dcConnectAc.addServer($1,$2,$3)

  :addBouncer
  return $dcConnectAc.addBouncer($1,$2,$3)
}

/*
* Initialisiert ein dcConnectAc Objekt
*
* @param $1 dcConnectBnc Objekt
* @param $2 dbhash (obtional)
* @return dcConnectAc objekt
*/
alias -l dcConnectAc.init {
  if ($2 == $null || $hget($2,database) != modul_connect) { 
    var %db $dbs(modul_connect)
    hadd %db createDB 1
  }
  else {
    var %db $2
    hadd %db createDB 0
  }
  hadd $1 dbhash %db
  .noop $dbs(%db,autoconnect).setSection
  hadd $1 error.obj $dcError
  hadd $1 aclist $dcConnectAcList(%db)

  hadd $1 limit_get aclist

  return $1
}

/*
* zerstört ein dcConnectAc objekt
*
* @param $1 dcConnectAc objekt
* @return 1
*/
alias -l dcConnectAc.destroy {
  .noop $dcError($hget($1,error.obj)).destroy
  if ($hget($1,createDB) == 1) {
    .noop $dbs($hget($1,dbhash)).destroy
  }
  .noop $dcConnectAcList($hget($1,aclist)).destroy
  .noop $baseClass($1).destroy
  return 1
}

/*
* Löscht die Liste
*
* @param $1 dcConnectAc objekt
* @return 1
*/
alias -l dcConnectAc.clearList {
  .noop $dbs($hget($1,dbhash)).deleteUserSection
  return 1
}

/*
* Fügt der Liste einen Server hinzu
*
* @param $1 dcConnectAc objekt
* @param $2 active
* @param $3 server
* @return 1 oder 0
*/
alias -l dcConnectAc.addServer {
  if (1 != $null || $2 != $null || $3 != $null) {
    var %server $serverData($3)
    var %group $serverData(%server,group).get
    .noop $serverData(%server).destroy
    .noop $dbs($hget($1,dbhash),SERVER_ $+ %group,$2 $+ $chr(44) $+ $3).setUserValue
    return 1
  }
  else {
    return 0
  }
}


/*
* Fügt der Liste einen Bouncer hinzu
*
* @param $1 dcConnectAc objekt
* @param $2 active
* @param $3 bouncer
* @return 1 oder 0
*/
alias -l dcConnectAc.addBouncer {
  if (1 != $null || $2 != $null || $3 != $null) {
    .noop $dbs($hget($1,dbhash),BOUNCER_ $+ $3,$2).setUserValue
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
alias dcConnectAcDialog {
  var %this = dcConnectAcDialog           | ; Name of Object (Alias name)
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
  return $dcConnectAcDialog.init(%x,$1)

  :destroy
  return $dcConnectAcDialog.destroy($1)

  :createControls
  return $dcConnectAcDialog.createControls($1)

  :fillAutoConnectList
  return $dcConnectAcDialog.fillAutoConnectList($1)

  :fillNetworkList
  return $dcConnectAcDialog.fillNetworkList($1)

  :fillServerList
  return $dcConnectAcDialog.fillServerList($1)

  :fillBouncerList
  return $dcConnectAcDialog.fillBouncerList($1)

  :selectListEntry
  return $dcConnectAcDialog.selectListEntry($1)

  :addServer
  return $dcConnectAcDialog.addServer($1)

  :addBouncer
  return $dcConnectAcDialog.addBouncer($1)

  :delEntry
  return $dcConnectAcDialog.delEntry($1)

  :move
  return $dcConnectAcDialog.move($1,$2)

  :saveList
  return $dcConnectAcDialog.saveList($1)
}

/*
* Initialisiert das dcConnectAcDialog objekt
*
* @param $1 dcConnectAcDialog objekt
* @param $2 dialog name
* @param $3 dbhash oder $null
* @return dcConnectAcDialog objekt
*/
alias -l dcConnectAcDialog.init {
  hadd $1 connect.ac.obj $dcConnectAc($3)
  if ($2 != $null) { hadd $1 dialog.name $2 }
  else { hadd $1 dialog.name dcConnectAc }

  .noop $dcDialog($1,435,540).createBasePanel
  .noop $dcConnectAcDialog($1).createControls
  .noop $dcConnectAcDialog($1).fillAutoConnectList
  .noop $dcConnectAcDialog($1).fillNetworkList
  .noop $dcConnectAcDialog($1).fillBouncerList

  return $1
}

/*
* löscht ein dcConnectAcDialog Objekt
*
* @param $1 dcConnectAcDialog objekt
* @return 1
*/
alias -l dcConnectAcDialog.destroy {
  .noop $dcConnectAc($hget($1,connect.ac.obj)).destroy
  .noop $baseClass($1).destroy
  return 1
}

/*
* Erzeugt die BedienElemente
*
* @param $1 dcConnectAcDialog objekt
* @return 1
*/
alias -l dcConnectAcDialog.createControls {
  xdid -c $hget($1,dialog.name) 1 100 text 0 0 200 25
  xdid -t $hget($1,dialog.name) 100 Server Verwaltung
  xdid -f $hget($1,dialog.name) 100 + default 14 Arial

  xdid -c $hget($1,dialog.name) 1 101 text 5 25 150 20
  xdid -t $hget($1,dialog.name) 101 AutoConnect Liste
  xdid -f $hget($1,dialog.name) 101 + default 10 Verdana

  xdid -c $hget($1,dialog.name) 1 2 listview 5 50 390 300 report checkbox fullrow grid singlesel noheadersort showsel
  xdid -t $hget($1,dialog.name) 2 +l 0 20 $chr(9) +l 0 30 Nr. $chr(9) +l 0 60 Typ $chr(9) +l 0 135 Netzwerk $chr(9) +l 0 140 Server

  xdid -c $hget($1,dialog.name) 1 75 toolbar 400 175 30 30 flat list nodivider noauto tooltips
  xdid -c $hget($1,dialog.name) 1 76 toolbar 400 210 30 30 flat list nodivider noauto tooltips

  xdid -l $hget($1,dialog.name) 75 24
  xdid -l $hget($1,dialog.name) 76 24
  xdid -w $hget($1,dialog.name) 75 +nh 0 images/ico/arrow_up.ico
  xdid -w $hget($1,dialog.name) 76 +nh 0 images/ico/arrow_down.ico

  xdid -w $hget($1,dialog.name) 75 +dhg 0 images/ico/arrow_up.ico
  xdid -w $hget($1,dialog.name) 76 +dhg 0 images/ico/arrow_down.ico

  xdid -a $hget($1,dialog.name) 75 1 +ld 30 1 $chr(9) Auf
  xdid -a $hget($1,dialog.name) 76 1 +ld 30 1 $chr(9) Ab

  xdid -c $hget($1,dialog.name) 1 80 button 295 355 100 20
  xdid -t $hget($1,dialog.name) 80 Speichern

  xdid -c $hget($1,dialog.name) 1 83 button 5 355 100 20 disabled
  xdid -t $hget($1,dialog.name) 83 Löschen

  xdid -c $hget($1,dialog.name) 1 102 text 5 380 200 20
  xdid -t $hget($1,dialog.name) 102 Server hinzufügen
  xdid -f $hget($1,dialog.name) 102 + default 10 Verdana

  xdid -c $hget($1,dialog.name) 1 3 comboex 25 400 125 300 dropdown disabled
  xdid -c $hget($1,dialog.name) 1 4 comboex 155 400 125 300 dropdown disabled
  xdid -c $hget($1,dialog.name) 1 81 button 295 400 100 20 disabled
  xdid -t $hget($1,dialog.name) 81 Hinzufügen

  xdid -c $hget($1,dialog.name) 1 103 text 5 430 200 20
  xdid -t $hget($1,dialog.name) 103 Bouncer hinzufügen
  xdid -f $hget($1,dialog.name) 103 + default 10 Verdana

  xdid -c $hget($1,dialog.name) 1 5 comboex 155 450 125 300 dropdown disabled
  xdid -c $hget($1,dialog.name) 1 82 button 295 450 100 20 disabled
  xdid -t $hget($1,dialog.name) 82 Hinzufügen
  return 1
}

/*
* Füllt die AutoConnect Liste
*
* @param $1 dcConnectAcDialog objekt
* @return 1
*/
alias -l dcConnectAcDialog.fillAutoConnectList {
  var %list $dcConnectAc($hget($1,connect.ac.obj),aclist).get
  if (%list) {
    .noop $dcConnectAcList(%list).prepareWhile
    while ($dcConnectAcList(%list).next) {
      var %nr $dcConnectAcList(%list).getPos
      var %active $calc($dcConnectAcList(%list).active +1)
      var %type $dcConnectAcList(%list).type
      var %network $dcConnectAcList(%list).group     
      if (%type == Server) {
        var %server $serverData($dcConnectAcList(%list).server)
        var %serverdesc $serverData(%server,desc).get
        .noop $serverData(%server).destroy
      }
      else {
        var %serverdesc $dcConnectAcList(%list).server
      }

      xdid -a $hget($1,dialog.name) 2 0 0 + 0 %active 0 0 $rgb(0,0,0) $rgb(0,0,0) $chr(9) + 0 0 $rgb(0,0,0) $rgb(0,0,0) %nr $chr(9) $&
        + 0 0 $rgb(0,0,0) $rgb(0,0,0) %type $chr(9) + 0 0 $rgb(0,0,0) $rgb(0,0,0) %network $chr(9) + 0 0 $rgb(0,0,0) $rgb(0,0,0) %serverdesc

    }
  }
  return 1
}

/*
* Füllt die Netzwerk Liste
*
* @param $1 dcConnectAcDialog objekt
* @return 1
*/
alias -l dcConnectAcDialog.fillNetworkList {
  var %list $networkList
  .noop $networkList(%list).prepareWhile
  while ($networkList(%list).next) {
    xdid -a $hget($1,dialog.name) 3 0 0 0 0 0 $networkList(%list).getValue
  }
  .noop $networkList(%list).destroy
  if ($xdid($hget($1,dialog.name),3).num > 0) {
    xdid -e $hget($1,dialog.name) 3
    xdid -c $hget($1,dialog.name) 3 1
    .noop $dcConnectAcDialog($1).fillServerList
  }
  return 1
}

/*
* Füllt die Server Liste
*
* @param $1 dcConnectAcDialog objekt
* @return 1
*/
alias -l dcConnectAcDialog.fillServerList {
  xdid -r $hget($1,dialog.name) 4
  xdid -b $hget($1,dialog.name) 4
  xdid -b $hget($1,dialog.name) 81
  var %list $serverList($xdid($hget($1,dialog.name),3).seltext)
  .noop $serverList(%list).prepareWhile
  while ($serverList(%list).next) {
    var %server $ServerData($serverList(%list).getValue)
    xdid -a $hget($1,dialog.name) 4 0 0 0 0 0 $serverData(%server,desc).get
    .noop $serverData(%server).destroy
  }
  .noop $serverList(%list).destroy
  if ($xdid($hget($1,dialog.name),4).num > 0) {
    xdid -e $hget($1,dialog.name) 4

    var %check $xdid($hget($1,dialog.name),2,$chr(9) $xdid($hget($1,dialog.name),3).seltext $chr(9),W,4,1).find
    if (%check != $null) {
      var %check2 $xdid($hget($1,dialog.name),4,$chr(9) $xdid($hget($1,dialog.name),2,$gettok(%check,1,32),5).text $chr(9),W,1).find
      xdid -c $hget($1,dialog.name) 4 %check2
      xdid -t $hget($1,dialog.name) 81 Ändern
      hadd $1 ac.mode edit
    }
    else {
      xdid -c $hget($1,dialog.name) 4 1
      xdid -t $hget($1,dialog.name) 81 Hinzufügen
      hadd $1 ac.mode add
    }
    xdid -e $hget($1,dialog.name) 81 
  }
  return 1
}

/*
* Füllt die Bouncer Liste
*
* @param $1 dcConnectAcDialog objekt
* @return 1
*/
alias -l dcConnectAcDialog.fillBouncerList {
  var %bnc $dcConnectBnc
  var %list $dcConnectBnc(%bnc,bnclist).get
  if (%list) {
    .noop $dbsList(%list).prepareWhile
    while ($dbsList(%list).next) {
      xdid -a $hget($1,dialog.name) 5 0 0 0 0 0 $dbsList(%list).getItem
    }
    .noop $dcConnectBnc(%bnc).destroy
    if ($xdid($hget($1,dialog.name),5).num > 0) {
      xdid -e $hget($1,dialog.name) 5
      xdid -c $hget($1,dialog.name) 5 1
      xdid -e $hget($1,dialog.name) 82
    }
  }
  return 1
}

/*
* Ein Eintrag in der AutoConnectListe wurde ausgewählt
*
* @param $1 dcConnectAcDialog objekt
* @return 1
*/
alias -l dcConnectAcDialog.selectListEntry {
  if ($xdid($hget($1,dialog.name),2,1).sel == 1 && $xdid($hget($1,dialog.name),2).num == 1) {
    xdid -t $hget($1,dialog.name) 75 1 +d
    xdid -t $hget($1,dialog.name) 76 1 +d
  }
  elseif ($xdid($hget($1,dialog.name),2,1).sel == 1) {
    xdid -t $hget($1,dialog.name) 75 1 +d
    xdid -t $hget($1,dialog.name) 76 1 +
  }
  elseif ($xdid($hget($1,dialog.name),2,1).sel == $xdid($hget($1,dialog.name),2).num) {
    xdid -t $hget($1,dialog.name) 75 1 +
    xdid -t $hget($1,dialog.name) 76 1 +d
  }
  else {
    xdid -t $hget($1,dialog.name) 75 1 +
    xdid -t $hget($1,dialog.name) 76 1 +
  }

  if ($xdid($hget($1,dialog.name),2,3).seltext == Server) {
    var %num $xdid($hget($1,dialog.name),3,$chr(9) $xdid($hget($1,dialog.name),2,4).seltext $chr(9),W,1).find
    xdid -c $hget($1,dialog.name) 3 %num
    .noop $dcConnectAcDialog($1).fillServerList
    var %num $xdid($hget($1,dialog.name),4,$chr(9) $xdid($hget($1,dialog.name),2,5).seltext $chr(9),W,1).find
    xdid -c $hget($1,dialog.name) 4 %num
    xdid -t $hget($1,dialog.name) 81 Ändern
    hadd $1 ac.mode edit
  }
  else {
    var %num $xdid($hget($1,dialog.name),5,$chr(9) $xdid($hget($1,dialog.name),2,5).seltext $chr(9),W,1).find
    xdid -c $hget($1,dialog.name) 5 %num
  }
  xdid -e $hget($1,dialog.name) 83
  return 1
}

/*
* Fügt der Liste einen Server hinzu
*
* @param $1 dcConnectAcDialog objekt
* @return 1
*/
alias -l dcConnectAcDialog.addServer {
  if ($hget($1,ac.mode) == add) {
    var %num $calc($xdid($hget($1,dialog.name),2).num + 1)
    xdid -a $hget($1,dialog.name) 2 0 0 + 0 2 0 0 $rgb(0,0,0) $rgb(0,0,0) $chr(9) + 0 0 $rgb(0,0,0) $rgb(0,0,0) %num $chr(9) $&
      + 0 0 $rgb(0,0,0) $rgb(0,0,0) Server $chr(9) + 0 0 $rgb(0,0,0) $rgb(0,0,0) $xdid($hget($1,dialog.name),3).seltext $chr(9) + 0 0 $rgb(0,0,0) $rgb(0,0,0) $xdid($hget($1,dialog.name),4).seltext
    xdid -c $hget($1,dialog.name) 2 %num
    xdid -t $hget($1,dialog.name) 81 Ändern
    hadd $1 ac.mode edit
  }
  else {
    var %num $xdid($hget($1,dialog.name),2,$chr(9) $xdid($hget($1,dialog.name),3).seltext $chr(9),W,4,1).find
    xdid -v $hget($1,dialog.name) 2 $gettok(%num,1,32) 5 $xdid($hget($1,dialog.name),4).seltext
  }
  return 1
}

/*
* Fügt der Liste einen Bouncer hinzu
*
* @param $1 dcConnectAcDialog objekt
* @return 1
*/
alias -l dcConnectAcDialog.addBouncer {
  var %num $xdid($hget($1,dialog.name),2,$chr(9) $xdid($hget($1,dialog.name),5).seltext $chr(9),W,5,1).find
  var %error 0
  var %i 1
  while (%i <= $numtok(%num,32)) {
    if ($xdid($hget($1,dialog.name),2,$gettok(%num,%i,32),3).text == Bouncer) {
      .noop $dcx(MsgBox,ok error modal owner $dialog($hget($1,dialog.name)).hwnd $chr(9) Fehler $chr(9) Bouncer bereits in Liste)
      var %error 1
      break
    }
    inc %i
  }
  if (%error == 0) {
    var %num $calc($xdid($hget($1,dialog.name),2).num + 1)
    xdid -a $hget($1,dialog.name) 2 0 0 + 0 2 0 0 $rgb(0,0,0) $rgb(0,0,0) $chr(9) + 0 0 $rgb(0,0,0) $rgb(0,0,0) %num $chr(9) $&
      + 0 0 $rgb(0,0,0) $rgb(0,0,0) Bouncer $chr(9) + 0 0 $rgb(0,0,0) $rgb(0,0,0) $chr(9) + 0 0 $rgb(0,0,0) $rgb(0,0,0) $xdid($hget($1,dialog.name),5).seltext
    xdid -c $hget($1,dialog.name) 2 %num
  }
  return 1
}

/*
* Löscht einen Eintrag aus der Liste
*
* @param $1 dcConnectAcDialog objekt
* @return 1
*/
alias -l dcConnectAcDialog.delEntry {
  var %sel $xdid($hget($1,dialog.name),2).sel
  if ($xdid($hget($1,dialog.name),2,%sel,3).text == Server) {
    set %connect.ac.mode add
    xdid -t $hget($1,dialog.name) 81 Hinzufügen
  }
  xdid -d $hget($1,dialog.name) 2 %sel
  var %i %sel
  if ($xdid($hget($1,dialog.name),2).num >= %i) {
    while (%i <= $xdid($hget($1,dialog.name),2).num) {
      xdid -v $hget($1,dialog.name) 2 %i 2 %i
      inc %i
    }
    xdid -c $hget($1,dialog.name) 2 %sel
  }
  else {
    xdid -c $hget($1,dialog.name) 2 $xdid($hget($1,dialog.name),2).num
  }
}

/*
* Bewegt einen Eintrag aus der Liste
*
* @param $1 dcConnectAcDialog objekt
* @param $2 up oder down
* @return 1
*/
alias -l dcConnectAcDialog.move {
  var %sel.active $xdid($hget($1,dialog.name),2).sel
  var %active $xdid($hget($1,dialog.name),2,%sel.active).state
  var %type $xdid($hget($1,dialog.name),2,%sel.active,3).text
  var %net $xdid($hget($1,dialog.name),2,%sel.active,4).text
  var %server $xdid($hget($1,dialog.name),2,%sel.active,5).text  

  if ($2 == down) {
    var %sel.move $calc(%sel.active + 1)
    xdid -a $hget($1,dialog.name) 2 $calc(%sel.move + 1) 0 + 0 %active 0 0 $rgb(0,0,0) $rgb(0,0,0) $chr(9) + 0 0 $rgb(0,0,0) $rgb(0,0,0) %sel.move $chr(9) $&
      + 0 0 $rgb(0,0,0) $rgb(0,0,0) %type $chr(9) + 0 0 $rgb(0,0,0) $rgb(0,0,0) %net $chr(9) + 0 0 $rgb(0,0,0) $rgb(0,0,0) %server
    xdid -d $hget($1,dialog.name) 2 %sel.active
    xdid -v $hget($1,dialog.name) 2 %sel.active 2 %sel.active
  }
  elseif ($2 == up) {
    var %sel.move $calc(%sel.active - 1)
    xdid -a $hget($1,dialog.name) 2 %sel.move 0 + 0 %active 0 0 $rgb(0,0,0) $rgb(0,0,0) $chr(9) + 0 0 $rgb(0,0,0) $rgb(0,0,0) %sel.move $chr(9) $&
      + 0 0 $rgb(0,0,0) $rgb(0,0,0) %type $chr(9) + 0 0 $rgb(0,0,0) $rgb(0,0,0) %net $chr(9) + 0 0 $rgb(0,0,0) $rgb(0,0,0) %server
    xdid -d $hget($1,dialog.name) 2 $calc(%sel.active + 1)
    xdid -v $hget($1,dialog.name) 2 %sel.active 2 %sel.active
  }
  xdid -c $hget($1,dialog.name) 2 %sel.move

  if ($xdid($hget($1,dialog.name),2,1).sel == 1) {
    xdid -t $hget($1,dialog.name) 75 1 +d
    xdid -t $hget($1,dialog.name) 76 1 +
  }
  elseif ($xdid($hget($1,dialog.name),2,1).sel == $xdid($hget($1,dialog.name),2).num) {
    xdid -t $hget($1,dialog.name) 75 1 +
    xdid -t $hget($1,dialog.name) 76 1 +d
  }
}

/*
* Speichert die AutoConnectListe
*
* @param $1 dcConnectAcDialog objekt
* @return 1
*/
alias -l dcConnectAcDialog.saveList {
  .noop $dcConnectAc($hget($1,connect.ac.obj)).clearList
  var %i 1
  while (%i <= $xdid($hget($1,dialog.name),2).num) {
    var %active $calc($xdid($hget($1,dialog.name),2,%i).state - 1)
    if ($xdid($hget($1,dialog.name),2,%i,3).text == Server) {
      var %list $serverList($xdid($hget($1,dialog.name),2,%i,4).text)
      .noop $serverList(%list).prepareWhile
      while ($serverList(%list).next) {
        var %serverdata $serverData($serverList(%list).getValue)
        if ($serverData(%serverdata,desc).get == $xdid($hget($1,dialog.name),2,%i,5).text) {
          var %server $serverList(%list).getValue
          .noop $serverData(%serverdata).destroy
          break
        }
        .noop $serverData(%serverdata).destroy
      }
      .noop $serverList(%list).destroy     
      .noop $dcConnectAc($hget($1,connect.ac.obj),%active,%server).addServer
    }
    else {
      .noop $dcConnectAc($hget($1,connect.ac.obj),%active,$xdid($hget($1,dialog.name),2,%i,5).text).addBouncer
    }
    inc %i
  }
  .noop $dcx(MsgBox,ok exclamation modal owner $dialog($hget($1,dialog.name)).hwnd $chr(9) OK $chr(9) Daten gespeichert)
}

/*
* Wird durch den Config-Dialog aufgerufen, initalisiert den Dialog
*
* @param $1 dcConfig objekt
*/
alias dc.connectAutoconnect.createPanel {
  set %connect.ac.dialog.obj $dcConnectAcDialog($dcConfig($1,dialog.name).get,$dcConfig($1,currentPanel.dbhash).get)

}

/*
* Wird durch den Config-Dialog aufgerufen, zerstört den Dialog
*/
alias dc.connectAutoconnect.destroyPanel {
  .noop $dcConnectAcDialog(%connect.ac.dialog.obj).destroy
  unset %connect.ac.* 
}

/*
* Verwaltet Dialog-Ereignisse wie Mausklicks, Tastatureingaben, ...
*
* @param $1 DialogName
* @param $2 Ereignis
* @param $3 Betroffene ID
* @param $4 sonstiges
*/
alias dc.connectAutoconnect.events { 
  if ($2 == sclick) {
    if ($3 == 3) { .noop $dcConnectAcDialog(%connect.ac.dialog.obj).fillServerList }
    if ($3 == 75 && $4 == 1) { .noop $dcConnectAcDialog(%connect.ac.dialog.obj,up).move }
    if ($3 == 76 && $4 == 1) { .noop $dcConnectAcDialog(%connect.ac.dialog.obj,down).move }
    if ($3 == 80) { .noop $dcConnectAcDialog(%connect.ac.dialog.obj).saveList }
    if ($3 == 81) { .noop $dcConnectAcDialog(%connect.ac.dialog.obj).addServer }
    if ($3 == 82) { .noop $dcConnectAcDialog(%connect.ac.dialog.obj).addBouncer }
    if ($3 == 83) { .noop $dcConnectAcDialog(%connect.ac.dialog.obj).delEntry }
  }
  elseif ($2 == selected) {
    if ($3 == 2) { .noop $dcConnectAcDialog(%connect.ac.dialog.obj).selectListEntry }
  }
}

alias dc.connect.autoStart {
  var %ac.obj $dcConnectAC
  var %bnc.obj $dcConnectBnc
  var %list $dcConnectAC(%ac.obj,aclist).get
  if (%list) {
    .noop $dcConnectAcList(%list).prepareWhile
    while ($dcConnectAcList(%list).next) {
      if ($dcConnectAcList(%list).getPos == 1) {
        if ($dcConnectAcList(%list).type == Server) { .server $dcConnectAcList(%list).server }
        else {  
          var %try $dcConnectBnc(%bnc.obj,$dcConnectAcList(%list).server).setBouncer
          if (%try) { .noop $dcConnectBnc(%bnc.obj,0).connect) }
        }
      }
      else {
        if ($dcConnectAcList(%list).type == Server) { .server -m $dcConnectAcList(%list).server }
        else {  
          var %try $dcConnectBnc(%bnc.obj,$dcConnectAcList(%list).server).setBouncer
          if (%try) { .noop $dcConnectBnc(%bnc.obj,1).connect }
        }
      }
    }
  }
  .noop $dcConnectAc(%ac.obj).destroy
  .noop $dcConnectBnc(%bnc.obj).destroy
}

/*
* Wird beim Verbinden zu einem Server/Netzwerk ausgeführt
*/
alias dc.connect.perform {
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

alias dc.connect.addIdent {
  var %param $hget(alias_server,param)
  if (!$istok(%param,-i,32)) {
    if ($chr(45) isin $gettok(%param,1,32)) { var %server $gettok(%param,2,32) }
    else { var %server $gettok(%param,1,32) }
    if ($server(0,%server) == 0) { var %group $server(%server).group }
    else { var %group %server }
    .var %connect $dcConnect
    .noop $dcConnect(%connect,%group).setNetwork
    var %ident $dcConnect(%connect,1,1).getIdent
    .noop $dcConnect(%connect).destroy
    var %pos $findtok(%param,-j,1,32)
    if (%pos) {
      hadd -m alias_server param $instok(%param,-i %ident,%pos,32)
    }
    else {
      hadd -m alias_server param $addtok(%param,-i %ident,32)
    }
  }
}

alias dc.connect.load { }
alias dc.connect.unload { }
