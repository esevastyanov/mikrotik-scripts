# Eugene Sevastyanov Home Scripting

/interface lte set lte1 apn-profiles=beeline
/interface lte set lte1 network-mode=3g
/system routerboard sim set sim-slot=up
# Restarting, just in case
/system routerboard usb power-reset duration=5s