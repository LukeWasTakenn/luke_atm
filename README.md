# luke_atm
FiveM ATM functionality for ESX framework

## About
The script will go through the ATM models that are listed in the config file and see if there is one near you, if there is it will open the UI if there isn't nothing will happen.

All the transactions (withdraws, deposits, transfers) you make are going to be saved in the database and you can see them inside of the 'transactions' page on the ATM.

Commands:
```
/atm - Open the ATM UI when near any ATM
/atmclose - If you ever get stuck in the UI you can type in atmclose in the console (F8) and it should close it
```

As of 1.1.0 you can toggle E in the config, which enables or disables the ability to access ATMs using E.

Tested on ESX version V1 Final - I'm not sure if it's going to work on older versions, most likely not. You would have to change the way the identifiers and money functions are in the server script, shouldn't be too difficult but I will offer no support in it.

~~Optionals~~

~~The resource also uses [pogressBar](https://forum.cfx.re/t/release-pogress-bar-progress-bar-standalone-smooth-animation/838951) made by Poggu but this is optional and can be toggled in the config.lua file. For the best experience I do however recommend using it, or if you have different progressbars replace the exports in the client.lua file.~~

### Requirements (As of 1.1.0)
<a href="https://github.com/ONyambura/mythic_progbar">mythic_progbar</a>

### Download
[Updated (1.1.0) Preview](https://streamable.com/38dgs8)

~~[Old Preview](https://youtu.be/1eo_7qJKqHQ)~~

### How to Install (Updated for 1.1.0)
1. Download the resource, remove -master from the folder name, place it inside of your resources folder.
2. Download mythic_progbar, do the same as above.
3. Import the .sql file into your database.
4. Start the resource in your server.cfg, don't forget to start mythic_progbar as well.

Feel free to edit and change the script to your liking, it's 100% open-source, however you <b>MAY NOT</b> claim it as your own.

If you're upgrading from 1.0.0 make sure you read the changelog under releases to see everything that's been changed.

If you enjoy my work and want to support me, you can purchase one of my resources at my <a href="https://aurorashop.tebex.io">Tebex</a> store.
