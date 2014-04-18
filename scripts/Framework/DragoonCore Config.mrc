/*
* Der Globale DragoonCore Einstellungs-Dialog
*
* @author Valfa
* @version 1.0
*
* Verwaltet die Script-Dialoge
*/

/*
* Class Alias
* var %var $dcConfig
*
* @param $1 dialog name
* @param $2 einsprung punkt
*/
alias dcConfig {
  var %this = dcConfig           | ; Name of Object (Alias name)
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
  return $dcConfig.init(%x,$1,$2,$3)

  :destroy
  return $dcConfig.destroy($1)

  :createControls
  return $dcConfig.createControls($1)

  :fillRebar
  return $dcConfig.fillRebar($1,$2)

  :addRebarEntrys
  return $dcConfig.addRebarEntrys($1,$2)

  :get
  return $dcBase($1,$2).get

  :set
  return $dcBase($1,$2,$3).set

  :selectRebarEntry
  return $dcConfig.selectRebarEntry($1,$2)

  :selectTreeviewItem
  return $dcConfig.selectTreeviewItem($1)

  :initDbs
  return $dcConfig.initDbs($1)

  :changeToolbar
  return $dcConfig.changeToolbar($1)

  :addConfig
  return $dcConfig.addConfig($1)

  :delConfig
  return $dcConfig.delConfig($1)

  :loadDefaults
  return $dcConfig.loadDefaults($1)

  :destroyPanel
  return $dcConfig.destroyPanel($1)

}

/*
* Initialisiert den Config Dialog
*
* @param $1 dcConfig objekt
* @param $2 dialog name
* @param $3 baum (script oder user)
* @param $3 einsprung Punkt (optional)
* @return dcConfig objekt
*/
alias -l dcConfig.init {
  if ($2 == $null) { hadd $1 dialog.name dcConf }
  else { hadd $1 dialog.name $2 }

  hadd $1 dbhash $dcDbs(fw_cfg_tree)
  hadd $1 config.rebarID $dcDbs(%dc.fw.dbhash,config_dialog,rebarID).getScriptValue
  hadd $1 limit_get config.rebarID,currentTree,currentSelpath,currentPanel,currentPanel.dbhash,dialog.name
  hadd $1 limit_set config.local
  hadd $1 loadTree $3
  hadd $1 jumpin.user.name $null
  hadd $1 jumpin.script.name $null
  hadd $1 jumpin. $+ $3 $+ .name $4
  hadd $1 jumpin.point 1

  .noop $dcConfig($1).createControls
  .noop $dcConfig($1,$3).fillRebar
  if (%dc.config.tree == user) {
    xdid -u $hget($1,dialog.name) 1030
    xdid -c $hget($1,dialog.name) 1031
  }

  .noop $dcConfig($1).selectTreeviewItem

  return $1
}

/*
* Zerstört ein dcDialog objekt
*
* @param $1 dcConfig objekt
* @return 1
*/
alias -l dcConfig.destroy {
  dc. $+ $hget($1,currentPanel) $+ .destroyPanel
  if ($hget($1,currentPanel.dbhash) != $null && $hget($1,currentPanel.dbhash) != 0) {
    .noop $dcDbs($hget($1,currentPanel.dbhash)).destroy
  }
  .hfree -w dcConfTree_*
  .noop $dcDbs($hget($1,dbhash)).destroy
  .noop $dcDialog($1).destroy
  return 1
}

