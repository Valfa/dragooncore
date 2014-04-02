alias BaseTestClass {
  var %this = BaseTestClass      | ; Name of Object (Alias name)
  var %base = $null              | ; Name of BaseClass, $null for none
  
  /*
  * Start of data parsing
  * Do not edit
  */
  
  if (% [ $+ [ %this ] ] != $null ) { goto callprop } 
  if (!$prop) { goto init } 
  if (!$hget($1) && $prop != init) { echo -a * Error: Object not initialized | halt }
  if (if %base == $null && $hget($1,BASE) != %this) { echo -a * Error: Object is not from %this | halt }
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
  return 1  
      
  :try
  return $1-
}

alias TestClass {
  var %this = TestClass            | ; Name of Object (Alias name)
  var %base = BaseTestClass        | ; Name of BaseClass, $null for none  

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
  inc %oop
  var %hash $md5($ctime $+ $ticks $+ %oop)
  hmake %hash 100
  hadd %hash INIT %this
  hadd %hash BASE %base
  return %hash
}

alias classtry {
  var %x $TestClass
  set %try $TestClass(%x,blubba,blubb,blu,123).try
  echo -s %try
}