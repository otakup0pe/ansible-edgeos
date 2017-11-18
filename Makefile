SHELL_BITS=files/vyos-misc.sh files/vyos-dns.sh files/vyos-dhcp.sh

test:
	for bit in $(SHELL_BITS) ; do \
	    docker run -v "$(shell pwd):/mnt" koalaman/shellcheck -e SC1008 $$bit ; \
	done
	yamllint tasks/*.yml defaults/*.yml meta/*.yml
