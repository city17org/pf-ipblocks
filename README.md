PF-IPBLOCKS(8) - System Manager's Manual

# NAME

**pf-ipblocks** - add a country's IP address blocks to a pf table

# SYNOPSIS

**pf-ipblocks**
\[**-x**]
cctld

# DESCRIPTION

**pf-ipblocks**
is a utility that downloads the IP address blocks in CIDR format for the
country code top-level domain passed as
*cctld*.

When run without any options the output is saved to the following location
if either the file does not already exist or has changed,
*/etc/pf-xx.zone*.
A
pf(4)
table called
*xx.zone*
is then either created or updated.
In both instances,
*xx*
is the
*cctld*
passed.

Alternatively, the IP address block data can be printed to stdout.

The options are as follows:

**-x**

> Print the IP address block data to stdout and exit.

# EXIT STATUS

The **pf-ipblocks** utility exits&#160;0 on success, and&#160;&gt;0 if an error occurs.

# EXAMPLES

The following
crontab(5)
entry runs
**pf-ipblocks**
every week to add all the IP addresses of Australia to a
pf(4)
table.

	0 22 * * 6 /usr/local/bin/pf-ipblocks au

The following lines can be added to
pf.conf(5)
to create a table definition for the Australian IP's and define a filter rule
to block all traffic coming from addresses listed in the table.

	table <au.zone> persist file "/etc/pf-au.zone"
	block drop quick on egress from <au.zone> to any

# SEE ALSO

pf(4),
crontab(5),
pf.conf(5),
cron(8),
pfctl(8),

[https://www.ipdeny.com/ipblocks](https://www.ipdeny.com/ipblocks)

# AUTHORS

Sean Davies &lt;[sean@city17.org](mailto:sean@city17.org)&gt;
