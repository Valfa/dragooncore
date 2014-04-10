/*
* Das DragoonCore Datenbank System (ini-file Basierend)
* Trennung zwischen reinen Script- und User-Daten
* Server Spezifisches Speichern und Lesen
*
* @author Valfa
* @version 1.0
*/

/*
* Class Alias
* var %var $dcdcDbs
*
* @param $1 Datenbank kürzel
* @param $2 Netzwerk oder $null
* @param $3 "Force Network Data" $null (Standard Verhalten), r (read) oder c (create)
*/
alias dcdcDbs {
  var %this = dcdcDbs            | ; Name of Object (Alias name)
  var %base = dcBase        | ; Name of dcBase, $null for none  

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
  return $dcdcDbs.init(%x,$1,$2,$3)

  :setSection
  return $dcdcDbs.setSection($1,$2)

  :getUserSection
  return $dcdcDbs.getSection($1,user,$2)

  :getScriptSection
  return $dcdcDbs.getSection($1,script,$2)

  :setUserValue
  return $dcdcDbs.setValue($1,user,$2,$3,$4)

  :getUserValue
  return $dcdcDbs.getValue($1,user,$2,$3)

  :getScriptValue
  return $dcdcDbs.getValue($1,script,$2,$3)

  :getUserItem
  return $dcdcDbs.getItem($1,user,$2,$3)

  :getScriptItem
  return $dcdcDbs.getItem($1,script,$2,$3)

  :deleteUserItem
  return $dcdcDbs.deleteItem($1,user,$2,$3)

  :deleteUserSection
  return $dcdcDbs.deleteSection($1,user,$2)
}

/*
* Initialisiert eine Datenbank
*
* @param $1 md5hash
* @param $2 zu Initialisierende DB
* @param $3 Netzwerk (optional)
* @param $4 Force $null, r (read) oder c (create)
* @return md5hash
*/
alias -l dcdcDbs.init {
  var %path.user dcdb/user/
  var %path.script dcdb/script/
  var %path.db $readini(dcdb/script/Framework/Framework.ini,n,dcdcDbs,$2) 
  hadd -m $1 config_user %path.user $+ %path.db
  hadd -m $1 config_script %path.script $+ %path.db
 
  if ($3 != $null) {
    var %file $replacex($hget($1,config_user),.ini,. $+ $3 $+ .ini)
    if ($exists(%file)) {
      hadd -m $1 config_user %file
    }
    else {
      if ($4 == r) {
        .noop $dcBase($1).destroy
        return 0
      }
      elseif ($4 == c) {
        write %file
        hadd -m $1 config_user %file
      }
    }
  }
  hadd $1 section $null
  hadd $1 database $2
  hadd $1 limit_get config_user,config_script
  return $1
}

/*
* Setzt eine Sektion fest
*
* @param $1 Datenbank md5hash
* @param $2 Sektion
* @return 0 oder 1
*/
alias -l dcdcDbs.setSection {
  if ($2 != $null) {
    hadd $1 section $2
    return 1
  }
  else {
    hadd $1 section $null
    return 0
  }
}

/*
* Liest den Namen einer Sektion aus
*
* @param $1 Datenbank md5hash
* @param $2 Datenbank-Datei
* @param $3 Nr. Der Sektion
* @return Name der Sektion oder $null
*/
alias -l dcDbs.getSection {
  return $ini($hget($1,config_ $+ $2),$3)
}

/*
* Setzt einen Wert in einer Benutzer Ini
*
* @param $1 Datenbank md5Hash
* @param $2 Datenbank Datei
* @param $3 Sektion (kann weggelassen werden wenn mit setsection gesetzt)
* @param $4 Item
* @param $5 Wert
* @return 1 oder 0
*/
alias -l dcDbs.setValue {
  if ($hget($1,section) == $null && $5 == $null) {
    return 0
  }
  else {
    if ($5 != $null) {
      .writeini $qt($hget($1,config_ $+ $2)) $3 $4 $5
    }
    else {
      .writeini $qt($hget($1,config_ $+ $2)) $hget($1,section) $3 $4
    }
    return 1
  }
}

