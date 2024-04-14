$USERPATH = ";C:\Apps\npm;C:\Users\login\AppData\Roaming\npm;F:\Develop\flutter\bin;F:\Develop\android\platform-tools;F:\Develop\VSCode\bin;C:\Tools\bin;C:\Apps\nodejs;C:\Apps\JDK\bin;C:\Apps\Python\Scripts;C:\Apps\Python;C:\Apps\Git\bin"
[Environment]::SetEnvironmentvariable("Path", $USERPATH, "User")
($env:PATH).split(";")