>Please be aware that for tournament servers where the plugin requires unloading on match start this is only currently possible if the SOAP-TF2DM's loader (SOAP Tournament) is installed on the server as the ProperPregame loader is still work-in-progress. See the installation instructions for details.

# Proper Pregame
TF2 SourceMod plugin to remove damage from certain weapons within pregame.

Removes damage from:
  - Sentry guns
  - Stickybombs
  
Self-damage is still applied and individual weapons can be enabled or disabled through console variables.

---

Installation instructions:

Plugin installation:
* Paste the contents of the "addons" folder into the "tf2/tf/addons" folder found in the tf2 server installation.

Setting the plugin to load/unload when match starts/stops (**Requires SOAP Tournament**):
* Paste the contents of the "cfg" folder into the "tf2/tf/cfg" folder found in the tf2 server installation.
**OR** to do it manually:
* Add "sm plugins unload properpregame" to the "soap_live.cfg" config file and "sm plugins load properpregame" to the "soap_notlive.cfg" config file.

---

Configuration:

Proper Pregame can be configured using the following cvars to enable/disable damage from the effected weapons.

* pp_disablestickies
* pp_disablesentries

---

Portions of code are based on SOAPTF2_DM (Author: Lange, https://github.com/Lange/SOAP-TF2DM) and SupStats2 (Author: F2, http://sourcemod.krus.dk/f2-sourcemod-plugins-src.zip)

