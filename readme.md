# Official [TrueNAS](https://www.truenas.com) Chia Docker Container


## Important Links

* [ixsystems/chia-docker - Docker Hub](https://hub.docker.com/repository/docker/ixsystems/chia-docker)


Current Versions:

* Chia: [1.5.1](https://github.com/Chia-Network/chia-blockchain/)
* Plotman: [v0.5.1](https://github.com/ericaltendorf/plotman/)
* Farmr: [1.7.7.4](https://github.com/joaquimguimaraes/farmr/)
* MadMax: [master / 2ffe7a6e84370d1a54e558deb392bdca9dfd89cb](https://github.com/Chia-Network/chia-plotter-madmax/)
* BladeBit: [v1.2.4](https://github.com/Chia-Network/bladebit/)
* PlotNG: [v0.62](https://github.com/maded2/plotng)
* ChiaDog: [v0.7.0](https://github.com/martomi/chiadog/)

## Basic Startup
```
docker run --name <container-name> -d ixsystems/chia-docker:latest
(optional -v /path/to/data:/data)
(optional -v /path/to/plots:/plots)
```

## Chia Binary
```
# chia
```

## Plotman
```
# plotman
```

## MadMax Plotter
```
# chia_plot
```

## BladeBit Plotter
```
# bladebit
```

## PlotNG
```
# plotng-server
# plotng-client
```

#### set the timezone for the container (optional, defaults to UTC)
Timezones can be configured using the `TZ` env variable. A list of supported time zones can be found [here](http://manpages.ubuntu.com/manpages/focal/man3/DateTime::TimeZone::Catalog.3pm.html)
```
-e TZ="America/Chicago"
```
## Configuration

You can modify the behavior of your Chia container by setting specific environment variables.

To ensure that your chia config settings and sycned blockchain persist, you can pass in a directory for /data
```
-v /path/to/data:/data
```

To use your own keys, place your secret mnemonic into a file and pass as arguments on startup.
```
-v /path/to/key/file:/path/in/container -e keys="/path/in/container"
```
or pass keys into the running container
```
docker exec -it <container-name> venv/bin/chia keys add
```

To start a farmer only node pass
```
-e farmer="true"
```

To start a harvester only node pass
```
-e harvester="true" -e farmer_address="addres.of.farmer" -e farmer_port="portnumber" -v /path/to/ssl/ca:/path/in/container -e ca="/path/in/container"
```

To start the farmr.net bot in farmer mode (Logs stored in /farmr/log.txt)
```
-e farmr="farmer"
```

To start the farmr.net bot in harvester mode (Logs stored in /farmr/log.txt)
```
-e farmr="harvester"
```

To start the Chiadog agent (Config file in /data/chiadog/config.yaml)
```
-e chiadog="true"
```

To start the plotman tool in daemon mode (Logs stored in /data/plotman/daemon.log)
```
-e plotman="true"
```
NOTE: You should make sure plotman is configured properly first


The `plots_dir` environment variable can be used to specify the directory containing the plots, it supports PATH-style colon-separated directories.

#### or run commands externally with venv (this works for most chia XYZ commands)
```
docker exec -it chia venv/bin/chia plots add -d /plots
```

#### status from outside the container
```
docker exec -it chia venv/bin/chia show -s -c
```

#### Connect to testnet?
```
docker run -d --expose=58444 --expose=8555 -e testnet=true --name <container-name> ixsystems/chia-docker:latest
```

#### Need a wallet?
```
docker exec -it chia-farmer1 venv/bin/chia wallet show (follow the prompts)
```
