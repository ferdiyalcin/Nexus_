#!/bin/bash

#Color definitions
GREEN='\033[0;32m'
NC='\033[0m' #No Color

#Function definition
cecho() {
    local message="$1"
    echo -e "${GREEN}${message}${NC}"
}
cecho "=> Komut dosyası çalıştırılıyor..."

sleep 5

cecho "=> Paket listesi güncelleniyor ve CMake yükleniyor..."
sudo apt update
sudo apt install -y cmake

sleep 5

cecho "=> Build-essential yükleniyor..."
sudo apt install -y build-essential

sleep 5

cecho "=> Rust yükleniyor..."
curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y
source "$HOME/.cargo/env"

sleep 5

cecho "=> Rust için RISC-V hedefi ekleniyor..."
rustup target add riscv32i-unknown-none-elf

sleep 5

cecho "=> Nexus zkVM yükleniyor..."
cargo install --git https://github.com/nexus-xyz/nexus-zkvm cargo-nexus --tag 'v0.2.0'

sleep 5

cecho "=> Yeni bir Nexus projesi oluşturuluyor..."
cargo nexus new nexus-project

sleep 5

cecho "=> main.rs dosyası düzenleniyor..."
cd nexus-project/src

cat > main.rs <<EOL
#![cfg_attr(target_arch = "riscv32", no_std, no_main)]

fn fib(n: u32) -> u32 {
    match n {
        0 => 0,
        1 => 1,
        _ => fib(n - 1) + fib(n - 2),
    }
}

#[nexus_rt::main]
fn main() {
    let n = 7;
    let result = fib(n);
    assert_eq!(result, 13);
}
EOL

sleep 5

cecho "=> Program çalıştırılıyor..."
cd ..
cargo nexus run

sleep 5

cecho "=> Ayrıntılı çıktılar ile çalıştırılıyor..."
cargo nexus run -v

sleep 5

cecho "=> Kanıt oluşturuluyor..."
cargo nexus prove

sleep 5

cecho "=> Kanıt doğrulanıyor..."
cargo nexus verify

sleep 5

cecho "=> Kanıt doğrulandı. Kanıtınızı indirip, kaydetmeyi unutmayın."
cecho "=> by Maximillion"
