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
* var %var $dcScriptList
*/
alias dcScriptList {
  var %this = dcScriptList           | ; Name of Object (Alias name)
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
  return $dcScriptList.init(%x,$1)
}

/*
* Initialisiert die Liste
*
* @param $1 dcScriptListe objekt
* @param $2 folder
* @return dcScriptListe objekt
*/
alias -l dcScriptList.init {
  var %hash $1
  var %remove $2
  hmake %hash $+ _tmp 100
  var %last $findfile($2,*.*,0,/hadd %hash $+ _tmp n $+ $findfilen $remove($1-,$mircdir $+ %remove))
  hadd $1 pos 1
  hadd $1 limit_get folder,file,active
  
  var %i 1
  var %j 0
  while (%i <= %last) {
    var %tmp $hget(%hash $+ _tmp,n $+ %i)
    if ($right(%tmp,4) == .mrc || $right(%tmp,4) == .ini) {
      inc %j
      hadd %hash n $+ %j %tmp
    }
    inc %i
  }
  hadd $1 last %j
  .hfree %hash $+ _tmp
  .noop $dcScriptList.getData($1)
  return $1
}

/*
* Liest die Daten zum aktuellen Element aus
*
* @param $1 dcScriptList objekt
* @return 1
*/
alias dcScriptList.getData {
  hadd $1 folder $remove($nofile($hget($1,n $+ $hget($1,pos))),/,\)
  hadd $1 file $remove($nopath($hget($1,n $+ $hget($1,pos))),/,\)
  hadd $1 active [ $iif($script($hget($1,file)),1,0) ]
  return 1
}

/*
* Class Alias
* var %var $dcScript
*
* @param $1 folder
*/
alias dcScript {
  var %this = dcScript           | ; Name of Object (Alias name)
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
  return $dcScript.init(%x,$1)

  :destroy
  return $dcScript.destroy($1)

  :getListObjekt
  return $hget($1,listhash)

  :getErrorObject
  return $hget($1,error.obj)

  :loadScript
  return $dcScript.loadScript($1,$2)

  :unloadScript
  return $dcScript.unloadScript($1,$2)

  :loadScriptFolder
  return $dcScript.loadScriptFolder($1,$2)

  :unloadScriptFolder
  return $dcScript.unloadScriptFolder($1,$2)
}

/*
* Initialisiert ein dcScript objekt
*
* @param $1 dcScript objekt
* @return dcScript objekt
*/
alias -l dcScript.init {
  hadd $1 listhash $dcScriptList($2)
  hadd $1 limit_get 
  hadd $1 folder $2
  hadd $1 error.obj $dcError
  return $1
}

/*
* Zerstört ein dcScript objekt
*
* @param $1 dcScript objekt
* @return 1
*/
alias -l dcScript.destroy {
  .noop $dcScriptList($hget($1,listhash)).destroy
  .noop $dcError($hget($1,error.obj)).destroy
  .noop $dcBase($1).destroy
  return 1
}

/*
* Lädt eine Script Datei
*
* @param $1 dcScript objekt
* @param $2 file
* @param $3 error 1
* @return 1 oder 0
*/
alias -l dcScript.loadScript {
  if (!$3) { .noop $dcError($hget($1,error.obj)).clear }
  var %file $hget($1,folder) $+ \ $+ $2
  if ($isfile($mircdir $+ %file)) {
    if ($right($2,4) == .mrc) {
      .load -rs $qt(%file)
      return 1
    }
    elseif ($right($2,4) == .ini) {
      if ($read(%file,w,[script])) { .load -rs $qt(%file) }
      else {
        .noop $dcError($hget($1,error.obj),Datei $qt(%file) ist keine gültige Script Datei).add
        return 0
      }
      return 1
    }
    else {
      .noop $dcError($hget($1,error.obj),Datei $qt(%file) besitzt ein ungültiges Format).add
      return 0
    }
  }
  else {
    .noop $dcError($hget($1,error.obj), Datei $qt(%file) wurde nicht gefunden).add
    return 0
  }
}

