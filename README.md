Colorum
=======


## DESCRIPTION

A set of tools for configuration management that aims to be simple and lightweight.
By default modules are written as POSIX shell scripts and the actual configuration is
written in a simple DSL which is valid Lua. Parallel execution is a requirement and appears
to be the most complicated to implement. Fortunately we have Mk (from Plan9) to handle that.
Mk is meant to replace Make for building software but its features make it suitable
for general purpose use.

Of these features the most significant are:

1. Non-file virtual target support.
1. Entire recipe if passed to the shell without internal interpretation.
1. Custom out-of-date determination.

The DSL is compiled and generates the mkfile that is passed to Mk.

## EXAMPLE

    user "add" {
      login "ed";
      base_dir "/home";
      comment "user";
      home_dir "/home/ed";
      expire_date "2037-01-01";
      inactive "0";
      group "1337";
      groups "audio,video";
      create_home "true";
      user_group "true";
      shell "/bin/bash";
      uid "1337";
    }

or:

    user "add" {
      login "ed";
    }

    passthrough {
      run [[
        echo "this is a test"
        touch /tmp/test
      ]]
    }

## GENERATED MKFILE

    main: user
    user:
      useradd -b /home -c user -d /home/ed -e 2037-01-01 -f 0 -g 1337 -G audio,video -m -U -s /bin/bash -u 1337 ed

    main: passthrough
    passthrough:
      echo "this is a test"
      touch /tmp/test

## DEPENDENCIES

1. Mk
1. POSIX shell
1. Lua


## HOW LIGHT IS IT?

   Intentionally blank at the moment.

All components can be compiled to static binaries with under 2MiB total space


## REFERENCE

* [Mk: A Successor to Make](http://doc.cat-v.org/bell_labs/mk/mk.pdf) -- PDF
* [Maintaining Files on Plan 9 with Mk](http://www.vitanuova.com/inferno/papers/mk.html) -- HTML

