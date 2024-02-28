import datetime, time, traceback
from shutil import move

class Log:
    def __init__(self, filename: str, newFileLog: bool=True) -> None:
        self.filename = filename
        if newFileLog:
            try:
                move(f'{filename}.log',f'{filename}.{int(time.time())}.log')
            except FileNotFoundError:
                print("File Not Exists")
        self.log = open(f'{filename}.log', "a")
        if not newFileLog:
            Log.__write(self,"\n---------beginning of log")
        else:
            Log.__write(self,"---------beginning of log")

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
        Log.__write(self,"---------Fatal Error---------")

    def isActive(self):
        return False if self.log.closed else True
        
    def closeLog(self) -> None:
        self.log.close()