/*
* Entlädt eine Script Datei
*
* @param $1 dcScript objekt
* @param $2 file
* @param $3 error 1
* @return 1 oder 0
*/
alias -l dcScript.unloadScript {
  if (!$3) { .noop $dcError($hget($1,error.obj)).clear }
  var %file $nopath($2)
  if ($script(%file)) {
    if ($right(%file,4) == .mrc) { 
      unload -rs $qt(%file)
      return 1
    }
    elseif ($right(%file,4) == .ini) {
      unload -rs %file
      return 1
    }
    else {
      .noop $dcError($hget($1,error.obj),Datei $qt(%file) besitzt ein ungültiges Format).add
      return 0
    }
  }
  else {
    .noop $dcError($hget($1,error.obj),Datei $qt(%file) ist nicht geladen).add
    return 0
  }
}

/*
* Lädt alle Script dateien eines ordners
*
* @param $1 dcScript objekt
* @param $2 ordner
* @return 1 oder 0
*/
alias -l dcScript.loadScriptFolder {
  .noop $dcError($hget($1,error.obj)).clear
  var %list $dcScriptList($hget($1,folder) $+ \ $+ $2)
  if (%list) {
    .noop $dcScriptList(%list).prepareWhile
    while ($dcScriptList(%list).next) {
      if (!$script($dcScriptList(%list,file).get)) {
        .noop $dcScript($1,$2 $+ \ $+ $dcScriptList(%list,file).get,1).loadScript
      }
    }
    if ($dcError($hget($1,error.obj)).count) {
      return 0
    }
    else {
      return 1
    }
  }
  else {
    .noop $dcError($hget($1,error.obj),Ordner $qt($2) nicht gefunden oder leer).add
    return 0
  }
}

/*
* Entlädt alle Script dateien eines ordners
*
* @param $1 dcScript objekt
* @param $2 ordner
* @return 1 oder 0
*/
alias -l dcScript.unloadScriptFolder {
  .noop $dcError($hget($1,error.obj)).clear
  var %list $dcScriptList($hget($1,folder) $+ \ $+ $2)
  if (%list) {
    .noop $dcScriptList(%list).prepareWhile
    while ($dcScriptList(%list).next) {
      if ($script($dcScriptList(%list,file).get)) {
        .noop $dcScript($1,$dcScriptList(%list,file).get,1).unloadScript
      }
    }
    if ($dcError($hget($1,error.obj)).count) {
      return 0
    }
    else {
      return 1
    }
  }
  else {
    .noop $dcError($hget($1,error.obj),Ordner $qt($2) nicht gefunden oder leer).add
    return 0
  }
}

/*
* Class Alias
* var %var $dcScriptDialog
*/
alias dcScriptDialog {
  var %this = dcScriptDialog           | ; Name of Object (Alias name)
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
  return $dcScriptDialog.init(%x,$1)

  :destroy
  return $dcScriptDialog.destroy($1)

  :createControls
  return $dcScriptDialog.createControls($1)

  :fillList
  return $dcScriptDialog.fillList($1)

  :toggleScript
  return $dcScriptDialog.toggleScript($1)
}

/*
* Initialisiert den Dialog
*
* @param $1 dcScriptDialog objekt
* @param $2 dialog name oder $null
* @return dcScriptDialog objekt
*/
alias -l dcScriptDialog.init {
  hadd $1 script.obj $dcScript(scripts\user)
  if ($2 != $null) { hadd $1 dialog.name $2 }
  else { hadd $1 dialog.name dcScript }

  .noop $dcDialog($1,435,540).createBasePanel
  .noop $dcScriptDialog($1).createControls
  .noop $dcScriptDialog($1).fillList

  return $1
}