/*
* Erstellt die BedienElemente
*
* @param $1 dcConfig objekt
* @return 1
*/
alias -l dcConfig.createControls {
  xdialog -c $hget($1,dialog.name) 1000 text 5 5 640 30 right
  xdid -t $hget($1,dialog.name) 1000 DragoonCore Einstellungen 
  xdid -f $hget($1,dialog.name) 1000 + default 18 Verdana

  xdialog -c $hget($1,dialog.name) 1001 line 5 45 640 15

  xdialog -c $hget($1,dialog.name) 1009 panel 210 55 435 540

  xdialog -c $hget($1,dialog.name) 1020 text 5 55 200 20
  xdid -t $hget($1,dialog.name) 1020 Konfiguration wählen
  xdid -f $hget($1,dialog.name) 1020 + default 10 Verdana

  xdialog -c $hget($1,dialog.name) 1030 radio 5 75 95 20 pushlike center
  xdid -t $hget($1,dialog.name) 1030 Framework
  xdid -c $hget($1,dialog.name) 1030

  xdialog -c $hget($1,dialog.name) 1031 radio 100 75 95 20 pushlike center
  xdid -t $hget($1,dialog.name) 1031 Module  

  xdialog -c $hget($1,dialog.name) 1010 toolbar 5 100 200 30 flat noauto  tooltips list
  xdid -l $hget($1,dialog.name) 1010 24
  xdid -w $hget($1,dialog.name) 1010 +nh 0 images/ico/page_add.ico
  xdid -w $hget($1,dialog.name) 1010 +nh 0 images/ico/page_gear.ico
  xdid -w $hget($1,dialog.name) 1010 +nh 0 images/ico/page_delete.ico

  xdid -w $hget($1,dialog.name) 1010 +dhg 0 images/ico/page_add.ico
  xdid -w $hget($1,dialog.name) 1010 +dhg 0 images/ico/page_gear.ico
  xdid -w $hget($1,dialog.name) 1010 +dhg 0 images/ico/page_delete.ico

  xdid -a $hget($1,dialog.name) 1010 1 +ld 30 1 $rgb(255,0,0) $chr(9) Lokale Konfiguration Hinzufügen
  xdid -a $hget($1,dialog.name) 1010 2 +ld 30 2 $rgb(255,0,0) $chr(9) Standart Konfiguration Laden
  xdid -a $hget($1,dialog.name) 1010 3 +ld 30 3 $rgb(255,0,0) $chr(9) Lokale Konfiguration Löschen

  xdialog -c $hget($1,dialog.name) 1040 text 5 135 200 20 center
  xdid -t $hget($1,dialog.name) 1040 Framework Einstellungen
  xdid -f $hget($1,dialog.name) 1040 + default 10 Verdana

  xdialog -c $hget($1,dialog.name) 1100 rebar 5 150 200 445 borders fixedorder noauto noparentalign noresize vertical notheme

  return 1
}

/*
* Füllt die Rebar mit Einträgen
*
* @param $1 dcConfig objekt
* @param $2 script oder user
* @return 1
*/
alias -l dcConfig.fillRebar {
  .hfree -w dcConfTree_*
  hadd $1 loadTree $2
  .noop $dcConfig($1).destroyPanel

  xdialog -d $hget($1,dialog.name) 1100
  xdialog -c $hget($1,dialog.name) 1100 rebar 5 150 200 445 borders fixedorder noauto noparentalign noresize vertical notheme
  hadd $1 treeviewID $hget($1,config.rebarID)
  if ($2 == user) { 
    xdid -t $hget($1,dialog.name) 1040 Modul Einstellungen
    .noop $dcConfig($1,user).addRebarEntrys

    hadd $1 currentTree $calc($hget($1,jumpin.point) + $hget($1,config.rebarID))
    hadd $1 currentSelpath 1
    xdid -c $hget($1,dialog.name) $calc($hget($1,jumpin.point) + $hget($1,config.rebarID)) 1
  }
  else {
    xdid -t $hget($1,dialog.name) 1040 Framework Einstellungen
    .noop $dcConfig($1,script).addRebarEntrys    
    hadd $1 currentTree 1101
    hadd $1 currentSelpath 1
    xdid -c $hget($1,dialog.name) 1101 1
  }
    if ($hget($1,jumpin.point) > 1) {
      xdid -m $hget($1,dialog.name) $hget($1,config.rebarID) $hget($1,jumpin.point)
    }
  ;hadd $1 currentPanel $gettok($hget(dcConfTree_1101,n1),3,44)
  return 1
}

