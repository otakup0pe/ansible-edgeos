SHELL_BITS=files/vyos-misc.sh files/vyos-dns.sh files/vyos-dhcp.sh
IS_WSL := $(shell uname -v | grep -i microsoft 1>/dev/null 2>/dev/null ; echo $$?)
SC_IGNORE=SC1008,SC2121

test:
	for bit in $(SHELL_BITS) ; do \
		(test -z $(TRAVIS) && test $(IS_WSL) = 1) && \
		    docker run -v "$(shell pwd):/mnt" koalaman/shellcheck -e $(SC_IGNORE) $$bit || \
			shellcheck -e $(SC_IGNORE) $$bit ; \
	done
	yamllint tasks/*.yml defaults/*.yml meta/*.yml
