/* Verschlüsselt einen Wert 
*
* @param $1- unverschlüsselter Wert
* @return verschlüsselter Wert
*/
alias dcEncryptValue {
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
alias dcDecryptValue {
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

alias dcCheck {
  var %regex $dcDbs(%dc.fw.dbhash,regex,$prop).getScriptValue
  if ($1 == $null || %regex == 0) { return 0 }
  goto $prop
  :error
  echo -s $error
  .reseterror
  return 0

  :space
  return [ $iif($regex(regex,$1-,%regex),0,1) ]

  :addSpace
  return [ $iif($regex(regex,$1-,%regex),0,1) ]

  :address
  return [ $iif($regex(regex,$1-,%regex),1,0) ]

  :email
  return [ $iif($regex(regex,$1-,%regex),1,0) ]

  :port
  return [ $iif($regex(regex,$1-,%regex),1,0) ]
}

menu channel,status {
  config:/config
}

alias server {
  hadd -m alias_server param $1-
  if ($1 == -s || $1 == -a || $1 == -r) {
    .server $1-
  }
  else {
    var %list $dcDbs(%dc.fw.dbhash,onRemote,alias_server).getValue
    var %i 1
    while (%i <= $numtok(%list,44)) {
      $gettok(%list,%i,44)
      inc %i
    }
    server $hget(alias_server,param)
  }
}

on *:start:{
  set %dc.fw.dbhash $dcDbs(framework)
  set %dc.fkey.obj $dcFkey
  set %oop 0
  var %list $dcDbs(%dc.fw.dbhash,onRemote,onStart).getValue
  var %i 1
  while (%i <= $numtok(%list,44)) {
    $gettok(%list,%i,44)
    inc %i
  }
}

on *:exit:{
  .noop $dcDbs(%dc.fw.dbhash).destroy
  unset %dc.fw.dbhash
  unset %fkey.obj
  unset %oop
}

on *:connect:{
  var %list $dcDbs(%dc.fw.dbhash,onRemote,onConnect).getValue
  var %i 1
  while (%i <= $numtok(%list,44)) {
    $gettok(%list,%i,44) $network
    inc %i
  }
}

on *:Input:?#: {
  var %list $dcDbs(%dc.fw.dbhash,onRemote,onInput).getValue
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

on *:Nick: {
  if ($nick == $me) {
    var %list $dcDbs(%dc.fw.dbhash,onRemote,onNick).getValue
    if (%list) {
      hmake nick_ $+ $network 100
      hadd nick_ $+ $network nick $nick
      hadd nick_ $+ $network newnick $newnick
      hadd nick_ $+ $network network $network
      var %i 1
      while (%i <= $numtok(%list,44)) {
        $gettok(%list,%i,44) nick_ $+ $network
        inc %i
      }
      hfree nick_ $+ $network
    }
  }
}