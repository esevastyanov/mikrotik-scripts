# Eugene Sevastyanov Home Scripting
# LTE Cell Locker
# Script waits for LTE connection initialised and running, checks cell ids and lock it

:global timeoutLTE 60
:global timeoutConnect 60

# Wait for LTE interface to initialize for maximum "timeoutLTE" seconds
# :log info message="(lte-cell-lock) Waiting if LTE is initialized"
:local i 0
:local isLTEinit false
:while ($i<$timeoutLTE) do={
    :foreach n in=[/interface lte find] do={:set $isLTEinit true}
    :if ($isLTEinit=true) do={
        :set $i $timeoutLTE
    }
    :set $i ($i+1)
    :delay 1s
}

# Check if LTE interface is initialized, or try power-reset the modem
# :log info message="(lte-cell-lock) Waiting if LTE is running"
:if ($isLTEinit=true) do={
    # Wait for LTE interface to connect to mobile network for maximum "timeoutConnet" seconds
    :local isConnected false
    :set $i 0
    :while ($i<$timeoutConnect) do={
        :if ([/interface lte get [find name="lte1"] running]=true) do={
            :set $isConnected true
            :set $i $timeoutConnect
        }
        :set $i ($i+1)
        :delay 1s
    }

    # Check if LTE is connected
    # :log info message="(lte-cell-lock) Checking if LTE is connected"
    if ($isConnected=true) do={
        # :log info message="(lte-cell-lock) Hooray! LTE is running"

        # Check if access tech is actually LTE
        :local isLTE [/interface lte info lte1 as-value]
        :set isLTE ($isLTE->"access-technology")
        if ($isLTE="Evolved 3G (LTE)") do={
            # :log info message="(lte-cell-lock) Hooray! It's LTE"
            :local cellId ([/interface lte info lte1 as-value] -> "current-cellid")
            :local isCellLocked true
            :local iCellCheck 50
            :while (($iCellCheck>0)&&$isCellLocked) do={
                :local currentCellId ([/interface lte info lte1 as-value] -> "current-cellid")
                :set $isCellLocked ($cellId=$currentCellId)
                :set $iCellCheck ($iCellCheck-1)
                :delay 100ms
            }
            
            # Check if it is cell locked
            if ($isCellLocked) do={
                :log info message="(lte-cell-lock) Hooray! Cell is locked"
            } else={
                # :log info message="(lte-cell-lock) Cell isn't locked"
                :local lteInfo [/interface lte info lte1 as-value]
                :local phyCellId ($lteInfo -> "phy-cellid")
                :local earfcnRaw ($lteInfo -> "earfcn")
                :local earfcn [:pick $earfcnRaw 0 [:find $earfcnRaw " "]]
                
                if (([:len $phyCellId]>0)&&([:len $earfcn]>0)) do={
                    :log info message="(lte-cell-lock) Locking cell id: AT*Cell=2,3,,$earfcn,$phyCellId"
                    /interface lte at-chat lte1 input="AT*Cell=2,3,,$earfcn,$phyCellId"
                } else={
                    :log warning message="(lte-cell-lock) Either phy-cellid or earfcn are empty "
                }
            }
        } else={
            :log info message="(lte-cell-lock) Cell Lock isn't required as access-technology is not LTE"
        }
    } else={
        :log info message="(lte-cell-lock) LTE interface did not connect to network, cell unlocking: AT*Cell=0"
        /interface lte at-chat lte1 input="AT*Cell=0"
    }
} else={
    :log info message="(lte-cell-lock) LTE modem did not appear"
    # /system routerboard usb power-reset duration=5s
}
