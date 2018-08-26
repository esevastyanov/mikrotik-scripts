# Eugene Sevastyanov Home Scripting

/interface lte set lte1 apn-profiles=yota
/interface lte set lte1 network-mode=lte
/system routerboard sim set sim-slot=down
# Restarting, just in case
/system routerboard usb power-reset duration=5s
# /delay 90s
# /interface lte at-chat lte1 input="AT*Cell=2,3,,3048,398"