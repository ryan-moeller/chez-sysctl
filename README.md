Chez Scheme Library for FreeBSD sysctl(3)
=========================================

[![13.5-RELEASE Build Status](https://api.cirrus-ci.com/github/ryan-moeller/chez-sysctl.svg?branch=main&task=releases/amd64/13.5-RELEASE)](https://cirrus-ci.com/github/ryan-moeller/chez-sysctl)
[![14.3-RELEASE Build Status](https://api.cirrus-ci.com/github/ryan-moeller/chez-sysctl.svg?branch=main&task=releases/amd64/14.3-RELEASE)](https://cirrus-ci.com/github/ryan-moeller/chez-sysctl)
[![15.0-RC2 Build Status](https://api.cirrus-ci.com/github/ryan-moeller/chez-sysctl.svg?branch=main&task=releases/amd64/15.0-RC2)](https://cirrus-ci.com/github/ryan-moeller/chez-sysctl)

Usage
-----

```scheme
> (import (sysctl))
> (sysctl-set (sysctl-name->mib "vfs.zfs.blake3_impl") "generic")
> (sysctl-get (sysctl-name->mib "vfs.zfs.blake3_impl"))
"cycle fastest [generic] sse2 sse41 avx2 "
> (sysctl-set (sysctl-name->mib "vfs.zfs.blake3_impl") "fastest")
> (sysctl-get (sysctl-name->mib "vfs.zfs.blake3_impl"))
"cycle [fastest] generic sse2 sse41 avx2 "
> (length (sysctl-all))
17341
> (length (sysctl-all-noskip))
20904
> (sysctl-name '#(1))
"kern"
> (sysctl-get '#(1))
node
> (sysctl-get '#(1 0))
Exception occurred with non-condition value "No such file or directory"
Type (debug) to enter the debugger.
> (sysctl-description (sysctl-name->mib "dev.cpu.0.freq"))
"Current CPU frequency"
> (sysctl-format (sysctl-name->mib "dev.cpu.0.freq"))
(3254781954 . "I")
> (sysctl-get (sysctl-name->mib "dev.cpu.0.freq"))
3500
> (map (lambda (mib) (cons (sysctl-name mib) (sysctl-get mib)))
       (sysctl-list (sysctl-name->mib "vfs.zfs.vol")))
(("vfs.zfs.vol.request_sync" . 0) ("vfs.zfs.vol.num_taskqs" . 0) ("vfs.zfs.vol.threads" . 0)
  ("vfs.zfs.vol.mode" . 1)
  ("vfs.zfs.vol.prefetch_bytes" . 131072)
  ("vfs.zfs.vol.inhibit_dev" . 0)
  ("vfs.zfs.vol.unmap_enabled" . 1)
  ("vfs.zfs.vol.recursive" . 0))
>
```
