## Automate SMB Mount in Linux #8

[![Thumbnail](https://img.youtube.com/vi/hdtW19TRdIU/maxresdefault.jpg)](https://www.youtube.com/watch?v=hdtW19TRdIU)


#### File Structure
```bash
scripts/
└── cifs_utils.sh
```

#### cifs_utils.sh
```bash
# Create Credentials file if not available
cred_file=user.cred

cd /home/user
if ! [ -f $cred_file ]; then
	echo "Credentials File does not exists!"
	echo "Creating - Credentials File"
	read -s -p "Enter username: " username
	echo ""
	read -s -p "Enter Password: " password
	touch $cred_file
	echo ""
	printf "username=$username\npassword=$password" >> $cred_file
fi

# Install CIFS utilities
sudo apt install cifs-utils -y

# Create the required folders
mkdir -p files
cd files

# Create mount directories
mkdir documents
mkdir backups

# Edit fstab file to mount smb shares to folders
fstab=/etc/fstab
mount_path=/mount/to/path

# Mount shares
echo "//<SMB SERVER IP>/<share1>	$mount_path/<share1> cifs	credentials=/home/user/$cred_file,uid=$username	0	0" | sudo tee -a $fstab
echo "//<SMB SERVER IP>/<share2>	$mount_path/<share2> cifs	credentials=/home/user/$cred_file,uid=$username	0	0" | sudo tee -a $fstab

# Reload the systemctl daemon
sudo systemctl daemon-reload
sudo mount -a
```
