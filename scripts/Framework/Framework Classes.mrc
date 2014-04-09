/*
* A Collection of Classes that can be used by other scripts
*
* @author Valfa
* @version 1.0
*/

/*
* BaseClass
* Just some default functions that can be directly called by other objects
*
* @author Valfa
* @version 1.0
*/
alias baseClass {
  var %this = baseClass      | ; Name of Object (Alias name)
  var %base = $null              | ; Name of BaseClass, $null for none

  /*
  * Start of data parsing
  * Do not edit
  */

  if (% [ $+ [ %this ] ] != $null ) { goto callprop } 
  if (!$prop) { goto init } 
  if (!$hget($1) && $hget($1,INIT) != $null && $prop != init) { echo -a * Error: Object not initialized %this | halt }
  ;if (if %base == $null && $hget($1,BASE) != %this) { echo -a * Error: Object is not from %this | halt }
  ;if (if %base != $null && $hget($1,INIT) != %this) { echo -a * Error: Object is not from %this | halt }
  if ($isalias($+(%this,.,$prop,.PRIVATE))) { echo -a * ERROR: Unable to access Method $qt(%prop) | halt }
  goto $prop
  halt

  :error
  echo -a $iif($error,$v1,Unknown error) in Class: %this
  .reseterror
  return 0

  :callprop
  var %prop $gettok(% [ $+ [ %this ] ],1,32)
  .tokenize 32 $gettok(% [ $+ [ %this ] ],2-,32)
  .unset % [ $+ [ %this ] ]
  goto %prop
  halt

  /*
  * Your Class methods
  * Start editing here
  */

  :init
  return $baseClass.init($1,$2)

  :get
  return $baseClass.get($1,$2)

  :set
  return $baseClass.set($1,$2,$3)

  :exists
  return $hget($1,exists)

  :destroy
  return $baseClass.destroy($1)
}

/*
* Initialisiert ein Objekt auf Basis der baseClass
*
* @param $1 Klasse
* @param $2 %this
* @return Hash des Objekts
*/
alias -l baseClass.init {
  inc %oop
  var %hash $md5($ctime $+ $ticks $+ %oop)
  hmake %hash 100
  hadd %hash INIT $1
  hadd %hash BASE $2
  hadd %hash exists 1
  return %hash
}

alias -l baseClass.destroy {
  hfree $1
  dec %oop
  return 1
}

/*
* Liest einen Wert aus
*
* @param $1 Objekthash
* @param $2 item
* @return Wert des Items
*/
alias -l baseClass.get {
  if (($hget($1,limit_vars) != $null && $2 isin $hget($1,limit_vars)) || ($hget($1,limit_get) != $null && $2 isin $hget($1,limit_get))) {
    return $hget($1,$2)  
  }
  elseif ($hget($1,limit_vars) == $null) {
    return $hget($1,$2)
  }
  else {
    return $null
  }

}

/*
* Setzt einen Wert
*
* @param $1 Objekthash
* @param $2 item
* @param $3 Wert
* @return 1 oder 0
*/
alias -l baseClass.set {
  if (($hget($1,limit_vars) != $null && $2 isin $hget($1,limit_vars)) || ($hget($1,limit_set) != $null && $2 isin $hget($1,limit_set))) {
    hadd $1 $2 $3
    return 1
  }
  elseif ($hget($1,limit_vars) == $null) {
    hadd $1 $2 $3
    return 1
  }
  else {
    return 0
  }
}

