sudo apt update
sudo apt install -y git make clang libtool-bin

git clone https://github.com/vim/vim.git --single-branch --depth 1
cd vim/src
./configure --with-features=huge --enable-python3interp
make
sudo make install

# Copy vim executable, settings and colorscheme
sudo cp ./vim/src/vim /usr/bin/vim
cp -r ../home/.vim* $HOME

# Install vim plug and ripgrep
curl -fLo ~/.vim/autoload/plug.vim --create-dirs \
    https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
sudo apt install ripgrep


