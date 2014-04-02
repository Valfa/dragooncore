;##################

alias dc.frameworkScriptUser.createPanel { 
  xdid -c dcConf 1009 1 panel 200 100 435 540

  xdid -c dcConf 1 100 text 0 0 200 25
  xdid -t dcConf 100 Benutzer Scripte
}
alias dc.frameworkScriptUser.destroyPanel { }
alias dc.frameworkScriptUser.events { }

;###############################

alias dc.frameworkTheme.createPanel { 
  xdid -c dcConf 1009 1 panel 200 100 435 540

  xdid -c dcConf 1 100 text 0 0 200 25
  xdid -t dcConf 100 Theme Manager
}
alias dc.frameworkTheme.destroyPanel { }
alias dc.frameworkTheme.events { }