/*
* BaseListClass
* Provides most Functionality for List Classes
*
* @author Valfa
* @version 1.0
*/
alias baseListClass {
  var %this = baseListClass      | ; Name of Object (Alias name)
  var %base = $null              | ; Name of BaseClass, $null for none

  /*
  * Start of data parsing
  * Do not edit
  */

  if (% [ $+ [ %this ] ] != $null ) { goto callprop } 
  if (!$prop) { goto init } 
  if (!$hget($1) && $prop != init) { echo -a * Error: Object not initialized %this | halt }
  if (if %base == $null && $hget($1,BASE) != %this) { echo -a * Error: Object is not from %this | halt }
  ;if (if %base != $null && $hget($1,INIT) != %this) { echo -a * Error: Object is not from %this | halt }
  if ($isalias($+(%this,.,$prop,.PRIVATE))) { echo -a * ERROR: Unable to access Method $qt(%prop) | halt }
  goto $prop
  halt

  :error
  echo -a $iif($error,$v1,Unknown error) in Class: %this
  .reseterror
  return 0

  :callprop
  var %prop $gettok(% [ $+ [ %this ] ],1,32)
  .tokenize 32 $gettok(% [ $+ [ %this ] ],2-,32)
  .unset % [ $+ [ %this ] ]
  goto %prop
  halt

  /*
  * Your Class methods
  * Start editing here
  */

  :init
  var %x $baseClass($1,$2).init
  return $baseListClass.init(%x)

  :prepareWhile
  return $baseListClass.prepareWhile($1,$2)

  :next
  return $baseListClass.next($1)

  :prev
  return $baseListClass.prev($1)

  :first
  return $baseListClass.first($1)

  :last
  return $baseListClass.last($1)

  :setPos
  return $baseListClass.setPos($1,$2)

  :getPos
  return $hget($1,pos)

  :getItem
  return $hget($1,current_item)

  :getValue
  return $hget($1,current_value)
  
  :count
  return $hget($1,last)

  :exists
  return $hget($1,exists)

  :destroy
  return $baseClass.destroy($1)

  :clear
  return $baseListClass.clear($1)

  :addLastElement
  return $baseListClass.addLastElement($1,$2-)

}

/*
* Initialisiert ein BaseListClass objekt
*
* @param $1 baseListClass objekt
* @return baseListClass objekt
*/
alias -l baseListClass.init {
  hadd $1 pos 0
  hadd $1 last 0
  return $1
}

/*
* Setzt die Position entsprechend der Nutzung von While Schleifen
*
* @param $1 ListKlassen Hash
* @param $2 0 --> oder 1 <--
* @return 1 oder 0
*/
alias -l baseListClass.prepareWhile {
  if ($2 == 0 || $2 == $null) { 
    hadd $1 pos 0 
    return 1
  }
  elseif ($2 == 1) { 
    hadd $1 pos $calc($hget($1,last) + 1) 
    return 1
  }
  else { 
    return 0
  }  
}

/*
* Liest Daten an der aktuellen ZeigerPosition aus
*
* @param $1 dbsList md5hash
* @return 1
*/
alias -l baseListClass.getData {
  var %tmp $hget($1,INIT) $+ .getData
  if ($isalias(%tmp)) {
    .noop $ [ $+ [ %tmp ] $+ ($1) ]
    ;%tmp $1
    return 1
  }
  else {
    hadd $1 current_item n $+ $hget($1,pos)
    hadd $1 current_value $hget($1,$hget($1,current_item))
  }
}

/*
* setzt den PositionsZeiger auf das nächste Element
*
* @param $1 ListKlassen md5hash
* @return 1 oder 0
*/
alias -l baseListClass.next {
  hinc $1 pos
  if ($hget($1,pos) > $hget($1,last)) {
    return 0
  }
  else {
    .noop $baseListClass.getData($1)
    return 1
  }
}

/*
* setzt den PositionsZeiger auf das vorherige Element
*
* @param $1 ListKlassen md5hash
* @return 1 oder 0
*/
alias -l baseListClass.prev {
  hdec $1 pos
  if ($hget($1,pos) < 1) {
    return 0
  }
  else {
    .noop $baseListClass.getData($1)
    return 1
  }
}

/*
* setzt den PositionsZeiger auf das erste Element
*
* @param $1 ListKlassen md5hash
* @return 1
*/
alias -l baseListClass.first {
  hadd $1 pos 1
  .noop $baseListClass.getData($1)
  return 1
}

/*
* setzt den PositionsZeiger auf das letzte Element
*
* @param $1 ListKlassen md5hash
* @return 1
*/
alias -l baseListClass.last {
  hadd $1 pos $hget($1,last)
  .noop $baseListClass.getData($1)
  return 1
}

