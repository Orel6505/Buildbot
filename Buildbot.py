import argparse, os, traceback
import Config, Sync, Log

#
# Copyright (C) 2024 Orel6505
#
# SPDX-License-Identifier: GNU General Public License v3.0
#

def Arguments() -> dict:
    parser = argparse.ArgumentParser(description="Android Building Script - Script that can assist building for one or multiple devices",formatter_class=argparse.ArgumentDefaultsHelpFormatter)
    parser.add_argument("-l", "--location", type=str, nargs='?', default=os.getcwd(), help="Custom build location, default is current directory")
    parser.add_argument("-c", "--config", type=str, nargs='?', default="config.json", help="Custom config file")
    args = vars(parser.parse_args())
    return args

def main():
    try:
        # Load Log
        log = Log.Log("Buildbot")
        
        #load arguments
        Arg = Arguments()
        location = Arg["location"]
        log.writeInfo(f'Location variable {location} was loaded')
        config_filename = Arg["config"]
        log.writeInfo(f'Location variable {config_filename} was loaded')
        
        #Load Config file
        log.writeInfo(f'Checking Location variable {location}')
        if not Config.IsLocation(location):
            log.writeError(f'Location variable {location} ins\'t full path location')
            return False
        config_location = f'{location}/{config_filename}'
        config = Config.LoadConfig(config_location, log)
        
        #Start Syncing
        ROM_location = f'{location}/rom/{config["ROM Name"]}-{config["Android Version"]}'
        Sync.Sync_ROM(config["Sync"], ROM_location, log)
    except Exception as e:
        if log.isActive:
            log.writeFatal()
        else:
            print(e)
            print("Please upload this log in Issues https://github.com/Orel6505/Buildbot/issues under Buildbot_Crashes")
        log.closeLog()
        return 1

#Define as script
if __name__ == "__main__":
    main()