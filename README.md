# 0x0.sh
A portable CLI interface to https://0x0.sh.

The main documentation is the man page which you can view at [0x0(1)](https://github.com/olav35/0x0.sh/raw/master/doc/0x0.1.pdf) or with `man 0x0`.

---

**Installation**
```sh
# OpenBSD
git clone https://github.com/olav35/0x0.sh /tmp/0x0.sh &&
cd /tmp/0x0.sh &&
doas bin/install.sh &&
cd -
```
```sh
# Darwin and Linux
git clone https://github.com/olav35/0x0.sh /tmp/0x0.sh &&
cd /tmp/0x0.sh &&
sudo bin/install.sh &&
cd -
```

**Uninstallation**
```sh
# OpenBSD
cd /tmp/0x0.sh &&
doas bin/uninstall.sh &&
cd -
```
```sh
# Darwin and Linux
cd /tmp/0x0.sh &&
sudo bin/uninstall.sh &&
cd -
```
