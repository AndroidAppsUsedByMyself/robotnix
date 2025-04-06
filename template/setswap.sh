echo '$ sudo swapoff /dev/zram0'
sudo swapoff /dev/zram0
echo '$ sudo zramctl --size 32GB --algorithm zstd /dev/zram0'
sudo zramctl --size 32GB --algorithm zstd /dev/zram0
echo '$ sudo mkswap /dev/zram0'
sudo mkswap /dev/zram0
echo '$ sudo swapon -p 1 /dev/zram0'
sudo swapon -p 1 /dev/zram0
