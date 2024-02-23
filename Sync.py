import os, time, subprocess, asyncio, git

async def Sync_ROM(sync_config: dict, Source_location: str) -> bool:
    try: 
        if not os.path.exists(Source_location):
            os.makedirs(Source_location)
        Repo_Init_Task = asyncio.create_task(Repo_Init(sync_config["Repo_URL"], sync_config["Repo_Branch"], Source_location))
        if "Manifest URL" in sync_config:
            manifest_location = f"{Source_location}/.repo/local_manifests"
            Manifest_Clone_Task = asyncio.create_task(Clone_Manifest(sync_config["Manifest URL"], sync_config.get("Manifest Branch", None), manifest_location))
            await Manifest_Clone_Task
        await Repo_Init_Task
        loop = asyncio.get_event_loop()
        sync = loop.create_subprocess_exec(*['repo', 'sync', '--force-sync', '--no-tags', '--no-clone-bundle'], cwd=Source_location, stdout=subprocess.PIPE, stderr=subprocess.PIPE)
        await Repo_Sync_Progress(sync)
        return True
    except Exception as e:
        print(e)
        return False
        
async def Repo_Init(Repo_URL: str, Repo_Branch:str, Source_location: str) -> bool:
    try:
        start_time = time.time()
        asyncio.subprocess.run(['repo', 'init','-u', Repo_URL,'-b', Repo_Branch, '--git-lfs', '--depth=1'], cwd=Source_location, check=True)
        end_time = time.time()
        return True
    except Exception:
        return False

async def Manifest_Clone(Repo_URL: str, Manifest_Branch: str, Manifest_Location: str) -> bool:
    try:
        start_time = time.time()
        subprocess.run(['git', 'clone', Repo_URL,'-b', Manifest_Branch, '--depth=1'], cwd=Manifest_Location, check=True)
        end_time = time.time()
        return True
    except Exception:
        return False

async def Clone_Manifest(Repo_URL: str, Manifest_Location: str) -> bool:
    try:
        start_time = time.time()
        subprocess.run(['git', 'clone', Repo_URL, '--depth=1'], cwd=Manifest_Location, check=True)
        end_time = time.time()
        return True
    except Exception:
        return False

async def Repo_Sync_Progress(sync: subprocess.Popen) -> None:
    while sync.returncode is None:
        output = await sync.stdout.readline()
        print(output)
        await asyncio.sleep(60)
    sync.stdout.close()
    await sync.wait()