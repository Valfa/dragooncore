                                                                      16 Feb 2003
=================================================================================
            BlowFish + Base64 Encryption/Decryption DLL for mIRC
=================================================================================

- DO NOT ASK ME FOR SUPPORT THERE ARE PLENTY FORUMS WHERE YOU CAN ASK QUESTIONS
- DO NOT ASK ME WHERE YOU CAN DOWNLOAD THESE FILES
- NO I'M NOT GOING TO MODIFY THIS FILE FOR YOU 

=================================================================================

This DLL is written in Delphi and it can encrypt and decrypt strings, it first 
applies a BlowFish encryption and then a Base64 encryption. 

I added the Base64 because ini files seemed to have some troubles with the #13
character showing up in some blowfish encryptions.

If you insist on compiling this dll yourself you'll have to get DCPcrypt v1.3 for 
delphi. This package is available at: http://www.scramdisk.clara.net/



=================================================================================
               Some Aliases to demonstrate the use of this dll
=================================================================================

/bfinfo echo -a $dll(BFmIRC.dll,DLLInfo,_);

     Command: /bfinfo

     Echos a credit line



/bfencrypt echo -a Encrypted: $dll(BFmIRC.dll,Encrypt,$1 $2-);

     Command: /bfencrypt <key> <string>
     Example: /bfencrypt mysecretkey Caution: Top secret message!

     Echos <string> encrypted with <key>



/bfdecrypt echo -a Decrypted: $dll(BFmIRC.dll,Decrypt,$1 $2-);

     Command: /bfdecrypt <key> <string>

     Example: /bfdecrypt mysecretkey 5K4Ir43vJHsbEGQxES+1dL4UBAQCfbLKuLZoLL==

     Echos <string> deencrypted with <key>


=================================================================================
Thats all....

Greets, Frozen
irc.renegadeirc.net


