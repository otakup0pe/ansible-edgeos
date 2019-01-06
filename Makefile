SHELL_BITS=files/vyos-misc.sh files/vyos-dns.sh files/vyos-dhcp.sh
SC_IGNORE=SC1008,SC2121

test:
	for bit in $(SHELL_BITS) ; do \
		test -z $(TRAVIS) && \
		    docker run -v "$(shell pwd):/mnt" koalaman/shellcheck -e $(SC_IGNORE) $$bit || \
			shellcheck -e $(SC_IGNORE) $$bit ; \
	done
	yamllint tasks/*.yml defaults/*.yml meta/*.yml
