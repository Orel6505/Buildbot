import argparse, os
import Config, Sync

def Arguments() -> dict:
    parser = argparse.ArgumentParser(description="Android Building Script - Script that can assist building for one or multiple devices",formatter_class=argparse.ArgumentDefaultsHelpFormatter)
    parser.add_argument("-l", "--location", type=str, nargs='?', default=os.getcwd(), help="Custom build location, default is current directory")
    parser.add_argument("-c", "--config", type=str, nargs='?', default="config.json", help="Custom config file")
    args = vars(parser.parse_args())
    return args

def main():
    Arg = Arguments()
    location = Arg["location"]
    if not Config.IsLocation(location):
        return False
    config_location = f'{location}/{Arg["config"]}'
    config = Config.ParseConfig(config_location)
    if not Config.CheckConfig(config):
        return False
    ROM_location = f'{location}/rom/{config.get("ROM Name")}-{config.get("Android Version")}'
    Sync.Sync_ROM(config["Sync"], ROM_location)

#Define as script
if __name__ == "__main__":
    main()