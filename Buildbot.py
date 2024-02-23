import argparse, os, Config

def Arguments() -> dict:
    parser = argparse.ArgumentParser(description="Android Building Script - Script that can assist building for one or multiple devices",formatter_class=argparse.ArgumentDefaultsHelpFormatter)
    parser.add_argument("-l", "--location", type=str, nargs='?', default=os.getcwd(), help="Custom build location, default is current directory")
    parser.add_argument("-c", "--config", type=str, nargs='?', default="config.json", help="Custom config file")
    args = vars(parser.parse_args())
    return args

def main():
    Arg = Arguments()
    config_location = f'{Arg.get("location")}/{Arg.get("config")}'
    config = Config.ParseConfig(config_location)
    print(Config.CheckConfig(config))

#Define as script
if __name__ == "__main__":
    main()