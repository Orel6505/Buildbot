import json, os
import Log

#
# Copyright (C) 2024 Orel6505
#
# SPDX-License-Identifier: GNU General Public License v3.0
#

def LoadConfig(config_location: str, log: Log.Log) -> dict:
    config = ParseConfig(config_location, log)
    if CheckConfig(config, log):
        return config
    return None

def IsLocation(location) -> bool:
    if not os.path.exists(location): return False
    if not os.path.isdir(location): return False
    return True

def ParseConfig(config_location: str, log: Log.Log) -> dict:
    log.writeInfo(f'Parsing config values (config location = {config_location})')
    with open(config_location, 'r') as config_path:
        return json.load(config_path)

def CheckConfig(config: dict, log: Log.Log) -> bool:
    Knox: int = 0
    Knox_Info: list = []
    log.writeInfo(f'Checking config values')
    if ValNullInDict(config, "ROM Name"):
        Knox_Info+=["ROM Name"]
        Knox+=1
    if ValNullInDict(config, "Android Version"): 
        Knox_Info+=["Android Version"]
        Knox+=1
        
    Sync_dict=config.get("Sync")
    if ValNullInDict(Sync_dict,"Repo URL"):
        Knox_Info+=["Repo URL"]
        Knox+=1
    if ValNullInDict(Sync_dict,"Repo Branch"):
        Knox_Info+=["Repo Branch"]
        Knox+=1
    
    Build_dict=config.get("Build")
    if not len(Build_dict.get("Device Codenames")): 
        Knox_Info+=["Device Codenames"]
        Knox+=1
    if ValNullInDict(Build_dict,"Lunch Name"):
        Knox_Info+=["Lunch Name"]
        Knox+=1
    if ValNullInDict(Build_dict,"Bacon Name"):
        Knox_Info+=["Bacon Name"]
        Knox+=1
    if Knox > 0:
        log.writeError(f'Config is invalid, config missing {Knox} Values including: {Knox_Info}')
        return False
    log.writeInfo(f'Config checks was completed, Config doesn\'t miss any value')
    return True

def ValNullInDict(data: dict, value: str) -> bool:
    return False if data.get(value) else True