/*
* Füllt die Rebar mit Einträgen
*
* @param $1 dcConfig objekt
* @param $2 script oder user
* @return 1
*/
alias -l dcConfig.addRebarEntrys {
  var %list.outer $dcDbsList($hget($1,dbhash),$2)
  .noop $dcDbsList(%list.outer).prepareWhile
  while ($dcDbsList(%list.outer).next) {
    var %list.inner $dcDbsList($hget($1,dbhash),$2,$dcDbsList(%list.outer).getItem)
    .noop $dcDbsList(%list.inner).prepareWhile
    while ($dcDbsList(%list.inner).next) {
      if ($dcDbsList(%list.inner).getItem == n0) {
        hinc $1 treeviewID
        xdid -a $hget($1,dialog.name) $hget($1,config.rebarID) 0 + 0 200 0 0 $rgb(0,0,255) $dcDbsList(%list.inner).getValue $chr(9) $hget($1,treeviewID) treeview 0 30 200 440 showsel hasbuttons haslines linesatroot
        if ($hget($1,jumpin. $+ $2 $+ .name) == $dcDbsList(%list.outer).getItem) {
          hadd $1 jumpin.point $calc($hget($1,treeviewID) - $hget($1,config.rebarID))
        }
      }
      else {
        hadd -m dcConfTree_ $+ $hget($1,treeviewID) $dcDbsList(%list.inner).getItem $dcDbsList(%list.inner).getValue
        var %treeviewPos $mid($dcDbsList(%list.inner).getItem,2)
        var %treeviewLine $gettok($dcDbsList(%list.inner).getValue,4-,44)
        xdid -a $hget($1,dialog.name) $hget($1,treeviewID) $+(%treeviewPos,$chr(9),+ 0 0 0 0 0 $rgb(0,0,255) $rgb(255,0,255) %treeviewLine,$chr(9),%treeviewLine)
        if ($gettok($dcDbsList(%list.inner).getValue,1,44) == local) {
          var %db_tmp $dcDbs($gettok($dcDbsList(%list.inner).getValue,2,44))
          var %wc $replace($nopath($hget(%db_tmp,config_user)),.ini,.*.ini)
          var %i 1
          var %max $findfile(dcdb/user/Module,%wc,0)
          while (%i <= %max) {
            var %net $nopath($findfile(dcdb/user/Module,%wc,%i))
            var %net $replace($mid(%net,$calc($pos(%net,.,1) + 1)),.ini,)
            xdid -a $hget($1,dialog.name) $hget($1,treeviewID) $+(%treeviewPos %i,$chr(9),+ 0 0 0 0 0 $rgb(0,0,255) $rgb(255,0,255) %net,$chr(9),%net)
            inc %i
          }
          .noop $dcDbs(%db_tmp).destroy
        }
      }
    }
    .noop $dcDbsList(%list.inner).destroy
  }
  .noop $dcDbsList(%list.outer).destroy

}

/*
* Wählt einen Punkt in der Rebar aus
*
* @param $1 dcConfig objekt
* @param $2 rebar nr
* @return 1
*/
alias -l dcConfig.selectRebarEntry {
  xdid -u $hget($1,dialog.name) $hget($1,currentTree)
  hadd $1 currentTree $calc($hget($1,config.rebarID) + $2)
  hadd $1 currentSelpath 1
  ;  hadd $1 currentPanel $gettok($hget(dcConfTree_ $+ $hget($1,currentTree),n1),3,44)
  xdid -c $hget($1,dialog.name) $hget($1,currentTree) 1

  if ($hget($1,loadTree) == user) {
    hadd $1 jumpin.user.name $dcDbs($hget($1,dbhash),$calc($hget($1,currentTree) - $hget($1,config.rebarID))).getSection
  }
  else {
    hadd $1 jumpin.script.name $dcDbs($hget($1,dbhash),$calc($hget($1,currentTree) - $hget($1,config.rebarID))).getScriptSection
  }
  return 1
}

