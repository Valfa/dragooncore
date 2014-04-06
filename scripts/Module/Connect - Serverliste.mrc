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
      if ($hget($1,ident.local.anick) != $null) { var %nick $hget($1,ident.local.anick) }
      if ($hget($1,ident.local.emailaddr) != $null) { var %nick $hget($1,ident.local.emailaddr) }
      if ($hget($1,ident.local.fullname) != $null) { var %nick $hget($1,ident.local.fullname) }
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
* @return 1
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
* Wird beim Verbinden zu einem Server/Netzwerk ausgeführt
*/
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
