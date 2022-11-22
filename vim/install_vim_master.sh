sudo apt update
sudo apt install git
sudo apt install make
sudo apt install clang
sudo apt install libtool-bin

git clone https://github.com/vim/vim.git --single-branch --depth 1
cd vim/src
make

make test

sudo make install

# Add X windows clipboard support (also needed for GUI):
sudo apt install libxt-dev
make reconfig

# Add GUI support:
sudo apt install libgtk-3-dev
make reconfig

# Copy vim executable, settings and colorscheme
sudo cp vim/src/vim /usr/bin/vim
cp ../home/.vim* $HOME
