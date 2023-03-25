import strformat
import os
import strutils
import terminal
import posix
import times
import osproc

proc getDistro(): string =
  var info = io.readLines("/etc/os-release", 3)
  for line in info:
    if "ID=" in line:
      return ansiForegroundColorCode(fgCyan) & capitalizeAscii(line.replace("ID=", "")) & ansiResetCode

proc getPackages(): string =
  if fileExists("/etc/pacman.conf"):
    return ansiForegroundColorCode(fgBlue) & execProcess("pacman -Q | wc -l").strip & ansiResetCode
  else:
    return "fix this bum"

proc getKernel(): string =
  var hostInfo: Utsname
  discard uname(hostInfo)
  let kernel = $(cast[cstring](addr hostInfo.release[0]))
  return ansiForegroundColorCode(fgYellow) & kernel & ansiResetCode


proc getDesktop(): string =
  if getEnv("XDG_CURRENT_DESKTOP") == "":
    return ansiForegroundColorCode(fgRed) & capitalizeAscii(getEnv("DESKTOP_SESSION")) & ansiResetCode 
  elif getEnv("XDG_CURRENT_DESKTOP") != "":
    return ansiForegroundColorCode(fgRed) & getEnv("XDG_CURRENT_DESKTOP") & ansiResetCode
  elif getEnv("XDG_CURRENT_DESKTOP") == "" and getEnv("DESKTOP_SESSION") == "":
    return ansiForegroundColorCode(fgRed) & "ion know" & ansiResetCode

proc getInstallTime(): string =
  let init = execProcess("stat / | awk '/Birth: /{print $2}'")
  var initToDate = parseTime(init.replace("\n", ""), "yyyy-MM-dd", utc())
  var timeN = parseTime(getDateStr(), "yyyy-MM-dd", utc())
  var final = initToDate - timeN
  return $final

let ascii = fmt("""
    .--.
   |o_o |    Distro: {getDistro()}
   |:_/ |    Kernel: {getKernel()}
  //   \ \   Desktop: {getDesktop()}
 (|     | )  Packages: {getPackages()}
/'\_   _/`\
\___)=(___/  You installed {getInstallTime().replace("-", "")} ago""")



