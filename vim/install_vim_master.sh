sudo apt update
sudo apt install -y git make clang libtool-bin

git clone https://github.com/vim/vim.git --single-branch --depth 1
cd vim/src
make

make test
sudo make install

# Add X windows clipboard support (also needed for GUI):
sudo apt install -y libxt-dev
make reconfig

# Add GUI support:
sudo apt install -y libgtk-3-dev
make reconfig

# Copy vim executable, settings and colorscheme
sudo cp ./vim/src/vim /usr/bin/vim
cp -r ../home/.vim* $HOME
