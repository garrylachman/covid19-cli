 ```
 _________             .__    ._______ ________          _________ .____    .___ 
\_   ___ \  _______  _|__| __| _/_   /   __   \         \_   ___ \|    |   |   |
/    \  \/ /  _ \  \/ /  |/ __ | |   \____    /  ______ /    \  \/|    |   |   |
\     \___(  <_> )   /|  / /_/ | |   |  /    /  /_____/ \     \___|    |___|   |
 \______  /\____/ \_/ |__\____ | |___| /____/            \______  /_______ \___|
        \/                    \/                                \/        \/        
        
 Corona Virus (Covid-19) statistics cli.

 MIT License
 Copyright (c) 2020 Garry Lachman
 https://github.com/garrylachman/covid19-cli

 Options:
  -c, --country     Specific Country (actual data + historical)
  -l, --list-all    List all countries
  -s, --sort        Sort countries list by key (country|cases|active|critical|deaths|recovered|todayCases|todayDeaths|casesPerOneMillion)
  -i, --historical  List all countries historical trend chart 
  -h, --help        Display this help and exit
  -n, --no-banner   Hides "Covid19-CLI" banner
      --version     Output version information and exit
```

## Usage
Please download the "compiled" version from [Releases tab](https://github.com/garrylachman/covid19-cli/releases)

```
bash covid19-cli.sh -h
```

Or if you prefer to make it executable:

```
chmod +x covid19-cli.sh
./covid19-cli.sh -h
```

# Build
1. `git clone https://github.com/garrylachman/covid19-cli.git`
2. `cd cd covid19-cli`
3. `make`

The compiled file is located at dist directory


## Screenshots
![Screenshot 1](https://i.imgur.com/RuECDg9.gif)
![Screenshot 2](https://i.imgur.com/osrONDc.gif)

## Dependencies
* bash (https://www.gnu.org/software/bash/)
* jq (https://stedolan.github.io/jq/)
* cURL (https://github.com/curl/curl)

# Credits
* Spark (https://github.com/holman/spark)
* NovelCOVID-API (https://github.com/novelcovid/api)

## Ego Boosters
![GitHub](https://img.shields.io/github/license/garrylachman/covid19-cli?style=flat-square)
![GitHub All Releases](https://img.shields.io/github/downloads/garrylachman/covid19-cli/total?style=flat-square)
![GitHub tag (latest by date)](https://img.shields.io/github/v/tag/garrylachman/covid19-cli?style=flat-square)
![GitHub Release Date](https://img.shields.io/github/release-date/garrylachman/covid19-cli?style=flat-square)
![GitHub contributors](https://img.shields.io/github/contributors/garrylachman/covid19-cli?style=flat-square)
![Analytics](https://gabeacon.irvinlim.com/UA-161573879-1/github/readme?flat&useReferer)