/*
* Initialisiert die Datenbank für ein Script
*
* @param $1 dcConfig objekt
* @return 1 oder 0
*/
alias dcConfig.initDbs {
  var %tmp $gettok($hget(dcConfTree_ $+ $hget($1,currentTree),n $+ $gettok($hget($1,currentSelpath),1,32)),2,44)
  if (%tmp != none) {
    if ($numtok($hget($1,currentSelpath),32) == 1) { 
      return $dcDbs(%tmp) 
    }
    else {
      return $dcDbs(%tmp,$xdid($hget($1,dialog.name),$hget($1,currentTree)).seltext)
    }
  }
  else {
    return 0
  }
}

/*
* Zerstört ein panel
*
* @param $1 dcConfig objekt
* @return 1
*/
alias -l dcConfig.destroyPanel {
  if ($hget($1,currentPanel) != $null) {
    dc. $+ $hget($1,currentPanel) $+ .destroyPanel
    if ($hget($1,currentPanel.dbhash) != $null && $hget($1,currentPanel.dbhash) != 0) {
      .noop $dcDbs($hget($1,currentPanel.dbhash)).destroy
      hadd $1 currentPanel.dbhash 0
    }
    xdialog -d $hget($1,dialog.name) 1009
    xdialog -c $hget($1,dialog.name) 1009 panel 210 55 435 540
    hadd $1 currentPanel $null
  }
  return 1
}

/*
* Ein Treeview Item wurde selektiert 
*
* @param $1 dcConfig objekt
* @return 1
*/
alias -l dcConfig.selectTreeviewItem {
  .noop $dcConfig($1).destroyPanel

  hadd $1 currentSelpath $xdid($hget($1,dialog.name),$hget($1,currentTree)).selpath
  hadd $1 currentPanel $gettok($hget(dcConfTree_ $+ $hget($1,currentTree),n $+ $gettok($hget($1,currentSelpath),1,32)),3,44)
  hadd $1 currentPanel.dbhash $dcConfig($1).initDbs
  dc. $+ $hget($1,currentPanel) $+ .createPanel $1

  .noop $dcConfig($1).changeToolbar

  return 1
}

/*
* Passt die Tollbar der aktuellen auswahl an
*
* @param $1 dcConfig objekt
* @return 1
*/
alias -l dcConfig.changeToolbar {
  if ($numtok($hget($1,currentSelpath),32) == 2) {
    xdid -t $hget($1,dialog.name) 1010 1 +d
    xdid -t $hget($1,dialog.name) 1010 3 +
  }
  else {
    if ($gettok($hget(dcConfTree_ $+ $hget($1,currentTree),n $+ $xdid($hget($1,dialog.name),$hget($1,currentTree)).selpath),1,44) == local) {
      xdid -t $hget($1,dialog.name) 1010 1 +
      xdid -t $hget($1,dialog.name) 1010 3 +d
    }
    else {
      xdid -t $hget($1,dialog.name) 1010 1 +d
      xdid -t $hget($1,dialog.name) 1010 3 +d
    }
  }
  if ($isalias(dc. $+ $hget($1,currentPanel) $+ .loadDefaults)) {
    xdid -t $hget($1,dialog.name) 1010 2 +
  }
  else {
    xdid -t $hget($1,dialog.name) 1010 2 +d
  }
  return 1
}

