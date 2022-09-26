import strformat
import os
import osproc
import strutils
import terminal

proc getDistro(): string =
  when defined(Linux):
    var info = io.readLines("/etc/os-release", 3)
    ansiForegroundColorCode(fgCyan) & capitalizeAscii(info[2].replace("ID=", "")) & ansiResetCode
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
  elif defined(MacOS) or defined(MacOSX):
    ansiForegroundColorCode(fgBlue) & execProcess("brew list | wc -l") & ansiResetCode

proc getKernel(): string =
  when defined(Linux) or defined(MacOS) or defined(MacOSX): 
    let kernel = execProcess("uname -r").strip
    ansiForegroundColorCode(fgYellow) & kernel & ansiResetCode

proc getDesktop(): string =
  when defined(Linux):
    if getEnv("XDG_CURRENT_DESKTOP") == "":
      return ansiForegroundColorCode(fgRed) & capitalizeAscii(getEnv("DESKTOP_SESSION")) & ansiResetCode 
    elif getEnv("XDG_CURRENT_DESKTOP") != "":
      return ansiForegroundColorCode(fgRed) & getEnv("XDG_CURRENT_DESKTOP") & ansiResetCode
    elif getEnv("XDG_CURRENT_DESKTOP") == "" and getEnv("DESKTOP_SESSION") == "":
      return ansiForegroundColorCode(fgRed) & "None" & ansiResetCode
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
