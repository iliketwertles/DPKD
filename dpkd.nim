import strformat
import os
import osproc
import strutils
import terminal

proc getDistro(): string =
  when defined(Linux):
    if execProcess("uname -o") != "Android":
      var info = io.readLines("/etc/os-release", 3)
      if "chromiumos" in info[2]:
        ansiForegroundColorCode(fgCyan) & capitalizeAscii(info[2].replace("ID_LIKE=", "")) & ansiResetCode
      else:
        ansiForegroundColorCode(fgCyan) & capitalizeAscii(info[2].replace("ID=", "")) & ansiResetCode

    else:
      ansiForegroundColorCode(fgCyan) & "Android" & ansiResetCode
  elif defined(MacOS) or defined(MacOSX):
    ansiForegroundColorCode(fgCyan) & "MacOS" & ansiResetCode

proc getPackages(): string =
  when defined(Linux):
    if fileExists("/etc/pacman.conf"):
      return ansiForegroundColorCode(fgBlue) & execProcess("pacman -Q | wc -l").strip & ansiResetCode
    elif fileExists("/etc/apt/apt.conf"):
      return ansiForegroundColorCode(fgBlue) & execProcess("dpkg -l | wc -l").strip & ansiResetCode
    elif fileExists("/etc/dnf/dnf.conf"):
      return ansiForegroundColorCode(fgBlue) & execProcess("rpm -qa | wc -l").strip & ansiResetCode
    elif fileExists("/etc/portage/make.conf"):
      return ansiForegroundColorCode(fgBlue) & execProcess("equery list '*' | wc -l").strip & ansiResetCode
    elif fileExists("/etc/apk/arch"):
      return ansiForegroundColorCode(fgBlue) & execProcess("apk list | wc -l").strip & ansiResetCode
    elif fileExists("/usr/local/bin/crew"):
      return ansiForegroundColorCode(fgBlue) & execProcess("crew list installed | wc -l").strip & ansiResetCode
    elif execProcess("uname -r") == "Android":
      return ansiForegroundColorCode(fgBlue) & execProcess("dpkg -l | wc -l").strip & ansiResetCode
  elif defined(MacOS) or defined(MacOSX):
    ansiForegroundColorCode(fgBlue) & execProcess("brew list | wc -l") & ansiResetCode

proc getKernel(): string =
  when defined(Linux) or defined(MacOS) or defined(MacOSX): 
    let kernel = execProcess("uname -r").strip
    ansiForegroundColorCode(fgYellow) & kernel & ansiResetCode

proc getDesktop(): string =
  when defined(Linux):
    var info = io.readLines("/etc/os-release", 3)
    if "chromiumos" in info[2]:
      return ansiForegroundColorCode(fgRed) & "Chromeos... idk" & ansiResetCode
    elif getEnv("XDG_CURRENT_DESKTOP") == "":
      return ansiForegroundColorCode(fgRed) & capitalizeAscii(getEnv("DESKTOP_SESSION")) & ansiResetCode 
    elif getEnv("XDG_CURRENT_DESKTOP") != "":
      return ansiForegroundColorCode(fgRed) & getEnv("XDG_CURRENT_DESKTOP") & ansiResetCode
    elif getEnv("XDG_CURRENT_DESKTOP") == "" and getEnv("DESKTOP_SESSION") == "":
      return ansiForegroundColorCode(fgRed) & "ion know" & ansiResetCode
    elif execProcess("uname -r") == "Android":
      var launcherPackageName = execProcess("cmd package resolve-activity -c android.intent.category.HOME -a android.intent.action.MAIN | grep packageName= | grep -m1 '' | tr -d '[:space:]' | cut -c 13-")
      var dirtyApkPath = execProcess(fmt("pm list packages -f {launcherPackageName} | cut -c 9-"))
      var cleanishApkPath = dirtyApkPath.replace(launcherPackageName, "")
      return execProcess("aapt dump badging {cleanishApkPath[..^2]} | grep application-label | grep -m1 '' | cut -c 19- ")
  elif defined(Macos) or defined(MacOSX):
    return ansiForegroundColorCode(fgRed) & "Finder" & ansiResetCode

#prompt
when defined(Linux) or defined(MacOS) or defined(MacOSX):
  let p = ansiForegroundColorCode(fgGreen) & "C>_" & ansiResetCode

var ascii = fmt("""
   .----.
   |{p} |     Distro: {getDistro()}
 __|____|__   Packages: {getPackages()}
|  ______--|  Kernel: {getKernel()}
`-/.::::.\-'a Desktop: {getDesktop()}
 `--------'""")

echo ascii
