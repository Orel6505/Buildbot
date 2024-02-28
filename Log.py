import datetime, time, traceback
from shutil import move

class Log:
    def __init__(self, filename: str, newFileLog: bool=True) -> None:
        self.filename = filename
        Name = f'{filename}.log'
        if newFileLog:
            try:
                newName = f'{filename}.{int(time.time())}.log'
                move(Name,newName)
                mStatus = f'old log file moved from {Name} to {newName}'
            except FileNotFoundError:
                mStatus = "Old log file doesn\'t exist, creating it"
        self.log = open(Name, "a")
        if not newFileLog:
            Log.__write(self,"\n---------beginning of log")
        else:
            Log.__write(self,"---------beginning of log")
        self.writeInfo("Log initialized successfully")
        self.writeInfo(f'{mStatus}')

    def __write(self, Message: str) -> None:
        try:
            self.log.write(f'{Message}\n')
        except Exception:
            raise OSError(f'Can\'t write to {self.filename}')
    
    def __writeLogEntry(self, LogEntry: str, Message: str) -> None:
        Log.__write(self,f'{LogEntry}: {datetime.datetime.now().replace(microsecond=0)}: {Message}')
        
    def writeInfo(self, Message: str) -> None:
        Log.__writeLogEntry(self,"I", Message)
    
    def writeWarning(self, Message: str) -> None:
        Log.__writeLogEntry(self,"W", Message)
        
    def writeError(self, Message: str) -> None:
        Log.__writeLogEntry(self,"E", Message)

    def writeFatal(self) -> None:
        Log.__write(self,"---------Fatal Error---------")
        Log.__writeLogEntry(self,"F", f'{traceback.format_exc().strip()}')
        Log.__writeLogEntry(self,"F", "Please upload this log in Issues https://github.com/Orel6505/Buildbot/issues under Buildbot_Crashes")
        Log.__write(self,"---------Fatal Error---------")

    def isActive(self):
        return False if self.log.closed else True
        
    def closeLog(self) -> None:
        self.log.close()