/*
* löscht ein dcModulDialog objekt
*
* @param $1 dcModulDialog objekt
* @return 1
*/
alias -l dcScriptDialog.destroy {
  .noop $dcScript($hget($1,script.obj)).destroy
  .noop $dcBase($1).destroy
  return 1
}

/*
* Initialisiert die Control-Elemente
* 
* @param $1 dcScriptDialog objekt
* @return 1
*/
alias -l dcScriptDialog.createControls {
  xdid -c $hget($1,dialog.name) 1 100 text 0 0 200 25
  xdid -t $hget($1,dialog.name) 100 Benutzer Scripte
  xdid -f $hget($1,dialog.name) 100 + default 14 Arial

  xdid -c $hget($1,dialog.name) 1 101 text 5 25 100 20
  xdid -t $hget($1,dialog.name) 101 Script Liste
  xdid -f $hget($1,dialog.name) 101 + default 10 Verdana

  xdid -c $hget($1,dialog.name) 1 2 treeview 5 50 300 485 haslines nohscroll showsel
  xdid -l $hget($1,dialog.name) 2 24
  xdid -w $hget($1,dialog.name) 2 +n 0 images/ico/unchecked_checkbox.ico
  xdid -w $hget($1,dialog.name) 2 +n 0 images/ico/checked_checkbox.ico

  return 1
}

/*
* Füllt die Script Liste
*
* @param $1 dcScriptDialog objekt
* @return 1
*/
alias -l dcScriptDialog.fillList {
  var %list $dcScript($hget($1,script.obj)).getListObjekt
  var %folder $null
  var %i 0
  var %j 0
  var %active.count 0
  .noop $dcScriptList(%list).prepareWhile
  while ($dcScriptList(%list).next) {
    if ($dcScriptList(%list,active).get) { var %icon 2 }
    else { var %icon 1 }
    if (%folder != $dcScriptList(%list,folder).get && $dcScriptList(%list,folder).get) {
      if (%i) {
        xdid -t $hget($1,dialog.name) 2 +e %i
        if (%active.count == $xdid($hget($1,dialog.name),2,%i).num) {
          xdid -j $hget($1,dialog.name) 2 %i $chr(9) 2 2
        }
      }    
      var %folder $dcScriptList(%list,folder).get
      var %j 1
      inc %i
      if (%icon == 2) { inc %active.count }
      xdid -a $hget($1,dialog.name) 2 $+(%i,$chr(9),+ 1 1 0 0 0 $rgb(0,0,255) $rgb(255,0,255) $dcScriptList(%list,folder).get,$chr(9),$dcScriptList(%list,folder).get)
      xdid -a $hget($1,dialog.name) 2 $+(%i %j,$chr(9),+ %icon %icon 0 0 0 $rgb(0,0,255) $rgb(255,0,255) $dcScriptList(%list,file).get,$chr(9),$dcScriptList(%list,file).get)
    }
    elseif (%folder == $dcScriptList(%list,folder).get && $dcScriptList(%list,folder).get) {
      inc %j
      if (%icon == 2) { inc %active.count }
      xdid -a $hget($1,dialog.name) 2 $+(%i %j,$chr(9),+ %icon %icon 0 0 0 $rgb(0,0,255) $rgb(255,0,255) $dcScriptList(%list,file).get,$chr(9),$dcScriptList(%list,file).get)
    }
    elseif (!$dcScriptList(%list,folder).get) {
      inc %i
      xdid -a $hget($1,dialog.name) 2 $+(%i,$chr(9),+ %icon %icon 0 0 0 $rgb(0,0,255) $rgb(255,0,255) $dcScriptList(%list,file).get,$chr(9),$dcScriptList(%list,file).get)
    }
  }
  if (%i) {
    xdid -t $hget($1,dialog.name) 2 +e %i
    if (%active.count == $xdid($hget($1,dialog.name),2,%i).num) {
      xdid -j $hget($1,dialog.name) 2 %i $chr(9) 2 2
    }
  }
  return 1
}

