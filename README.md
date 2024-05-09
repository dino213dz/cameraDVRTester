This little script exploit the CVE-2018-9995 of DVR Cameras.

Syntaxe:
vulnTester.sh $target_url

Example:
vulnTester.sh https://127.0.0.1

Les cameras concernées sont :
 - Novo
 - CeNova
 - QSee
 - Pulnix
 - XVR 5 in 1
 - Securus
 - Night OWL
 - DVR
 - HVR
 - MDVR

Pages de connexion:
La plupart de ces caméras ont une page de login suivante: "/login.rsp"
Le titre de la page est souvent "DVR login" ou eventuellement le no mde marque suivi du terme "Login" comme ceci :
 - Novo
 - CeNova
 - QSee
 - Pulnix
 - XVR 5 in 1 (titre: "XVR Login")
 - Securus
 - Night OWL
 - DVR Login
 - HVR Login
 - MDVR Login