/*
* setzt den PositionsZeiger auf ein bestimmtes
*
* @param $1 ListKlassen md5hash
* @param $2 Position
* @return 1 oder 0
*/
alias -l baseListClass.setPos {
  if ($2 >= 1 && $2 <= $hget($1,last)) {
    hadd $1 pos $2
    .noop $baseListClass.getData($1)
    return 1
  }
  else {
    return 0
  }
}

/*
* Fügt ein Element am Ende der Liste ein
*
* @param $1 baseListClass objekt
* @param $2- Wert
* @return 1 oder 0
*/
alias -l baseListClass.addLastElement {
  if ($2 != $null) {
    hadd $1 n $+ $calc($hget($1,last) + 1) $2-
    hinc $1 last
    return 1
  }
  else {
    return 0
  }
}

/*
* Löscht alle Elemente
*
* @param $1 baseListClass objekt
* @return 1
*/
alias -l baseListClass.clear {
  hdel -w $1 n*
  hadd $1 last 0
  hadd $1 pos 0
  return 1
}

/*
* Class Alias
* var %var $networkList
*/
alias networkList {
  var %this = networkList            | ; Name of Object (Alias name)
  var %base = baseListClass        | ; Name of BaseClass, $null for none  

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
  return $networkList.init(%x)
}

/*
* Initialisiert eine Datenbank
*
* @param $1 md5hash
* @return md5hash
*/
alias -l networkList.init {
  var %i 1
  var %j 1
  var %max $server(0)
  while (%i <= %max) {
    if ($hfind($1,$server(%i).group,1,n).data == $null) {
      hadd $1 n $+ %j $server(%i).group
      inc %j
    }
    inc %i
  }
  hadd $1 pos 1
  hadd $1 last $calc(%j - 1)
  .noop $baseListClass.getData($1)
  return $1
}

/*
* Class Alias
* var %var $serverList
*
* @param $1 Netzwerk
*/
alias serverList {
  var %this = serverList           | ; Name of Object (Alias name)
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
  return $serverList.INIT(%x,$1)
}

/*
* Initialisiert eine Datenbank
*
* @param $1 md5hash
* @param $2 netzwerk
* @return md5hash
*/
alias -l serverList.INIT {
  var %i 1
  var %max $server(0,$2)
  while (%i <= %max) {
    hadd $1 n $+ %i $server(%i,$2)
    inc %i
  }
  hadd $1 pos 1
  hadd $1 last $calc(%i - 1)
  .noop $baseListClass.getData($1)
  return $1
}

/*
* Class Alias
* var %var $serveData
*
* @param $1 server
*/
alias serverData {
  var %this = serverData            | ; Name of Object (Alias name)
  var %base = baseClass        | ; Name of BaseClass, $null for none  

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
  return $serverData.init(%x,$1)

  :destroy
  return $serverData.destroy($1)

  :saveServer
  return $serverData.saveServer($1)

  :delServer
  return $serverData.delServer($1)

  :seperatePorts
  return $serverData.seperatePorts($1,$2)

  :combinePorts
  return $serverData.combinePorts($1,$2,$3)

  :set
  return 0

  :setAddress
  return $serverData.setAddress($1,$2)

  :setDesc
  return $serverData.setDesc($1,$2)

  :setPorts
  return $serverData.setPorts($1,$2-)

  :setSSL-Ports
  return $serverData.setSSL-Ports($1,$2-)

  :setPass
  return $serverData.setPass($1,$2)

  :setGroup
  return $serverData.setGroup($1,$2)

  :getErrorObject
  return $hget($1,error.obj)
}

/*
* Initialisiert ein serverData objekt
*
* @param $1 serverData objekt
* @param $2 netzwerk (optional)
* @return serverdata objekt
*/
alias -l serverData.init {
  if ($2 != $null && $server($2) != $null) {
    hadd $1 address $2
    hadd $1 desc $server($2).desc
    hadd $1 group $server($2).group
    hadd $1 pass $server($2).pass

    .noop $serverData($1,$server($2).port).seperatePorts
    hadd $1 exists 1
    hadd $1 mode edit
  }
  else {
    hadd $1 address $null
    hadd $1 desc $null
    hadd $1 group $null
    hadd $1 pass $null
    hadd $1 ports $null
    hadd $1 ssl-ports $null
    hadd $1 exists 0
    hadd $1 mode new
  }
  hadd $1 error.obj $dcError
  return $1
}

