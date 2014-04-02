/* Verschlüsselt einen Wert 
*
* @param $1- unverschlüsselter Wert
* @return verschlüsselter Wert
*/
alias encryptValue {
  if ($1- != $null) {
    if (!$exists(dcdb/user/Framework/dragooncore.key)) {
      var %key $sha1($md5($ctime))
      write dcdb/user/Framework/dragooncore.key $encode(%key,ut,0)
    }
    var %key $decode($read(dcdb/user/Framework/dragooncore.key,1),ut,0)
    return $dll(dll/BFmIRC.dll,Encrypt,%key $1-)
  }
  else {
    return $null
  }
}

/* Verschlüsselt einen Wert 
*
* @param $1- verschlüsselter Wert
* @return $null oder unverschlüsselter Wert
*/
alias decryptValue {
  if ($1- != $null) {
    if (!$exists(dcdb/user/Framework/dragooncore.key)) {
      return $null
    }
    var %key $decode($read(dcdb/user/Framework/dragooncore.key,1),ut,0)
    return $dll(dll/BFmIRC.dll,Decrypt,%key $1-)
  }
  else {
    return $null
  }
}

/*
* Kodiert FormatCodes in einem String
*
* @param $1- zu Kodierenender String
* @return Kodierter String
*/
alias formatEncode {
  return $replace($1-,,©B,,©I,,©U,,©R,,©K,,©O)
}

/*
* Dekodiert FormatCodes in einem String
*
* @param $1- zu Dekodierenender String
* @return dekodierter String
*/
alias formatDecode {
  return $replace($1-,©B,,©I,,©U,,©R,,©K,,©O,)
}

menu channel,status {
  config:/config
}

alias -l framework.initRemote {
  hmake remote 100
  var %list.outer $dbsList(%framework.dbhash,remote)
  .noop $dbsList(%list.outer).prepareWhile
  while ($dbsList(%list.outer).next) {
    hadd remote $dbsList(%list.outer).getItem $null
    var %list.inner $dbsList(%framework.dbhash,remote,$dbsList(%list.outer).getItem)
    .noop $dbsList(%list.inner).prepareWhile
    while ($dbsList(%list.inner).next) {
      hadd remote $dbsList(%list.outer).getItem $hget(remote,$dbsList(%list.outer).getItem) $+ $dbsList(%list.inner).getValue $+ $chr(44)
    }
    .noop $dbsList(%list.inner).destroy
  }
  .noop $dbsList(%list.outer).destroy
}

on *:start:{
  set %framework.dbhash $dbs(framework)
  set %fkey.obj $dcFkey
  set %oop 0
  ;framework.initRemote
  var %list $dbs(%framework.dbhash,onRemote,onStart).getUserValue
  var %i 1
  while (%i <= $numtok(%list,44)) {
    $gettok(%list,%i,44)
    inc %i
  }
}

on *:exit:{
  .noop $dbs(%framework.dbhash).destroy
  unset %framework.dbhash
  unset %fkey.obj
  unset %oop
}

on *:connect:{
  var %list $dbs(%framework.dbhash,onRemote,onConnect).getUserValue
  var %i 1
  while (%i <= $numtok(%list,44)) {
    $gettok(%list,%i,44)
    inc %i
  }
}

on *:Input:*: {
  var %list $dbs(%framework.dbhash,onRemote,onInput).getUserValue
  if (%list) {
    if ($left($1,1) == /) && ($ctrlenter == $false) { return }
    hmake input_ $+ $active 100
    hadd input_ $+ $active text $1-
    var %i 1
    while (%i <= $numtok(%list,44)) {
      $gettok(%list,%i,44) input_ $+ $active
      inc %i
    }
    .say $hget(input_ $+ $active,text)
    hfree input_ $+ $active
    haltdef
  }
}