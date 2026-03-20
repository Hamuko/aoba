import os
import subprocess
from typing import Annotated

from fastapi import FastAPI, Form, Request
from fastapi.responses import PlainTextResponse
from pydantic import BaseModel

gallery_dl_path = os.environ.get("GALLERY_DL_PATH", ".")
youtube_dl_path = os.environ.get("YOUTUBE_DL_PATH", ".")

app = FastAPI()


class ProcessException(Exception):
    def __init__(self, stderr: bytes):
        self.stderr = stderr


@app.exception_handler(ProcessException)
async def process_exception_handler(request: Request, exc: ProcessException):
    return PlainTextResponse(exc.stderr, status_code=400)


class DownloadJob(BaseModel):
    url: str


@app.post("/gallery-dl/", response_class=PlainTextResponse)
def gallery_dl(job: Annotated[DownloadJob, Form()]):
    process = subprocess.run(
        ("gallery-dl", "--dest", gallery_dl_path, job.url), capture_output=True
    )
    if process.returncode != 0:
        raise ProcessException(process.stderr)
    return process.stdout


@app.post("/yt-dlp/", response_class=PlainTextResponse)
def youtube_dl(job: Annotated[DownloadJob, Form()]):
    process = subprocess.run(
        ("yt-dlp", job.url), capture_output=True, cwd=youtube_dl_path
    )
    if process.returncode != 0:
        raise ProcessException(process.stderr)
    return process.stdout
