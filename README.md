# mikrotik-scripts
Various Mikrotik Scripts

### Fix cell tower (and cell id !)
```/interface lte at-chat lte1 input="AT*Cell=2,3,7,3048,398"```

### No restrictions on cell, band and tech
```/interface lte at-chat lte1 input="AT*Cell=0,,,,"```

### Sim slot 1
```/system routerboard sim set sim-slot=down```

### Sim slot 2
```/system routerboard sim set sim-slot=up```

### Set apn profile
```/interface lte set lte1 apn-profiles=yota```

### Set network mode
```/interface lte set lte1 network-mode=lte```

### Run beeline
```/system script run setBeeline```

### Run beeline
```/system script run setYota```

### Restart the lte interface
```/system routerboard usb power-reset duration=10```