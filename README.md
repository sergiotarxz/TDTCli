# TDTCli

A cli program written in Perl to watch the TDT.

## How to install

Clone this repository and `cd` into the new directory.

Install the program using cpan:

```shell
cpan .
```

If you get prompted by questions press intro to
use the defaults and run: (Supposing your are
using bash.)

```shell
. ~/.bashrc
echo $PERL5LIB
```

If you don't get an output that looks like

```
/home/sergio/perl5/lib/perl5:/home/sergio/perl5/lib/perl5
```

Run `perl -I${HOME}/perl5/lib/ -Mlocal::lib` to
see what enviroment variables you will have to set in your .profile, .shellrc or whatever
file your shell sources.

Once you have a working local::lib you will
be able to run:

```shell
tdtcli.pl
```

It should get you into a new command line that
looks like:

```
tdtcli ~>
```

Now type `help` to get further instructions of usage.