/*
* Lädt und Entlädt Scripte
*
* @param $1 dcScriptDialog objekt
* @return 1
*/
alias -l dcScriptDialog.toggleScript {
  var %path $xdid($hget($1,dialog.name),2).selpath
  if ($xdid($hget($1,dialog.name),2,%path).num) {
    if ($xdid($hget($1,dialog.name),2,%path).icon == 1) {
      if ($dcScript($hget($1,script.obj),$xdid($hget($1,dialog.name),2,%path).seltext).loadScriptFolder) {
        xdid -j $hget($1,dialog.name) 2 %path $chr(9) 2 2
        var %i 1, %last $xdid($hget($1,dialog.name),2,%path).num
        while (%i <= %last) {
          xdid -j $hget($1,dialog.name) 2 %path %i $chr(9) 2 2
          inc %i
        }
      }
      else {
        .noop $dcError($dcScript($hget($1,script.obj)).getErrorObject,$dialog($hget($1,dialog.name)).hwnd).showDialog
      }
    }
    else {
      if ($dcScript($hget($1,script.obj),$xdid($hget($1,dialog.name),2,%path).seltext).unloadScriptFolder) {
        xdid -j $hget($1,dialog.name) 2 %path $chr(9) 1 1
        var %i 1, %last $xdid($hget($1,dialog.name),2,%path).num
        while (%i <= %last) {
          xdid -j $hget($1,dialog.name) 2 %path %i $chr(9) 1 1
          inc %i
        }
      }
      else {
        .noop $dcError($dcScript($hget($1,script.obj)).getErrorObject,$dialog($hget($1,dialog.name)).hwnd).showDialog
      }
    }
    ;xdid -t $hget($1,dialog.name) 2 +a %path
  }
  else {
    var %folder $null
    if ($numtok(%path,32) == 2) {
      var %folder $xdid($hget($1,dialog.name),2,$gettok(%path,1,32)).text $+ \
    }

    if ($xdid($hget($1,dialog.name),2,%path).icon == 1) {
      if ($dcScript($hget($1,script.obj),%folder $+ $xdid($hget($1,dialog.name),2).seltext).loadScript) {
        xdid -j $hget($1,dialog.name) 2 %path $chr(9) 2 2
      }
      else {
        .noop $dcError($dcScript($hget($1,script.obj)).getErrorObject,$dialog($hget($1,dialog.name)).hwnd).showDialog
      }
    }
    else {
      if ($dcScript($hget($1,script.obj),$xdid($hget($1,dialog.name),2).seltext).unloadScript) {
        xdid -j $hget($1,dialog.name) 2 %path $chr(9) 1 1
      }
      else {
        .noop $dcError($dcScript($hget($1,script.obj)).getErrorObject,$dialog($hget($1,dialog.name)).hwnd).showDialog
      }
    }
  }
}

/*
* Wird durch den Config-Dialog aufgerufen, initalisiert den Dialog
*
* @param $1 dcConfig objekt
*/
alias dc.frameworkScriptUser.createPanel { 
  set %dc.fw.script.obj $dcScriptDialog($dcConfig($1,dialog.name).get)
}

/*
* Wird durch den Config-Dialog aufgerufen, zerstört den Dialog
*/
alias dc.frameworkScriptUser.destroyPanel { 
  .noop $dcScriptDialog(%dc.fw.script.obj).destroy
}

/*
* Verwaltet Dialog-Ereignisse wie Mausklicks, Tastatureingaben, ...
*
* @param $1 DialogName
* @param $2 Ereignis
* @param $3 Betroffene ID
* @param $4 sonstiges
*/
alias dc.frameworkScriptUser.events {
  if ($2 == sclick && $3 == 2) { 
    .noop $dcScriptDialog(%dc.fw.script.obj).toggleScript
  }
}
