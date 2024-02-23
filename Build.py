#Define as script
import argparse, os, json

def main():
    Arg = Arguments()
    print(Arg)


def Arguments() -> dict:
    parser = argparse.ArgumentParser(description="Android Building Script - Script that can assist building for one or multiple devices",formatter_class=argparse.ArgumentDefaultsHelpFormatter)
    parser.add_argument("-l", "--location", type=str, nargs='1', default=os.getcwd(), help="Custom build location, default is current directory")
    parser.add_argument("-c", "--config", type=str, nargs='1', default="config.json", help="Custom config file, default is config.json")
    args = vars(parser.parse_args())
    return args

def ParseConfig(config: str) -> dict:
    with open(config, 'r') as config_file:
        return json.loads(config_file)

if __name__ == "__main__":
    main()