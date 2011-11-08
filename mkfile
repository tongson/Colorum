NPROC=99
PATH=/usr/bin:/etc/colorum
base:QV: accounts authorized_keys network package_config package_install permissions
accounts:QV:
  . recipes/accounts/add
authorized_keys:QV: accounts
  . recipes/authorized_keys/enforce
network:QV:
  . recipes/network/config
package_config:QV:
  . recipes/package/config
package_install:QV: package_config
  . recipes/package/install
permissions:QV: authorized_keys
  . recipes/permissions/enforce
