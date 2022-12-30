///////////////////////////////////////////////////////////////////////////////
// NAME:            main.rs
//
// AUTHOR:          Ethan D. Twardy <ethan.twardy@gmail.com>
//
// DESCRIPTION:     Entrypoint for the make-nginx-conf application.
//
// CREATED:         12/26/2022
//
// LAST EDITED:	    12/30/2022
//
//////

use clap::Parser;
use serde::Deserialize;
use std::collections::HashMap;
use std::fmt;
use std::fs::File;
use std::io::{stdout, Write};

///////////////////////////////////////////////////////////////////////////////
// Configuration Files
////

const SUPPORTED_VERSION: &'static str = "1.0";

#[derive(Deserialize)]
#[serde(rename_all = "lowercase")]
enum ServerBlock {
    Header(String),
    Location(String),
}

#[derive(Deserialize)]
#[serde(rename_all = "lowercase")]
enum ConfigBlock {
    Top(String),
    Server {
        name: String,
        configuration: Vec<ServerBlock>,
    },
}

#[derive(Deserialize)]
struct ConfigFile {
    pub version: String,
    pub configuration: Vec<ConfigBlock>,
}

///////////////////////////////////////////////////////////////////////////////
// Writable Configuration
////

#[derive(Clone, Debug, Default)]
struct VirtualServer {
    preamble: String,
    locations: Vec<String>,
}

#[derive(Clone, Debug, Default)]
struct Service {
    header: String,
    servers: HashMap<String, VirtualServer>,
}

impl FromIterator<ConfigFile> for Service {
    fn from_iter<T>(collection: T) -> Self
    where
        T: IntoIterator<Item = ConfigFile>,
    {
        let mut service = Service::default();
        let blocks = collection
            .into_iter()
            .map(|file| {
                if SUPPORTED_VERSION != file.version {
                    panic!("Unsupported configuration version");
                }
                file.configuration
            })
            .flatten()
            .collect::<Vec<ConfigBlock>>();

        for block in blocks {
            match block {
                ConfigBlock::Top(content) => service.header += &content,
                ConfigBlock::Server {
                    name,
                    configuration,
                } => {
                    if !service.servers.contains_key(&name) {
                        service
                            .servers
                            .insert(name.clone(), VirtualServer::default());
                    }

                    for block in configuration {
                        match block {
                            ServerBlock::Header(content) => {
                                (*service.servers.get_mut(&name).unwrap())
                                    .preamble += &content
                            }
                            ServerBlock::Location(content) => {
                                (*service.servers.get_mut(&name).unwrap())
                                    .locations
                                    .push(content)
                            }
                        }
                    }
                }
            }
        }

        service
    }
}

impl fmt::Display for Service {
    fn fmt(&self, f: &mut fmt::Formatter<'_>) -> fmt::Result {
        todo!()
    }
}

///////////////////////////////////////////////////////////////////////////////
// Main
////

#[derive(Parser, Debug)]
#[clap(author, version, about, long_about = None)]
struct Args {
    /// File to parse
    #[clap(value_parser)]
    file: Vec<String>,

    /// Output file
    #[clap(short, long, value_parser)]
    output: Option<String>,
}

fn main() -> Result<(), anyhow::Error> {
    let args = Args::parse();

    // Read all of the service files (from command line arguments) and
    // aggregate their contents into a single service.
    let service = args
        .file
        .iter()
        .map(|file| {
            serde_yaml::from_reader::<File, ConfigFile>(
                File::open(file)
                    .expect(&format!("Couldn't open file {}", file)),
            )
            .expect(&format!("Couldn't parse file {}", file))
        })
        .collect::<Service>();

    // Then, write its definition to the output file.
    if let Some(file) = args.output {
        let mut output = File::create(file)?;
        write!(output, "{}", &service)?;
    } else {
        let mut stdout = stdout().lock();
        write!(stdout, "{}", &service)?;
    }
    Ok(())
}

///////////////////////////////////////////////////////////////////////////////
