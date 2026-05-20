use sha2::{Sha256, Sha512, Digest};
use std::env;
use std::fs;
use std::io::{self, Read};
use std::process;

fn hash_input(algo: &str, data: &[u8]) -> String {
    match algo {
        "sha512" => hex::encode(Sha512::digest(data)),
        _ => hex::encode(Sha256::digest(data)),
    }
}

fn main() {
    let args: Vec<String> = env::args().collect();
    if args.len() > 1 && (args[1] == "-h" || args[1] == "--help") {
        eprintln!("Usage: hash-digest [-a sha256|sha512] [string | -f file]");
        process::exit(0);
    }

    let mut algo = "sha256".to_string();
    let mut file_path = None;
    let mut input_str = None;
    let mut i = 1;

    while i < args.len() {
        match args[i].as_str() {
            "-a" | "--algo" => {
                i += 1;
                algo = args.get(i).cloned().unwrap_or_else(|| "sha256".into());
            }
            "-f" | "--file" => {
                i += 1;
                file_path = args.get(i).cloned();
            }
            _ => input_str = Some(args[i].clone()),
        }
        i += 1;
    }

    let data: Vec<u8> = if let Some(path) = file_path {
        fs::read(&path).unwrap_or_else(|e| {
            eprintln!("Error reading file '{}': {}", path, e);
            process::exit(1);
        })
    } else if let Some(s) = input_str {
        s.into_bytes()
    } else {
        let mut buf = Vec::new();
        io::stdin().read_to_end(&mut buf).unwrap_or_else(|e| {
            eprintln!("Error reading stdin: {}", e);
            process::exit(1);
        });
        buf
    };

    println!("{}", hash_input(&algo, &data));
}
