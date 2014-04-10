/*
* DragoonCore Framework Modul Dialog
*
* @author Valfa
* @version 1.0
*
* Verwaltet die Module
*/

/*
* Class Alias
* var %var $dcModulList
*/
alias dcModulList {
  var %this = dcModulList           | ; Name of Object (Alias name)
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
  return $dcModulList.INIT(%x)
}

/*
* Initialisiert die Liste
*
* @param $1 dcModulListe objekt
* @return dcModulListe objekt
*/
alias -l dcModulList.init {
  var %hash $1-
  hadd %hash last $findfile(scripts/Module/,*.mrc,0,/hadd %hash n $+ $findfilen $remove($1-,$mircdirscripts\Module\,.mrc))
  hadd %hash pos 1
  return $1
}


/*
* Class Alias
* var %var $dcModul
*
* @param $1 Datenbank hash (optional)
*/
alias dcModul {
  var %this = dcModul           | ; Name of Object (Alias name)
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
  return $dcModul.init(%x)

  :destroy
  return $dcModul.destroy($1)

  :getListObjekt
  return $hget($1,listhash)

  :setActiveModul
  return $dcModul.setActiveModul($1,$2-)

  :getModulInfo
  return $dcModul.getModulInfo($1)

  :loadModul
  return $$dcModul.loadModul($1)

  :unloadModul
  return $$dcModul.unloadModul($1)

  :unsetModulInfo
  return $dcModul.unsetModulInfo($1)
}

/*
* Initialisiert ein dcModul objekt
*
* @param $1 dcModul objekt
* @return dcModul objekt
*/
alias -l dcModul.init {
  hadd $1 listhash $dcModulList
  hadd $1 limit_vars modul.name,modul.author,modul.version,modul.text
  return $1
}

/*
* Zerstört ein dcModul objekt
*
* @param $1 dcModul objekt
* @return 1
*/
alias -l dcModul.destroy {
  .noop $dcModulList($hget($1,listhash)).destroy
  .noop $dcBase($1).destroy
  return 1
}

/*
* Setzt das aktive Modul
*
* @param $1 dcModul objekt
* @param $2- Modulname
* @return 1 oder 0
*/
alias -l dcModul.setActiveModul {
  hadd $1 modul.current $lower($2-)
  hadd $1 modul.file $mircdirscripts\Module\ $+ $2- $+ .mrc
  if ($exists($hget($1,modul.file))) {
    .noop $dcModul($1).getModulInfo
    hadd $1 modul.exists 1
    return 1
  }
  else {
    .noop $dcModul($1).unsetModulInfo
    hadd $1 modul.exists 0
    return 0
  }
}

/*
* Löscht die Informationen zu einem Modul
*
* @param $1 dcModul objekt
* @return 1
*/
alias -l dcModul.unsetModulInfo {
  hadd $1 modul.name $null
  hadd $1 modul.author $null
  hadd $1 modul.version $null
  hadd $1 modul.text $null
  return 1
}

/*
* Ermittelt anhand des Namens die ModulInformationen
*
* @param $1 dcModul objekt
* @return 1
*/
alias -l dcModul.getModulInfo {
  hadd $1 modul.name $mid($read($hget($1,modul.file),2),3)
  hadd $1 modul.author $mid($read($hget($1,modul.file),4),11)
  hadd $1 modul.version $mid($read($hget($1,modul.file),5),12)
  hadd $1 modul.text $mid($read($hget($1,modul.file),7),3)
  return 1
}

