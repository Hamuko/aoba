#[macro_use]
extern crate rocket;

use rocket::form::Form;
use rocket::State;
use serde::{Deserialize, Serialize};
use std::env;
use std::process::Command;
use std::str;

#[derive(Debug, Deserialize, Serialize)]
struct AppConfig {
    gallery_dl_path: String,
    youtube_dl_path: String,
}

#[derive(Debug, FromForm)]
struct DownloadJob<'r> {
    url: &'r str,
}

#[post("/gallery-dl", data = "<job>")]
fn gallery_dl(job: Form<DownloadJob<'_>>, config: &State<AppConfig>) -> String {
    let output = Command::new("gallery-dl")
        .arg("--dest")
        .arg(&config.gallery_dl_path)
        .arg(&job.url)
        .output();
    let output = match output {
        Ok(output) => output,
        Err(_) => return "Could not execute gallery-dl!".to_string(),
    };
    let stdout = String::from_utf8(output.stdout).unwrap();
    stdout
}

#[post("/youtube-dl", data = "<job>")]
fn youtube_dl(job: Form<DownloadJob<'_>>, config: &State<AppConfig>) -> String {
    let output = Command::new("youtube-dl")
        .current_dir(&config.youtube_dl_path)
        .arg(&job.url)
        .output();
    let output = match output {
        Ok(output) => output,
        Err(_) => return "Could not execute youtube-dl!".to_string(),
    };
    let stdout = String::from_utf8(output.stdout).unwrap();
    stdout
}

#[launch]
fn rocket() -> _ {
    let config = AppConfig {
        gallery_dl_path: env::var("GALLERY_DL_PATH").unwrap_or(".".to_string()),
        youtube_dl_path: env::var("YOUTUBE_DL_PATH").unwrap_or(".".to_string()),
    };
    let rocket = rocket::build()
        .mount("/", routes![gallery_dl, youtube_dl])
        .manage(config);

    rocket
}