#main
case paramCount()
of 1:
  proc getArch(): string =
    var hostInfo: Utsname
    discard uname(hostInfo)
    let cpu = $(cast[cstring](addr hostInfo.machine[0]))
    return ansiForegroundColorCode(fgMagenta) & cpu & ansiResetCode

  proc getCPU(): string =
    let fname = "/proc/cpuinfo"
    for line in lines fname:
      if "model name" in line:
        let split = line.split(' ')
        let realFinal = split[2] & " " & split[3] & " " & split[4]
        return ansiForegroundColorCode(fgCyan) & realFinal & ansiResetCode

  proc getGPU(): string =
    let cmd = execProcess("lspci").split("\n")
    for line in cmd:
      if "VGA compatible controller" in line:
        let gpu = line.find('[')+1..line.rFind(']')-1
        return ansiForegroundColorCode(fgGreen) & line[gpu] & ansiResetCode

  proc getInit(): string =
    if dirExists("/etc/systemd"):
      return ansiForegroundColorCode(fgYellow) & "rystemd" & ansiResetCode
    elif dirExists("/etc/runit"):
      return ansiForegroundColorCode(fgYellow) & "runit" & ansiResetCode
    elif fileExists("/etc/rc.conf"):
      return ansiForegroundColorCode(fgYellow) & "openrc" & ansiResetCode
    else:
      return "/shrug"

  proc getShell(): string =
    if "/usr" in getEnv("SHELL"):
      return ansiForegroundColorCode(fgMagenta) & getEnv("SHELL").replace("/usr/bin/","") & ansiResetCode
    else:
      return ansiForegroundColorCode(fgMagenta) & getEnv("SHELL").replace("/bin/","") & ansiResetCode

  proc getMem(): string =
    let
      memoryraw = readLine(open("/proc/meminfo", fmRead))
      memoryit = memoryraw.find(':')+1..memoryraw.rFind('k')-1
      memorykb = memoryraw[memoryit].strip()
      memorymb = parseInt(memorykb) / 1024
    return ansiForegroundColorCode(fgBlue) & $int(memorymb) & " mb" & ansiResetCode

  case paramStr(1)
  of "-p", "--pickle":
    let ani_ascii = fmt("""
⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢀⠔⠊⠁⠈⠉⠐⢦⡀⠀⠀
⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠰⠃⠀⠾⠶⠖⣢⡀⠀⢛⡄⠀
⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢠⠃⡰⢒⠒⣄⣀⣈⠚⠀⢸⠸⠀
⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⡎⠀⢧⡈⣀⡏⠠⠤⣳⠀⠸⠀⡆
⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⡘⠰⡟⢿⣵⡥⠙⣆⡴⠁⠀⠇⢀⠃
⠀⠀⠀⠀⠀⠀⠀⠀⠀⢠⠃⠘⢧⣄⡛⢻⠿⡋⣿⠀⠰⠀⢸⠀     Distro: {getDistro()}
⠀⠀⠀⠀⠀⠀⠀⠀⢀⠞⣏⠀⠀⠉⠙⠻⠿⡿⠟⠀⠃⢀⠇⠀     Kernel: {getKernel()}
⠀⠀⠀⠀⠀⠀⠀⠀⡜⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⡸⠀⣸⠀⠀     Desktop: {getDesktop()}
⠀⠀⠀⠀⠀⠀⠀⢠⠁⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠁⢀⠃⠀⠀     Packages: {getPackages()}
⠀⠀⠀⠀⠀⠀⢀⠇⠀⠀⠀⠀⠀⠀⠀⠀⠀⢀⠀⠀⡸⠀⠀⠀     Arch: {getArch()}
⠀⠀⠀⠀⠀⠀⡾⣖⠀⠀⠀⠀⠀⠀⠀⢠⠀⠴⠃⢠⠁⠀⠀⠀     CPU: {getCPU()}
⠀⠀⠀⠀⠀⡜⠀⠀⠀⠀⠀⠀⠀⠀⠀⠆⠀⠀⢀⠎⠀⠀⠀⠀     GPU: {getGPU()}
⠀⠀⠀⢰⠊⠀⠀⡀⠀⠀⠀⠀⠀⠀⠌⢠⠁⠀⡼⠀⠀⠀⠀⠀     Init: {getInit()}
⠀⠀⢠⠋⠀⢰⡖⠁⠀⠠⠀⠀⠀⡌⢠⠃⠀⡜⠀⠀⠀⠀⠀⠀     Shell: {getShell()}
⠀⢀⠻⡍⠀⠀⠀⠀⡀⠁⠀⢀⠌⠠⠃⠀⡜⠀⠀⠀⠀⠀⠀⠀     Mem: {getMem()}
⠀⡎⢰⠁⠀⠀⠀⡀⠀⠀⠠⠃⢔⠁⢀⠎⠁⠀⠀⠀⠀⠀⠀⠀
⢰⢀⠃⠀⠢⠠⠐⠀⠀⡠⠀⠈⠁⡠⠊⠀⠀⠀⠀⠀⠀⠀⠀⠀
⠈⣼⠀⠀⠀⠀⠀⠀⠜⡀⠀⢠⠜⠁⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀
⠀⠘⠣⣤⠀⣀⢔⠡⣊⠠⠚⠁⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀
⠀⠀⠀⠀⠉⠉⠉⠉⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀     You installed {getInstallTime().replace("-", "")} ago
""")
    echo ani_ascii
  of "-f", "--fumo":
    let fumo_ascii = fmt("""
⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢀⠀⠀⢀⢀⣀⣀⣠⣤⡴⠶⡩⠕⠿⣦⡀⣀⠀⢀⡀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀
⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⣠⡶⣟⣛⡚⡟⣏⠯⣍⢦⡱⣍⠶⣡⢛⡬⢍⣫⢙⠫⣍⢛⠻⡹⣒⢓⣦⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀
⠀⠀⠀⠀⠀⠀⠀⠀⠀⣠⣶⣾⢏⡵⢲⡜⡼⣱⢊⡗⡜⢦⠳⣌⠳⣥⠳⡜⡪⠴⣉⠳⡌⢎⡱⡱⢌⠶⣘⡇⠀⠀⠀⠀⠀⠀⠀⠀⡀
⠀⠀⠀⠀⠀⠀⠀⠀⣰⣿⣿⣎⡗⣮⠳⡼⣱⢣⢏⡼⣸⢣⡛⣬⢓⢦⡓⡭⣱⡙⣌⠳⣘⢣⠲⣅⡋⠖⣍⣿⠀⠀⢀⢀⢠⠲⠀⠣⠀
⠀⠀⠀⢀⣠⣴⣿⣿⣿⣿⣟⢶⡹⣖⡹⢲⣥⢋⡞⣔⢣⠣⡕⣾⡍⢦⡹⢔⢣⡟⡤⢓⠥⣣⢓⡤⣍⣹⢴⢺⠀⠆⠘⠈⠄⠁⠂⠔⠀
⠀⣠⣶⣿⣿⣿⣿⣿⣿⣿⣟⣮⢷⣎⢷⡃⣿⠛⠻⣿⢿⣻⣿⣷⣿⣶⠋⡌⣻⠛⠻⣿⡟⣿⢛⡽⣻⠍⢘⡦⢣⠀⡈⠈⡰⠁⠌⠀⠀       Distro: {getDistro()}
⠈⢹⣿⣿⣿⣿⣿⣿⣿⣿⡟⡼⢳⣚⢮⡕⣹⡷⣾⢟⡭⣗⣾⣚⢧⣿⠐⡀⢿⡦⣞⡧⣝⠶⣋⢶⣹⠂⢼⣣⢓⡰⠀⠣⠵⣉⠀⠀⠀       Kernel: {getKernel()}
⠀⠘⣿⣿⣿⣿⣿⣿⣿⣿⣿⡵⣫⢜⢮⣳⡌⢿⣎⡻⣞⡽⢶⣏⣿⠇⡐⠠⢹⡞⡼⣱⢎⢯⡕⣯⠃⢌⡾⣃⢎⠁⠀⠀⠀⠀⠀⠀⠀       Desktop: {getDesktop()}
⠀⠐⣿⣿⣿⣿⣿⣿⣿⣿⣿⣷⡝⣮⡒⣷⡝⣎⢻⣷⣿⣼⣯⣞⠋⡐⢠⢁⠂⢹⣷⣭⣾⣧⡟⣡⣴⣾⡟⡔⣾⣠⡄⠀⠀⠀⠀⠀⠀       Packages: {getPackages()}
⠀⠀⠻⠿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣯⡿⣿⣿⣿⣿⣷⣳⢯⡼⣌⢞⡵⢣⣮⣞⡰⣤⣹⣵⣶⣿⣿⣿⣿⠷⣽⣿⣽⡿⠀⠀⠀⠀⠀⠀       Arch: {getArch()}
⠀⠀⠀⠀⠈⠉⠙⠛⠛⠛⠛⠛⠉⣿⣷⣉⢿⣿⣿⣿⣿⢦⣷⣭⣮⣱⣆⣶⣌⣷⠤⣛⣿⣿⣿⣿⣿⢿⡐⣿⣿⡙⠃⠀⠀⠀⠀⠀⠀       CPU: {getCPU()}
⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠻⠟⠟⠒⢻⢏⢯⣛⣾⣽⣿⣿⣿⣿⣿⣿⣿⣼⡗⣸⢍⠻⡛⡜⢦⡑⠛⠳⡁⠀⠀⠀⠀⠀⠀⠀       GPU: {getGPU()}
⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⡀⠮⡌⠂⢎⢼⣿⣭⣫⣿⡿⣿⣿⣿⣿⣇⡿⣌⠳⣄⡈⢇⠈⣁⠂⠀⡀⠀⠀⠀⠀⠀⠀       Init: {getInit()}
⠀⠀⠀⠀⠀⠀⣀⣤⣦⡞⡀⠀⡀⠄⡐⠤⣁⢔⣠⣹⣦⣿⣿⣿⣿⣿⣛⣿⣿⣿⣿⣿⣷⣯⢷⠾⣟⡷⣜⡔⡜⡠⡐⡁⠀⠀⠀⠀⠀       Shell: {getShell()}
⠀⠀⠀⡠⠒⠛⠛⠻⣏⡴⠛⠛⠓⢾⢷⠓⠒⠚⠛⢿⣿⣿⡟⠛⠛⠛⠻⣿⣿⠛⠛⠛⣿⡟⠛⠛⢶⠛⠛⠚⣷⠓⠓⣾⠓⢲⠀⠀⠀
⠀⠀⠀⡇⠀⢸⠀⢀⣿⠁⠀⣿⠀⠈⣿⠀⠀⡇⠀⢸⣿⣿⡇⠀⢰⡆⠀⢿⡇⠀⡀⠀⣧⡇⠀⠀⢸⠀⠀⠀⣿⠀⠀⢹⠀⢸⠀⠀⠀
⠀⠀⠀⡇⠀⢸⠉⠉⣿⠀⠀⣿⠀⠀⣿⠀⠀⡏⠀⢸⣂⠙⡇⠀⢸⡅⠀⣻⠇⠀⣇⠀⢸⡇⠀⢄⠀⠀⠆⠀⣿⠀⢀⠀⠀⢸⠀⠀⠀
⠀⠀⠀⡇⠀⢸⠀⠀⡿⡄⠀⠿⠀⢠⣿⠀⠀⠏⠀⢸⣦⣥⡇⠀⠸⠁⠀⣿⠀⠀⣀⠀⠸⡇⠀⣸⠀⢸⡁⠀⣿⠀⢸⡆⠀⢸⠀⠀⠀
⠀⠀⠀⠙⠦⠤⠶⠤⠇⠑⠦⠤⣴⣾⣿⣤⣤⣤⣴⣮⠋⠉⠧⠤⠤⠤⠖⠻⠤⠤⠻⠤⠤⠧⠤⣼⣤⣼⣥⣤⣿⠤⠼⠳⠤⠼⠀⠀⠀
⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠘⠛⢿⢿⡿⠛⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠻⠿⣿⠟⠁⠀⠀⠀⠀⠀⠀⠀⠀       You installed {getInstallTime().replace("-", "")} ago
""")
    echo fumo_ascii
  of "-b", "--big":
    
    let beeg_ascii = fmt("""
        a8888b.
       d888888b.
       8P"YP"Y88      Distro: {getDistro()}
       8|o||o|88      Kernel: {getKernel()}
       8'    .88      Desktop: {getDesktop()}
       8`._.' Y8.     Packages: {getPackages()}
      d/      `8b.    Arch: {getArch()}
     dP   .    Y8b.   CPU: {getCPU()}
    d8:'  "  `::88b   GPU: {getGPU()}
   d8"         'Y88b  Init: {getInit()}
  :8P    '      :888  Shell: {getShell()}
   8a.   :     _a88P
._/"Yaa_:   .| 88P|
\    YP"    `| 8P  `.
/     \.___.d|    .'
`--..__)8888P`._.'    You installed {getInstallTime().replace("-", "")} ago
""")
    echo beeg_ascii
else:
  echo ascii

