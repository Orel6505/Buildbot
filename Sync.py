import os, time, subprocess, asyncio
import Log

#
# Copyright (C) 2024 Orel6505
#
# SPDX-License-Identifier: GNU General Public License v3.0
#

async def Sync_ROM(sync_config: dict, Source_location: str, log: Log.Log) -> bool:
    try:
        log.writeInfo("Starting with Syncing the ROM")
        if not os.path.exists(Source_location):
            log.writeInfo("Source Location doesn't exist, creating it")
            os.makedirs(Source_location)
        Repo_Init_Task = asyncio.create_task(Repo_Init(sync_config["Repo URL"], sync_config["Repo Branch"], Source_location))
        if sync_config.get("Manifest URL"):
            log.writeInfo(f'cloning manifest to: {Source_location}/.repo/local_manifests')
            Manifest_Clone_Task = asyncio.create_task(Clone_Manifest(sync_config.get("Manifest URL"), f'{Source_location}/.repo/local_manifests', Source_location))
            await Manifest_Clone_Task
        await Repo_Init_Task
        Repo_Sync_Progress_Task = asyncio.create_task(Repo_Sync_Progress(subprocess.run(['repo', 'sync', '--force-sync'], cwd=Source_location, stdout=subprocess.PIPE, stderr=subprocess.PIPE)))
        await Repo_Sync_Progress_Task
        return True
    except Exception:
        log.writeFatal()
        return False
        
async def Repo_Init(Repo_URL: str, Repo_Branch:str, Source_location: str) -> bool:
    try:
        start_time = time.time()
        subprocess.run(['repo', 'init','-u', Repo_URL,'-b', Repo_Branch, '--git-lfs', '--depth=1'], cwd=Source_location, check=True)
        end_time = time.time()
        return True
    except Exception:
        return False

#TODO - merge Manifest_Clone and Clone_Manifest
#Also transfer the log instance.
async def Manifest_Clone(Repo_URL: str, Manifest_Branch: str, Manifest_Location: str, Source_location: str) -> bool:
    try:
        start_time = time.time()
        subprocess.run(['git', 'clone', Repo_URL,'-b', Manifest_Branch, Manifest_Location, '--depth=1'], cwd=Source_location, check=True)
        end_time = time.time()
        return True
    except Exception:
        return False

async def Clone_Manifest(Repo_URL: str, Manifest_Location: str, Source_location: str) -> bool:
    try:
        start_time = time.time()
        subprocess.run(['git', 'clone', Repo_URL, '--depth=1', Manifest_Location], cwd=Source_location, check=True)
        end_time = time.time()
        return True
    except Exception:
        return False

#TODO - fix this method
async def Repo_Sync_Progress(sync: subprocess.Popen) -> None:
    while sync.returncode is None:
        output = await sync.stdout.readline()
        print(output)
        await asyncio.sleep(60)
    sync.stdout.close()
    await sync.wait()