/*
* Liest einen Wert aus
*
* @param $1 Datenbank md5hash
* @param $2 Datenbank datei
* @param $3 Sektion (kann weggelassen werden wenn setSection gesetzt)
* @param $4 Item
* @return Wert des Items oder $null
*/
alias -l dcDbs.getValue {
  if ($hget($1,section) == $null && $4 == $null) {
    return $null
  }
  else {
    if ($4 != $null) {
      return $readini($hget($1,config_ $+ $2),n,$3,$4)
    }
    else {
      return $readini($hget($1,config_ $+ $2),n,$hget($1,section),$3)
    }
  }
}

/*
* Liest den Namen eines Bestimmten Items aus
*
* @param $1 Datenbank md5hash
* @param $2 Datenbank-datei
* @param $3 Sektion (kann entfallen wenn setSection gesetzt)
* @param $4 ItemId
* @return Name der Sektion oder $null
*/
alias -l dcDbs.getItem {
  if ($hget($1,section) == $null && $4 == $null) {
    return $null
  }
  else {
    if ($4 != $null) {
      return $ini($hget($1,config_ $+ $2),$3,$4)
    }
    else {
      return $ini($hget($1,config_ $+ $2),$hget($1,section),$3)
    }
  }
}

/*
* Löscht einen Bestimmten Wert
*
* @param $1 Datenbank md5hash
* @param $2 Datenbank datei
* @param $3 Sektion (kann entfallen wenn setSection gesetzt)
* @param $4 item
* @return 1 oder 0
*/
alias -l dcDbs.deleteItem {
  if ($hget($1,section) == $null && $4 == $null) {
    return 0
  }
  else {
    if ($4 != $null) {
      .remini $qt($hget($1,config_ $+ $2)) $3 $4
      return 1
    }
    else {
      .remini $qt($hget($1,config_ $+ $2)) $hget($1,section) $3
      return 1
    }
  }
}

/*
* Löscht eine Bestimmten Sektion
*
* @param $1 Datenbank md5hash
* @param $2 Datenbak datei
* @param $3 Sektion (kann entfallen wenn setSection gesetzt)
* @return 1 oder 0
*/
alias -l dcDbs.deleteSection {
  if ($hget($1,section) == $null && $3 == $null) {
    return 0
  }
  else {
    if ($3 != $null) {
      .remini $qt($hget($1,config_ $+ $2)) $3
      return 1
    }
    else {
      .remini $qt($hget($1,config_ $+ $2)) $hget($1,section)
      return 1
    }
  }
}



/*
* Class Alias
* var %var $dcDbsList
*
* @param $1 dcDbs md5hash
* @param $2 Datenbank-datei
* @param $3 sektion oder $null
* @return dcDbsList md5hash
*/
alias dcDbsList {
  var %this = dcDbsList              | ; Name of Object (Alias name)
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
  return $dcDbsList.init(%x,$1,$2,$3)


}

/*
* Initialisiert eine Liste
*
* @param $1 md5hash
* @param $2 dcDbs md5hash
* @param $3 Datenbank-datei
* @param $4 sektion oder $null
* @return DB md5hash
*/
alias -l dcDbsList.INIT {
  var %file $hget($2,config_ $+ $3)
  hadd $1 getData 1
  hadd $1 file %file
  hadd $1 section $4
  hadd $1 current_item $null
  hadd $1 current_value $null
  if (%file != $null) {
    if ($4 == $null) {
      if ($ini(%file,0) > 0) {
        hadd $1 pos 1
        hadd $1 last $ini(%file,0)
        return $1
      }
      else {
        return 0
      }
    }
    else {
      if ($ini(%file,$4,0) > 0) {
        hadd $1 pos 1
        hadd $1 last $ini(%file,$4,0)
        return $1
      }
      else {
        return 0
      }
    }
  }
  else {
    return 0
  }
}

/*
* Liest Daten an der aktuellen ZeigerPosition aus
*
* @param $1 dcDbsList md5hash
* @return 1
*/
alias dcDbsList.getData {
  if ($hget($1,section) == $null) {
    hadd $1 current_item $ini($hget($1,file),$hget($1,pos))
    hadd $1 current_value $null
  }
  else {
    hadd $1 current_item $ini($hget($1,file),$hget($1,section),$hget($1,pos))
    hadd $1 current_value $readini($hget($1,file),n,$hget($1,section),$hget($1,current_item))
  }
  return 1
}
