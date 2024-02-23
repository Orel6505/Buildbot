import json

def ParseConfig(config: str) -> dict:
    with open(config, 'r') as config_path:
        return json.load(config_path)

def CheckConfig(config: dict) -> bool:
    Knox: int = 0
    Knox_Info: list = []
    if ValNullInDict(config, "ROM Name"):
        Knox_Info+=["ROM Name"]
        Knox+=1
    if ValNullInDict(config, "Android Version"): 
        Knox_Info+=["Android Version"]
        Knox+=1
        
    Sync_dict=config.get("Sync", {})
    if ValNullInDict(Sync_dict,"Repo URL"):
        Knox_Info+=["Repo URL"]
        Knox+=1
    if ValNullInDict(Sync_dict,"Repo Branch"):
        Knox_Info+=["Repo Branch"]
        Knox+=1
    
    Build_dict=config.get("Build", {})
    if ValNullInDict(Build_dict,"Device Codenames"): 
        Knox_Info+=["Device Codenames"]
        Knox+=1
    if ValNullInDict(Build_dict,"Lunch Name"):
        Knox_Info+=["Lunch Name"]
        Knox+=1
    if ValNullInDict(Build_dict,"Bacon Name"):
        Knox_Info+=["Bacon Name"]
        Knox+=1
    if Knox > 0:
        print(f'Config is invalid, config missing {Knox} Values including: {Knox_Info}')
        return False
    return True

def ValNullInDict(data: dict, value: str) -> bool:
    return False if data.get(value) else True
