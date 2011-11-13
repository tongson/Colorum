Colorum
=======


## DESCRIPTION

A set of tools for configuration management that aims to be simple and
lightweight. The most complicated part of configuration management is handling
dependencies. Fortunately we have Mk (from Plan9) to handle that and so it is
considered the most important component. Mk is meant to replace Make for
building software but its features make it suitable for general purpose use.

Of these features here are the most significant:
1. Non-file virtual target support.
1. Entire recipe if passed to the shell without internal interpretation.
1. Custom out-of-date determination.

Recipes can be written as POSIX shell scripts or with your preferred scripting
language. Jshon can also be replaced with another tool that stores your data.
Colorum can be considered as a set of tools that promote the usefullness of Mk.
JSON (due to Jshon) and POSIX shell was chosen because minimal tools exist that
can be compiled statically without too much trouble.

Depending on how you structure your recipes and recipe locations you can
trivially automate the generation of the mkfile for Mk.

## EXAMPLE mkfile

    NPROC=99
    PATH=/usr/bin:/etc/colorum
    base:QV: accounts authorized_keys network package_config permissions
    accounts:QV:
      recipes/accounts/add
    authorized_keys:QV: accounts
      recipes/authorized_keys/enforce
    network:QV:
      recipes/network/config
    package_config:QV:
      recipes/package/config
      recipes/package/install
    permissions:QV: authorized_keys
      recipes/permissions/enforce


## EXAMPLE JSON

    {
        "accounts": {
          "add": [ {
            "login": "ed",
            "uid": "1000",
            "groups": "wheel,audio",
            "shell": "/bin/sh"
            }
          ]
        }
    }


## EXAMPLE RECIPE

    #!/usr/bin/env ash
    set -efu
    usercnt=$(get -e accounts -e add -l)
    cnt=0
    until [[ $usercnt -eq $cnt ]]; do
      set -- $(get -e accounts -e add -e $cnt \
                   -e uid -u -p \
                   -e shell -u -p \
                   -e groups -u -p \
                   -e login -u)
      cut -f1 -d: /etc/passwd | grep -q "$4" && return 0
      useradd -u "$1" -s "$2" -G "$3" -m "$4"
      cnt=$(($cnt+1))
    done


## DEPENDENCIES

1. Mk
1. Jshon
1. POSIX shell (for recipes)


## HOW LIGHT IS IT?

    ed@Gimokod /usr/bin $ ls -la mk jshon busybox-static
    -rwxr-xr-x 1 root root 730456 Nov  8 03:57 busybox.static
    -rwxr-xr-x 1 root root  50504 Nov  8 03:58 jshon
    -rwxr-xr-x 1 root root 645208 Nov  5 17:02 mk

All components can be compiled to static binaries with under 2MiB total space


## REFERENCE

[Mk: A Successor to Make](http://doc.cat-v.org/bell_labs/mk/mk.pdf) -- PDF
[Maintaining Files on Plan 9 with Mk](http://www.vitanuova.com/inferno/papers/mk.html) -- HTML

