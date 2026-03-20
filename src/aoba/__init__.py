import os
import subprocess
from typing import Annotated

from fastapi import FastAPI, Form
from fastapi.responses import PlainTextResponse
from pydantic import BaseModel

gallery_dl_path = os.environ.get("GALLERY_DL_PATH", ".")
youtube_dl_path = os.environ.get("YOUTUBE_DL_PATH", ".")

app = FastAPI()


class DownloadJob(BaseModel):
    url: str


@app.post("/gallery-dl/", response_class=PlainTextResponse)
def gallery_dl(job: Annotated[DownloadJob, Form()]):
    process = subprocess.run(
        ("gallery-dl", "--dest", gallery_dl_path, job.url), capture_output=True
    )
    return process.stdout


@app.post("/yt-dlp/", response_class=PlainTextResponse)
def youtube_dl(job: Annotated[DownloadJob, Form()]):
    process = subprocess.run(
        ("yt-dlp", job.url), capture_output=True, cwd=youtube_dl_path
    )
    return process.stdout
