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
  if fileExists("/etc/portage/make.conf"):
    var lineCnt = 0
    for kind, dir in walkDir("/var/db/pkg"):
      for kind, pkg in walkDir(dir):
        inc lineCnt
    return ansiForegroundColorCode(fgBlue) & $lineCnt & ansiResetCode
  else:
    return "fix this bum"

proc getKernel(): string =
  var hostInfo: Utsname
  let buf = uname(hostInfo)
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
    let buf = uname(hostInfo)
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
⠀⠀⠀⢰⠊⠀⠀⡀⠀⠀⠀⠀⠀⠀⠌⢠⠁⠀⡼⠀⠀⠀⠀⠀
⠀⠀⢠⠋⠀⢰⡖⠁⠀⠠⠀⠀⠀⡌⢠⠃⠀⡜⠀⠀⠀⠀⠀⠀
⠀⢀⠻⡍⠀⠀⠀⠀⡀⠁⠀⢀⠌⠠⠃⠀⡜⠀⠀⠀⠀⠀⠀⠀
⠀⡎⢰⠁⠀⠀⠀⡀⠀⠀⠠⠃⢔⠁⢀⠎⠁⠀⠀⠀⠀⠀⠀⠀
⢰⢀⠃⠀⠢⠠⠐⠀⠀⡠⠀⠈⠁⡠⠊⠀⠀⠀⠀⠀⠀⠀⠀⠀
⠈⣼⠀⠀⠀⠀⠀⠀⠜⡀⠀⢠⠜⠁⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀
⠀⠘⠣⣤⠀⣀⢔⠡⣊⠠⠚⠁⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀
⠀⠀⠀⠀⠉⠉⠉⠉⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀
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
⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⡀⠮⡌⠂⢎⢼⣿⣭⣫⣿⡿⣿⣿⣿⣿⣇⡿⣌⠳⣄⡈⢇⠈⣁⠂⠀⡀⠀⠀⠀⠀⠀⠀
⠀⠀⠀⠀⠀⠀⣀⣤⣦⡞⡀⠀⡀⠄⡐⠤⣁⢔⣠⣹⣦⣿⣿⣿⣿⣿⣛⣿⣿⣿⣿⣿⣷⣯⢷⠾⣟⡷⣜⡔⡜⡠⡐⡁⠀⠀⠀⠀⠀
⠀⠀⠀⡠⠒⠛⠛⠻⣏⡴⠛⠛⠓⢾⢷⠓⠒⠚⠛⢿⣿⣿⡟⠛⠛⠛⠻⣿⣿⠛⠛⠛⣿⡟⠛⠛⢶⠛⠛⠚⣷⠓⠓⣾⠓⢲⠀⠀⠀
⠀⠀⠀⡇⠀⢸⠀⢀⣿⠁⠀⣿⠀⠈⣿⠀⠀⡇⠀⢸⣿⣿⡇⠀⢰⡆⠀⢿⡇⠀⡀⠀⣧⡇⠀⠀⢸⠀⠀⠀⣿⠀⠀⢹⠀⢸⠀⠀⠀
⠀⠀⠀⡇⠀⢸⠉⠉⣿⠀⠀⣿⠀⠀⣿⠀⠀⡏⠀⢸⣂⠙⡇⠀⢸⡅⠀⣻⠇⠀⣇⠀⢸⡇⠀⢄⠀⠀⠆⠀⣿⠀⢀⠀⠀⢸⠀⠀⠀
⠀⠀⠀⡇⠀⢸⠀⠀⡿⡄⠀⠿⠀⢠⣿⠀⠀⠏⠀⢸⣦⣥⡇⠀⠸⠁⠀⣿⠀⠀⣀⠀⠸⡇⠀⣸⠀⢸⡁⠀⣿⠀⢸⡆⠀⢸⠀⠀⠀
⠀⠀⠀⠙⠦⠤⠶⠤⠇⠑⠦⠤⣴⣾⣿⣤⣤⣤⣴⣮⠋⠉⠧⠤⠤⠤⠖⠻⠤⠤⠻⠤⠤⠧⠤⣼⣤⣼⣥⣤⣿⠤⠼⠳⠤⠼⠀⠀⠀
⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠘⠛⢿⢿⡿⠛⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠻⠿⣿⠟⠁⠀⠀⠀⠀⠀⠀⠀⠀
""")
    echo fumo_ascii
  of "-b", "--big":
    
    let beeg_ascii = fmt("""
        a8888b.
       d888888b.
       8P"YP"Y88     Distro: {getDistro()}
       8|o||o|88     Kernel: {getKernel()}
       8'    .88     Desktop: {getDesktop()}
       8`._.' Y8.    Packages: {getPackages()}
      d/      `8b.   Arch: {getArch()}
     dP   .    Y8b.  CPU: {getCPU()}
    d8:'  "  `::88b  GPU: {getGPU()}
   d8"         'Y88b
  :8P    '      :888
   8a.   :     _a88P
._/"Yaa_:   .| 88P|
\    YP"    `| 8P  `.
/     \.___.d|    .'
`--..__)8888P`._.'       
""")
    echo beeg_ascii
else:
  echo ascii