/*
* Zerstört ein serverData objekt
*
* @param $1 serverData objekt
* @return 1
*/
alias -l serverData.destroy {
  .noop $dcError($hget($1,error.obj)).destroy
  .noop $baseClass($1).destroy
  return 1
}

/*
* Trennt einen String mit Ports nach ssl und non-ssl
*
* @param $1 serverData objekt
* @param $2 port string
* @return 1
*/
alias -l serverData.seperatePorts {
  var %ports $null
  var %ssl-ports $null
  var %i 1
  while (%i <= $numtok($2,44)) {
    var %tmp $gettok($2,%i,44)
    if ($left(%tmp,1) == $chr(43)) {
      var %ssl-ports $addtok(%ssl-ports,%tmp,44)
    }
    else {
      var %ports $addtok(%ports,%tmp,44)
    }
    inc %i
  }
  hadd $1 ports %ports
  hadd $1 ssl-ports $replace(%ssl-ports,$chr(43),)
  return 1
}

/*
* Verbindet einen ssl und non-ssl Port String mirc tauglich
*
* @param $1 serverData objekt
* @param $2 ports
* @param $3 ssl-ports
* @return port String
*/
alias -l serverData.combinePorts {
  var %ports $2
  if ($3 != $null) {
    var %i 1
    var %ssl-ports $null
    while (%i <= $numtok($3,44)) {
      var %tmp $gettok($3,%i,44)
      if ($chr(45) isin %tmp) {
        var %port $chr(43) $+ $gettok(%tmp,1,45) $+ $chr(45) $+ $chr(43) $+ $gettok(%tmp,2,45)
      }
      else {
        var %port $chr(43) $+ %tmp
      }
      if (%i > 1) {
        var %ssl-ports %ssl-ports $+ $chr(44)
      }
      var %ssl-ports %ssl-ports $+ %port
      inc %i
    }
    var %ports %ports $+ $chr(44) $+ %ssl-ports
  }
  return %ports
}

/*
* Löscht den aktuellen Server
*
* @param $1 serverData objekt
* @return 1 oder 0
*/
alias -l serverData.delServer {
  if ($hget($1,address) != $null && $hget($1,exists) == 1) {
    .server -r $hget($1,address)
    hadd $1 exists 0
    return 1
  }
  else {
    return 0
  }
}

/*
* Setzt die Server-Gruppe/Netzwerk
*
* @param $1 serverData objekt
* @param $2 gruppe
* @return 1
*/
alias -l serverData.setGroup {
  if ($2 == $null) {
    .noop $dcError($hget($1,error.obj),ServerGruppe darf nicht leer sein).add
  }
  elseif ($2 == none) {
    .noop $dcError($hget($1,error.obj),ServerGruppe darf nicht $qt(none) lauten).add
  }
  elseif ($regex(regex,$2,[[:space:]])) {
    .noop $dcError($hget($1,error.obj),Server Gruppe enthält unzulässige Leerzeichen).add
  }
  hadd $1 group.save $2
  return 1
}

/*
* Setzt das Passwort
*
* @param $1 serverData objekt
* @param $2 passwort
* @return 1
*/
alias -l serverData.setPass {
  if ($2 == none) {
    .noop $dcError($hget($1,error.obj),Passwort darf nicht $qt(none) lauten).add
  }
  elseif ($regex(regex,$2,^[[:space:]]|[[:space:]]$) == 1) {
    .noop $dcError($hget($1,error.obj),Passwort ungültig).add
  }
  hadd $1 pass.save $2
  return 1
}

/*
* Setzt die Ports
*
* @param $1 serverData objekt
* @param $2 ports
* @return 1
*/
alias -l serverData.setPorts {
  if ($2 != $null && $regex(regex,$2,(^[1-9][0-9]{3,4})((,|-)?([1-9][0-9]{3,4}))*$) == 0) {
    .noop $dcError($hget($1,error.obj),Port Angabe ungültig).add
  }
  hadd $1 ports.save $2
  return 1
}

