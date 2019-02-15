
from gameLauncher import GameLauncher

gm =GameLauncher()
gm.importFromXML('./config.xml')
gm.prettyPrint()
gm.step()
gm.step()
gm.prettyPrint()
