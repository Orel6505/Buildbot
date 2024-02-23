#Define as script
import argparse, os

def main():
    Arg = Arguments()
    print(Arg)


def Arguments() -> dict:
    parser = argparse.ArgumentParser(description="Android Building Script - Script that can assist building for one or multiple devices",formatter_class=argparse.ArgumentDefaultsHelpFormatter)
    parser.add_argument("-l", "--location", type=str, nargs='1', default=os.getcwd(), help="Custom build location, default is current directory")
    parser.add_argument("-f", "--file", type=str, nargs='1', default="config.json", help="Custom config file, default is config.json")
    args = vars(parser.parse_args())
    return args

if __name__ == "__main__":
    main()