/*
* Setzt die SSL-Ports
*
* @param $1 serverData objekt
* @param $2 ssl-ports
* @return 1
*/
alias -l serverData.setSSL-Ports {
  if ($2 != $null && $regex(regex,$2,(^[1-9][0-9]{3,4})((,|-)?([1-9][0-9]{3,4}))*$) == 0) {
    .noop $dcError($hget($1,error.obj),SSL-Port Angabe ungültig).add
  }
  hadd $1 ssl-ports.save $2
  return 1
}

/*
* Setzt die Server-Addresse
*
* @param $1 serverData objekt
* @param $2 addresse
* @return 1
*/
alias -l serverData.setAddress {
  if ($2 == $null) {
    .noop $dcError($hget($1,error.obj),Server Addresse darf nicht leer sein).add
  }
  elseif ($regex(regex,$2,^localhost$|^([a-z]+\.)*[a-z0-9]([a-z]|[0-9]|[-_\.~])*\.[a-z][a-z]+|(\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3})) == 0) {
    .noop $dcError($hget($1,error.obj),Server Addresse ungültig).add
  }
  else {
    var %server $serverData($2)
    if (($serverData(%server,exists).get == 1 && ($hget($1,mode) == new) || ($hget($1,mode) == edit && $2 != $hget($1,address)))) {
      .noop $dcError($hget($1,error.obj),Server Addresse darf nur einmal existieren).add
    }
    .noop $serverData(%server).destroy
  }
  hadd $1 address.save $2
  return 1
}

/*
* Setzt die Server Beschreibung
*
* @param $1 serverData objekt
* @param $2 Beschreibung
* @return 1
*/
alias -l serverData.setDesc {
  if ($hget($1,group.save) == $null) {
    .noop $dcError($hget($1,error.obj),ServerGruppe/Netzwerk muss vorher gesetzt werden).add
  }
  elseif ($2 == $null) {
    .noop $dcError($hget($1,error.obj),Server Beschreibung darf nicht leer sein).add
  }
  elseif ($regex(regex,$2,^[[:space:]]|[[:space:]]$) == 1) { 
    .noop $dcError($hget($1,error.obj),Server Beschreibung enthält unzulässige Leerzeichen).add
  }
  elseif ($2 == none) {
    .noop $dcError($hget($1,error.obj),Server Beschreibung darf nicht $qt(none) lauten).add
  }
  hadd $1 desc.save $2
  return 1
}

/*
* Speichert einen Server
*
* @param $1 serverData objekt
* @return 1 oder 0
*/
alias -l serverData.saveServer {
    if ($hget($1,address) != $hget($1,address.save) && $hget($1,desc) != $hget($1,desc.save) && $hget($1,mode) == edit) {
      .noop $dcError($hget($1,error.obj),Es darf nur die Server-Addresse oder die Beschreibung geändert werden nicht beides).add
    }
    var %list $serverList($hget($1,group.save))
    .noop $serverList(%list).prepareWhile
    while ($serverList(%list).next) {
      var %data $serverData($serverList(%list).getValue)
      if ($hget($1,desc.save) == $serverData(%data,desc).get) {
        if ($hget($1,mode) == new || ($hget($1,mode) == edit && $severList(%list).getValue != $hget($1,address.save))) { 
          .noop $dcError($hget($1,error.obj),Server Beschreibung muss einzigartig sein).add
        }        
      }
      .noop $serverData(%data).destroy
    }
    .noop $serverList(%list).destroy
    if ($hget($1,ports.save) == $null && $hget($1,ssl-ports.save) == $null) {
      .noop $dcError($hget($1,error.obj),Es muss zumindest ein normaler oder ein SSL-Port angegeben sein).add
    }
    if ($dcError($hget($1,error.obj)).count > 0) {
      return 0
    }
    else {
      var %ports $serverData($1,$hget($1,ports.save),$hget($1,ssl-ports.save)).combinePorts

      if ($hget($1,pass.save) == $null) {
        hadd $1 pass.save none
      }
      server -a $hget($1,address.save) -p %ports -g $hget($1,group.save) -w $hget($1,pass.save) -d $hget($1,desc.save)    
    }
  
  return 1
}

