![Maintenance](https://img.shields.io/maintenance/yes/2019.svg)

Terrible EdgeOS Opinions
------------------------

Consider this to be beta at best, caveat emptor and all that.

![an-image](https://github.com/otakup0pe/ansible-edgeos/blob/master/docs/maybe.gif)

I've been super into the whole [Ubiquiti](https://www.ubnt.com/) ecosystem since I discovered them a bunch of years ago. I'm still super into them, even if their stuff shows up _allll_ the time on [shodan](https://www.shodan.io/). This role does a bunch of stuff on an EdgeOS/[VyOS](https://vyos.io) machine.

* install ssl cert
* setup [pimd](https://github.com/troglobit/pimd) for multicast forwarding
* install some helper scripts

# vyos-misc

This is just used to restart lighthttp when I swap out the TLS bits.

```
# vyos-misc web restart
```

# vyos-dns

Used to manage static DNS mappings.

```
# vyos-dns list
foo.example.com - 10.0.0.1
bar.example.com - 10.0.0.2
# vyos-dns update foo.example.com 10.0.0.3
Updating foo.example.com 10.0.0.1 to 10.0.0.3
...
# vyos-dns delete bar.example.com
Deleting bar.example.com (10.0.0.2)
...
```

# vyos-dhcp

Used to manage static DHCP entries.

```
# vyos-dhcp list Intranet
00:11:22:aa:bb:cc 10.0.0.1 - foo
00:11:22:aa:bb:cd 10.0.0.2 - bar
# vyos-dhcp update Intranet foo 10.0.0.3 00:11:22:aa:bb:cc
Updating foo - 00:11:22:aa:bb:cc 10.0.0.3 (from 00:11:22:aa:bb:cc 10.0.0.1)
...
# vyos-dhcp delete Intranet bar
Deleting bar - 00:11:22:aa:bb:cd 10.0.0.2
```

# errata

The whole `vbash` thing is kind of interesting. The biggest thing I've noticed thus far is config functions do not seem to be accessible from within other functions. This is why everything is so duplciated in the vbash scripts. Even when sourcing and re-initializing inside the function, the various commands are not found. I'm assuming this is because I don't understand something about how bash functions work.

# License

[MIT](https://github.com/otakup0pe/ansible-edgeos/blob/master/LICENSE)

# Author

This Ansible role was created by [Jonathan Freedman](http://jonathanfreedman.bio/) because he is trying to break the EdgeOS gooey habit.