/*
* legt eine lokale Konfiguartionsdatei an
*
* @param $1 dcConfig objekt
* @return 1
*/
alias -l dcConfig.addConfig {
  .noop $dialog(dcConf_local,dcConf_local_table,-4)
  if ($hget($1,config.local) != $null) {
    if ($xdid($hget($1,dialog.name), $hget($1,currentTree),$chr(9) $+ $hget($1,config.local) $+ $chr(9),W,0,$hget($1,currentSelpath)).find == 0) {
      var %base $hget($hget($1,currentPanel.dbhash),config_user)
      var %target $replace(%base,.ini,. $+ $hget($1,config.local) $+ .ini)
      .copy $qt(%base) $qt(%target)
      var %pos $calc($xdid($hget($1,dialog.name),$hget($1,currentTree),$hget($1,currentSelpath)).num + 1)
      xdid -a $hget($1,dialog.name) $hget($1,currentTree) $+($hget($1,currentSelpath) %pos,$chr(9),+ 0 0 0 0 0 $rgb(0,0,255) $rgb(255,0,255) $hget($1,config.local),$chr(9),$hget($1,config.local))
      xdid -t $hget($1,dialog.name) $hget($1,currentTree) +a $hget($1,currentSelpath)
    }
    else {
      .noop $dcx(MsgBox,ok error modal owner $dialog($hget($1,dialog.name)).hwnd $chr(9) Fehler $chr(9) Konfiguration existiert bereits)
    }
  }
  return 1
}

/*
* Löscht eine Lokale Konfiguartion
*
* @param $1 dcConfig objekt
* @return 1
*/
alias -l dcConfig.delConfig {
  .remove $qt($hget($hget($1,currentPanel.dbhash),config_user))
  xdid -d $hget($1,dialog.name) $hget($1,currentTree) $hget($1,currentSelpath)
  xdid -c $hget($1,dialog.name) $hget($1,currentTree) $gettok($hget($1,currentSelpath),1,32)
  return 1
}

/*
* Lädt die Standart Konfiguration
*
* @param $1 dcConfig objekt
* @return 1
*/
alias -l dcConfig.loadDefaults {
  if ($isalias(dc. $+ $hget($1,currentpanel) $+ .loadDefaults)) {
    dc. $+ $hget($1,currentpanel) $+ .loadDefaults
  }
}

/*
* Alias zum Aufrufen des Config Dialoges
*/
alias config {
  set %dc.config.tree script
  set %dc.config.jumpin $1
  dialog -ma dcConf dcConf_table
}

alias config_modul {
  set %dc.config.jumpin $1
  set %dc.config.tree user
  dialog -ma dcConf dcConf_table
}

/**
* Setzt DialogName und Größe
*/
dialog dcConf_table {
  title "DragoonCore Einstellungen"
  size -1 -1 650 600
}

/*
* Verwaltet init und close Ereignis des Dialoges
*/
on *:dialog:dcConf:*:*: {
  if ($devent == init) {
    dcx Mark $dname dcConf.events
    xdialog -b $dname +twy
    set %dc.config.obj $dcConfig($dname,%dc.config.tree,%dc.config.jumpin)
  }
  elseif ($devent == close) {
    .noop $dcConfig(%dc.config.obj).destroy
    unset %dc.config.*
  }
}

/*
* Verwaltet Dialog-Ereignisse wie Mausklicks, Tastatureingaben, ...
*
* @param $1 DialogName
* @param $2 Ereignis
* @param $3 Betroffene ID
* @param $4 sonstiges
*/
alias dcConf.events {
  if (%dc.config.obj != $null) {
    if ($2 == sclick) {
      if ($3 == 1010) {
        if ($4 == 1) { .noop $dcConfig(%dc.config.obj).addConfig }
        elseif ($4 == 2) { .noop $dcConfig(%dc.config.obj).loadDefaults }
        elseif ($4 == 3) { .noop $dcConfig(%dc.config.obj).delConfig }
      }
      elseif ($3 == 1030) { .noop $dcConfig(%dc.config.obj,script).fillRebar }
      elseif ($3 == 1031) { .noop $dcConfig(%dc.config.obj,user).fillRebar }
      elseif ($3 == $dcConfig(%dc.config.obj,config.rebarId).get) {   
        if ($4 == 1) { xdid -m $1 $dcConfig(%dc.config.obj,config.rebarID).get 1 }
        .noop $dcConfig(%dc.config.obj,$4).selectRebarEntry
      }
    }
    if ($2 == selchange) {
      if ($3 > $dcConfig(%dc.config.obj,config.rebarID).get) { .noop $dcConfig(%dc.config.obj).selectTreeviewItem }
    }
    if ($3 > 0 && $3 < 1000) { dc. $+ $dcConfig(%dc.config.obj,currentPanel).get $+ .events $1- }
  }
}