/*
* Class Alias
* var %var $dcError
*/
alias dcError {
  var %this = dcError            | ; Name of Object (Alias name)
  var %base = baseClass        | ; Name of BaseClass, $null for none  

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
  return $dcError.init(%x)

  :add
  return $dcError.add($1,$2-)

  :clear
  return $dcError.clear($1)

  :count
  return $hget($1,error.count)

  :showDialog
  return $dcError.showDialog($1,$2)
}
/*
* Initialisiert ein error objekt
* @param $1 error objekt
* @return error objekt
*/
alias -l dcError.init {
  hadd $1 error.count 0
  hadd $1 error.text_multi Es sind Fehler aufgetreten. Bitte überprüfen sie ihre Eingaben: $lf
  hadd $1 error.text_single Es ist ein Fehler aufgetreten. Bitte überprüfen sie ihre Eingaben: $lf
  hadd $1 limit_vars error.text_multi,error.text_single
  return $1
}

/*
* fügt einen fehler hinzu
*
* @param $1 error objekt
* @param $2 fehler text
* @return 1 oder 0
*/
alias -l dcError.add {
  if ($2- != $null) {
    hinc $1 error.count
    hadd $1 error.n $+ $hget($1,error.count) $2-
    return 1
  }
  else {
    return 0
  }
}

/*
* Leert die Fehler liste
*
* @param $1 error objekt
* @return 1
*/
alias -l dcError.clear {
  hdel -w $1 error.n*
  hadd $1 error.count 0
  return 1
}

/*
* Zeigt einen Dialog mit allen Fehlern
*
* @param $1 error objekt
* @param $2 owner
* @return 1 oder 0
*/
alias -l dcError.showDialog {
  if ($hget($1,error.count) > 0) {
    if ($hget($1,error.count) == 1) { var %error $hget($1,error.text_single) }
    else { var %error $hget($1,error.text_multi) }
    var %i 1
    while (%i <= $hget($1,error.count)) {
      var %error %error $+ $lf $+ * $+ $chr(32) $+ $hget($1,error.n $+ %i)
      inc %i
    }
    if ($2 != $null) {
      .noop $dcx(MsgBox,ok error modal owner $2 $chr(9) Fehler $chr(9) %error)
    }
    else {
      .noop $dcx(MsgBox,ok error modal $chr(9) Fehler $chr(9) %error)
    }
    return 1
  }
  else {
    return 0
  }
}

/*
* BaseClass
* Just some default functions that can be directly called by other objects
*
* @author Valfa
* @version 1.0
*/
alias dcDialog {
  var %this = dcDialog      | ; Name of Object (Alias name)
  var %base = $null              | ; Name of BaseClass, $null for none

  /*
  * Start of data parsing
  * Do not edit
  */

  if (% [ $+ [ %this ] ] != $null ) { goto callprop } 
  if (!$prop) { goto init } 
  if (!$hget($1) && $hget($1,INIT) != $null && $prop != init) { echo -a * Error: Object not initialized %this | halt }
  ;if (if %base == $null && $hget($1,BASE) != %this) { echo -a * Error: Object is not from %this | halt }
  ;if (if %base != $null && $hget($1,INIT) != %this) { echo -a * Error: Object is not from %this | halt }
  if ($isalias($+(%this,.,$prop,.PRIVATE))) { echo -a * ERROR: Unable to access Method $qt(%prop) | halt }
  goto $prop
  halt

  :error
  echo -a $iif($error,$v1,Unknown error) in Class: %this
  .reseterror
  return 0

  :callprop
  var %prop $gettok(% [ $+ [ %this ] ],1,32)
  .tokenize 32 $gettok(% [ $+ [ %this ] ],2-,32)
  .unset % [ $+ [ %this ] ]
  goto %prop
  halt

  /*
  * Your Class methods
  * Start editing here
  */

  :init
  var %x $baseClass.init($1,$2).init
  return $dcDialog.init(%x)

  :exists
  return $hget($1,exists)

  :destroy
  return $baseClass.destroy($1)

  :panelCenter
  return $dcDialog.panelCenter($1,$2,$3)

  :createBasePanel
  return $dcDialog.createBasePanel($1,$2,$3)

  :createHeader
  return $dcDialog.createHeader($1,$2,$3,$4,$5-)

  :addControl
  return $dcDialog.addControl($1,$2,$3,$4,$5-)

  :enableControls
  return $dcDialog.multiControl($1,-e,$2-)

  :disableControls
  return $dcDialog.multiControl($1,-b,$2-)

  :checkControls
  return $dcDialog.multiControl($1,-c,$2-)

  :uncheckControls
  return $dcDialog.multiControl($1,-u,$2-)

  :clearControls
  return $dcDialog.multiControl($1,-r,$2-)
}