/*
* Lädt ein Modul
*
* @param $1 dcmodul objekt
* @return 1 oder 0
*/
alias -l dcModul.loadModul {
  var %db $dcDbs(modul_ $+ $hget($1,modul.current))
  if (%db) {
    var %list $dcDbsList(%db,script,onRemote)
    if (%list) {
      .noop $dcDbsList(%list).prepareWhile
      .noop $dcDbs(%dc.fw.dbhash,onRemote).setSection
      while ($dcDbsList(%list).next) {
        var %tmp $dcDbs(%dc.fw.dbhash,$dcDbsList(%list).getItem).getUserValue
        var %tmp $addtok(%tmp,$dcDbsList(%list).getValue,44)
        .noop $dcDbs(%dc.fw.dbhash,$dcDbsList(%list).getItem,%tmp).setUserValue
      }
      .noop $dcDbsList(%list).destroy
    }

    var %list $dcDbsList(%db,script,configTree)
    if (%list) {
      var %section $dcDbs(%db,modul_config,configTree).getScriptValue
      var %tree_db $dcDbs(fw_cfg_tree)
      .noop $dcDbsList(%list).prepareWhile
      while ($dcDbsList(%list).next) {
        .noop $dcDbs(%tree_db,%section,$dcDbsList(%list).getItem,$dcDbsList(%list).getValue).setUserValue
      }
      .noop $dcDbsList(%list).destroy
      .noop $dcDbs(%tree_db).destroy
    }

    var %list $dcDbsList(%db,script,fkey)
    if (%list) {
      var %section $dcDbs(%db,modul_config,fkey).getScriptValue
      var %fkey_db $dcDbs(fw_fkey)
      .noop $dcDbs(%fkey_db,%section).setSection
      .noop $dcDbsList(%list).prepareWhile
      while ($dcDbsList(%list).next) {
        .noop $dcDbs(%fkey_db,$dcDbsList(%list).getItem,$dcDbsList(%list).getValue).setUserValue
      }
      .noop $dcDbsList(%list).destroy
      .noop $dcDbs(%fkey_db,__groups__,%section,%section).setUserValue
      .noop $dcDbs(%fkey_db).destroy
    }

    .noop $dcDbs(%db).destroy
    .load -rs $qt($hget($1,modul.file))
    if ($isalias(dc. $+ $hget($1,modul.current) $+ .load)) { dc. $+ $hget($1,modul.current) $+ .load }
    .noop $dcDbs(%dc.fw.dbhash,active_moduls).setSection
    .noop $dcDbs(%dc.fw.dbhash,$hget($1,modul.current),1).setUserValue
    return 1
  }
  else {
    return 0
  }
}

/*
* Entlädt ein Modul
*
* @param $1 dcModul objekt
@return 1 oder 0
*/
alias -l dcModul.unloadModul {
  var %db $dcDbs(modul_ $+ $hget($1,modul.current))
  if (%db) {
    var %list $dcDbsList(%db,script,onRemote)
    if (%list) {
      .noop $dcDbsList(%list).prepareWhile
      .noop $dcDbs(%dc.fw.dbhash,onRemote).setSection
      while ($dcDbsList(%list).next) {
        var %tmp $dcDbs(%dc.fw.dbhash,$dcDbsList(%list).getItem).getUserValue
        var %tmp $remtok(%tmp,$dcDbsList(%list).getValue,1,44)
        if (%tmp != $null) {
          .noop $dcDbs(%dc.fw.dbhash,$dcDbsList(%list).getItem,%tmp).setUserValue
        }
        else {
          .noop $dcDbs(%dc.fw.dbhash,$dcDbsList(%list).getItem).deleteUserItem
        }
      }
      .noop $dcDbsList(%list).destroy
    }

    var %section $dcDbs(%db,modul_config,configTree).getScriptValue
    var %tree_db $dcDbs(fw_cfg_tree)
    .noop $dcDbs(%tree_db,%section).deleteUserSection
    .noop $dcDbs(%tree_db).destroy

    var %fkey_db $dcDbs(fw_fkey)
    var %section $dcDbs(%db,modul_config,fkey).getScriptvalue
    .noop $dcDbs(%fkey_db,%section).deleteUserSection
    .noop $dcDbs(%fkey_db,__groups__,%section).deleteUserItem
    .noop $dcDbs(%fkey_db).destroy  

    .noop $dcDbs(%db).destroy
    if ($isalias(dc. $+ $hget($1,modul.current) $+ .unload)) { dc. $+ $hget($1,modul.current) $+ .unload }
    .unload -nrs $nopath($hget($1,modul.file))
    .noop $dcDbs(%dc.fw.dbhash,active_moduls).setSection
    .noop $dcDbs(%dc.fw.dbhash,$hget($1,modul.current)).deleteUserItem
    return 1
  }
  else {
    return 0      
  }
}