/*
* Class Alias
* var %var $dcConfigLocal
*/
alias dcConfigLocal {
  var %this = dcConfigLocal           | ; Name of Object (Alias name)
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
  return $dcConfiglocal.init(%x,$1)

  :destroy
  return $dcConfigLocal.destroy($1)

  :createControls
  return $dcConfigLocal.createControls($1)

  :fillDropDown
  return $dcConfigLocal.fillDropDown($1)

  :addConfig
  return $dcConfigLocal.addConfig($1)

  :get
  return $dcBase($1,$2).get
}

/*
* Initialisiert den Dialog
*
* @param $1 dcConfigLocal objekt
* @param $2 dialog name
* @return dcConfigLocal objekt
*/
alias -l dcConfigLocal.init {
  if ($2 == $null) { hadd $1 dialog.name dcConf_local }
  else { hadd $1 dialog.name $2 }

  .noop $dcConfigLocal($1).createControls
  .noop $dcConfigLocal($1).fillDropDown

  hadd $1 limit_vars result

  return $1
}

/*
* Löscht ein dcConfigLocal objekt
*
* @param $1 dcConfigLocal objekt
* @return 1
*/
alias -l dcConfigLocal.destroy {

  .noop $dcBase($1).destroy
  return 1
}

/*
* Erzeugt die Bedienelemente
*
* @param $1 dcConfigLocal objekt
* @return 1
*/
alias -l dcConfigLocal.createControls {
  xdialog -c $hget($1,dialog.name) 1 comboex 10 10 150 300 dropdown
  xdialog -c $hget($1,dialog.name) 2 button 50 40 75 20 default
  xdid -t $hget($1,dialog.name) 2 Hinzufügen
  return 1
}

/*
* Füllt das Dropdown
*
* @param $1 dcConfigLocal objekt
* return 1
*/
alias -l dcConfigLocal.fillDropDown {
  var %list $dcNetworkList
  .noop $dcNetworkList(%list).prepareWhile
  while ($dcNetworkList(%list).next) {
    xdid -a $hget($1,dialog.name) 1 0 0 0 0 0 $dcNetworkList(%list).getValue
    if ($dcNetworkList(%list).getValue == $network) {
      xdid -c $hget($1,dialog.name) 1 $dcNetworkList(%list).getPos
    }
  }
  .noop $dcNetworkList(%list).destroy
}

/*
* Button Hinzufügen wurde gedrückt
*
* @param $1 dcConfigLocal objekt
* @return 1
*/
alias -l dcConfigLocal.addConfig {
  .noop $dcConfig(%dc.config.obj,config.local,$xdid($hget($1,dialog.name),1).seltext).set
  dialog -x $hget($1,dialog.name)
}


/*
* Setzt DialogName und Größe
*/
dialog dcConf_local_table {
  title "Lokale Config"
  size -1 -1 175 65
}

/*
* Verwaltet init und close Ereignis des Dialoges
*/
on *:dialog:dcConf_local:*:*: {
  if ($devent == init) {
    dcx Mark $dname dcConf_local.events
    xdialog -b $dname +twy
    set %dc.config.local.obj $dcConfigLocal($dname)


  }
  elseif ($devent == close) {
    .noop $dcConfigLocal(%dc.config.local.obj).destroy
  }
}

/*
* Verwaltet Dialog-Ereignisse wie Mausklicks, Tastatureingaben, ...
*
* @param $1 DialogName
* @param $2 Ereignis
* @param $3 Betroffene ID
* @param $4 sonstiges
*/
alias dcConf_local.events {
  if ($2 == sclick) {
    if ($3 == 2) { .noop $dcConfigLocal(%dc.config.local.obj).addConfig }
  }
}