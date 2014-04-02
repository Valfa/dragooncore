alias dc.frameworkFavs.createPanel {
  set %config.dialog dcConf 
  dc.frameworkFavs.createPanelContent
}
alias dc.frameworkFavs.destroyPanel { return 1 }
alias dc.frameworkFavs.events { }

alias dc.frameworkFavs.createPanelContent {
  xdid -c %config.dialog 1009 1 panel 200 100 435 540

  xdid -c %config.dialog 1 100 text 0 0 225 25
  xdid -t %config.dialog 100 DragoonCore Favouriten
  xdid -f %config.dialog 100 +u default 12 Verdana
  ;xdid -x %config.dialog 100 +b
  
  xdid -c %config.dialog 1 101 text 5 25 165 20
  xdid -t %config.dialog 101 Favouriten Einstellungen
  xdid -f %config.dialog 101 +u default 10 Verdana
  ;xdid -x %config.dialog 101 +b
  
  xdid -c %config.dialog 1 2 check 10 50 150 20
  xdid -t %config.dialog 2 Favouriten aktivieren
  
    
      
        
          
            
              
                
/*                  
  xdid -c %config.dialog 1 101 text 5 35 125 20
  xdid -t %config.dialog 101 Server Favouriten
  xdid -f %config.dialog 101 +u default 10 Verdana
  ;xdid -x %config.dialog 101 +b
  
  xdid -c %config.dialog 1 2 comboex 5 65 125 300 dropdown
  
  xdid -c %config.dialog 1 3 button 135 65 75 20
  xdid -t %config.dialog 3 Hinzufügen
  
  xdid -c %config.dialog 1 4 list 5 90 125 200
*/
}