/*
* Class Alias
* var %var $dcModulDialog
*/
alias dcModulDialog {
  var %this = dcModulDialog           | ; Name of Object (Alias name)
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
  return $dcModulDialog.init(%x,$1)

  :destroy
  return $dcModulDialog.destroy($1)

  :createControls
  return $dcModulDialog.createControls($1)

  :fillList
  return $dcModulDialog.fillList($1)

  :getModulInfo
  return $dcModulDialog.getModulInfo($1)

  :toggleModul
  return $dcModulDialog.toggleModul($1)
}

/*
* Initialisiert den Dialog
*
* @param $1 dcModulDialog objekt
* @param $2 dialog name oder $null
* @return dcModulDialog objekt
*/
alias -l dcModulDialog.init {
  hadd $1 modul.obj $dcModul()
  if ($2 != $null) { hadd $1 dialog.name $2 }
  else { hadd $1 dialog.name dcModul }

  .noop $dcDialog($1,435,540).createBasePanel
  .noop $dcModulDialog($1).createControls
  .noop $dcModulDialog($1).fillList

  return $1
}

/*
* löscht ein dcModulDialog objekt
*
* @param $1 dcModulDialog objekt
* @return 1
*/
alias -l dcModulDialog.destroy {
  .noop $dcModul($hget($1,modul.obj)).destroy
  .noop $dcBase($1).destroy
  return 1
}

/*
* Initialisiert die Control-Elemente
* 
* @param $1 dcModulDialog objekt
* @return 1
*/
alias -l dcModulDialog.createControls {
  xdid -c $hget($1,dialog.name) 1 100 text 0 0 200 25
  xdid -t $hget($1,dialog.name) 100 Modul Manager
  xdid -f $hget($1,dialog.name) 100 + default 14 Arial

  xdid -c $hget($1,dialog.name) 1 101 text 5 25 100 20
  xdid -t $hget($1,dialog.name) 101 Modul Liste
  xdid -f $hget($1,dialog.name) 101 + default 10 Verdana

  xdid -c $hget($1,dialog.name) 1 2 treeview 5 50 200 485 fullrow showsel
  xdid -l $hget($1,dialog.name) 2 24
  xdid -w $hget($1,dialog.name) 2 +n 0 images/ico/unchecked_checkbox.ico
  xdid -w $hget($1,dialog.name) 2 +n 0 images/ico/checked_checkbox.ico

  xdid -c $hget($1,dialog.name) 1 102 text 215 25 150 20
  xdid -t $hget($1,dialog.name) 102 Modul Informationen
  xdid -f $hget($1,dialog.name) 102 + default 10 Verdana

  xdid -c $hget($1,dialog.name) 1 103 text 215 55 100 20
  xdid -t $hget($1,dialog.name) 103 Modul Name
  xdid -c $hget($1,dialog.name) 1 3 edit 215 75 215 20 autohs readonly

  xdid -c $hget($1,dialog.name) 1 104 text 215 105 100 20
  xdid -t $hget($1,dialog.name) 104 Author
  xdid -c $hget($1,dialog.name) 1 4 edit 215 125 215 20 autohs readonly

  xdid -c $hget($1,dialog.name) 1 105 text 215 155 100 20
  xdid -t $hget($1,dialog.name) 105 Version
  xdid -c $hget($1,dialog.name) 1 5 edit 215 175 215 20 autohs readonly

  xdid -c $hget($1,dialog.name) 1 106 text 215 205 100 20
  xdid -t $hget($1,dialog.name) 106 Beschreibung
  xdid -c $hget($1,dialog.name) 1 6 edit 215 225 215 200 multi readonly vsbar
  return 1
}

