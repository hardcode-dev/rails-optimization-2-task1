- Установка cargo

    curl -sSf https://static.rust-lang.org/rustup.sh | sh

    curl https://sh.rustup.rs -sSf | sh

    
- Установка rbspy

    cd ~

    git clone https://github.com/rbspy/rbspy

    cd ~/rbspy

    ~/.cargo/bin/cargo install --path .


-  Запуск задания и профилировщика по pid из htop

    ruby task-1.rb data_large.txt

    sudo /home/filonov/.cargo/bin/rbspy record --pid 16344 --rate 50 --format summary_by_line

    