/*
* Initialisiert ein dcDialog objekt
* @param $1 zu initialisierendes objekt
* @return dc dialog objekt
*/
alias -l dcDialog.init {
  if (%framework.dbhash == $null) { set %framework.dbhash $dbs(framework) }
  .noop $dbs(%framework.dbhash,config_dialog).setSection
  hadd $1 basePanelID $dbs(%framework.dbhash,basePanelID).getScriptValue
  hadd $1 panelWidth $dbs(%framework.dbhash,panelWidth).getScriptValue
  hadd $1 panelHeight $dbs(%framework.dbhash,panelHeight).getScriptValue
  .noop $dbs(%framework.dbhash).setSection
  return $1
}

/*
* Zentriert ein Panel
*
* @param $1 dc dialog objekt
* @param $1 Breite
* @param $2 Höhe
* @return X Y Breite Höhe
*/
alias -l dcDialog.panelCenter {
  var %x $round($calc($hget($1,panelWidth) / 2 - $2 / 2),0)
  var %y $round($calc($hget($1,panelHeight) / 2 - $3 / 2),0)
  return %x %y $2 $3
}

/*
* erstellt das Basis Panel
*
* @param $1 dc Dialog obj
* @param $2 breite
* @param $2 höhe
* @return 1
*/
alias -l dcDialog.createBasePanel {
  xdid -c $hget($1,dialog.name) $hget($1,basePanelID) 1 panel $dcDialog.panelCenter($1,$2,$3)
  return 1
}

/*
* erstellt eine Überschrift
*
* @param $1 dc Dialog obj
* @param $2 ID
* @param $3 x y w h
* @param $4 Header Typ 1 oder 2
* @param $5- überschrift
* @ return 1
*/
alias -l dcDialog.createHeader {
  xdid -c $hget($1,dialog.name) 1 $2 text $3
  xdid -t $hget($1,dialog.name) $2 $5-
  if ($4 == 1) {
    xdid -f $hget($1,dialog.name) $2 + default 14 Arial  
  }
  elseif ($4 == 2) {
    xdid -f $hget($1,dialog.name) $2 + default 10 Verdana
  }
  else {
    xdid -f $hget($1,dialog.name) $2 +d
  }
}

/*
* fügt dem Dialog ein Element hinzu
*
* @param $1 dc dialog objekt
* @param $2 id
* @param $2 element typ
* @param $3 x y w h
* @param $4 modes
* @param $5- text
*/
alias -l dcDialog.addControl {
  xdid -c $hget($1,dialog.name) 1 $2 $3 $4
  if ($5 != $null) {
    xdid -t $hget($1,dialog.name) $2 $5-
  }
}

/*
* Kann einfache Befehle gleichzeitig an mehreren Control-Elemente ausführen
*
* @param $1 dc Dialog objekt
* @param $2 dcx Befehls kürzel (bsp -e -b)
* @param $3- Controls (Bsp: 1-4 6)
* @return 1
*/
alias -l dcDialog.multiControl {
  var %i 1
  while (%i <= $numtok($3-,32)) {
    var %tmp $gettok($3-,%i,32)
    if ($numtok(%tmp,45) == 2) {
      var %j $gettok(%tmp,1,45)
      while (%j <= $gettok(%tmp,2,45)) {
        xdid $2 $hget($1,dialog.name) %j
        inc %j
      }
    }
    elseif ($numtok(%tmp,45) == 1) {
      xdid $2 $hget($1,dialog.name) %tmp
    }     
    inc %i 
  }
  return 1
}