/*
* Füllt die Modul Liste
*
* @param $1 dcModulDialog objekt
* @return 1
*/
alias -l dcModulDialog.fillList {
  var %list $dcModul($hget($1,modul.obj)).getListObjekt
  .noop $dcModulList(%list).prepareWhile
  .noop $dcDbs(%dc.fw.dbhash,active_moduls).setSection
  while ($dcModulList(%list).next) {
    if ($dcDbs(%dc.fw.dbhash,$dcModulList(%list).getValue).getUserValue == 1) { var %icon 2 }
    else { var %icon 1 }
    xdid -a $hget($1,dialog.name) 2 $+($dcModulList(%list).getPos,$chr(9),+ %icon %icon 0 0 0 $rgb(0,0,255) $rgb(255,0,255) $dcModulList(%list).getValue,$chr(9),$dcModulList(%list).getValue)
  }
  return 1
}

/*
* Zeigt die Informationen zum ausgewählten Modul
*
* @param $1 dcModulDialog objekt
* @return 1
*/
alias -l dcModulDialog.getModulInfo {
  .noop $dcDialog($1,3-6).clearControls
  if ($dcModul($hget($1,modul.obj),$xdid($hget($1,dialog.name),2).seltext).setActiveModul) {
    xdid -a $hget($1,dialog.name) 3 $dcModul($hget($1,modul.obj),modul.name).get
    xdid -a $hget($1,dialog.name) 4 $dcModul($hget($1,modul.obj),modul.author).get
    xdid -a $hget($1,dialog.name) 5 $dcModul($hget($1,modul.obj),modul.version).get
    xdid -a $hget($1,dialog.name) 6 $dcModul($hget($1,modul.obj),modul.text).get
  }
  return 1
}

/*
* Aktiviert oder Deaktiviert ein Modul
*
* @param $1 dcModulDialog objekt
* @return 1
*/
alias -l dcModulDialog.toggleModul {
  .noop $dcDbs(%dc.fw.dbhash,active_moduls).setSection
  var %modul $xdid($hget($1,dialog.name),2).seltext
  if ($dcDbs(%dc.fw.dbhash,$xdid($hget($1,dialog.name),2).seltext).getUserValue == 1) {
    ;// Modul wird deaktiviert
    if ($dcModul($hget($1,modul.obj)).unloadModul) {
      xdid -j $hget($1,dialog.name) 2 $xdid($hget($1,dialog.name),2).selpath $chr(9) 1 1
    }
  }
  else {
    ;// Modul wird aktiviert
    if ($dcModul($hget($1,modul.obj)).loadModul) {   
      xdid -j $hget($1,dialog.name) 2 $xdid($hget($1,dialog.name),2).selpath $chr(9) 2 2
    }
  }
  return 1
}

/*
* Wird durch den Config-Dialog aufgerufen, initalisiert den Dialog
*
* @param $1 dcConfig objekt
*/
alias dc.frameworkScriptModule.createPanel {
  set %dc.fw.modul.obj $dcModulDialog($dcConfig($1,dialog.name).get)

}

/*
* Wird durch den Config-Dialog aufgerufen, zerstört den Dialog
*/
alias dc.frameworkScriptModule.destroyPanel { 
  .noop $dcModulDialog(%dc.fw.modul.obj).destroy
  return 1 
}

/*
* Verwaltet Dialog-Ereignisse wie Mausklicks, Tastatureingaben, ...
*
* @param $1 DialogName
* @param $2 Ereignis
* @param $3 Betroffene ID
* @param $4 sonstiges
*/
alias dc.frameworkScriptModule.events { 
  if ($2 == sclick && $3 == 2) { .noop $dcModulDialog(%dc.fw.modul.obj).getModulInfo }
  if ($2 == dclick && $3 == 2) { .noop $dcModulDialog(%dc.fw.modul.obj).toggleModul }
}
