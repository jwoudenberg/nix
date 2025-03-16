#!/usr/bin/env nu

def main [] {
  date now | format date "%Y-%m-%d %H:%M" | print
  if ("/sys/class/power_supply/BAT1" | path exists) {
    print $"Battery: (cat /sys/class/power_supply/BAT1/capacity)%"
  }
  cat ~/hjgames/agenda/*agenda.txt | agenda-txt *1d | print
}
